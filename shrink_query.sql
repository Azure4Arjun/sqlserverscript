
DECLARE @stmt nvarchar(1000)

CREATE TABLE #showfilestats_final (
	Banco	nvarchar(128),
	Total	DECIMAL(15,2),
	Utilizado DECIMAL(15,2),
	Livre	DECIMAL(15,2)
)
CREATE TABLE #showlogstats (
	Banco	nvarchar(128),
	TotalLog DECIMAL(15,2),
	Utilizado DECIMAL(15,2),
	Status INT
)

EXEC sp_MSforeachdb @command1 = '
USE [?]
SET NOCOUNT ON

CREATE TABLE #showfilestats (
	Fileid	INT,
	FileGroup INT,
	TotalExtents DECIMAL(15),
	UsedExtents DECIMAL(15),
	Name VARCHAR(255),
	FileName VARCHAR(255))

INSERT INTO #showfilestats
EXEC (''DBCC SHOWFILESTATS WITH NO_INFOMSGS'')

INSERT INTO #showfilestats_final
SELECT	''?'',
	Total = TotalExtents*65536/1024/1024,
	Utilizado = UsedExtents*65536/1024/1024,
	Livre = TotalExtents*65536/1024/1024 - UsedExtents*65536/1024/1024
FROM	#showfilestats

DROP TABLE #showfilestats'

INSERT INTO #showlogstats
EXEC ('DBCC SQLPERF(LOGSPACE)')

	SELECT @stmt = 'SELECT	SERVIDOR = CONVERT(VARCHAR,@@SERVERNAME),
			INSTANCIA = CONVERT(VARCHAR,ISNULL(SERVERPROPERTY(''InstanceName''), @@SERVERNAME)),
			BANCO = CONVERT(VARCHAR,A.Banco),
			TAMANHO_BANCO_MB = A.Total,
			LIVRE_BANCO_MB = A.Livre,
			PERC_OCUP = 100 - CONVERT(DECIMAL(5,2),A.Livre * 100.0 / Total),
			TAMANHO_LOG_MB = B.TotalLog,
			LOG_SPACE_USED = B.Utilizado,
			DATA = GETDATE()
		FROM	#showfilestats_final A
			inner join #showlogstats B on A.Banco = B.Banco
		WHERE	A.Banco != ''model'' '

CREATE TABLE #GETSPACE(
SERVIDOR VARCHAR(50),
INSTANCIA VARCHAR(50),
BANCO VARCHAR (70),
TAMANHO_BANCO_MB DECIMAL (15,2),
LIVRE_BANCO_MB DECIMAL (15,2),
PERC_OCUP DECIMAL (15,2),
TAMANHO_LOG_MB DECIMAL (15,2),
LOG_SPACE_USED DECIMAL (15,2),
DATA VARCHAR(30))

INSERT INTO #GETSPACE exec (@stmt)

select BANCO, TAMANHO_BANCO_MB,TAMANHO_LOG_MB from #GETSPACE


drop table #showfilestats_final
drop table #showlogstats
drop table #GETSPACE
go

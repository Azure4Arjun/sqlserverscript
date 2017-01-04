
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_t4b_getspace]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_t4b_getspace]
GO

PRINT 'Criando: sp_t4b_getspace'
GO

CREATE PROCEDURE [sp_t4b_getspace](@dbname nvarchar(128) = NULL, @threshold decimal(5,2) = NULL)
AS
set nocount on

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

IF NOT REPLACE(@@VERSION, '  ', ' ') LIKE 'Microsoft SQL Server 7%'
BEGIN
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
END
ELSE
BEGIN
	SELECT @stmt = 'SELECT	SERVIDOR = CONVERT(VARCHAR,@@SERVERNAME),
			INSTANCIA = CONVERT(VARCHAR,@@SERVERNAME),
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
END

IF @dbname IS NOT NULL
BEGIN
	SELECT @stmt = @stmt + '
	AND A.Banco like ''' + @dbname + ''' '
END

IF NOT @threshold IS NULL
BEGIN
	SELECT @stmt = @stmt + '
			AND 100 - CONVERT(DECIMAL(5,2),A.Livre * 100.0 / Total) >= ' + CONVERT(VARCHAR, @threshold)
END

SELECT @stmt = @stmt + '
		ORDER BY 1,2,3'
		
set nocount off

EXEC(@stmt)


DROP TABLE #showfilestats_final
DROP TABLE #showlogstats
GO


SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

print 'OK'
GO

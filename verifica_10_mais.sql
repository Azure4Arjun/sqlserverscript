use master
go
--Deverá .
DECLARE @BANCO VARCHAR(20)
SET @BANCO = 'AB_RENFIX'
select @BANCO 
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT 'Mais gastaram em Execucao.' ;
-- Total reads by DB
SELECT TOP 20 
        [Total Tempo] = total_elapsed_time
		,[Execution count] = qs.execution_count
        ,[Media Reads] = total_elapsed_time/qs.execution_count
		,DatabaseName = DB_NAME(qt.dbid)
		,Comando = text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
WHERE DB_NAME(qt.dbid) = @BANCO
ORDER BY [Total Tempo] DESC;

SELECT 'Mais gastaram em Reads.' ;
-- Total reads by DB
SELECT TOP 20 
        [Total Reads] = total_logical_reads
		,[Execution count] = qs.execution_count
        ,[Media Reads] = total_logical_reads/qs.execution_count
		,DatabaseName = DB_NAME(qt.dbid)
		,Comando = text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
WHERE DB_NAME(qt.dbid) = @BANCO
ORDER BY [Total Reads] DESC;

SELECT 'Os que mais gastaram em Writes.' ;
-- Total Writes by DB
SELECT TOP 20 
        [Total Writes] = total_logical_writes
		,[Execution count] = qs.execution_count
        ,[Media Writes] = total_logical_writes/qs.execution_count
		,DatabaseName = DB_NAME(qt.dbid)
		,Comando = text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
where DB_NAME(qt.dbid) = @BANCO
ORDER BY [Total Writes] DESC;

SELECT 'Missing Indexes.' ;
SELECT migs.user_seeks, avg_total_user_cost, avg_user_impact
	,DatabaseName = DB_NAME(database_id)
	,Tabela = OBJECT_NAME ( object_id , database_id)
	,Igual = equality_columns
	,Diferente = inequality_columns
	,OutrasColunas = included_columns
FROM sys.dm_db_missing_index_group_stats AS migs
INNER JOIN sys.dm_db_missing_index_groups AS mig
    ON (migs.group_handle = mig.index_group_handle)
INNER JOIN sys.dm_db_missing_index_details AS mid
    ON (mig.index_handle = mid.index_handle)
where DB_NAME(database_id) = @BANCO
ORDER BY avg_total_user_cost DESC;
go
use AB_RENFIX
go
SP_HELPDB AB_RENFIX
go
select 'Tabelas sem PK'
go
select o.name from sysobjects o
where type = 'u' 
and o.id not in (select parent_obj from sysobjects k where k.parent_obj = o.id and type  = 'k')
order by name
go

--OPCOES DOS BANCOS#-
SELECT  *
FROM    sys.databases
-------
--Informações do Espaço#-
EXEC dbo.sp_MSforeachdb ' USE [?]
SELECT name AS [Nome do Arquivo] , physical_name AS [Nome Fisico], size/128.0 AS [Tamanho MB],
size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS int)/128.0 AS [Espaço Disponivel MB]
FROM sys.database_files WITH (NOLOCK) OPTION (RECOMPILE);'

-------
--Informações do TEMPDB#-
SELECT DB_NAME([database_id])AS [Database Name], 
       [file_id], name, physical_name, type_desc, state_desc, 
       CONVERT( bigint, size/128.0) AS [Total Size in MB]
FROM sys.master_files WITH (NOLOCK)
WHERE [database_id] = 2 and type_desc = 'ROWS'
ORDER BY DB_NAME([database_id]) OPTION (RECOMPILE);

-------
--Informações do Backup#-
SELECT  D.NAME AS BANCO ,
        CASE WHEN MAX(B.BACKUP_FINISH_DATE) IS NULL
		THEN '1900-1-1'
		ELSE MAX(B.BACKUP_FINISH_DATE)
		END AS ULTIMO_BACKUP,
		getdate() as 'data da coleta'
FROM    MASTER.SYS.DATABASES D
        LEFT OUTER JOIN MSDB.DBO.BACKUPSET B ON D.NAME = B.DATABASE_NAME
                                                AND B.TYPE = 'D'
WHERE   D.DATABASE_ID NOT IN ( 2, 3 ) AND D.SOURCE_DATABASE_ID IS NULL
GROUP BY D.NAME
ORDER BY 2 DESC

-------
--BANCO EM RECOVERY FULL MAS SEM BACKUP DE LOG NA ULTIMA HORA#-
SELECT  D.NAME ,
        CASE WHEN MAX(B.BACKUP_FINISH_DATE) IS NULL
		THEN '1900-1-1'
		ELSE MAX(B.BACKUP_FINISH_DATE)
		END AS ULTIMO_BACKUP
FROM    MASTER.SYS.DATABASES D
        LEFT OUTER JOIN MSDB.DBO.BACKUPSET B ON D.NAME = B.DATABASE_NAME
                                                AND B.TYPE = 'L' 
WHERE   D.DATABASE_ID NOT IN ( 2, 3 ) 
		AND D.SOURCE_DATABASE_ID IS NULL
		AND D.RECOVERY_MODEL IN ( 1, 2 )
		AND NOT EXISTS( SELECT * FROM MSDB.DBO.BACKUPSET B WHERE B.BACKUP_FINISH_DATE >= DATEADD(MINUTE, -60, GETDATE()))
GROUP BY D.NAME
ORDER BY 2 DESC

-------
--BANCOS SEM DBCC CHECKDB#-                                              
CREATE TABLE #TEMP
    (
      PARENTOBJECT VARCHAR(255) ,
      [OBJECT] VARCHAR(255) ,
      FIELD VARCHAR(255) ,
      [VALUE] VARCHAR(255)
    )   
   
CREATE TABLE #DBCCRESULTS
    (
      SERVERNAME VARCHAR(255) ,
      DBNAME VARCHAR(255) ,
      LASTCLEANDBCCDATE DATETIME
    )   
    
EXEC MASTER.DBO.SP_MSFOREACHDB @COMMAND1 = 'USE ? INSERT INTO #TEMP EXECUTE (''DBCC DBINFO WITH TABLERESULTS'')',
    @COMMAND2 = 'INSERT INTO #DBCCRESULTS SELECT @@SERVERNAME, ''?'', VALUE FROM #TEMP WHERE FIELD = ''DBI_DBCCLASTKNOWNGOOD''',
    @COMMAND3 = 'TRUNCATE TABLE #TEMP'   
   
   
   
   ;
WITH    DBCC_CTE
          AS ( SELECT   ROW_NUMBER() OVER ( PARTITION BY SERVERNAME, DBNAME,
                                            LASTCLEANDBCCDATE ORDER BY LASTCLEANDBCCDATE ) ROWID
               FROM     #DBCCRESULTS
             )
    DELETE  FROM DBCC_CTE
    WHERE   ROWID > 1 ;
   
SELECT  SERVERNAME ,
        DBNAME ,
        CASE LASTCLEANDBCCDATE
          WHEN '1900-01-01 00:00:00.000' THEN 'BANCOS SEM DBCC CHECKDB'
          ELSE CAST(LASTCLEANDBCCDATE AS VARCHAR)
        END AS LASTCLEANDBCCDATE
FROM    #DBCCRESULTS
ORDER BY 3
   
DROP TABLE #TEMP, #DBCCRESULTS ;

-------
--FRAGMENTACAO DE INDICES#-                                             
SELECT  db.name AS databaseName ,
        ps.OBJECT_ID AS objectID ,
        ps.index_id AS indexID ,
        ps.partition_number AS partitionNumber ,
        ps.avg_fragmentation_in_percent AS fragmentation ,
        ps.page_count
FROM    sys.databases db
        INNER JOIN sys.dm_db_index_physical_stats(NULL, NULL, NULL, NULL,
                                                  N'Limited') ps ON db.database_id = ps.database_id
WHERE   ps.index_id > 0
        AND ps.page_count > 100
        AND ps.avg_fragmentation_in_percent > 30
OPTION  ( MAXDOP 1 ) ;

-------
--VERIFICACAO DE TRIGGERS#-                                             
EXEC dbo.sp_MSforeachdb 'SELECT ''[?]'' AS database_name, o.name AS table_name, t.* FROM [?].sys.triggers t INNER JOIN [?].sys.objects o ON t.parent_id = o.object_id'

-------
--VERIFICACAO DE INDICES#-                                              
EXEC dbo.sp_MSforeachdb 'SELECT DisabledIndexes = ''O index [?].['' + s.name + ''].['' + o.name + ''].['' + i.name + ''] esta desabilitado.'' from [?].sys.indexes i INNER JOIN [?].sys.objects o ON i.object_id = o.object_id INNER JOIN [?].sys.schemas s ON o.schema_id = s.schema_id WHERE i.is_disabled = 1' ;


-------
--VERIFICACAO DE FK#-                                               
EXEC dbo.sp_MSforeachdb 'SELECT NOtrustedFK = (''A foreign key [?].['' + s.name + ''].['' + o.name + ''].['' + i.name + ''] não é confiavel.'') from [?].sys.foreign_keys i INNER JOIN [?].sys.objects o ON i.parent_object_id = o.object_id INNER JOIN [?].sys.schemas s ON o.schema_id = s.schema_id WHERE i.is_not_trusted = 1' ;

-------
--VERIFICACAO DE SPINLOCKS#-                                              
CREATE TABLE #spins([Spinlock Name] varchar(50),Collisions numeric,Spins numeric,[Spins/Collision] float,[Sleep Time (ms)] numeric,Backoffs numeric)
INSERT INTO #spins EXECUTE ('DBCC SQLPERF (''SPINLOCKSTATS'')')
SELECT TOP 20 * FROM #spins ORDER BY Collisions DESC
DROP TABLE #spins

-------
--VERIFICACAO DE PARAMETROS#-                                            
SELECT name, value, value_in_use, [description] 
FROM sys.configurations WITH (NOLOCK)
ORDER BY name  OPTION (RECOMPILE);

-------
--TOP BANCOS CPU-                                                
WITH DB_CPU_Stats
AS
(SELECT DatabaseID, DB_Name(DatabaseID) AS [DatabaseName], SUM(total_worker_time) AS [CPU_Time_Ms]
 FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
 CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID] 
              FROM sys.dm_exec_plan_attributes(qs.plan_handle)
              WHERE attribute = N'dbid') AS F_DB
 GROUP BY DatabaseID)
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [row_num],
       DatabaseName, [CPU_Time_Ms], 
       CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPUPercent]
FROM DB_CPU_Stats
WHERE DatabaseID > 4
AND DatabaseID <> 32767
ORDER BY row_num OPTION (RECOMPILE);


-------
--EVENTOS DE ESPERA-                                             
WITH Waits AS
(SELECT wait_type, wait_time_ms / 1000. AS wait_time_s,
100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
FROM sys.dm_os_wait_stats WITH (NOLOCK)
WHERE wait_type NOT IN (N'CLR_SEMAPHORE',N'LAZYWRITER_SLEEP',N'RESOURCE_QUEUE',N'SLEEP_TASK',
N'SLEEP_SYSTEMTASK',N'SQLTRACE_BUFFER_FLUSH',N'WAITFOR', N'LOGMGR_QUEUE',N'CHECKPOINT_QUEUE',
N'REQUEST_FOR_DEADLOCK_SEARCH',N'XE_TIMER_EVENT',N'BROKER_TO_FLUSH',N'BROKER_TASK_STOP',N'CLR_MANUAL_EVENT',
N'CLR_AUTO_EVENT',N'DISPATCHER_QUEUE_SEMAPHORE', N'FT_IFTS_SCHEDULER_IDLE_WAIT',
N'XE_DISPATCHER_WAIT', N'XE_DISPATCHER_JOIN', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
N'ONDEMAND_TASK_QUEUE', N'BROKER_EVENTHANDLER', N'SLEEP_BPOOL_FLUSH'))
SELECT W1.wait_type, 
CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s,
CAST(W1.pct AS DECIMAL(12, 2)) AS pct,
CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct
FROM Waits AS W1
INNER JOIN Waits AS W2
ON W2.rn <= W1.rn
GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
HAVING SUM(W2.pct) - W1.pct < 99 OPTION (RECOMPILE);

-------
--TOP READS-                                            
EXEC dbo.sp_MSforeachdb ' USE [?]
SELECT TOP(25) db_name() as Banco, qt.[text] AS [SP Name], total_logical_reads, qs.max_logical_reads,
total_logical_reads/qs.execution_count AS [AvgLogicalReads], qs.execution_count AS [Execution Count], 
qs.execution_count/DATEDIFF(Second, qs.creation_time, GETDATE()) AS [Calls/Second], 
qs.total_worker_time/qs.execution_count AS [AvgWorkerTime],
qs.total_worker_time AS [TotalWorkerTime],
qs.total_elapsed_time/qs.execution_count AS [AvgElapsedTime],
qs.total_logical_writes,
 qs.max_logical_writes, qs.total_physical_reads, 
DATEDIFF(Minute, qs.creation_time, GETDATE()) AS [Age in Cache]
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE qt.[dbid] = DB_ID()
ORDER BY total_logical_reads DESC OPTION (RECOMPILE);'

-------
--TOP CPU- 
EXEC dbo.sp_MSforeachdb ' USE [?]
SELECT TOP(25) qt.[text] AS [SP Name], qs.total_worker_time AS [TotalWorkerTime], 
qs.total_worker_time/qs.execution_count AS [AvgWorkerTime],
qs.execution_count AS [Execution Count], 
ISNULL(qs.execution_count/DATEDIFF(Second, qs.creation_time, GETDATE()), 0) AS [Calls/Second],
ISNULL(qs.total_elapsed_time/qs.execution_count, 0) AS [AvgElapsedTime], 
qs.max_logical_reads, qs.max_logical_writes, 
DATEDIFF(Minute, qs.creation_time, GETDATE()) AS [Age in Cache]
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE qt.[dbid] = DB_ID() -- Filter by current database
ORDER BY qs.total_worker_time DESC OPTION (RECOMPILE);'

-------

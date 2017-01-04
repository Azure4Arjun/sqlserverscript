--http://stackoverflow.com/questions/3505752/quickest-way-to-identify-most-used-stored-procedure-variation-in-sql-server-2005
--http://wiki.lessthandot.com/index.php/Display_the_50_most_used_stored_procedures_in_SQL_Server
-- MOST USED PROCS
SELECT TOP 50 * FROM(SELECT COALESCE(OBJECT_NAME(s2.objectid),'Ad-Hoc') AS ProcName,
  execution_count,s2.objectid,
    (SELECT TOP 1 SUBSTRING(s2.TEXT,statement_start_offset / 2+1 ,
      ( (CASE WHEN statement_end_offset = -1
  THEN (LEN(CONVERT(NVARCHAR(MAX),s2.TEXT)) * 2)
ELSE statement_end_offset END)- statement_start_offset) / 2+1)) AS sql_statement,
       last_execution_time
FROM sys.dm_exec_query_stats AS s1
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS s2 ) x
WHERE sql_statement NOT like 'SELECT * FROM(SELECT coalesce(object_name(s2.objectid)%'
and OBJECTPROPERTYEX(x.objectid,'IsProcedure') = 1
and exists (SELECT 1 FROM sys.procedures s
WHERE s.is_ms_shipped = 0
and s.name = x.ProcName )
ORDER BY execution_count DESC

--- MOST USED FUNCTIONS
SELECT TOP 50 * FROM(SELECT COALESCE(OBJECT_NAME(s2.objectid),'Ad-Hoc') AS FuncName,
  execution_count,s2.objectid,
    (SELECT TOP 1 SUBSTRING(s2.TEXT,statement_start_offset / 2+1 ,
      ( (CASE WHEN statement_end_offset = -1
  THEN (LEN(CONVERT(NVARCHAR(MAX),s2.TEXT)) * 2)
ELSE statement_end_offset END)- statement_start_offset) / 2+1)) AS sql_statement,
       last_execution_time
FROM sys.dm_exec_query_stats AS s1
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS s2 ) x
WHERE sql_statement NOT like 'SELECT * FROM(SELECT coalesce(object_name(s2.objectid)%'
and (OBJECTPROPERTYEX(x.objectid,'IsScalarFunction') = 1
OR OBJECTPROPERTYEX(x.objectid,'IsInlineFunction') = 1
OR OBJECTPROPERTYEX(x.objectid,'IsTableFunction') = 1
)
ORDER BY execution_count DESC

-- MOST USED PROCS AGAIN
SELECT CASE WHEN database_id = 32767 then 'Resource' ELSE DB_NAME(database_id)END AS DBName
      ,OBJECT_SCHEMA_NAME(object_id,database_id) AS [SCHEMA_NAME] 
      ,OBJECT_NAME(object_id,database_id)AS [OBJECT_NAME]
      ,cached_time
      ,last_execution_time
      ,execution_count
      ,total_worker_time / execution_count AS AVG_CPU
      ,total_elapsed_time / execution_count AS AVG_ELAPSED
      ,total_logical_reads / execution_count AS AVG_LOGICAL_READS
      ,total_logical_writes / execution_count AS AVG_LOGICAL_WRITES
      ,total_physical_reads  / execution_count AS AVG_PHYSICAL_READS
FROM sys.dm_exec_procedure_stats 
ORDER BY execution_count DESC
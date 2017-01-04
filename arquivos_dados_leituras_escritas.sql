SELECT DB_NAME(vfs.DbId) DatabaseName, mf.name,
mf.physical_name, vfs.BytesRead, vfs.BytesWritten,
vfs.IoStallMS, vfs.IoStallReadMS, vfs.IoStallWriteMS,
vfs.NumberReads, vfs.NumberWrites,
(Size*8)/1024 Size_MB
FROM ::fn_virtualfilestats(NULL,NULL) vfs
INNER JOIN sys.master_files mf ON mf.database_id = vfs.DbId
AND mf.FILE_ID = vfs.FileId
order by vfs.BytesRead desc
GO

-- outros

SELECT TOP 10 
        [Total Reads] = SUM(total_logical_reads)
        ,[Execution count] = SUM(qs.execution_count)
        ,DatabaseName = DB_NAME(qt.dbid)
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
GROUP BY DB_NAME(qt.dbid)
ORDER BY [Total Reads] DESC;

SELECT TOP 10 
        [Total Writes] = SUM(total_logical_writes)
        ,[Execution count] = SUM(qs.execution_count)
        ,DatabaseName = DB_NAME(qt.dbid)
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
GROUP BY DB_NAME(qt.dbid)
ORDER BY [Total Writes] DESC;
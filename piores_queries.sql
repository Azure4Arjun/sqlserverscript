SELECT TOP 20 total_worker_time / execution_count AS AvgCPU ,
    total_worker_time AS TotalCPU ,
    total_elapsed_time / execution_count AS AvgDuration ,
    total_elapsed_time AS TotalDuration ,
    total_logical_reads / execution_count AS AvgReads ,
    total_logical_reads AS TotalReads ,
    execution_count ,
    DatabaseName       = DB_Name(st.dbid),
    qs.creation_time AS plan_creation_time,
    qs.last_execution_time,
    SUBSTRING(st.text, ( qs.statement_start_offset / 2 ) + 1, ( ( CASE qs.statement_end_offset
        WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset
        END - qs.statement_start_offset ) / 2 ) + 1) AS QueryText,
        query_plan
    FROM sys.dm_exec_query_stats AS qs
        CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
        CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
    /* Sorting options - uncomment the one you'd like to use: */
    --ORDER BY TotalReads DESC;
    ORDER BY TotalCPU DESC;
    --ORDER BY TotalDuration DESC;
    --ORDER BY execution_count DESC;
GO


SELECT TOP 50
    ObjectName          = OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)
    ,TextData           = qt.text   
    ,DiskReads          = qs.total_physical_reads   -- The worst reads, disk reads
    ,MemoryReads        = qs.total_logical_reads    --Logical Reads are memory reads
    ,Executions         = qs.execution_count
    ,TotalCPUTime       = qs.total_worker_time
    ,AverageCPUTime     = qs.total_worker_time/qs.execution_count
    ,DiskWaitAndCPUTime = qs.total_elapsed_time
    ,MemoryWrites       = qs.max_logical_writes
    ,DateCached         = qs.creation_time
    ,DatabaseName       = DB_Name(qt.dbid)
    ,LastExecutionTime  = qs.last_execution_time
 FROM sys.dm_exec_query_stats AS qs
 CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
 ORDER BY qs.total_worker_time/qs.execution_count DESC
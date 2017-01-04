WHILE 1=1 
BEGIN 

 DECLARE @ltbl_sql_server_error_log TABLE (
            log_date DATETIME
          , process_info VARCHAR(100)
          , text VARCHAR(8000)
          )
      INSERT INTO @ltbl_sql_server_error_log
      EXEC sp_readerrorlog  0     --log file you want to read: 0 = Current, 1 = Archive #1, 2 = Archive #2, etc
                          , Null  --log file type. 1 or Null = error log. 2 = SQL Agent log.
                          , NULL  --string one you want to search for.
                          , NULL  --string two you want to search for (to further refine results).

    IF ( SELECT count(1)
      FROM @ltbl_sql_server_error_log
      WHERE text LIKE ('%occurrence(s) of I/O requests%')
        AND log_date > DATEADD(MINUTE,-2,getdate())) > 0
      BEGIN 
        exec performance..rpt_performance_daily_healthcheck
        SELECT * FROM sys.dm_os_schedulers 
        --SELECT SUM(pending_disk_io_count) AS [Number of pending I/Os] FROM sys.dm_os_schedulers 
        SELECT *  FROM sys.dm_io_pending_io_requests
              
        SELECT TOP (20) * FROM sys.dm_os_memory_clerks ORDER BY pages_kb DESC

        ----------------------------------------------------
        --- Memory not in buffer pool
        ----------------------------------------------------

        SELECT counter_name, instance_name, mb = cntr_value/1024.0
          FROM sys.dm_os_performance_counters 
          --WHERE counter_name LIKE '%cache%'
          WHERE (counter_name = N'Cursor memory usage' and instance_name <> N'_Total')
          OR (instance_name = N'' AND counter_name IN 
               (N'Connection Memory (KB)', N'Granted Workspace Memory (KB)', 
                N'Lock Memory (KB)', N'Optimizer Memory (KB)', N'Stolen Server Memory (KB)', 
                N'Log Pool Memory (KB)', N'Free Memory (KB)')
          ) ORDER BY mb DESC;

        ----------------------------------------------------
        --- Memory used by cached plans
        ----------------------------------------------------

        select objtype, 
        count(*) as number_of_plans, 
        sum(cast(size_in_bytes as bigint))/1024/1024 as size_in_MBs,
        avg(usecounts) as avg_use_count
        from sys.dm_exec_cached_plans
        group by objtype
        ORDER BY sum(cast(size_in_bytes as bigint))/1024/1024 desc

        ---------------------------------------
        --- Current wait events
        -------------------------------------

        
        SELECT st.text AS [SQL Text],
         w.session_id, 
         w.wait_duration_ms,
         w.wait_type, w.resource_address, 
         w.blocking_session_id, 
         w.resource_description FROM sys.dm_os_waiting_tasks AS w
         INNER JOIN sys.dm_exec_connections AS c ON w.session_id = c.session_id 
         CROSS APPLY (SELECT * FROM sys.dm_exec_sql_text(c.most_recent_sql_handle))
         AS st WHERE w.session_id > 50
         AND w.wait_duration_ms > 0
 

        break

      END

  DELETE FROM @ltbl_sql_server_error_log
  WAITFOR DELAY '00:01:00'
END




Encontrei esses scripts para monitorar lentidão no SQL Server.


/****************************************************************************************

        Author : Peter Ward - peter@wardyit.com

        Version : 1.0.0 - 25/09/2011

        Description :
               SQL Server 2008 R2 - Basic Server Takedown to see what is *really* happening


****************************************************************************************/

-- 1)   What version of SQL Server and OS is running
SELECT @@VERSION AS [SQL Server and OS Version Info];



-- 2)   Get an overview of the hardware running
SELECT  
               cpu_count AS [Logical CPU Count], 
               hyperthread_ratio AS [Hyperthread Ratio],
               cpu_count/hyperthread_ratio AS [Physical CPU Count],
               physical_memory_in_bytes/1048576 AS [Physical Memory (MB)], 
               sqlserver_start_time
FROM sys.dm_os_sys_info;



-- 3)   Get an snapshot of the memory allocation
SELECT 
               physical_memory_in_use_kb,locked_page_allocations_kb,
               page_fault_count, memory_utilization_percentage,
               available_commit_limit_kb, process_physical_memory_low,
               process_virtual_memory_low
FROM sys.dm_os_process_memory;



-- 4)   Check the SQL Server Configurations  
-- Common Gotcha's
--  * lightweight pooling (should be zero)
--      * max degree of parallelism
--      * max server memory (MB) (set to an appropriate value)
--      * optimize for ad hoc workloads (should be 1)
--      * priority boost (should be zero)
SELECT  name, value, value_in_use, [description]
FROM    sys.configurations
ORDER BY name;



-- 5)   Get info about each database file
SELECT 
               DB_NAME([database_id])AS [Database Name],
               [file_id], 
               name, physical_name, 
               type_desc, 
               state_desc,
               CONVERT(BIGINT, size/128.0) AS [Total Size in MB]
FROM    sys.master_files
WHERE   [database_id] > 4
AND            [database_id] <> 32767
OR             [database_id] = 2
ORDER BY DB_NAME([database_id]);



-- 6)   Check Wait Stats
WITH Waits AS
(SELECT 
               wait_type, 
               wait_time_ms / 1000. AS wait_time_s,
               100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
               ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
FROM    sys.dm_os_wait_stats
WHERE   wait_type NOT IN ('CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE','SLEEP_TASK'
                                                      ,'SLEEP_SYSTEMTASK','SQLTRACE_BUFFER_FLUSH','WAITFOR', 'LOGMGR_QUEUE','CHECKPOINT_QUEUE'
                                                      ,'REQUEST_FOR_DEADLOCK_SEARCH','XE_TIMER_EVENT','BROKER_TO_FLUSH','BROKER_TASK_STOP','CLR_MANUAL_EVENT'
                                                      ,'CLR_AUTO_EVENT','DISPATCHER_QUEUE_SEMAPHORE', 'FT_IFTS_SCHEDULER_IDLE_WAIT'
                                                     ,'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP')
)
SELECT 
               W1.wait_type,
               CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s,
               CAST(W1.pct AS DECIMAL(12, 2)) AS pct,
                CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct
FROM    Waits AS W1 JOIN Waits AS W2
ON             W2.rn <= W1.rn
GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
HAVING SUM(W2.pct) - W1.pct < 99; -- percentage threshold



-- 7)   Signal Waits for CPU pressure
SELECT  
               CAST(100.0 * SUM(signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [%signal (cpu) waits],
               CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20, 2)) AS [%resource waits]
FROM    sys.dm_os_wait_stats;




-- 8)   Check the Page Life Expectancy (PLE)
SELECT 
               cntr_value AS [Page Life Expectancy]
FROM    sys.dm_os_performance_counters
WHERE   OBJECT_NAME = N'SQLServer:Buffer Manager' -- Modify this if you have named instances
AND            counter_name = N'Page life expectancy';



-- 9)   Buffer cache hit ratio for default instance
SELECT 
               (a.cntr_value * 1.0 / b.cntr_value) * 100.0 AS [Buffer Cache Hit Ratio]
FROM    sys.dm_os_performance_counters A JOIN (SELECT cntr_value, [OBJECT_NAME], instance_name
                                                                                            FROM sys.dm_os_performance_counters 
                                                                                            WHERE counter_name = N'Buffer cache hit ratio base'
                                                                                            AND [OBJECT_NAME] = N'SQLServer:Buffer Manager') AS b -- Modify this if you have named instances
ON             a.[OBJECT_NAME] = b.[OBJECT_NAME]
AND            a.instance_name = b.instance_name
WHERE   a.counter_name = N'Buffer cache hit ratio'
AND            a.[OBJECT_NAME] = N'SQLServer:Buffer Manager'; -- Modify this if you have named instances



-- 10)  Look for high value for CACHESTORE_SQLCP (Ad-hoc query plans)
SELECT 
               TOP 20  [type], 
               [name], 
               SUM(single_pages_kb) AS [SPA Mem, Kb]
FROM    sys.dm_os_memory_clerks
GROUP BY [type], [name]
ORDER BY SUM(single_pages_kb) DESC;

    

-- 11)  Find ad-hoc queries that are bloating the plan cache
SELECT 
               TOP 100 [text], cp.size_in_bytes
FROM    sys.dm_exec_cached_plans AS cp CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE   cp.cacheobjtype = N'Compiled Plan'
AND            cp.objtype = N'Adhoc'
AND            cp.usecounts = 1
ORDER BY cp.size_in_bytes DESC;





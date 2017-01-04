--------------------------------
--CREATING XEVENT TO PERFORMANCE
--------------------------------

--STEP 1
CREATE EVENT SESSION [performance_data] ON SERVER 
ADD EVENT sqlos.wait_info(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text)
    WHERE ([package0].[greater_than_uint64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlserver.sp_statement_completed(SET collect_object_name=(1),collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id)
    WHERE ([package0].[greater_than_uint64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id)
    WHERE ([package0].[greater_than_uint64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)))) 
ADD TARGET package0.event_file(SET filename=N'N:\sqlserver\query_performance.xel',max_file_size=(64),max_rollover_files=(5),metadatafile=N'N:\sqlserver\query_performance.xem')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=5 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


ALTER EVENT SESSION [performance_data] ON SERVER 
STATE = START;
GO

--STEP 2

/* (c) 2014 Brent Ozar Unlimited */


/* Create tables for intermediate processing */
IF OBJECT_ID('xevents') IS NULL
   CREATE TABLE xevents (
       event_time DATETIME2,
       event_type NVARCHAR(128),
       query_hash decimal(38,0),
       event_data XML
   );

IF OBJECT_ID('waits') IS NULL
   CREATE TABLE waits (
       event_time DATETIME2,
       event_interval DATETIME2,
       query_hash DECIMAL(38,0),
       query_plan_hash DECIMAL(38,0),
       session_id INT,
       client_hostname NVARCHAR(MAX),
       database_name NVARCHAR(MAX),
       statement NVARCHAR(MAX),
       wait_type NVARCHAR(MAX),
       duration_ms INT,
       signal_duration_ms INT
   );


IF OBJECT_ID('query_stats') IS NULL
   CREATE TABLE query_stats (
       event_time DATETIME2,
       event_interval DATETIME2, 
       query_hash DECIMAL(38,0),
       query_plan_hash DECIMAL(38,0),
       session_id INT,
       client_hostname NVARCHAR(MAX),
       database_name NVARCHAR(MAX),
       statement NVARCHAR(MAX),
       duration_ms INT,
       cpu_time_ms INT,
       physical_reads INT,
       logical_reads INT,
       writes INT,
       row_count INT
   );

TRUNCATE TABLE xevents;
TRUNCATE TABLE waits;
TRUNCATE TABLE query_stats;

INSERT INTO xevents (event_time, event_type, query_hash, event_data)
SELECT  DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP), x.event_data.value('(event/@timestamp)[1]', 'datetime2')) AS event_time,
       x.event_data.value('(/event/@name)[1]', 'nvarchar(max)'),
       x.event_data.value('(event/action[@name="query_hash"])[1]', 'decimal(38,0)'),
       x.event_data
FROM    sys.fn_xe_file_target_read_file ('N:\sqlserver\query_performance*.xel', 'N:\sqlserver\query_performance*.xem', null, null)
           CROSS APPLY (SELECT CAST(event_data AS XML) AS event_data) as x ;


INSERT INTO waits
SELECT  DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP), x.event_data.value('(event/@timestamp)[1]', 'datetime2')) AS event_time,
       DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0) AS event_interval,
       x.event_data.value('(event/action[@name="query_hash"])[1]', 'decimal(38,0)') AS query_hash,
       x.event_data.value('(event/action[@name="query_plan_hash"])[1]', 'decimal(38,0)') AS query_plan_hash,
       x.event_data.value('(event/action[@name="session_id"])[1]', 'int') AS session_id,
       x.event_data.value('(event/action[@name="client_hostname"])[1]', 'nvarchar(max)') AS client_hostname,
       x.event_data.value('(event/action[@name="database_name"])[1]', 'nvarchar(max)') AS database_name,
       x.event_data.value('(event/action[@name="sql_text"])[1]', 'nvarchar(max)') AS statement,
       x.event_data.value('(event/data[@name="wait_type"]/text)[1]', 'nvarchar(max)') AS wait_type,
       x.event_data.value('(event/data[@name="duration"])[1]', 'int') AS duration_ms,
       x.event_data.value('(event/data[@name="signal_duration"])[1]', 'int') AS signal_duration_ms
FROM    xevents AS x 
WHERE   x.query_hash > 0
       AND x.event_type = 'wait_info';


INSERT INTO query_stats 
SELECT  
       DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP), x.event_data.value('(event/@timestamp)[1]', 'datetime2')) AS event_time,
       DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0) AS event_interval,
       x.event_data.value('(event/action[@name="query_hash"])[1]', 'decimal(38,0)') AS query_hash,
       x.event_data.value('(event/action[@name="query_plan_hash"])[1]', 'decimal(38,0)') AS query_plan_hash,
       x.event_data.value('(event/action[@name="session_id"])[1]', 'int') AS session_id,
       x.event_data.value('(event/action[@name="client_hostname"])[1]', 'nvarchar(max)') AS client_hostname,
       x.event_data.value('(event/action[@name="database_name"])[1]', 'nvarchar(max)') AS database_name,
       x.event_data.value('(event/data[@name="statement"])[1]', 'nvarchar(max)') AS statement,
       x.event_data.value('(event/data[@name="duration"])[1]', 'int') AS duration_ms,
       x.event_data.value('(event/data[@name="cpu_time"])[1]', 'int') AS cpu_time_ms,
       x.event_data.value('(event/data[@name="physical_reads"])[1]', 'int') AS physical_reads,
       x.event_data.value('(event/data[@name="logical_reads"])[1]', 'int') AS logical_reads,
       x.event_data.value('(event/data[@name="writes"])[1]', 'int') AS writes,
       x.event_data.value('(event/data[@name="row_count"])[1]', 'int') AS row_count
FROM   xevents AS x
WHERE  x.query_hash > 0
       AND (x.event_type = 'sp_statement_completed' OR x.event_type = 'sql_statement_completed') ;

--STEP 3

WITH statement_ntile_cte AS (
    SELECT  DISTINCT
            event_interval, 
            query_hash,
            query_plan_hash,
            PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY duration_ms) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS  duration_50th,
            PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY duration_ms) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS duration_75th,
            PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY duration_ms) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS duration_90th,
            PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY duration_ms) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS duration_95th,
            PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY duration_ms) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS duration_99th,
 
            PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY cpu_time_ms) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS cpu_time_50th,
            PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cpu_time_ms) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS cpu_time_75th,
            PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY cpu_time_ms) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS cpu_time_90th,
            PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY cpu_time_ms) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS cpu_time_95th,
            PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY cpu_time_ms) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS cpu_time_99th,
 
            PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY physical_reads) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS  physical_reads_50th,
            PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY physical_reads) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS  physical_reads_75th,
            PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY physical_reads) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS  physical_reads_90th,
            PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY physical_reads) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS  physical_reads_95th,
            PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY physical_reads) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS  physical_reads_99th,
 
            PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY logical_reads) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS logical_reads_50th,
            PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY logical_reads) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS logical_reads_75th,
            PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY logical_reads) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS logical_reads_90th,
            PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY logical_reads) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS logical_reads_95th,
            PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY logical_reads) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS logical_reads_99th,
 
            PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY writes) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS writes_50th,
            PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY writes) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS writes_75th,
            PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY writes) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS writes_90th,
            PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY writes) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS writes_95th,
            PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY writes) OVER (PARTITION BY query_plan_hash, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, event_time), 0)) AS writes_99th
    FROM    query_stats
),
statement_analyzed_cte AS (
    SELECT  sc.query_hash,
            sc.query_plan_hash,
            event_interval,
            sc.statement,
            SUM(duration_ms) AS total_duration_ms,
            AVG(duration_ms) AS average_duration_ms,
            COALESCE(STDEV(duration_ms), 0) AS stdev_duration_ms,
            MIN(duration_ms) AS min_duration_ms,
            MAX(duration_ms) AS max_duration_ms,
            SUM(cpu_time_ms) AS total_cpu_time_ms,
            AVG(cpu_time_ms) AS average_cpu_time_ms,
            COALESCE(STDEV(cpu_time_ms), 0) AS stdev_cpu_time_ms,
            MIN(cpu_time_ms) AS min_cpu_time_ms,
            MAX(cpu_time_ms) AS max_cpu_time_ms,
            SUM(physical_reads) AS total_physical_reads,
            AVG(physical_reads) AS average_physical_reads,
            COALESCE(STDEV(physical_reads), 0) AS stdev_physical_reads,
            MIN(physical_reads) AS min_physical_reads,
            MAX(physical_reads) AS max_physical_reads,
            SUM(logical_reads) AS total_logical_reads,
            AVG(logical_reads) AS average_logical_reads,
            COALESCE(STDEV(logical_reads), 0) AS stdev_logical_reads,
            MIN(logical_reads) AS min_logical_reads,
            MAX(logical_reads) AS max_logical_reads,
            SUM(writes) AS total_writes,
            AVG(writes) AS average_writes,
            COALESCE(STDEV(writes), 0) AS stdev_writes,
            MIN(writes) AS min_writes,
            MAX(writes) AS max_writes
    FROM    query_stats sc
    GROUP BY sc.query_hash, sc.query_plan_hash, sc.statement, event_interval
),
query_stats AS (
SELECT  sac.query_hash,
        sac.query_plan_hash,
        sac.statement,
        sac.event_interval,
        
        sac.total_duration_ms,
        sac.average_duration_ms,
        sac.stdev_duration_ms,
        sac.min_duration_ms,
        sac.max_duration_ms,
        snc.duration_50th,
        snc.duration_75th,
        snc.duration_90th,
        snc.duration_95th,
        snc.duration_99th,
 
        sac.total_cpu_time_ms,
        sac.average_cpu_time_ms,
        sac.stdev_cpu_time_ms,
        sac.min_cpu_time_ms,
        sac.max_cpu_time_ms,
        snc.cpu_time_50th,
        snc.cpu_time_75th,
        snc.cpu_time_90th,
        snc.cpu_time_95th,
        snc.cpu_time_99th,
        
        sac.total_physical_reads,
        sac.average_physical_reads,
        sac.stdev_physical_reads,
        sac.min_physical_reads,
        sac.max_physical_reads,
        snc.physical_reads_50th,
        snc.physical_reads_75th,
        snc.physical_reads_90th,
        snc.physical_reads_95th,
        snc.physical_reads_99th,        
 
        sac.total_logical_reads,
        sac.average_logical_reads,
        sac.stdev_logical_reads,
        sac.min_logical_reads,
        sac.max_logical_reads,
        snc.logical_reads_50th,
        snc.logical_reads_75th,
        snc.logical_reads_90th,
        snc.logical_reads_95th,
        snc.logical_reads_99th,
 
        sac.total_writes,
        sac.average_writes,
        sac.stdev_writes,
        sac.min_writes,
        sac.max_writes,
        snc.writes_50th,
        snc.writes_75th,
        snc.writes_90th,
        snc.writes_95th,
        snc.writes_99th
FROM    statement_analyzed_cte sac
        JOIN statement_ntile_cte AS snc ON sac.query_plan_hash = snc.query_plan_hash 
                                           AND sac.event_interval = snc.event_interval
)
SELECT  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(qs.statement)), NCHAR(13), ' '), NCHAR(10), ' '), NCHAR(9), ' '), ' ','<>'),'><',''),'<>',' ') AS QueryText,
        qs.event_interval,
 
        qs.total_duration_ms,
        qs.average_duration_ms,
        qs.stdev_duration_ms,
        qs.min_duration_ms,
        qs.max_duration_ms,
        qs.duration_50th,
        qs.duration_75th,
        qs.duration_90th,
        qs.duration_95th,
        qs.duration_99th,
 
        qs.total_cpu_time_ms,
        qs.average_cpu_time_ms,
        qs.stdev_cpu_time_ms,
        qs.min_cpu_time_ms,
        qs.max_cpu_time_ms,
        qs.cpu_time_50th,
        qs.cpu_time_75th,
        qs.cpu_time_90th,
        qs.cpu_time_95th,
        qs.cpu_time_99th,
        
        qs.total_physical_reads,
        qs.average_physical_reads,
        qs.stdev_physical_reads,
        qs.min_physical_reads,
        qs.max_physical_reads,
        qs.physical_reads_50th,
        qs.physical_reads_75th,
        qs.physical_reads_90th,
        qs.physical_reads_95th,
        qs.physical_reads_99th,        
 
        qs.total_logical_reads,
        qs.average_logical_reads,
        qs.stdev_logical_reads,
        qs.min_logical_reads,
        qs.max_logical_reads,
        qs.logical_reads_50th,
        qs.logical_reads_75th,
        qs.logical_reads_90th,
        qs.logical_reads_95th,
        qs.logical_reads_99th,
 
        qs.total_writes,
        qs.average_writes,
        qs.stdev_writes,
        qs.min_writes,
        qs.max_writes,
        qs.writes_50th,
        qs.writes_75th,
        qs.writes_90th,
        qs.writes_95th,
        qs.writes_99th
FROM    query_stats AS qs
ORDER BY qs.event_interval ASC, qs.total_duration_ms DESC
OPTION (RECOMPILE) ;
 
 
 
 
 
 
 
 
 
 
 
 WITH waits_analyzed AS (
    SELECT  query_hash,
            query_plan_hash,
            event_interval,
            statement,
            wait_type,
            SUM(duration_ms) AS total_duration_ms,
            AVG(duration_ms) AS average_duration_ms,
            COALESCE(STDEVP(duration_ms), 0) AS stdev_duration_ms,
            MIN(duration_ms) AS min_duration_ms,
            MAX(duration_ms) AS max_duration_ms,
            SUM(signal_duration_ms) AS total_signal_duration_ms,
            AVG(signal_duration_ms) AS average_signal_duration_ms,
            COALESCE(STDEVP(signal_duration_ms), 0) AS stdev_signal_duration_ms,
            MIN(signal_duration_ms) AS min_signal_duration_ms,
            MAX(signal_duration_ms) AS max_signal_duration_ms
    FROM    waits
    GROUP BY query_hash,
            query_plan_hash,
            event_interval,
            statement,
            wait_type
),
waits_ntile_cte AS (
    SELECT  DISTINCT
            query_hash,
            query_plan_hash,
            event_interval,
            statement,
            wait_type,
            PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS duration_50th,
            PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS duration_75th,
            PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS duration_90th,
            PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS duration_95th,
            PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS duration_99th,
            PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY signal_duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS signal_duration_50th,
            PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY signal_duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS signal_duration_75th,
            PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY signal_duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS signal_duration_90th,
            PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY signal_duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS signal_duration_95th,
            PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY signal_duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS signal_duration_99th
    FROM    waits
),
wait_rank AS (
    SELECT  query_hash, query_plan_hash, event_interval, statement,
            SUM(total_duration_ms) r
    FROM    waits_analyzed
    GROUP BY query_hash, query_plan_hash, event_interval, statement
),
waits AS (
    SELECT  wc.query_hash,
            wc.query_plan_hash,
            wc.event_interval,
            wc.statement,
            wc.wait_type,
 
            wc.total_duration_ms ,
            wc.average_duration_ms,
            wc.stdev_duration_ms,
            wc.min_duration_ms,
            wc.max_duration_ms,
            wnc.duration_50th,
            wnc.duration_75th,
            wnc.duration_90th,
            wnc.duration_95th,
            wnc.duration_99th,
 
            wc.total_signal_duration_ms,
            wc.average_signal_duration_ms,
            wc.stdev_signal_duration_ms,
            wc.min_signal_duration_ms,
            wc.max_signal_duration_ms,
            wnc.signal_duration_50th,
            wnc.signal_duration_75th,
            wnc.signal_duration_90th,
            wnc.signal_duration_95th,
            wnc.signal_duration_99th
    FROM    waits_analyzed wc
            JOIN waits_ntile_cte as wnc ON wc.query_hash = wnc.query_hash
                                           AND wc.query_plan_hash = wnc.query_plan_hash
                                           AND wc.event_interval = wnc.event_interval
                                           AND wc.statement = wnc.statement
                                           AND wc.wait_type = wnc.wait_type
            JOIN wait_rank AS wr ON wc.query_hash = wr.query_hash
                                    AND wc.query_plan_hash = wr.query_plan_hash
                                    AND wc.event_interval = wr.event_interval
                                    AND wc.statement = wr.statement
)
SELECT  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(w.statement)), NCHAR(13), ' '), NCHAR(10), ' '), NCHAR(9), ' '), ' ','<>'),'><',''),'<>',' ') AS QueryText,
        w.event_interval,
        w.wait_type,
 
        w.total_duration_ms AS wait_total_duration_ms,
        w.average_duration_ms AS wait_average_duration_ms,
        w.stdev_duration_ms AS wait_stdev_duration_ms,
        w.min_duration_ms AS wait_min_duration_ms,
        w.max_duration_ms AS wait_max_duration_ms,
        w.duration_50th AS wait_duration_50th,
        w.duration_75th AS wait_duration_75th,
        w.duration_90th AS wait_duration_90th,
        w.duration_95th AS wait_duration_95th,
        w.duration_99th AS wait_duration_99th,
 
        w.total_signal_duration_ms AS signal_wait_total_duration_ms,
        w.average_signal_duration_ms AS signal_wait_average_duration_ms,
        w.stdev_signal_duration_ms AS signal_wait_stdev_duration_ms,
        w.min_signal_duration_ms AS signal_wait_min_duration_ms,
        w.max_signal_duration_ms AS signal_wait_max_duration_ms,
        w.signal_duration_50th AS signal_wait_duration_50th,
        w.signal_duration_75th AS signal_wait_duration_75th,
        w.signal_duration_90th AS signal_wait_duration_90th,
        w.signal_duration_95th AS signal_wait_duration_95th,
        w.signal_duration_99th AS signal_wait_duration_99th,
 
        w.query_hash,
        w.query_plan_hash
FROM    waits w
ORDER BY w.event_interval ASC, w.total_duration_ms DESC
OPTION (RECOMPILE) ;
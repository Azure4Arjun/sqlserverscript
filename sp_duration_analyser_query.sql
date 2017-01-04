SELECT 'excluding MAX and MIN'

DECLARE @file_path NVARCHAR(2000)
DECLARE @mdfile_path NVARCHAR(2000)

SET @file_path = N'S:\SP_Exec_0_130928521214140000.xel' -- Change the file name path here
SET @mdfile_path = N'S:\SP_Exec.xem' -- Don't need to change this

;WITH ee_data AS 
(
  SELECT data = CONVERT(XML, event_data)
    FROM sys.fn_xe_file_target_read_file(
   @file_path, 
    @mdfile_path, 
   NULL, NULL
 )
), 

tab_raw AS
(
 SELECT 
  --[host] = data.value('(event/action[@name="client_hostname"]/value)[1]','nvarchar(400)'),
  --app_name = data.value('(event/action[@name="client_app_name"]/value)[1]','nvarchar(400)'),
  --username = data.value('(event/action[@name="username"]/value)[1]','nvarchar(400)'),
  [object_name] = data.value('(event/data[@name="object_name"]/value)[1]','nvarchar(250)'),
  [timestamp] = data.value('(event/@timestamp)[1]','datetime2'),
  duration = data.value ('(event/data[@name="duration"]/value)[1]','BIGINT'),
  transaction_id = data.value('(event/action[@name="transaction_id"]/value)[1]','BIGINT'),
  session_id = data.value('(event/action[@name="session_id"]/value)[1]','BIGINT')
 FROM ee_data
), 
tab_sum_dur_per_trans AS
--SELECT * FROM tab
(
   SELECT DISTINCT 
          MIN([timestamp]) as first_executed
        , MAX([timestamp]) as last_executed
        , [object_name]
        , SUM(duration) as duration
        , transaction_id -- there could be more than one row
        , session_id	 --  
      FROM tab_raw
      GROUP BY [object_name]
      , transaction_id
      , session_id 
 ), 
 tab_max_min_to_exclude AS
 (
	 SELECT object_name
			, MAX(duration) as max_duration
			, MIN(duration) as min_duration
	FROM tab_sum_dur_per_trans
	GROUP BY object_name
), 
tab_final_to_agregate AS
(
	SELECT * 
	FROM tab_sum_dur_per_trans t1
	WHERE NOT EXISTS (	
			SELECT object_name
			FROM tab_max_min_to_exclude t2
			WHERE t1.object_name = t2.object_name
				AND t1.duration = t2.max_duration)
	AND NOT EXISTS (
			SELECT object_name
			FROM tab_max_min_to_exclude t2
			WHERE t1.object_name = t2.object_name
				AND t1.duration = t2.min_duration
				)
)

SELECT 
    MIN(first_executed) as first_executed
    , MAX(last_executed) as last_executed
    , [object_name]
    , AVG(duration) as avg_duration
    , MAX(duration) as max_duration
    , MIN(duration) as min_duration
    , COUNT(object_name) as executions
FROM tab_final_to_agregate
 GROUP BY [object_name]
 ORDER BY executions;

 ----------------------------------------------

 SELECT 'including MAX and MIN'

 ;WITH ee_data AS 
(
  SELECT data = CONVERT(XML, event_data)
    FROM sys.fn_xe_file_target_read_file(
   @file_path, 
    @mdfile_path, 
   NULL, NULL
 )
), 

--SELECT * FROM ee_data;
tab AS
(
 SELECT 
  --[host] = data.value('(event/action[@name="client_hostname"]/value)[1]','nvarchar(400)'),
  --app_name = data.value('(event/action[@name="client_app_name"]/value)[1]','nvarchar(400)'),
  --username = data.value('(event/action[@name="username"]/value)[1]','nvarchar(400)'),
  [object_name] = data.value('(event/data[@name="object_name"]/value)[1]','nvarchar(250)'),
  [timestamp] = data.value('(event/@timestamp)[1]','datetime2'),
  duration = data.value ('(event/data[@name="duration"]/value)[1]','BIGINT'),
  transaction_id = data.value('(event/action[@name="transaction_id"]/value)[1]','BIGINT'),
  session_id = data.value('(event/action[@name="session_id"]/value)[1]','BIGINT')
 FROM ee_data
)
 --SELECT * FROM tab
 -- WHERE [object_name] = 'rpt_reefer_position_history';

SELECT 
    MIN(first_executed) as first_executed
    , MAX(last_executed) as last_executed
    , [object_name]
    , AVG(duration) as avg_duration
    , MAX(duration) as max_duration
    , MIN(duration) as min_duration
    , COUNT(object_name) as executions
FROM (
      SELECT DISTINCT 
          MIN([timestamp]) as first_executed
        , MAX([timestamp]) as last_executed
        , [object_name]
        , SUM(duration) as duration
        , transaction_id -- there could be more than one row
        , session_id	 --  
      FROM tab
      GROUP BY [object_name]
      , transaction_id
      , session_id 
      ) t1
 GROUP BY [object_name]
 ORDER BY executions
 
 go
 ---------------------------------------------
 ----------More complete one------------------
 ---------------------------------------------
 
 DECLARE @file_path NVARCHAR(2000)
DECLARE @mdfile_path NVARCHAR(2000)

SET @file_path = N'S:\SP_Exec_0_130948160635380000.xel' -- Change the file name path here
SET @mdfile_path = N'S:\SP_Exec.xem' -- Don't need to change this

 SELECT '17122015'

 ;WITH ee_data AS 
(
  SELECT data = CONVERT(XML, event_data)
    FROM sys.fn_xe_file_target_read_file(
   @file_path, 
    @mdfile_path, 
   NULL, NULL
 )
), 

--SELECT * FROM ee_data;
tab AS
(
 SELECT 
  --[host] = data.value('(event/action[@name="client_hostname"]/value)[1]','nvarchar(400)'),
  --app_name = data.value('(event/action[@name="client_app_name"]/value)[1]','nvarchar(400)'),
  --username = data.value('(event/action[@name="username"]/value)[1]','nvarchar(400)'),
  [object_name] = data.value('(event/data[@name="object_name"]/value)[1]','nvarchar(250)'),
  [timestamp] = data.value('(event/@timestamp)[1]','datetime2'),
  duration = data.value ('(event/data[@name="duration"]/value)[1]','BIGINT'),
  transaction_id = data.value('(event/action[@name="transaction_id"]/value)[1]','BIGINT'),
  session_id = data.value('(event/action[@name="session_id"]/value)[1]','BIGINT'),
  physical_reads = data.value('(event/data[@name="physical_reads"]/value)[1]','BIGINT'),
  writes = data.value('(event/data[@name="writes"]/value)[1]','BIGINT'),
  logical_reads = data.value('(event/data[@name="logical_reads"]/value)[1]','BIGINT')
 FROM ee_data
)
 SELECT object_name
		, avg(duration) as avg_dur, min(duration) as min_dur, max(duration) as max_dur
		, avg(physical_reads) as avg_phyr, min(physical_reads) as min_phyr, max(physical_reads) as max_phyr
		, avg(logical_reads) as avg_logr, min(logical_reads) as min_logr, max(logical_reads) as max_logr
		, avg(writes)as avg_wri, min(writes) as min_wri, max(writes) as max_wri
 FROM tab
 GROUP BY object_name
 ORDER BY max_logr DESC
 -- WHERE [object_name] = 'rpt_reefer_position_history';

--SELECT 
--    MIN(first_executed) as first_executed
--    , MAX(last_executed) as last_executed
--    , [object_name]
--    , AVG(duration) as avg_duration
--    , MAX(duration) as max_duration
--    , MIN(duration) as min_duration
--	, AVG(physical_reads) as avg_physical_reads
--    , MAX(physical_reads) as max_physical_reads
--    , MIN(physical_reads) as min_physical_reads
--    , COUNT(object_name) as executions
--FROM (
--      SELECT DISTINCT 
--          MIN([timestamp]) as first_executed
--        , MAX([timestamp]) as last_executed
--        , [object_name]
--        , SUM(duration) as duration
--        , transaction_id -- there could be more than one row
--        , session_id --  
--		, physical_reads
--      FROM tab
--      GROUP BY [object_name]
--      , transaction_id
--      , session_id 
--      ) t1
-- GROUP BY [object_name]
-- ORDER BY executions

GO


DECLARE @file_path NVARCHAR(2000)
DECLARE @mdfile_path NVARCHAR(2000)

SET @file_path = N'S:\SP_Exec_0_130930989992040000.xel' -- Change the file name path here
SET @mdfile_path = N'S:\SP_Exec.xem' -- Don't need to change this

 SELECT '27112015'

 ;WITH ee_data AS 
(
  SELECT data = CONVERT(XML, event_data)
    FROM sys.fn_xe_file_target_read_file(
   @file_path, 
    @mdfile_path, 
   NULL, NULL
 )
), 

--SELECT * FROM ee_data;
tab AS
(
 SELECT 
  --[host] = data.value('(event/action[@name="client_hostname"]/value)[1]','nvarchar(400)'),
  --app_name = data.value('(event/action[@name="client_app_name"]/value)[1]','nvarchar(400)'),
  --username = data.value('(event/action[@name="username"]/value)[1]','nvarchar(400)'),
  [object_name] = data.value('(event/data[@name="object_name"]/value)[1]','nvarchar(250)'),
  [timestamp] = data.value('(event/@timestamp)[1]','datetime2'),
  duration = data.value ('(event/data[@name="duration"]/value)[1]','BIGINT'),
  transaction_id = data.value('(event/action[@name="transaction_id"]/value)[1]','BIGINT'),
  session_id = data.value('(event/action[@name="session_id"]/value)[1]','BIGINT'),
  physical_reads = data.value('(event/data[@name="physical_reads"]/value)[1]','BIGINT'),
  writes = data.value('(event/data[@name="writes"]/value)[1]','BIGINT'),
  logical_reads = data.value('(event/data[@name="logical_reads"]/value)[1]','BIGINT')
 FROM ee_data
)
 SELECT object_name
		, avg(duration) as avg_dur, min(duration) as min_dur, max(duration) as max_dur
		, avg(physical_reads) as avg_phyr, min(physical_reads) as min_phyr, max(physical_reads) as max_phyr
		, avg(logical_reads) as avg_logr, min(logical_reads) as min_logr, max(logical_reads) as max_logr
		, avg(writes)as avg_wri, min(writes) as min_wri, max(writes) as max_wri
 FROM tab
 GROUP BY object_name
 ORDER BY max_logr DESC
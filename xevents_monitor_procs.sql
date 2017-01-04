--Using Extended Events to Capture SQL Server Stored Procedure Usage
--
--The last method we will explore in this tip for capturing stored procedure execution is using Extended Events. Extended Events were introduced in SQL Server 2008. Read more here about Extended Events.
--https://www.mssqltips.com/sqlservertip/3259/several-methods-to-collect-sql-server-stored-procedure-execution-history/
--The advantages of this method:
--
--Extended Events is a light weight performance monitoring system that has very little impact on the database server
--This is relatively new monitoring system that in the future will replace SQL Server Profiler, so DBAs need to replace trace monitoring with Extended Events.
--Create the new event session and start it with the following script (replace "[source_database_id]=(9)" and files locations with your values):

---------------
---- Version 2, FINAL
---------------

CREATE EVENT SESSION [exec_sp_dur] ON SERVER 
ADD EVENT sqlserver.module_end(SET collect_statement=(0)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.request_id,sqlserver.session_id,sqlserver.transaction_id,sqlserver.username)
    WHERE ([package0].[equal_uint64]([source_database_id],(6)) AND [package0].[greater_than_uint64]([duration],(1)) AND [sqlserver].[equal_i_sql_ansi_string]([object_type],'P'))) 
ADD TARGET package0.event_file(SET filename=N'S:\SP_Duration.xel',metadatafile=N'S:\SP_Duration.xem')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


---- To Query the file created above

;WITH ee_data AS 
(
  SELECT data = CONVERT(XML, event_data)
    FROM sys.fn_xe_file_target_read_file(
   N'S:\SP_Duration_0_131009729061600000.xel', 
    N'S:\SP_Duration.xem', 
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
  duration = data.value ('(event/data[@name="duration"]/value)[1]','BIGINT')--,
  --[request_id] = data.value('(event/action[@name="request_id"]/value)[1]','BIGINT'),
  --transaction_id = data.value('(event/action[@name="transaction_id"]/value)[1]','BIGINT'),
  --session_id = data.value('(event/action[@name="session_id"]/value)[1]','BIGINT')
 FROM ee_data
)
--SELECT * FROM tab
--WHERE object_name = 'ws_reefer_history_with_all_alarms'
--order by timestamp

SELECT 
    MIN(timestamp) as first_executed
    , MAX(timestamp) as last_executed
    , [object_name]
    , AVG(duration)/1000 as avg_duration
    , MAX(duration)/1000 as max_duration
    , MIN(duration)/1000 as min_duration
    , COUNT(object_name) as executions
FROM tab
 GROUP BY [object_name]
 ORDER BY executions


-------------------
--- END V2 Final
-------------------



CREATE EVENT SESSION [EXEC_SP] ON SERVER 
ADD EVENT sqlserver.sp_statement_completed(SET collect_object_name=(1), 
     collect_statement=(0)
    ACTION(sqlserver.client_app_name, 
     sqlserver.client_hostname,
     sqlserver.database_id,
     sqlserver.database_name,
     sqlserver.username)
    WHERE (([object_type]=(8272)) 
     AND ([source_database_id]=(9)))) -- replace with your database ID
 ADD TARGET package0.asynchronous_file_target
  (
    SET FILENAME = N'E:\DBA_Audit\SP_Exec.xel',
    METADATAFILE = N'E:\DBA_Audit\SP_Exec.xem'
  );
GO

ALTER EVENT SESSION [EXEC_SP] ON SERVER
  STATE = START;
GO
--To review events data you can run this query:

;WITH ee_data AS 
(
  SELECT data = CONVERT(XML, event_data)
    FROM sys.fn_xe_file_target_read_file(
   'E:\DBA_Audit\SP_Exec*.xel', 
   'E:\DBA_Audit\SP_Exec*.xem', 
   NULL, NULL
 )
),
tab AS
(
 SELECT 
  [host] = data.value('(event/action[@name="client_hostname"]/value)[1]','nvarchar(400)'),
  app_name = data.value('(event/action[@name="client_app_name"]/value)[1]','nvarchar(400)'),
  username = data.value('(event/action[@name="username"]/value)[1]','nvarchar(400)'),
  [object_name] = data.value('(event/data[@name="object_name"]/value)[1]','nvarchar(250)'),
  [timestamp] = data.value('(event/@timestamp)[1]','datetime2')
 FROM ee_data
)
SELECT DISTINCT [host], app_name, username, MAX([timestamp]) as last_executed, 
  COUNT([object_name]) as number_of_executions, [object_name]
  FROM tab 
  GROUP BY [host], app_name, username, [object_name] ;
  
  
  
  ------------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------------
  ---------------------------Analysing Improved Below---------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------------
  
  
  
  
CREATE EVENT SESSION [EXEC_SP] ON SERVER 
ADD EVENT sqlserver.sp_statement_completed(SET collect_object_name=(1),collect_statement=(0)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.session_id,sqlserver.transaction_id,sqlserver.username)
    WHERE ([package0].[equal_uint64]([object_type],(8272)) AND [package0].[equal_uint64]([source_database_id],(6)) AND [package0].[greater_than_int64]([duration],(0)) AND [sqlserver].[not_equal_i_sql_unicode_string]([object_name],N'R2Go_process_journey') AND [object_name]<>N'R2Go_process_journey_processor_job' AND [object_name]<>N'spr_mq_vehicle_scheduled_requests' AND [object_name]<>N'map_position_parsing')) 
ADD TARGET package0.event_file(SET filename=N'S:\SP_Exec.xel',metadatafile=N'S:\SP_Exec.xem')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO



GO
ALTER EVENT SESSION [EXEC_SP] ON SERVER
  STATE = START;
GO
----------------
----------------

;WITH ee_data AS 
(
  SELECT data = CONVERT(XML, event_data)
    FROM sys.fn_xe_file_target_read_file(
   N'S:\SP_Exec_0_130928502913600000.xel', 
    N'S:\SP_Exec.xem', 
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


  ------------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------------
  ---------------------------Analysing Improved Below---------------------------------------------------------------------
  --------------------------Now excluding MAX and MIN to do AVG-----------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------------
  
  SELECT 'excluding MAX and MIN'

;WITH ee_data AS 
(
  SELECT data = CONVERT(XML, event_data)
    FROM sys.fn_xe_file_target_read_file(
   N'S:\SP_Exec_0_130928502913600000.xel', 
    N'S:\SP_Exec.xem', 
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
   N'S:\SP_Exec_0_130928502913600000.xel', 
    N'S:\SP_Exec.xem', 
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
  
Estagio@90
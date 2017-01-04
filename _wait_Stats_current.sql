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
 
 -- maiores eventos
 
 SELECT TOP 10
wait_type ,
max_wait_time_ms wait_time_ms ,
signal_wait_time_ms ,
wait_time_ms - signal_wait_time_ms AS resource_wait_time_ms ,
100.0 * wait_time_ms / SUM(wait_time_ms) OVER ( )
AS percent_total_waits ,
100.0 * signal_wait_time_ms / SUM(signal_wait_time_ms) OVER ( )
AS percent_total_signal_waits ,
100.0 * ( wait_time_ms - signal_wait_time_ms )
/ SUM(wait_time_ms) OVER ( ) AS percent_total_resource_waits
FROM sys.dm_os_wait_stats
WHERE wait_time_ms > 0 -- remove zero wait_time
AND wait_type NOT IN -- filter out additional irrelevant waits
( 'SLEEP_TASK', 'BROKER_TASK_STOP', 'BROKER_TO_FLUSH',
'SQLTRACE_BUFFER_FLUSH','CLR_AUTO_EVENT', 'CLR_MANUAL_EVENT',
'LAZYWRITER_SLEEP', 'SLEEP_SYSTEMTASK', 'SLEEP_BPOOL_FLUSH',
'BROKER_EVENTHANDLER', 'XE_DISPATCHER_WAIT', 'FT_IFTSHC_MUTEX',
'CHECKPOINT_QUEUE', 'FT_IFTS_SCHEDULER_IDLE_WAIT',
'BROKER_TRANSMITTER', 'FT_IFTSHC_MUTEX', 'KSOURCE_WAKEUP',
'LAZYWRITER_SLEEP', 'LOGMGR_QUEUE', 'ONDEMAND_TASK_QUEUE',
'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BAD_PAGE_PROCESS',
'DBMIRROR_EVENTS_QUEUE', 'BROKER_RECEIVE_WAITFOR',
'PREEMPTIVE_OS_GETPROCADDRESS', 'PREEMPTIVE_OS_AUTHENTICATIONOPS',
'WAITFOR', 'DISPATCHER_QUEUE_SEMAPHORE', 'XE_DISPATCHER_JOIN',
'RESOURCE_QUEUE' )
ORDER BY wait_time_ms DESC

--

-- query do dba Glenn Berry
-- Isolate top waits for server instance since last restart or statistics clear
WITH Waits AS
(SELECT wait_type, wait_time_ms / 1000. AS wait_time_s,
100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN ('CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE','SLEEP_TASK'
,'SLEEP_SYSTEMTASK','SQLTRACE_BUFFER_FLUSH','WAITFOR', 'LOGMGR_QUEUE','CHECKPOINT_QUEUE'
,'REQUEST_FOR_DEADLOCK_SEARCH','XE_TIMER_EVENT','BROKER_TO_FLUSH','BROKER_TASK_STOP','CLR_MANUAL_EVENT'
,'CLR_AUTO_EVENT','DISPATCHER_QUEUE_SEMAPHORE', 'FT_IFTS_SCHEDULER_IDLE_WAIT'
,'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP'))
SELECT W1.wait_type,
CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s,
CAST(W1.pct AS DECIMAL(12, 2)) AS pct,
CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct
FROM Waits AS W1
INNER JOIN Waits AS W2
ON W2.rn <= W1.rn
GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
HAVING SUM(W2.pct) - W1.pct < 99 OPTION (RECOMPILE); -- percentage threshold
GO

--top 10 waits
select top 10 *from sys.dm_os_wait_stats
where wait_type not in-- remove system waits  
( 
'KSOURCE_WAKEUP', 'SLEEP_BPOOL_FLUSH', 'BROKER_TASK_STOP',
'XE_TIMER_EVENT', 'XE_DISPATCHER_WAIT', 'FT_IFTS_SCHEDULER_IDLE_WAIT',  
'SQLTRACE_BUFFER_FLUSH', 'CLR_AUTO_EVENT', 'BROKER_EVENTHANDLER',
'LAZYWRITER_SLEEP', 'BAD_PAGE_PROCESS', 'BROKER_TRANSMITTER', 
'CHECKPOINT_QUEUE', 'DBMIRROR_EVENTS_QUEUE', 'LAZYWRITER_SLEEP', 
'ONDEMAND_TASK_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'LOGMGR_QUEUE', 
'SLEEP_TASK', 'SQLTRACE_BUFFER_FLUSH', 'CLR_MANUAL_EVENT',
'BROKER_RECEIVE_WAITFOR', 'PREEMPTIVE_OS_GETPROCADDRESS', 
'PREEMPTIVE_OS_AUTHENTICATIONOPS', 'BROKER_TO_FLUSH'
) 
order by wait_time_ms desc

--waits sendo executados agora

SELECT * FROM sys.dm_os_waiting_tasks
WHERE wait_type NOT IN
('CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE','SLEEP_TASK'
,'SLEEP_SYSTEMTASK','SQLTRACE_BUFFER_FLUSH','WAITFOR'
,'LOGMGR_QUEUE','CHECKPOINT_QUEUE'
,'REQUEST_FOR_DEADLOCK_SEARCH','XE_TIMER_EVENT'
,'BROKER_TO_FLUSH','BROKER_TASK_STOP','CLR_MANUAL_EVENT'
,'CLR_AUTO_EVENT','DISPATCHER_QUEUE_SEMAPHORE'
,'FT_IFTS_SCHEDULER_IDLE_WAIT','XE_DISPATCHER_WAIT'
,'XE_DISPATCHER_JOIN','SQLTRACE_INCREMENTAL_FLUSH_SLEEP')
ORDER BY wait_duration_ms DESC;

select top 1 * from t4bdb01..t4b_procadm_param


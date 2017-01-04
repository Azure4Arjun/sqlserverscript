http://blogs.msdn.com/b/alwaysonpro/archive/2015/01/06/troubleshooting-data-latency-issues-on-alwayson-readable-secondary-replicas-due-to-slow-redo-or-redo-thread-contention.aspx?CommentPosted=true#commentmessage

--RUN 
SELECT db_name(database_id) as DBName,
    session_id FROM sys.dm_exec_requests
    WHERE command = 'DB STARTUP'
-- get spid of db you want to troubleshoot and add below on session_id

CREATE EVENT SESSION [redo_wait_info] ON SERVER 
ADD EVENT sqlos.wait_info(
    ACTION(package0.event_sequence,
        sqlos.scheduler_id,
        sqlserver.database_id,
        sqlserver.session_id)
    WHERE ([opcode]=(1) AND 
        [sqlserver].[session_id]=(43))) -- change here
ADD TARGET package0.event_file(
    SET filename=N'redo_wait_info')
WITH (MAX_MEMORY=4096 KB,
    EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY=30 SECONDS,
    MAX_EVENT_SIZE=0 KB,
    MEMORY_PARTITION_MODE=NONE,
    TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

--RUN for 1 minute
ALTER EVENT SESSION [redo_wait_info] ON SERVER STATE=START

WAITFOR DELAY '00:00:59'

ALTER EVENT SESSION [redo_wait_info] ON SERVER STATE=STOP

--check the link above to read the file.
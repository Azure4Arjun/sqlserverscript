

CREATE PROC spr_run_failover_history_job

AS
EXEC msdb.dbo.sp_start_job 'FAILOVER_HISTORY'


-- EXEC sp_procoption N'spr_run_failover_history_job', 'startup', 'on'

/*
SELECT name, type_desc, create_date, modify_date
FROM sys.procedures
WHERE is_auto_executed = 1
*/
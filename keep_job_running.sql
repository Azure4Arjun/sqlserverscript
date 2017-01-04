WHILE 1 = 1
BEGIN
	IF (SELECT count(1)
		--ja.job_id,
		--j.name AS job_name,
		--ja.start_execution_date,      
		--ISNULL(last_executed_step_id,0)+1 AS current_executed_step_id,
		--Js.step_name
	FROM msdb.dbo.sysjobactivity ja 
	LEFT JOIN msdb.dbo.sysjobhistory jh 
		ON ja.job_history_id = jh.instance_id
	JOIN msdb.dbo.sysjobs j 
	ON ja.job_id = j.job_id
	JOIN msdb.dbo.sysjobsteps js
		ON ja.job_id = js.job_id
		AND ISNULL(ja.last_executed_step_id,0)+1 = js.step_id
	WHERE ja.session_id = (SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC)
	AND start_execution_date is not null
	AND stop_execution_date is null
	AND j.name = 'IndexOptimize - USER_DATABASES'
	) < 1
		BEGIN
				EXEC msdb.dbo.sp_start_job 'IndexOptimize - USER_DATABASES'


		END
			WAITFOR DELAY '01:00:00'
END
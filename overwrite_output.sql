CREATE PROC spr_change_job_output (@flag TINYINT)
AS
--flag = 0 -> overwrite
--flag = 2 -> append
-- exec spr_change_job_output 0
-- exec spr_change_job_output 2
BEGIN


DECLARE @job_id UNIQUEIDENTIFIER
DECLARE @step_id TINYINT


 SELECT t1.*, t2.job_id
 INTO #job_to_cycle_output
 FROM performance..jobs_to_change_output t1
  INNER JOIN msdb..sysjobs t2
    ON t1.job_name = t2.name

  WHILE (                
  SELECT count(1)                
  FROM #job_to_cycle_output                
  ) > 0               
	
	BEGIN
    SET ROWCOUNT 1
	    SELECT @job_id = job_id
           , @step_id = step_id
      FROM #job_to_cycle_output 
	  SET ROWCOUNT 0


    EXECUTE msdb.dbo.sp_update_jobstep            
            @job_id           = @job_id,            
            @step_id          = @step_id,            
            @flags            = @flag -- append/overwrite to output fil
	  
    DELETE
    FROM #job_to_cycle_output
    WHERE job_id = @job_id
      
    
  END
  DROP TABLE #job_to_cycle_output  
END
DECLARE @job_id varchar(255)
DECLARE @jobname varchar(255)
DECLARE @step_id INT

SET @job_id = '0C389745-37A3-41C7-9B4F-83B36BE09EFC'
SET @step_id = 1

EXECUTE msdb.dbo.sp_update_jobstep            
            @job_id           = @job_id,            
            @step_id          = @step_id,            
            @flags            = 2 -- append to output file 


/*
SELECT * FROM sysjobs
WHERE job_id IN('F8DEE555-86ED-44C2-952D-FAB76812CDB0'
,'B0592370-B948-4934-A6B9-E973191CDCAC'
,'A1540A9F-8F3E-4C3A-9368-E20179BAE78A'
,'0C389745-37A3-41C7-9B4F-83B36BE09EFC')
*/
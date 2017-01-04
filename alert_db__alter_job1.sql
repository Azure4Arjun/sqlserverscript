USE [msdb]
GO

/****** Object:  Job [WMI Response - DATABASE Class Event]    Script Date: 06/09/2014 11:42:33 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 06/09/2014 11:42:33 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'WMI Response - DATABASE Class Event', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Salva o alerta em um arquivo para análise', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Gravar WMI alert(s) no arquivo]    Script Date: 06/09/2014 11:42:33 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Gravar WMI alert(s) no arquivo', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=2, 
		@on_fail_action=4, 
		@on_fail_step_id=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @class_string NVARCHAR(200), @str_body NVARCHAR(max), @xdoc INT, @doc NVARCHAR(max)
-- get TSQL Command Text from XML
SET @doc =''$(ESCAPE_SQUOTE(WMI(TSQLCommand)))''
EXEC sp_xml_preparedocument @xdoc OUTPUT, @doc
SELECT   @str_body = ''TSQL Command: "'' + CommandText + ''"; 
 Database Name: $(ESCAPE_SQUOTE(WMI(DatabaseName)));
 SQL Server: '' + @@SERVERNAME + '';
 Post Time: $(ESCAPE_SQUOTE(WMI(PostTime))); 
 Login Name: $(ESCAPE_SQUOTE(WMI(LoginName)));
 SPID: $(ESCAPE_SQUOTE(WMI(SPID)));''
FROM       OPENXML (@xdoc , ''/TSQLCommand/CommandText'',1)
      WITH (CommandText  varchar(max) ''text()'')
EXEC sp_xml_removedocument @xdoc
-- identify type of the event
SELECT @class_string = ''"$(ESCAPE_SQUOTE(WMI(DatabaseName)))": $(ESCAPE_SQUOTE(WMI(__CLASS))) event''
  
-- select login
select  @str_body

--select @doc
--select @xdoc

EXEC sp_xml_removedocument @xdoc', 
		@database_name=N'master', 
		@output_file_name=N'C:\dba\SINGLE_USER.txt', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sp_whoisactive]    Script Date: 06/09/2014 11:42:33 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_whoisactive', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--exec sp_whoisactive
--go
select * from sysprocesses
', 
		@database_name=N'master', 
		@output_file_name=N'C:\dba\SINGLE_USER.txt', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO



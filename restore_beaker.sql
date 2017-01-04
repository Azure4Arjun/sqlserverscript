USE Master
GO

SELECT GetDate() Start_date_time
--
-- Kill open processes on 'celtrak_data_last_weekend' database
--
  DECLARE @ll_SPID INT
         ,@ls_SQL VARCHAR(100)
		

  DECLARE lcr_Processes CURSOR LOCAL STATIC
  FOR
    SELECT t1.spid
--          ,t1.status
--          ,t1.waittime
--          ,t1.blocked
    FROM master.dbo.sysprocesses t1 WITH (NoLock)
    INNER JOIN master.dbo.sysdatabases t2 WITH (NoLock)
      ON t2.dbid = t1.dbid
  WHERE t2.Name = 'celtrak_data_last_weekend' -- Don't forget to come it back to 'celtrak_data_last_weekend'
    ORDER BY t1.waittime DESC

  OPEN lcr_Processes
  FETCH NEXT FROM lcr_Processes
  INTO @ll_SPID

  WHILE (@@Fetch_Status = 0)
    BEGIN
      EXEC sp_who2 @ll_SPID
      SET @ls_SQL = 'KILL ' + Convert(VARCHAR(3), @ll_SPID)
      EXEC (@ls_SQL)

      FETCH NEXT FROM lcr_Processes
      INTO @ll_SPID
    END
--ENDWHILE
  CLOSE lcr_Processes
  DEALLOCATE lcr_Processes
GO

DECLARE @file_name NVARCHAR (MAX)
	   ,@bkp_command NVARCHAR (MAX)

--Select the last data backup file name of celtrak_data database in BERT
SELECT TOP 1 @file_name = name 
FROM [BERT].msdb.dbo.backupset
WHERE database_name = 'celtrak_data'
	AND type = 'D'
ORDER BY backup_finish_date DESC

--Remove the seconds from the filename in backupset
SET @file_name = LEFT(@file_name,LEN(@file_name)-2)

--Set the dynamic SQL before execute
SET @bkp_command = 'RESTORE DATABASE celtrak_data_last_weekend
    FROM DISK = ''\\bert\G$\sqlserver\backup\' + @file_name + '.bak' + ''' WITH FILE = 1
    ,RECOVERY
    ,REPLACE
    ,MOVE ''celtrak_data_Data'' TO ''F:\sqlserver\celtrak_data_last_weekend_data.mdf''
    ,MOVE ''celtrak_data_Log'' TO ''F:\sqlserver\celtrak_data_last_weekend_log.ldf'''

SELECT (@bkp_command)

--EXEC (@bkp_command)

GO

ALTER DATABASE celtrak_data_last_weekend SET RECOVERY SIMPLE
GO

USE celtrak_data_last_weekend 
GO

DBCC SHRINKFILE (celtrak_data_Log, 1000)
GO
--
-- The below is the same as \maintance\db\4_ResetDatabaseAfterRestore.sql
--
update tk_vehicle set download_status = 0 where download_status = 1  --do this instead of setting them all to zero
update tk_vehicle set active = 0 where active = 1

Update 	tk_vehicle
Set	mobile_number = replace(mobile_number, '+', '+xxx')

Update 	contact
Set	mobile_number_1 = 'x' + mobile_number_1
       ,mobile_number_2 = 'x' + mobile_number_2
       ,mobile_number_3 = 'x' + mobile_number_3
       ,mobile_number_4 = 'x' + mobile_number_4
       ,mobile_number_5 = 'x' + mobile_number_5
       ,email_1 = 'x' + email_1
       ,email_2 = 'x' + email_2
       ,email_3 = 'x' + email_3
       ,email_4 = 'x' + email_4
       ,email_5 = 'x' + email_5

UPDATE t1
SET t1.ftp_server = 'x' + t1.ftp_server
   ,t1.ftp_username = 'x' + t1.ftp_username
   ,t1.ftp_password  = 'x' + t1.ftp_password
FROM scheduled_report_definition t1

-- remove any scheduled jobs       
--delete from dbo.QRTZ_BLOB_TRIGGERS
--delete from dbo.QRTZ_CALENDARS
--delete from dbo.QRTZ_CRON_TRIGGERS
--delete from dbo.QRTZ_FIRED_TRIGGERS
--delete from dbo.QRTZ_SIMPLE_TRIGGERS
--delete from dbo.QRTZ_TRIGGER_LISTENERS
--delete from dbo.QRTZ_TRIGGERS
--delete from dbo.QRTZ_PAUSED_TRIGGER_GRPS
--delete from dbo.QRTZ_SCHEDULER_STATE
--delete from dbo.QRTZ_JOB_DETAILS
--delete from dbo.QRTZ_JOB_LISTENERS


-- Remove messaging
delete from dbo.JMS_MESSAGES
delete from dbo.JMS_TRANSACTIONS

-- Remove Alarm notifications
-- gjc - As long as we update the contacts above do we need this
--delete from dbo.alarm_notifications_notify_mapping
--delete from dbo.alarm_notifications_types_mapping
--delete from dbo.alarm_notifications_group_mapping
--delete from dbo.alarm_notifications_contact_mapping
--delete from dbo.alarm_notifications
--delete from dbo.alarm_notifications_history

update tk_vehicle set download_logger_status = 0

Update users
set password = 'superbad'
where rid = 300
and user_name = 'superuser'

CREATE USER [celtrak_data_last_weekend] FOR LOGIN [celtrak_data_last_weekend]
GO
EXEC sp_addrolemember N'db_owner', N'celtrak_data_last_weekend'
Go

CREATE USER [developers] FOR LOGIN [developers]
GO
EXEC sp_addrolemember N'db_datareader', N'developers'
GO

CREATE USER [celtrak_data_dev] FOR LOGIN [celtrak_data_dev]
GO
EXEC sp_addrolemember N'db_datareader', N'celtrak_data_dev'
GO
--CREATE USER [celtrak_data_performance] FOR LOGIN [celtrak_data_performance]
--GO
--EXEC sp_addrolemember N'db_datareader', N'celtrak_data_performance'
--GO

CREATE USER [celtrak_data_staging] FOR LOGIN [celtrak_data_staging]
GO
EXEC sp_addrolemember N'db_datareader', N'celtrak_data_staging'
GO

CREATE USER [celtrak_data_tk_dev] FOR LOGIN [celtrak_data_tk_dev]
GO
EXEC sp_addrolemember N'db_datareader', N'celtrak_data_tk_dev'
GO

CREATE USER [celtrak_jenkins] FOR LOGIN [celtrak_jenkins]
GO
EXEC sp_addrolemember N'db_datareader', N'celtrak_jenkins'
GO

CREATE USER [celtrak_data_dev_janice] FOR LOGIN [celtrak_data_dev_janice]
GO
EXEC sp_addrolemember N'db_datareader', N'celtrak_data_dev_janice'
GO

CREATE USER [dev050] FOR LOGIN [dev050]
GO
EXEC sp_addrolemember N'db_datareader', N'dev050'
GO
CREATE USER [dev090] FOR LOGIN [dev090]
GO
EXEC sp_addrolemember N'db_datareader', N'dev090'
GO
CREATE USER [dev085] FOR LOGIN [dev085]
GO
EXEC sp_addrolemember N'db_datareader', N'dev085'
GO
CREATE USER [dev121] FOR LOGIN [dev121]
GO
EXEC sp_addrolemember N'db_datareader', N'dev121'
GO

SELECT GetDate() End_date_time

SELECT TOP 10 *
FROM tk_mu_data
ORDER BY rid DESC
DECLARE   
      @server_name varchar(50)
    , @is_connected bit
    , @is_secondary tinyint
  
  SELECT  
      @server_name  = t2.replica_server_name
    , @is_connected = t1.connected_state
    , @is_secondary = t1.role
  FROM sys.dm_hadr_availability_replica_states t1
    RIGHT JOIN sys.availability_replicas t2
      ON t1.replica_id = t2.replica_id
    WHERE t1.role = 2
  
  SELECT @server_name, @is_secondary, @is_connected
  

  IF (@server_name = @@SERVERNAME and @is_connected = 1)
    BEGIN
      PRINT 'backup all users databases here' --BACKUP DATABASE 
    END
  ELSE IF (@is_connected = 0)
    BEGIN
       PRINT 'secondary off, backup here'
    END
  ELSE
    PRINT 'No backups here'


---------------------------------------------
--
---------------------------------------------

CREATE PROCEDURE usp_BackupDatabaseAG 
(
 @DatabaseName SYSNAME, 
 @BackupPath VARCHAR(256),
 @BackupType VARCHAR(4)
)
AS
BEGIN
DECLARE @FileName varchar(512) = @BackupPath + 
 CAST(@@SERVERNAME AS VARCHAR) + '_' + @DatabaseName
DECLARE @SQLcmd VARCHAR(MAX)
IF sys.fn_hadr_backup_is_preferred_replica(@DatabaseName) = 1
 IF @BackupType = 'FULL'
 BEGIN
  SET @FileName = @FileName + '_FULL_'+ 
   REPLACE(CONVERT(VARCHAR(10), GETDATE(), 112), '/', '') + 
   REPLACE(CONVERT(VARCHAR(10), GETDATE(), 108) , ':', '')  + '.bak'
  SET @SQLcmd = 'BACKUP DATABASE ' + QUOTENAME(@DatabaseName) + 
   ' TO DISK = ''' + @FileName + ''' WITH COPY_ONLY ;'
  --PRINT @SQLcmd
  EXECUTE(@SQLcmd);
 END
 ELSE IF @BackupType = 'LOG'
 BEGIN
  SET @FileName = @FileName + '_LOG_'+ 
   REPLACE(CONVERT(VARCHAR(10), GETDATE(), 112), '/', '') + 
   REPLACE(CONVERT(VARCHAR(10), GETDATE(), 108) , ':', '')  + '.trn'
  SET @SQLcmd = 'BACKUP LOG ' + QUOTENAME(@DatabaseName) + 
   ' TO DISK = ''' + @FileName + ''' ;'
  --PRINT @SQLcmd
  EXECUTE(@SQLcmd);
 END
END
SELECT database_name, 
    ( SELECT 
      CASE 
      WHEN t101.database_name IN ('master', 'model','msdb','celtrak_jms','GoSafe_jms')
        THEN REPLACE(x1.physical_device_name, 'N:\sqlserver\backup\SQLFCIU4$SQLU4\' + t101.database_name + '\FULL_COPY_ONLY\', '')
      ELSE
        REPLACE(x1.physical_device_name, 'N:\sqlserver\backup\SQLCLUSTER$SQL_SERVER_AG\' + t101.database_name + '\FULL_COPY_ONLY\', '')
      END
      FROM [SQLFCIU4\SQLU4].msdb.dbo.[backupmediafamily] x1
      WHERE x1.media_set_id = t101.media_set_id
      ) as fileName
FROM (
        SELECT t1.database_name, 
        MAX(t1.media_set_id) as media_set_id
        FROM [SQLFCIU4\SQLU4].msdb.dbo.backupset t1
        WHERE t1.type = 'D'
        GROUP BY database_name 
      ) t101

-------------------------------------------------


DECLARE @filelocation VARCHAR(MAX)
DECLARE @file_list TABLE (
file_location VARCHAR(MAX)
)
INSERT INTO @file_list

SELECT  
    ( SELECT x1.physical_device_name
      FROM msdb.dbo.[backupmediafamily] x1
      WHERE x1.media_set_id = t101.media_set_id
      ) 
FROM (
        SELECT t1.database_name, 
        MAX(t1.media_set_id) as media_set_id
        FROM msdb.dbo.backupset t1
        WHERE t1.type = 'D'
        GROUP BY database_name 
      ) t101

WHILE (SELECT count(1) FROM @file_list) > 0

	BEGIN
		SELECT TOP 1 @filelocation = file_location
		FROM @file_list
	
		RESTORE VERIFYONLY FROM DISK = @filelocation -- WITH CHECKSUM
	
		DELETE 
		FROM @file_list
		WHERE file_location = @filelocation

	END




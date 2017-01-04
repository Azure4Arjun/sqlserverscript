SELECT 'RESTORE LOG celtrak_rafael FROM DISK = ''' + REPLACE(RTRIM(t2.physical_device_name), 'N:\','\\CEL-SQLU4\N$\') + ''' WITH STATS, NORECOVERY'
, backup_start_date		
FROM msdb.dbo.backupset t1		
  INNER JOIN msdb.dbo.backupmediafamily t2		
    ON t2.media_set_id=t1.media_set_id		
WHERE t1.database_name = 'Stocky'		
	AND t1.type = 'L'	
	AND t1.backup_start_date > '2016-01-30 22:30'
ORDER BY t1.backup_start_date 

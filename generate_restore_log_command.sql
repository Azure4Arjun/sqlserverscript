select backup_start_date, 'RESTORE LOG celtrak_data FROM DISK = ''' + REPLACE(physical_device_name,'N:','\\CEL-SQLU4\N$') + ''' WITH STATS, NORECOVERY'
from backupmediafamily t1
inner join backupset t2
on t2.media_set_id = t1.media_set_id
where t2.database_name = 'celtrak_data'
and t2.backup_start_date >= '2015-11-01'
and type = 'L'

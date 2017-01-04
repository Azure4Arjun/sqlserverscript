--Restore log fail troubleshooting

select t1.database_name, 
       t1.type, 
       t1.first_lsn, 
       t1.last_lsn ,
--       t2.first_lsn as first_lsn_next, 
--       t2.last_lsn as last_lsn_next, 
       t1.checkpoint_lsn ,
       t1.database_backup_lsn, 
       t1.backup_finish_date
FROM backupset t1
  --INNER JOIN msdb..backupset t2
  --  ON t1.last_lsn = t2.first_lsn
WHERE t1.database_name = 'celtrak_paul'
AND t1.backup_finish_date between '2015-07-12' AND '2015-07-16'
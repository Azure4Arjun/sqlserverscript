WITH cte AS (

  SELECT database_name
  , MAX(backup_finish_date) as last_backup_finish_date--, * 
  FROM msdb.dbo.backupset
  WHERE type = 'L'
  AND DATABASEPROPERTYEX(database_name, 'Recovery') = 'FULL'
  GROUP BY database_name

)

SELECT t1.name
    , t2.last_backup_finish_date
FROM sysdatabases t1
  LEFT JOIN cte t2
    ON t1.name = t2.database_name
WHERE ISNULL(t2.last_backup_finish_date, DATEADD(HOUR, -2, GETDATE())) < DATEADD(HOUR, -1, GETDATE())
AND DATABASEPROPERTYEX(name, 'Recovery') = 'FULL'
AND database_name NOT IN  ('model','')
------------------------

;WITH cte AS (

  SELECT database_name
  , MAX(backup_finish_date) as last_backup_finish_date--, * 
  FROM msdb.dbo.backupset
  WHERE type = 'D'
  GROUP BY database_name

)

SELECT t1.name
    , t2.last_backup_finish_date
FROM sysdatabases t1
  LEFT JOIN cte t2
    ON t1.name = t2.database_name
WHERE t1.name NOT IN (
  'master'
, 'tempdb'
, 'msdb'
, 'celtrak_jms'
, 'GoSafe_jms'
, 'ReportServer'
, 'ReportServerTempDB'
)
AND ISNULL(t2.last_backup_finish_date, DATEADD(DAY, -2, GETDATE())) < DATEADD(DAY, -1, GETDATE())
AND database_name <> 'model'
USE tempdb

IF (SELECT 1 FROM sysobjects WHERE name = 'spr_get_space_used_tempdb') <> 0

BEGIN
  DROP PROC spr_get_space_used_tempdb
END
 GO 
  CREATE PROC spr_get_space_used_tempdb

  AS

  SELECT 
  --DB_NAME() AS DbName, 
  name AS FileName, 
 -- size/128.0 AS CurrentSizeMB,  
--  size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB,
  100-(size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0)*100/(size/128.0) AS Percentage_occupied
  FROM tempdb.sys.database_files; 

 GO
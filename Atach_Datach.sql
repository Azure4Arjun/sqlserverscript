--sp_detach_db macchips

--EXEC sp_attach_db @dbname = 'macchips', 
   @filename1 = 'e:\mssql\data\macchips_Data.MDF', 
   @filename2 = 'e:\mssql\data\macchips_Log.LDF'

-------------------------------------------------------


set nocount on
select 'sp_detach_db '+ name +'' + char(13) + 'go' + char(13) from sysdatabases
set nocount off

-------------------------------------------------------



set nocount on
select 'use master' + char(13) + 'go' 
select 'sp_attach_db @dbname = "'+ name + '", ' + char(13) + '@filename1 = "e:\mssql\data\macchips_Data.MDF",'
+ char(13) + '@filename2 = "e:\mssql\data\macchips_Data.LDF"' + char(13) + 'go' from sysdatabases
set nocount off

---------------------------------------------------------
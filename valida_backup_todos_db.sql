
/*select distinct(sd.name), database_name, backup_start_date, backup_finish_date from master..sysdatabases sd 
left join msdb..backupset bs on sd.name = bs.database_name and bs.backup_start_date > dateadd(hh,-12,GETDATE()) and bs.type = 'd' 
where bs.database_name is null*/


CREATE PROC sp_dba_valida_backup as  
  
 declare @msg [VARCHAR](512),    
   @currdate [VARCHAR](20)  
     
  
if exists (  
select distinct(sd.name), database_name, backup_start_date, backup_finish_date from master..sysdatabases sd   
left join msdb..backupset bs on sd.name = bs.database_name and bs.backup_start_date > dateadd(hh,-12,GETDATE()) and bs.type = 'd'   
where bs.database_name is null  
and sd.name <> 'tempdb')   
 BEGIN    
  select @currdate = CONVERT(VARCHAR, GETDATE())    
  select @msg = 'Nao foi feito o Backup FULL dos Bancos a seguir'  
  select distinct(sd.name),   
  database_name,   
  backup_start_date,   
  backup_finish_date from master..sysdatabases sd   
  left join msdb..backupset bs on sd.name = bs.database_name   
  and bs.backup_start_date > dateadd(hh,-12,GETDATE())   
  and bs.type = 'd'   
  where bs.database_name is null  
  and sd.name <> 'tempdb'  
        
  RAISERROR (@msg, 16,1, @currdate, @@servername)    
  --RETURN -1    
 END    
else   
select 'Todos os bancos foram backapeados com Sucesso no dia ', dateadd(dd,-1,GETDATE())  
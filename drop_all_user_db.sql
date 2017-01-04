
declare @name varchar (100),
		@comando varchar (500)

select name into #excluiusers from sysusers 
 where name not in ('dbo',
 'public',
 'dbo',
 'guest',
 'INFORMATION_SCHEMA',
 'sys',
 'db_denydatawriter',
'db_owner',
'db_accessadmin',
'db_securityadmin',
'db_ddladmin',
'db_backupoperator',
'db_datareader',
'db_datawriter',
'db_denydatareader',
'db_denydatawriter'
 )

while (        
Select count(1)        
from #excluiusers ) > 0  

begin

select top 1 @name = name
from #excluiusers


  begin
        begin try        
        set @comando = 'drop user [' + @name + ']'
		exec (@comando)
       	end try        
		begin catch        
		end catch
	
 end
 delete from #excluiusers
 where name = @name
 
 end
 
 drop table #excluiusers
 
 
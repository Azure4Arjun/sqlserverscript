USE []		-- Inserir o nome do banco entre []
GO

set nocount on

declare @stmt nvarchar(4000)

create table #users (
	Username varchar(100),
	GroupName varchar(100),
	LoginName varchar(100),
	DefDBName varchar(100),
	UserID int,
	SID varchar(100)
)

select @stmt = ''

select @stmt = @stmt + 'exec sp_helpuser "' + name + '"' + char(13)
from sysusers
where issqlrole = 0
and name not in ('guest', 'dbo', 'INFORMATION_SCHEMA', 'system_function_schema')

insert into #users
	exec(@stmt)

select 'exec sp_addrolemember ''' + GroupName + ''', ''' + Username + '''' from #users
where GroupName not in ('public')
--select 'exec sp_addrolemember ''db_owner'', ''' + Username + '''' from #users
--where GroupName = 'db_owner'

drop table #users

set nocount off


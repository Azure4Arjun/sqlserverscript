set nocount on
go
use OPVD
go
select 'USE ' + db_name() + char(13) + 'go'
go
select '--utilizando o banco de dados ' + db_name()
go
select 'grant ' +  CASE action
         WHEN 193 THEN 'SELECT '
         WHEN 195 THEN 'INSERT '
	 WHEN 196 THEN 'DELETE '
	 WHEN 197 THEN 'UPDATE '
	 WHEN 224 THEN 'EXECUTE '
         --ELSE 'Not yet categorized'
	 END
+ ' on ' + object_name(id) + ' to ' + user_name(uid) + char(13) + 'go'
from sysprotects
where uid = user_id('sactabatch')
go
use OPTEMP
go
select 'USE ' + db_name() + char(13) + 'go'
go
select '--utilizando o banco de dados ' + db_name()
go
select 'grant ' +  CASE action
         WHEN 193 THEN 'SELECT '
         WHEN 195 THEN 'INSERT '
	 WHEN 196 THEN 'DELETE '
	 WHEN 197 THEN 'UPDATE '
	 WHEN 224 THEN 'EXECUTE '
         --ELSE 'Not yet categorized'
	 END
+ ' on ' + object_name(id) + ' to ' + user_name(uid) + char(13) + 'go'
from sysprotects
where uid = user_id('sactabatch')
GO
use OPVD_WK
go
select 'USE ' + db_name() + char(13) + 'go'
go
select '--utilizando o banco de dados ' + db_name()
go
select 'grant ' +  CASE action
         WHEN 193 THEN 'SELECT '
         WHEN 195 THEN 'INSERT '
	 WHEN 196 THEN 'DELETE '
	 WHEN 197 THEN 'UPDATE '
	 WHEN 224 THEN 'EXECUTE '
         --ELSE 'Not yet categorized'
	 END
+ ' on ' + object_name(id) + ' to ' + user_name(uid) + char(13) + 'go'
from sysprotects
where uid = user_id('sactabatch')
GO
use OPVD_HIST
go
select 'USE ' + db_name() + char(13) + 'go'
go
select '--utilizando o banco de dados ' + db_name()
go
go
select 'grant ' +  CASE action
         WHEN 193 THEN 'SELECT '
         WHEN 195 THEN 'INSERT '
	 WHEN 196 THEN 'DELETE '
	 WHEN 197 THEN 'UPDATE '
	 WHEN 224 THEN 'EXECUTE '
         --ELSE 'Not yet categorized'
	 END
+ ' on ' + object_name(id) + ' to ' + user_name(uid) + char(13) + 'go'
from sysprotects
where uid = user_id('sactabatch')
GO
set nocount off
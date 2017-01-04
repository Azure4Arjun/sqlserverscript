-- generate sp_addgroup
select "EXEC sp_addgroup " +name from sysusers where suid=-2 and name not like "%role%" and name <> "public"
-- generate sp_adduser
select "EXEC sp_adduser " +"'" +name +"'" +"," +"'" +name +"'" +"," +"'" +user_name(gid) +"'" from sysusers where suid>3
-- generate grants
select 'GRANT select on ' +object_name(sp.id) +' TO ' +user_name(sp.uid)
from sysprotects sp, sysobjects so
where sp.id = so.id and so.type in('U','V') and sp.action = 193
order by so.type,so.name
select 'GRANT insert on ' +object_name(sp.id) +' TO ' +user_name(sp.uid)
from sysprotects sp, sysobjects so
where sp.id = so.id and so.type in('U','V') and sp.action = 195
select 'GRANT delete on ' +object_name(sp.id) +' TO ' +user_name(sp.uid)
from sysprotects sp, sysobjects so
where sp.id = so.id and so.type in('U','V') and sp.action = 196
select 'GRANT update on ' +object_name(sp.id) +' TO ' +user_name(sp.uid)
from sysprotects sp, sysobjects so
where sp.id = so.id and so.type in('U','V') and sp.action = 197
select 'GRANT exec on ' +object_name(sp.id) +' TO ' +user_name(sp.uid)
from sysprotects sp, sysobjects so
where sp.id = so.id and so.type = 'P' and sp.action = 224

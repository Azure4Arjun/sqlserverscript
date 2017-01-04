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
where uid = 9
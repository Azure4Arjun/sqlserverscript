set nocount on
select 'sp_change_users_login "update_one", "'+ name +'", "'+ name + '"' + char(13) + 'go' + char(13) from sysusers where status = 2
set nocount off
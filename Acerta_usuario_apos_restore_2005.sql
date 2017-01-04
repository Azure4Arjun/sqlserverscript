set nocount on
select 'sp_change_users_login "update_one", "'+ name +'", "'+ name + '"' + char(10) + 'go' + char(10) from sysusers
set nocount off

---http://thesqldude.com/2012/04/07/how-to-prevent-users-from-accessing-sql-server-from-any-application-or-any-login-expect-your-main-application-its-login/
USE master
GO
CREATE TABLE dbo.loginAuditTable (
    id INT IDENTITY PRIMARY KEY,
    host_name nvarchar(128),
    created datetime
)
GO

--Step3: Create Logon Trigger to block all users expect SA & MyApplicationUser
IF EXISTS(
    SELECT * FROM master.sys.server_triggers
    WHERE parent_class_desc = 'SERVER' AND name = N'Allow_only_Application_Login_Trigger')
DROP TRIGGER [Allow_only_Application_Login_Trigger] ON ALL SERVER
GO
 
CREATE TRIGGER Allow_only_Application_Login_Trigger
ON ALL SERVER WITH EXECUTE AS 'sa'
FOR LOGON
AS
BEGIN

DECLARE @data XML
SET @data = EVENTDATA()
 
DECLARE @LoginName sysname
       ,@HostName sysname

SELECT @LoginName = @data.value('(/EVENT_INSTANCE/LoginName)[1]', 'sysname')
      ,@HostName = @data.value('(/EVENT_INSTANCE/ClientHost)[1]', 'sysname')

--IF @LoginName in ('celtrak_data') and @HostName not in ('waldorf','NIALLCOLREAVY02')
IF @LoginName in ('test') and @HostName not in ('192.168.51.157')
    BEGIN
        ROLLBACK; --Disconnect the session
        --Log the exception to our Auditing table
        INSERT INTO master.dbo.loginAuditTable(host_name, created)
        VALUES(@HostName, GETDATE())
    END 
END;


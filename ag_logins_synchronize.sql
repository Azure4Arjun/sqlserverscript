http://blog.sqlauthority.com/2015/04/18/sql-server-create-login-with-sid-way-to-synchronize-logins-on-secondary-server/

--run Primary
USE AppDB 
SELECT name, sid 
FROM sys.sysusers 
WHERE name = 'AppUser' 

USE MASTER 
SELECT name, sid 
FROM sys.sql_logins 
WHERE name = 'AppUser'


--run Secondary
USE AppDB 
SELECT name, sid 
FROM sys.sysusers 
WHERE name = 'AppUser' 

USE MASTER 
SELECT name, sid 
FROM sys.sql_logins 
WHERE name = 'AppUser'


--run Secondary
DROP LOGIN AppUser

--run Secondary--using SID you got from primary
CREATE Login AppUser WITH password = 'password@123', SID = 0x59B662112A43D24585BFE2BF80D9BE19, CHECK_POLICY = OFF
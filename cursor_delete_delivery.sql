BEGIN

SET NOCOUNT ON;

DECLARE @dbname nvarchar(100);

DECLARE @sqlcmd nvarchar(1000);

DECLARE DBs CURSOR STATIC FOR

/* define HERE the list of databases to be processed */

SELECT name FROM sys.databases WHERE name NOT IN ('TempDB','Model','master','msdb','t4bdb01') ORDER By name;

OPEN DBs;

FETCH NEXT FROM DBs INTO @dbname;

WHILE @@FETCH_STATUS = 0

BEGIN

/* Write a procedure to do the work on each database */

SET @sqlcmd = 'USE [' + QUOTENAME(@dbname) + '] delete from tbltraducao where codtraducao in(select t2.codtraducao from (select t3.codtraducao, count(*) as f from tbltraducao t3 group by t3.codtraducao having count(*) = 1) as t2)';

PRINT @sqlcmd;

EXECUTE sp_executesql @sqlcmd;

FETCH NEXT FROM DBs INTO @dbname;

PRINT 'Next: ' + CONVERT(NVARCHAR(20),GETDATE(),120) + ', ' + @dbname + ', Fetch Status ' + CAST(@@FETCH_STATUS as NVARCHAR(4))

   PRINT '-----------------------------------------------------------------';

END

CLOSE DBs;

DEALLOCATE DBs;

PRINT '=================================================================';

END
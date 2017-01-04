BEGIN

SET NOCOUNT ON;

DECLARE @dbname nvarchar(100);

DECLARE @sqlcmd nvarchar(1000);

DECLARE DBs CURSOR STATIC FOR

/* define HERE the list of databases to be processed */

SELECT name FROM sys.databases WHERE name NOT IN ('TempDB','Model') ORDER By name;

OPEN DBs;

FETCH NEXT FROM DBs INTO @dbname;

WHILE @@FETCH_STATUS = 0

BEGIN

/* Write a procedure to do the work on each database */

SET @sqlcmd = 'DBadministration.dbo.dba_fragmentation ' + QUOTENAME(@dbname);

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
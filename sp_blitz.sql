USE [master];
GO

IF OBJECT_ID('dbo.sp_Blitz') IS NOT NULL 
    DROP PROC dbo.sp_Blitz;
GO

CREATE PROCEDURE [dbo].[sp_Blitz]
    @CheckUserDatabaseObjects TINYINT = 1 ,
    @CheckProcedureCache TINYINT = 0 ,
    @OutputType VARCHAR(20) = 'TABLE' ,
    @OutputProcedureCache TINYINT = 0 ,
    @CheckProcedureCacheFilter VARCHAR(10) = NULL ,
    @CheckServerInfo TINYINT = 0 ,
    @SkipChecksServer NVARCHAR(256) = NULL ,
    @SkipChecksDatabase NVARCHAR(256) = NULL ,
    @SkipChecksSchema NVARCHAR(256) = NULL ,
    @SkipChecksTable NVARCHAR(256) = NULL ,
    @IgnorePrioritiesBelow INT = NULL ,
    @IgnorePrioritiesAbove INT = NULL ,
    @OutputDatabaseName NVARCHAR(128) = NULL ,
    @OutputSchemaName NVARCHAR(256) = NULL ,
    @OutputTableName NVARCHAR(256) = NULL ,
    @Version INT = NULL OUTPUT
AS 
    SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	/*
	sp_Blitz (TM) v27 - August 6, 2013
    
	(C) 2013, Brent Ozar Unlimited. 
	See http://BrentOzar.com/go/eula for the End User Licensing Agreement.

	To learn more, visit http://www.BrentOzar.com/blitz where you can download
	new versions for free, watch training videos on how it works, get more info on
	the findings, and more.  To contribute code and see your name in the change
	log, email your improvements & checks to Help@BrentOzar.com.

	Sample execution call with the most common parameters:

	EXEC [master].[dbo].[sp_Blitz]
		@CheckUserDatabaseObjects = 1 ,
		@CheckProcedureCache = 0 ,
		@OutputType = 'TABLE' ,
		@OutputProcedureCache = 0 ,
		@CheckProcedureCacheFilter = NULL,
		@CheckServerInfo = 1

	Known limitations of this version:
	 - No support for SQL Server 2000 or compatibility mode 80.
	 - If a database name has a question mark in it, some tests will fail.  Gotta
	   love that unsupported sp_MSforeachdb.
	 - If you have offline databases, sp_Blitz fails the first time you run it,
	   but does work the second time. (Hoo, boy, this will be fun to fix.)

	Unknown limitations of this version:
	 - None.  (If we knew them, they'd be known.  Duh.)

	Changes in v27 - August 6, 2013
	 - Whoops! Even more bug fixes in check 114. Thanks, Andy Jarman!

	Changes in v26 - August 2, 2013
	 - Whoops! Improved check 114 to skip SQL Server 2005, since the necessary
	   DMVs don't exist there. Thanks, Conan Farrell.

	Changes in v25 - August 2, 2013
	 - Andrew Jarman was the first to catch a bug in check 70 for named instances.
	 - David Todd suggested a tweak to make it easier to deploy this stored proc
	   in other databases.
	 - Added check for Adam Machanic's make_parallel function (115).
	 - Added check for basic NUMA config (114).
	 - Added check for backup compression defaulted to off (116), suggested by
	   David Todd.
	 - Added check for forced grants in sys.dm_exec_query_resource_semaphores,
	   indicating memory pressure is affecting query performance (117).

    Changes in v24 - June 23, 2013
	 - Alin Selicean @AlinSelicean:
	   - debugged check 72 for non-aligned partitioned indexes.
	   - improved check 70 for the @@servername variable.
	 - Andreas Schubert debugged check 14 to remove duplicate results.
	 - Josh Duewer added check 112 looking for change tracking.
	 - Justin Dearing @Zippy1981 improved @OutputTableName to export the results
	   to a global temp table.
	 - Katie Vetter improved check 6 for jobs owned by <> SA, by removing the join
	   to sys.server_principals and using a function for the name instead.
	 - Kevin Frazier improved check 106 by removing extra copy/paste code.
	 - Mike Eastland added check 111 looking for broken log shipping subscribers.
	 - Added check 110 for memory nodes offline.
	 - Added check 113 for full text indexes not crawled in the last week.
	 - Changed VLF threshold from 50 to 1,000. We were getting a lot of questions
	   about databases with 51-100 VLFs, and that's just not a real performance
	   killer. To minimize false alarms, we cranked the threshold way up. Let's
	   get you focused on making sure your databases are backed up first.
	 - Fixed bugs in @SkipChecks tables. Man, there's no way any of you were
	   using that thing, because it was chock full of nuts.
	 - Added basic SQL Server 2014 compatibility.

	Changes in v23 - June 2, 2013:
	 - Katherine Villyard @geekg0dd3ss caught bug in check 72 (non-aligned 
	   partitioned indexes) that wasn't honoring @CheckUserDatabaseObjects.
	 - Paul Olson http://www.SQLsprawl.com wrote check 106 to show how much
	   history is being kept in the default traces, and where they are. Only runs
	   if @CheckServerInfo = 1.
	 - Randall Stone suggested ignoring ReportServer% databases in the collation
	   checks. Prior versions of the checks were only ignoring default name
	   instances of SSRS.
	 - Added checks for "poison" wait types: THREADPOOL, RESOURCE_SEMAPHORE, and
	   RESOURCE_SEMAPHORE_QUERY_COMPILE. Any occurrence of these waits often
	   indicates a killer performance issue. Checks 107-109.
	 - Non-default sp_configure options used to be CheckID 22 for all possible
	   sp_configure settings. Now we use the range 1,000-1,999 for sp_configure.
	   This way, if you're writing a tool that outputs specific advice for each
	   CheckID, you can get more specific with the advice based on which
	   sp_configure option has been changed.
	 - Fixed various typos.

	Changes in v22 - May 6, 2013:
	 - Fixed new v21 case sensitivity bug reported by several users.
	 - Cleaned up some typos in script output.

	Changes in v21 - April 25, 2013:
	 - Easier readability - cleaned up the code with Red Gate SQL Prompt, plus
	   added comments explaining what's happening.
	 - Added @OutputDatabaseName, @OutputSchemaName, @OutputTableName. If set, the 
	   #BlitzResults table is saved into that. Only outputs the check results, not
	   the plan cache. Suggested by Robbert Hof and Andy Bassitt.
	 - Alin Selicean @AlinSelicean:
	   - Added check 100 looking for disabled remote access to the DAC.
	   - Added check 101 looking for disabled CPU schedulers due to licensing or
		 affinity masking.
	 - Chris Leavitt coded check 103 looking for virtualization.
	 - Mike Eastland suggested check 102 for databases in unusual states - suspect,
	   recovering, emergency, etc.
	 - Russell Hart coded check 104 looking for logins with CONTROL SERVER perms.
	 - Added check 105 looking for extended stored procedures in master.
	 - Moved temp table creation up to the top of the sproc while trying to fix an
	   issue with offline databases. I like it up there, so leaving it. Didn't fix
	   the issue, but ah well.
	 - Moved the old changes to http://www.BrentOzar.com/blitz/changelog/

	For prior changes, see http://www.BrentOzar.com/blitz/changelog/
	*/


	/*
	We start by creating #BlitzResults. It's a temp table that will store all of
	the results from our checks. Throughout the rest of this stored procedure,
	we're running a series of checks looking for dangerous things inside the SQL
	Server. When we find a problem, we insert rows into #BlitzResults. At the
	end, we return these results to the end user.

	#BlitzResults has a CheckID field, but there's no Check table. As we do
	checks, we insert data into this table, and we manually put in the CheckID.
	We (Brent Ozar Unlimited) maintain a list of the checks by ID#. You can
	download that from http://www.BrentOzar.com/blitz/documentation/ - you'll
	see why it can help shortly.
	*/
	DECLARE @StringToExecute NVARCHAR(4000)
		,@curr_tracefilename NVARCHAR(500) 
		,@base_tracefilename NVARCHAR(500) 
		,@indx int ;

	select @curr_tracefilename = [path] from sys.traces where is_default = 1 ;
	set @curr_tracefilename = reverse(@curr_tracefilename);
	select @indx = patindex('%\%', @curr_tracefilename) ;
	set @curr_tracefilename = reverse(@curr_tracefilename) ;
	set @base_tracefilename = left( @curr_tracefilename,len(@curr_tracefilename) - @indx) + '\log.trc' ;

    IF OBJECT_ID('tempdb..#BlitzResults') IS NOT NULL 
        DROP TABLE #BlitzResults;
    CREATE TABLE #BlitzResults
        (
          ID INT IDENTITY(1, 1) ,
          CheckID INT ,
          DatabaseName NVARCHAR(128) ,
          Priority TINYINT ,
          FindingsGroup VARCHAR(50) ,
          Finding VARCHAR(200) ,
          URL VARCHAR(200) ,
          Details NVARCHAR(4000) ,
          QueryPlan [XML] NULL ,
          QueryPlanFiltered [NVARCHAR](MAX) NULL
        );

	/*
	You can build your own table with a list of checks to skip. For example, you
	might have some databases that you don't care about, or some checks you don't
	want to run. Then, when you run sp_Blitz, you can specify these parameters:
	@SkipChecksDatabase = 'DBAtools',
	@SkipChecksSchema = 'dbo',
	@SkipChecksTable = 'BlitzChecksToSkip'
	Pass in the database, schema, and table that contains the list of checks you
	want to skip. This part of the code checks those parameters, gets the list,
	and then saves those in a temp table. As we run each check, we'll see if we
	need to skip it.
	
	Really anal-retentive users will note that the @SkipChecksServer parameter is
	not used. YET. We added that parameter in so that we could avoid changing the
	stored proc's surface area (interface) later.
	*/
    IF OBJECT_ID('tempdb..#SkipChecks') IS NOT NULL 
        DROP TABLE #SkipChecks;
    CREATE TABLE #SkipChecks
        (
          DatabaseName NVARCHAR(128) ,
          CheckID INT ,
          ServerName NVARCHAR(128)
        );
	CREATE CLUSTERED INDEX IX_CheckID_DatabaseName ON #SkipChecks(CheckID, DatabaseName);

    IF @SkipChecksTable IS NOT NULL
        AND @SkipChecksSchema IS NOT NULL
        AND @SkipChecksDatabase IS NOT NULL 
        BEGIN
            SET @StringToExecute = 'INSERT INTO #SkipChecks(DatabaseName, CheckID, ServerName )
            SELECT DISTINCT DatabaseName, CheckID, ServerName
            FROM ' + QUOTENAME(@SkipChecksDatabase) + '.' + QUOTENAME(@SkipChecksSchema) + '.' + QUOTENAME(@SkipChecksTable)
                + ' WHERE ServerName IS NULL OR ServerName = SERVERPROPERTY(''ServerName'');'
            EXEC(@StringToExecute)
        END


	/* 
	That's the end of the SkipChecks stuff.
	The next several tables are used by various checks later.
	*/
    IF OBJECT_ID('tempdb..#ConfigurationDefaults') IS NOT NULL 
        DROP TABLE #ConfigurationDefaults;
    CREATE TABLE #ConfigurationDefaults
        (
          name NVARCHAR(128) ,
          DefaultValue BIGINT,
		  CheckID INT
        );

    IF OBJECT_ID('tempdb..#DBCCs') IS NOT NULL 
        DROP TABLE #DBCCs;
    CREATE TABLE #DBCCs
        (
          ID INT IDENTITY(1, 1)
                 PRIMARY KEY ,
          ParentObject VARCHAR(255) ,
          Object VARCHAR(255) ,
          Field VARCHAR(255) ,
          Value VARCHAR(255) ,
          DbName NVARCHAR(128) NULL
        )


    IF OBJECT_ID('tempdb..#LogInfo2012') IS NOT NULL 
        DROP TABLE #LogInfo2012;
    CREATE TABLE #LogInfo2012
        (
          recoveryunitid INT ,
          FileID SMALLINT ,
          FileSize BIGINT ,
          StartOffset BIGINT ,
          FSeqNo BIGINT ,
          [Status] TINYINT ,
          Parity TINYINT ,
          CreateLSN NUMERIC(38)
        );

    IF OBJECT_ID('tempdb..#LogInfo') IS NOT NULL 
        DROP TABLE #LogInfo;
    CREATE TABLE #LogInfo
        (
          FileID SMALLINT ,
          FileSize BIGINT ,
          StartOffset BIGINT ,
          FSeqNo BIGINT ,
          [Status] TINYINT ,
          Parity TINYINT ,
          CreateLSN NUMERIC(38)
        );

    IF OBJECT_ID('tempdb..#partdb') IS NOT NULL 
        DROP TABLE #partdb;
    CREATE TABLE #partdb
        (
          dbname NVARCHAR(128) ,
          objectname NVARCHAR(200) ,
          type_desc NVARCHAR(128)
        )

    IF OBJECT_ID('tempdb..#TraceStatus') IS NOT NULL 
        DROP TABLE #TraceStatus;
    CREATE TABLE #TraceStatus
        (
          TraceFlag VARCHAR(10) ,
          status BIT ,
          Global BIT ,
          Session BIT
        );

    IF OBJECT_ID('tempdb..#driveInfo') IS NOT NULL 
        DROP TABLE #driveInfo;
    CREATE TABLE #driveInfo
        (
          drive NVARCHAR ,
          SIZE DECIMAL(18, 2)
        )


    IF OBJECT_ID('tempdb..#dm_exec_query_stats') IS NOT NULL 
        DROP TABLE #dm_exec_query_stats;
    CREATE TABLE #dm_exec_query_stats
        (
          [id] [int] NOT NULL
                     IDENTITY(1, 1) ,
          [sql_handle] [varbinary](64) NOT NULL ,
          [statement_start_offset] [int] NOT NULL ,
          [statement_end_offset] [int] NOT NULL ,
          [plan_generation_num] [bigint] NOT NULL ,
          [plan_handle] [varbinary](64) NOT NULL ,
          [creation_time] [datetime] NOT NULL ,
          [last_execution_time] [datetime] NOT NULL ,
          [execution_count] [bigint] NOT NULL ,
          [total_worker_time] [bigint] NOT NULL ,
          [last_worker_time] [bigint] NOT NULL ,
          [min_worker_time] [bigint] NOT NULL ,
          [max_worker_time] [bigint] NOT NULL ,
          [total_physical_reads] [bigint] NOT NULL ,
          [last_physical_reads] [bigint] NOT NULL ,
          [min_physical_reads] [bigint] NOT NULL ,
          [max_physical_reads] [bigint] NOT NULL ,
          [total_logical_writes] [bigint] NOT NULL ,
          [last_logical_writes] [bigint] NOT NULL ,
          [min_logical_writes] [bigint] NOT NULL ,
          [max_logical_writes] [bigint] NOT NULL ,
          [total_logical_reads] [bigint] NOT NULL ,
          [last_logical_reads] [bigint] NOT NULL ,
          [min_logical_reads] [bigint] NOT NULL ,
          [max_logical_reads] [bigint] NOT NULL ,
          [total_clr_time] [bigint] NOT NULL ,
          [last_clr_time] [bigint] NOT NULL ,
          [min_clr_time] [bigint] NOT NULL ,
          [max_clr_time] [bigint] NOT NULL ,
          [total_elapsed_time] [bigint] NOT NULL ,
          [last_elapsed_time] [bigint] NOT NULL ,
          [min_elapsed_time] [bigint] NOT NULL ,
          [max_elapsed_time] [bigint] NOT NULL ,
          [query_hash] [binary](8) NULL ,
          [query_plan_hash] [binary](8) NULL ,
          [query_plan] [xml] NULL ,
          [query_plan_filtered] [nvarchar](MAX) NULL ,
          [text] [nvarchar](MAX) COLLATE SQL_Latin1_General_CP1_CI_AS
                                 NULL ,
          [text_filtered] [nvarchar](MAX) COLLATE SQL_Latin1_General_CP1_CI_AS
                                          NULL
        )


	/* If we're outputting CSV, don't bother checking the plan cache because we cannot export plans. */
    IF @OutputType = 'CSV' 
        SET @CheckProcedureCache = 0;

	/* Sanitize our inputs */
    SELECT
		@OutputDatabaseName = QUOTENAME(@OutputDatabaseName),
		@OutputSchemaName = QUOTENAME(@OutputSchemaName),
		@OutputTableName = QUOTENAME(@OutputTableName)



	/* 
	Whew! we're finally done with the setup, and we can start doing checks.
	First, let's make sure we're actually supposed to do checks on this server.
	The user could have passed in a SkipChecks table that specified to skip ALL
	checks on this server, so let's check for that:
	*/
    IF ( ( SERVERPROPERTY('ServerName') NOT IN ( SELECT ServerName
                                                 FROM   #SkipChecks
                                                 WHERE  DatabaseName IS NULL
                                                        AND CheckID IS NULL ) )
         OR ( @SkipChecksTable IS NULL )
       ) 
        BEGIN

			/*
			Our very first check! We'll put more comments in this one just to
			explain exactly how it works. First, we check to see if we're
			supposed to skip CheckID 1 (that's the check we're working on.)
			*/
            IF NOT EXISTS ( SELECT  1
                            FROM    #SkipChecks
                            WHERE   DatabaseName IS NULL AND CheckID = 1 ) 
                BEGIN

					/*
					Below, we check master.sys.databases looking for databases
					that haven't had a backup in the last week. If we find any,
					we insert them into #BlitzResults, the temp table that
					tracks our server's problems. Note that if the check does
					NOT find any problems, we don't save that. We're only
					saving the problems, not the successful checks.
					*/
                    INSERT  INTO #BlitzResults
                            ( CheckID ,
                              DatabaseName ,
                              Priority ,
                              FindingsGroup ,
                              Finding ,
                              URL ,
                              Details
                            )
                            SELECT  1 AS CheckID ,
                                    d.[name] AS DatabaseName ,
                                    1 AS Priority ,
                                    'Backup' AS FindingsGroup ,
                                    'Backups Not Performed Recently' AS Finding ,
                                    'http://BrentOzar.com/go/nobak' AS URL ,
                                    'Database ' + d.Name + ' last backed up: '
                                    + CAST(COALESCE(MAX(b.backup_finish_date),
                                                    ' never ') AS VARCHAR(200)) AS Details
                            FROM    master.sys.databases d
                                    LEFT OUTER JOIN msdb.dbo.backupset b ON d.name = b.database_name
                                                              AND b.type = 'D'
                                                              AND b.server_name = SERVERPROPERTY('ServerName') /*Backupset ran on current server */
                            WHERE   d.database_id <> 2  /* Bonus points if you know what that means */
                                    AND d.state <> 1 /* Not currently restoring, like log shipping databases */
                                    AND d.is_in_standby = 0 /* Not a log shipping target database */
                                    AND d.source_database_id IS NULL /* Excludes database snapshots */
                                    AND d.name NOT IN ( SELECT DISTINCT
                                                              DatabaseName
                                                        FROM  #SkipChecks
                                                        WHERE CheckID IS NULL )
									/* 
									The above NOT IN filters out the databases we're not supposed to check.
									*/
                            GROUP BY d.name
                            HAVING  MAX(b.backup_finish_date) <= DATEADD(dd,
                                                              -7, GETDATE());
					/* 
					And there you have it. The rest of this stored procedure works the same
					way: it asks:
					- Should I skip this check?
					- If not, do I find problems?
					- Insert the results into #BlitzResults
					This particular check is just a little bit fancy - it also has a second
					query below that checks for databases that have NEVER been backed up.
					We use CheckID #1 for both of these just because they represent the same
					problem - a database that needs a backup.
					*/

                    INSERT  INTO #BlitzResults
                            ( CheckID ,
                              DatabaseName ,
                              Priority ,
                              FindingsGroup ,
                              Finding ,
                              URL ,
                              Details
                            )
                            SELECT  1 AS CheckID ,
                                    d.name AS DatabaseName ,
                                    1 AS Priority ,
                                    'Backup' AS FindingsGroup ,
                                    'Backups Not Performed Recently' AS Finding ,
                                    'http://BrentOzar.com/go/nobak' AS URL ,
                                    ( 'Database ' + d.Name
                                      + ' never backed up.' ) AS Details
                            FROM    master.sys.databases d
                            WHERE   d.database_id <> 2 /* Bonus points if you know what that means */
                                    AND d.state <> 1 /* Not currently restoring, like log shipping databases */
                                    AND d.is_in_standby = 0 /* Not a log shipping target database */
                                    AND d.source_database_id IS NULL /* Excludes database snapshots */
                                    AND d.name NOT IN ( SELECT DISTINCT
                                                              DatabaseName
                                                        FROM  #SkipChecks
                                                        WHERE CheckID IS NULL )
                                    AND NOT EXISTS ( SELECT *
                                                     FROM   msdb.dbo.backupset b
                                                     WHERE  d.name = b.database_name
                                                            AND b.type = 'D'
                                                            AND b.server_name = SERVERPROPERTY('ServerName') /*Backupset ran on current server */)

                END

			/* 
			And that's the end of CheckID #1.

			CheckID #2 is a little simpler because it only involves one query, and it's
			more typical for queries that people contribute. But keep reading, because
			the next check gets more complex again.
			*/
    
            IF NOT EXISTS ( SELECT  1
                            FROM    #SkipChecks
                            WHERE   DatabaseName IS NULL AND CheckID = 2 ) 
                BEGIN
                    INSERT  INTO #BlitzResults
                            ( CheckID ,
                              DatabaseName ,
                              Priority ,
                              FindingsGroup ,
                              Finding ,
                              URL ,
                              Details
                            )
                            SELECT DISTINCT
                                    2 AS CheckID ,
                                    d.name AS DatabaseName ,
                                    1 AS Priority ,
                                    'Backup' AS FindingsGroup ,
                                    'Full Recovery Mode w/o Log Backups' AS Finding ,
                                    'http://BrentOzar.com/go/biglogs' AS URL ,
                                    ( 'Database ' + ( d.Name COLLATE database_default )
                                      + ' is in ' + d.recovery_model_desc
                                      + ' recovery mode but has not had a log backup in the last week.' ) AS Details
                            FROM    master.sys.databases d
                            WHERE   d.recovery_model IN ( 1, 2 )
                                    AND d.database_id NOT IN ( 2, 3 )
                                    AND d.source_database_id IS NULL
                                    AND d.state <> 1 /* Not currently restoring, like log shipping databases */
                                    AND d.is_in_standby = 0 /* Not a log shipping target database */
                                    AND d.source_database_id IS NULL /* Excludes database snapshots */
                                    AND d.name NOT IN ( SELECT DISTINCT
                                                              DatabaseName
                                                        FROM  #SkipChecks
                                                        WHERE CheckID IS NULL )
                                    AND NOT EXISTS ( SELECT *
                                                     FROM   msdb.dbo.backupset b
                                                     WHERE  d.name = b.database_name
                                                            AND b.type = 'L'
                                                            AND b.backup_finish_date >= DATEADD(dd,
                                                              -7, GETDATE()) );
                END


			/* 
			Next up, we've got CheckID 8. (These don't have to go in order.) This one
			won't work on SQL Server 2005 because it relies on a new DMV that didn't
			exist prior to SQL Server 2008. This means we have to check the SQL Server
			version first, then build a dynamic string with the query we want to run:			
			*/

            IF NOT EXISTS ( SELECT  1
                            FROM    #SkipChecks
                            WHERE   DatabaseName IS NULL AND CheckID = 8 ) 
                BEGIN
                    IF @@VERSION NOT LIKE '%Microsoft SQL Server 2000%'
                        AND @@VERSION NOT LIKE '%Microsoft SQL Server 2005%' 
                        BEGIN
                            SET @StringToExecute = 'INSERT INTO #BlitzResults 
                        (CheckID, Priority, 
                        FindingsGroup, 
                        Finding, URL, 
                        Details)
                  SELECT 8 AS CheckID, 
                  150 AS Priority, 
                  ''Security'' AS FindingsGroup, 
                  ''Server Audits Running'' AS Finding, 
                  ''http://BrentOzar.com/go/audits'' AS URL,
                  (''SQL Server built-in audit functionality is being used by server audit: '' + [name]) AS Details FROM sys.dm_server_audit_status'
                            EXECUTE(@StringToExecute)
                        END;
                END

			/* 
			But what if you need to run a query in every individual database?
			Check out CheckID 99 below. Yes, it uses sp_MSforeachdb, and no,
			we're not happy about that. sp_MSforeachdb is known to have a lot
			of issues, like skipping databases sometimes. However, this is the
			only built-in option that we have. If you're writing your own code
			for database maintenance, consider Aaron Bertrand's alternative:
			http://www.mssqltips.com/sqlservertip/2201/making-a-more-reliable-and-flexible-spmsforeachdb/
			We don't include that as part of sp_Blitz, of course, because
			copying and distributing copyrighted code from others without their
			written permission isn't a good idea.
			*/
            IF NOT EXISTS ( SELECT  1
                            FROM    #SkipChecks
                            WHERE   DatabaseName IS NULL AND CheckID = 99 ) 
                BEGIN
                    EXEC dbo.sp_MSforeachdb 'USE [?];  IF EXISTS (SELECT * FROM  sys.tables WITH (NOLOCK) WHERE name = ''sysmergepublications'' ) IF EXISTS ( SELECT * FROM sysmergepublications WITH (NOLOCK) WHERE retention = 0)   INSERT INTO #BlitzResults (CheckID, DatabaseName, Priority, FindingsGroup, Finding, URL, Details) SELECT DISTINCT 99, DB_NAME(), 110, ''Performance'', ''Infinite merge replication metadata retention period'', ''http://BrentOzar.com/go/merge'', (''The ['' + DB_NAME() + ''] database has merge replication metadata retention period set to infinite - this can be the case of significant performance issues.'')';
                END
			/*
			Note that by using sp_MSforeachdb, we're running the query in all
			databases. We're not checking #SkipChecks here for each database to
			see if we should run the check in this database. That means we may
			still run a skipped check if it involves sp_MSforeachdb. We just
			don't output those results in the last step.

			And that's the basic idea! You can read through the rest of the
			checks if you like - some more exciting stuff happens closer to the
			end of the stored proc, where we start doing things like checking
			the plan cache, but those aren't as cleanly commented.

			If you'd like to contribute your own check, use one of the check
			formats shown above and email it to Help@BrentOzar.com. You don't
			have to pick a CheckID or a link - we'll take care of that when we
			test and publish the code. Thanks!
			*/


            IF NOT EXISTS ( SELECT  1
                            FROM    #SkipChecks
                            WHERE   DatabaseName IS NULL AND CheckID = 93 ) 
                BEGIN
                    INSERT  INTO #BlitzResults
                            ( CheckID ,
                              Priority ,
                              FindingsGroup ,
                              Finding ,
                              URL ,
                              Details
                            )
                            SELECT DISTINCT
                                    93 AS CheckID ,
                                    1 AS Priority ,
                                    'Backup' AS FindingsGroup ,
                                    'Backing Up to Same Drive Where Databases Reside' AS Finding ,
                                    'http://BrentOzar.com/go/backup' AS URL ,
                                    'Drive '
                                    + UPPER(LEFT(bmf.physical_device_name, 3))
                                    + ' houses both database files AND backups taken in the last two weeks. This represents a serious risk if that array fails.' Details
                            FROM    msdb.dbo.backupmediafamily AS bmf
                                    INNER JOIN msdb.dbo.backupset AS bs ON bmf.media_set_id = bs.media_set_id
                                                              AND bs.backup_start_date >= ( DATEADD(dd,
                                                              -14, GETDATE()) )
                            WHERE   UPPER(LEFT(bmf.physical_device_name, 3)) IN (
                                    SELECT DISTINCT
                                            UPPER(LEFT(mf.physical_name, 3))
                                    FROM    sys.master_files AS mf )
                END


            IF NOT EXISTS ( SELECT  1
                            FROM    #SkipChecks
                            WHERE   DatabaseName IS NULL AND CheckID = 3 ) 
                BEGIN
                    INSERT  INTO #BlitzResults
                            ( CheckID ,
                              DatabaseName ,
                              Priority ,
                              FindingsGroup ,
                              Finding ,
                              URL ,
                              Details
                            )
                            SELECT TOP 1
                                    3 AS CheckID ,
                                    'msdb' ,
                                    200 AS Priority ,
                                    'Backup' AS FindingsGroup ,
                                    'MSDB Backup History Not Purged' AS Finding ,
                                    'http://BrentOzar.com/go/history' AS URL ,
                                    ( 'Database backup history retained back to '
                                      + CAST(bs.backup_start_date AS VARCHAR(20)) ) AS Details
                            FROM    msdb.dbo.backupset bs
                            WHERE   bs.backup_start_date <= DATEADD(dd, -60,
                                                              GETDATE())
                            ORDER BY backup_set_id ASC;
                END
    
            IF NOT EXISTS ( SELECT  1
                            FROM    #SkipChecks
                            WHERE   DatabaseName IS NULL AND CheckID = 4 ) 
                BEGIN
                    INSERT  INTO #BlitzResults
                            ( CheckID ,
                              Priority ,
                              FindingsGroup ,
                              Finding ,
                              URL ,
                              Details
                            )
                            SELECT  4 AS CheckID ,
                                    10 AS Priority ,
                                    'Security' AS FindingsGroup ,
                                    'Sysadmins' AS Finding ,
                                    'http://BrentOzar.com/go/sa' AS URL ,
                                    ( 'Login [' + l.name
                                      + '] is a sysadmin - meaning they can do absolutely anything in SQL Server, including dropping databases or hiding their tracks.' ) AS Details
                            FROM    master.sys.syslogins l
                            WHERE   l.sysadmin = 1
                                    AND l.name <> SUSER_SNAME(0x01)
                                    AND l.denylogin = 0;
                END
    
        
            IF NOT EXISTS ( SELECT  1
                            FROM    #SkipChecks
                            WHERE   DatabaseName IS NULL AND CheckID = 5 ) 
                BEGIN
                    INSERT  INTO #BlitzResults
                            ( CheckID ,
                              Priority ,
                              FindingsGroup ,
                              Finding ,
                              URL ,
                              Details
                            )
                            SELECT  5 AS CheckID ,
                                    10 AS Priority ,
                                    'Security' AS FindingsGroup ,
                                    'Security Ad
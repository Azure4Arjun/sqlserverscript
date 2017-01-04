--DBCC TRACEON(3604)

DECLARE @spid INT
DECLARE @current_page varchar(max)
DECLARE @index_id INT

DECLARE @object_id BIGINT
DECLARE @dbcc_page_out table (

	parent_obj VARCHAR (MAX)
	, obj VARCHAR(MAX)
	, field varchar(max)
	, value varchar(max)

)


-- change just SPID
SET @spid = 70

SELECT @current_page = waitresource 
FROM master..sysprocesses
WHERE spid = @spid

SET @current_page = REPLACE(REPLACE(@current_page, ':',','),' ','')
SELECT @current_page as page_accessed

IF @current_page = '0,0,0' or @current_page IS NULL or @current_page = ''
	BEGIN
		
		SELECT @current_page + ' is not a valid page, execute again' as error

	END
ELSE
	BEGIN				                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
		INSERT INTO @dbcc_page_out
		exec ('DBCC PAGE (' + @current_page +')  WITH TABLERESULTS')

		SELECT @object_id = value
		FROM @dbcc_page_out
		WHERE field = 'Metadata: ObjectId'

		IF (SELECT 1 FROM @dbcc_page_out WHERE field = 'Metadata: IndexId') > 0
			BEGIN
				SELECT @index_id = value
				FROM @dbcc_page_out 
				WHERE field = 'Metadata: IndexId'

				SELECT object_name(id) as table_under_analysis
					, name as index_under_analysis
					, rows
				FROM sysindexes
				WHERE id = @object_id
				AND indid = @index_id

				SELECT 'Indexes of the same table left' as status
					, name as index_name
				FROM sysindexes 
				WHERE id = @object_id
				AND indid > @index_id
				AND rows > 0
				order by indid
			END
		ELSE
			BEGIN
				SELECT object_name(@object_id) as obj_under_analysis, @object_id as object_id
			END

		SELECT 'Objects_left_to_be_analysed' as status
			, t1.id
			, t1.name as table_name
			, count(t2.indid) as indexes_per_table
			, max(t2.rows) as rows
		FROM sysobjects t1
			INNER JOIN sysindexes t2
				ON t1.id = t2.id
		where t1.id > @object_id
		and type = 'u'
		and t2.rows > 0
		GROUP BY t1.id, t1.name
	END
--sp_spaceused R2Go_journey

-- probably next R2Go_journey_speed_zone_with_filter

-- DBCC PAGE (6,1,58214712)  WITH TABLERESULTS
-- R2Go_journey
-- SELECT * FROM sysprocesses
-- SELECT * FROM sysindexes 
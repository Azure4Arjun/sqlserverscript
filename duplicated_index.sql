--
--SELECT distinct IndexName, tblname 
--FROM (
SELECT x1.TableName as tblname
    , x1.IndexName as t1_index_name
    , x2.IndexName 
    , x1.ColumnName
FROM 
(
SELECT 
     TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name --,
     --ind.*,
     --ic.*,
     --col.* 
FROM 
     sys.indexes ind 
INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id 
WHERE 
     ind.is_primary_key = 0 
     AND ind.is_unique = 0 
     AND ind.is_unique_constraint = 0 
     AND t.is_ms_shipped = 0 
--ORDER BY 
--     t.name, ind.name, ind.index_id, ic.index_column_id 
     )  x1 

    INNER JOIN (
SELECT 
     TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name --,
     --ind.*,
     --ic.*,
     --col.* 
FROM 
     sys.indexes ind 
INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id 
WHERE 
     ind.is_primary_key = 0 
     AND ind.is_unique = 0 
     AND ind.is_unique_constraint = 0 
     AND t.is_ms_shipped = 0 
--ORDER BY 
--     t.name, ind.name, ind.index_id, ic.index_column_id 
     ) x2
     ON x1.TableName = x2.TableName
     AND x1.IndexName <> x2.IndexName
     AND x1.ColumnName = x2.ColumnName 
--     ) t1

------------------------
------------------------
------------------------
------------------------
-- Index Keys
------------------------
------------------------
------------------------
------------------------

;WITH CTE AS ( 
           SELECT      ic.[index_id] + ic.[object_id] AS [IndexId],t.[name] AS [TableName] 
                       ,i.[name] AS [IndexName],c.[name] AS [ColumnName],i.[type_desc] 
                       ,i.[is_primary_key],i.[is_unique] 
                       ,ic.index_column_id
           FROM  [sys].[indexes] i 
           INNER JOIN [sys].[index_columns] ic 
                   ON  i.[index_id]    =   ic.[index_id] 
                   AND i.[object_id]   =   ic.[object_id] 
           INNER JOIN [sys].[columns] c 
                   ON  ic.[column_id]  =   c.[column_id] 
                   AND i.[object_id]   =   c.[object_id] 
           INNER JOIN [sys].[tables] t 
                   ON  i.[object_id] = t.[object_id] 
) 
SELECT c.[TableName],c.[IndexName],c.[type_desc],c.[is_primary_key],c.[is_unique] 
       ,STUFF( ( SELECT ','+ a.[ColumnName] FROM CTE a WHERE c.[IndexId] = a.[IndexId] ORDER BY index_column_id FOR XML PATH('')),1 ,1, '') AS [Columns]  --could get rid of the order, and all columns would be sorted by name
FROM   CTE c 
GROUP  BY c.[IndexId],c.[TableName],c.[IndexName],c.[type_desc],c.[is_primary_key],c.[is_unique] 
ORDER  BY c.[TableName] ASC,c.[is_primary_key] DESC; 

------------------------
------------------------
------------------------
------------------------
------------------------
------------------------
---- Indexes same table with duplicated columns
------------------------
------------------------
------------------------
------------------------
------------------------
------------------------

;WITH CTE AS ( 
           SELECT      ic.[index_id] + ic.[object_id] AS [IndexId],t.[name] AS [TableName] 
                       ,i.[name] AS [IndexName],c.[name] AS [ColumnName],i.[type_desc] 
                       ,i.[is_primary_key],i.[is_unique] 
                       ,ic.index_column_id
           FROM  [sys].[indexes] i 
           INNER JOIN [sys].[index_columns] ic 
                   ON  i.[index_id]    =   ic.[index_id] 
                   AND i.[object_id]   =   ic.[object_id] 
           INNER JOIN [sys].[columns] c 
                   ON  ic.[column_id]  =   c.[column_id] 
                   AND i.[object_id]   =   c.[object_id] 
           INNER JOIN [sys].[tables] t 
                   ON  i.[object_id] = t.[object_id] 
) 
, cte2 AS (
SELECT distinct IndexName, tblname 
FROM (
SELECT x1.TableName as tblname
    , x1.IndexName as t1_index_name
    , x2.IndexName 
    , x1.ColumnName
FROM 
(
SELECT 
     TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name --,
     --ind.*,
     --ic.*,
     --col.* 
FROM 
     sys.indexes ind 
INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id 
WHERE 
     ind.is_primary_key = 0 
     AND ind.is_unique = 0 
     AND ind.is_unique_constraint = 0 
     AND t.is_ms_shipped = 0 
--ORDER BY 
--     t.name, ind.name, ind.index_id, ic.index_column_id 
     )  x1 

    INNER JOIN (
SELECT 
     TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name --,
     --ind.*,
     --ic.*,
     --col.* 
FROM 
     sys.indexes ind 
INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id 
WHERE 
     ind.is_primary_key = 0 
     AND ind.is_unique = 0 
     AND ind.is_unique_constraint = 0 
     AND t.is_ms_shipped = 0 
         ) x2
     ON x1.TableName = x2.TableName
     AND x1.IndexName <> x2.IndexName
     AND x1.ColumnName = x2.ColumnName 
    ) t1
                 )  

SELECT c.[TableName]
      ,c.[IndexName]--, c.[type_desc],c.[is_primary_key],c.[is_unique] 
      ,STUFF( ( SELECT ','+ a.[ColumnName] FROM CTE a WHERE c.[IndexId] = a.[IndexId] ORDER BY index_column_id FOR XML PATH('')),1 ,1, '') AS [Columns] 
FROM   CTE c 
  INNER JOIN cte2 c2
    ON c.IndexName = c2.IndexName
GROUP  BY c.[IndexId],c.[TableName],c.[IndexName],c.[type_desc],c.[is_primary_key],c.[is_unique] 
ORDER  BY c.[TableName] ASC,c.[is_primary_key] DESC; 

------------------------
------------------------
------------------------
------------------------
------------------------
------------------------
-------- index used, keys, duplicated
------------------------
------------------------
------------------------
------------------------
------------------------

;WITH CTE AS ( 
           SELECT      ic.[index_id] + ic.[object_id] AS [IndexId],t.[name] AS [TableName] 
                       ,i.[name] AS [IndexName],c.[name] AS [ColumnName],i.[type_desc] 
                       ,i.[is_primary_key],i.[is_unique] 
                       ,ic.index_column_id

           FROM  [sys].[indexes] i 
           INNER JOIN [sys].[index_columns] ic 
                   ON  i.[index_id]    =   ic.[index_id] 
                   AND i.[object_id]   =   ic.[object_id] 
           INNER JOIN [sys].[columns] c 
                   ON  ic.[column_id]  =   c.[column_id] 
                   AND i.[object_id]   =   c.[object_id] 
           INNER JOIN [sys].[tables] t 
                   ON  i.[object_id] = t.[object_id] 
) 
, cte2 AS (
SELECT distinct IndexName, tblname 
FROM (
SELECT x1.TableName as tblname
    , x1.IndexName as t1_index_name
    , x2.IndexName 
    , x1.ColumnName
FROM 
(
SELECT 
     TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name --,
     --ind.*,
     --ic.*,
     --col.* 
FROM 
     sys.indexes ind 
INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id 
WHERE 
     ind.is_primary_key = 0 
     AND ind.is_unique = 0 
     AND ind.is_unique_constraint = 0 
     AND t.is_ms_shipped = 0 
--ORDER BY 
--     t.name, ind.name, ind.index_id, ic.index_column_id 
     )  x1 

    INNER JOIN (
SELECT 
     TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name --,
     --ind.*,
     --ic.*,
     --col.* 
FROM 
     sys.indexes ind 
INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id 
WHERE 
     ind.is_primary_key = 0 
     AND ind.is_unique = 0 
     AND ind.is_unique_constraint = 0 
     AND t.is_ms_shipped = 0 
         ) x2
     ON x1.TableName = x2.TableName
     AND x1.IndexName <> x2.IndexName
     AND x1.ColumnName = x2.ColumnName 
    ) t1
                 )  
, cte3 as 
(

    SELECT     	'USE ' + DB_NAME(database_id) + CHAR(10) + 
				'GO' +	CHAR(10) +
    			'DROP INDEX ' + QUOTENAME(i.name) 
    		+ ' ON ' + QUOTENAME(c.name) 
    		+ '.' + QUOTENAME(OBJECT_NAME(s.object_id)) + CHAR(10) + 
				'GO' +	CHAR(10)
    		AS 'DropSQL',
		DB_NAME(s.database_id) as [database],
		'['+ c.name + '].[' + o.name + ']' AS TableName,
    	i.name AS IndexName,
    	(
    		SELECT SUM(ps.[used_page_count]) * 8 
    		FROM sys.dm_db_partition_stats ps 
    		where ps.[object_id] = i.[object_id] AND ps.[index_id] = i.[index_id] 
		)   as Index_size,
    	s.user_scans as u_scans,
    	s.user_seeks as u_seeks,
    	s.user_lookups as u_lookups,
    	s.user_updates as u_updates,
    	s.last_user_scan as last_scan,
    	s.last_user_seek as last_seek,
    	s.last_user_update as last_update,
    	(
    		SELECT SUM(p.rows) 
    		FROM sys.partitions p 
    		WHERE p.index_id = s.index_id 
    			AND s.object_id = p.object_id
    	) AS TotalRows,
    	i.index_id AS IndexID,   
    	user_seeks + user_scans + user_lookups AS Reads,
    	user_updates AS Writes

    	/*CASE
    		WHEN s.user_updates < 1 THEN 100
    		ELSE 1.00 * (s.user_seeks + s.user_scans + s.user_lookups) 
    			/ s.user_updates
    	END AS ReadsPerWrite,*/
    FROM sys.dm_db_index_usage_stats s  
    INNER JOIN sys.indexes i ON i.index_id = s.index_id 
			AND s.object_id = i.object_id   
    INNER JOIN sys.objects o on s.object_id = o.object_id
    INNER JOIN sys.schemas c on o.schema_id = c.schema_id
  --  WHERE i.is_primary_key = 0
  --  	AND s.database_id = DB_ID()   
  --  	AND i.type_desc = 'nonclustered'
  --  	AND OBJECTPROPERTY(s.object_id,'IsUserTable') = 1
  --  	AND i.is_unique_constraint = 0
		--AND 
		--(
  --  	SELECT SUM(p.rows) 
  --  	FROM sys.partitions p 
  --  	WHERE p.index_id = s.index_id 
  --  		AND s.object_id = p.object_id
		--) > 10000
)

SELECT c.[TableName]
      ,c.[IndexName]--, c.[type_desc],c.[is_primary_key],c.[is_unique] 
      ,STUFF( ( SELECT ','+ a.[ColumnName] FROM CTE a WHERE c.[IndexId] = a.[IndexId] FOR XML PATH('')),1 ,1, '') AS [Columns] --ORDER BY index_column_id FOR XML PATH('')),1 ,1, '') AS [Columns] 
      , c3.u_scans
      , c3.u_seeks
      , c3.u_updates
      , MAX(c4.rows) rows
      , c3.last_scan
      , c3.last_seek
      , c3.last_update
    
FROM   CTE c 
  INNER JOIN cte2 c2
    ON c.IndexName = c2.IndexName
  INNER JOIN cte3 c3
    ON c2.IndexName = c3.IndexName
  INNER JOIN sys.sysindexes c4
    ON c.TableName = object_name(c4.id)
GROUP  BY c.[IndexId]
    ,c.[TableName]
    ,c.[IndexName]
    ,c.[type_desc]
    ,c.[is_primary_key]
    ,c.[is_unique] 
--    , c4.rows
    , c3.u_scans
    , c3.u_seeks
    , c3.u_updates
    , c3.last_scan
    , c3.last_seek
    , c3.last_update
ORDER  BY c.[TableName] ASC,c.[is_primary_key] DESC; 
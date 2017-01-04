http://blog.sqlauthority.com/2015/01/17/sql-server-watching-table-variable-data-in-tempdb/

http://sqlblog.com/blogs/paul_white/archive/2010/08/14/viewing-another-session-s-temporary-table.aspx?CommentPosted=true#commentmessage


http://translate.google.com.br/translate?hl=pt-BR&sl=pt&tl=en&u=http%3A%2F%2Ffabianosqlserver.spaces.live.com%2Fblog%2Fcns!52EFF7477E74CAA6!1898.entry&anno=2&sandbox=1

SELECT  T.name,
        T.[object_id],
        AU.type_desc,
--		pa.allocated_page_page_id,
        AU.first_page,
        AU.data_pages,
        P.[rows]
FROM    tempdb.sys.tables T
JOIN    tempdb.sys.partitions P
        ON  P.[object_id] = T.[object_id]
JOIN    tempdb.sys.system_internals_allocation_units AU
        ON  (AU.type_desc = N'IN_ROW_DATA' AND AU.container_id = P.partition_id)
        OR  (AU.type_desc = N'ROW_OVERFLOW_DATA' AND AU.container_id = P.partition_id)
        OR  (AU.type_desc = N'LOB_DATA' AND AU.container_id = P.hobt_id)
--CROSS APPLY tempdb.sys.dm_db_database_page_allocations(2, t.object_id , 1, NULL, 'DETAILED') pa
--WHERE name = '#test_______________________________________________________________________________________________________________000000000372'


DBCC TRACEON(3604)

--take output first_page, the first eight bytes inverted in group of two give us hexa first page, change to decimal, paste below	
DBCC PAGE (tempdb, 1, 89756, 3) WITH TABLERESULTS;


SELECT * 
FROM tempdb.sys.dm_db_database_page_allocations(2, NULL , 1, NULL, 'DETAILED') pa
WHERE object_id = -1206041854
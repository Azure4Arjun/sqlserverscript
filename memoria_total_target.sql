select counter_name ,cntr_value,cast((cntr_value/1024.0)/1024.0 as numeric(8,2)) as Gb
from sys.dm_os_performance_counters
where counter_name like '%server_memory%'

SELECT (committed_kb/1024) as  bpool_committed
    , (committed_target_kb/1024) as  bpool_commit_target
FROM  sys.dm_os_sys_info


http://www.fabriciolima.net/blog/2010/12/25/casos-do-dia-a-dia-diminuindo-um-problema-de-memoria-no-sql-server/

http://jamessql.blogspot.ie/2012/04/clean-sql-server-cache.html

https://www.mssqltips.com/sqlservertip/2393/determine-sql-server-memory-use-by-database-and-object/
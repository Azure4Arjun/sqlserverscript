--TROUBLESHOOTING MEMORY SQL

----------------------------------------------------
--- Total / Target
----------------------------------------------------

select counter_name ,cntr_value,cast((cntr_value/1024.0)/1024.0 as numeric(8,2)) as Gb
from sys.dm_os_performance_counters
where counter_name like '%server_memory%'
-- confirm
SELECT (physical_memory_in_use_kb/1024.00)/1024.00 AS [PhysicalMemInUseGB]
FROM sys.dm_os_process_memory;
GO

----------------------------------------------------
--- How memory is being used
----------------------------------------------------

SELECT TOP (20) * FROM sys.dm_os_memory_clerks ORDER BY pages_kb DESC

--dig into the next, to be sure

SELECT counter_name, instance_name, mb = cntr_value/1024.0
  FROM sys.dm_os_performance_counters 
  WHERE counter_name LIKE '%Memory%'
  AND counter_name NOT LIKE 'XT%'
  ORDER BY cntr_value/1024.0 desc

----------------------------------------------------
--- Memory not in buffer pool
----------------------------------------------------

SELECT counter_name, instance_name, mb = cntr_value/1024.0
  FROM sys.dm_os_performance_counters 
  --WHERE counter_name LIKE '%cache%'
  WHERE (counter_name = N'Cursor memory usage' and instance_name <> N'_Total')
  OR (instance_name = N'' AND counter_name IN 
       (N'Connection Memory (KB)', N'Granted Workspace Memory (KB)', 
        N'Lock Memory (KB)', N'Optimizer Memory (KB)', N'Stolen Server Memory (KB)', 
        N'Log Pool Memory (KB)', N'Free Memory (KB)')
  ) ORDER BY mb DESC;

----------------------------------------------------
--- Memory used by cached plans
----------------------------------------------------

select objtype, 
count(*) as number_of_plans, 
sum(cast(size_in_bytes as bigint))/1024/1024 as size_in_MBs,
avg(usecounts) as avg_use_count
from sys.dm_exec_cached_plans
group by objtype
ORDER BY sum(cast(size_in_bytes as bigint))/1024/1024 desc

----------------------------------------------------
--- Size each Database is using on buffer
----------------------------------------------------

DECLARE @total_buffer INT;

SELECT @total_buffer = cntr_value
FROM sys.dm_os_performance_counters 
WHERE RTRIM([object_name]) LIKE '%Buffer Manager'
AND counter_name = 'Database Pages';

;WITH src AS
(
SELECT 
database_id, db_buffer_pages = COUNT_BIG(*)
FROM sys.dm_os_buffer_descriptors
--WHERE database_id BETWEEN 5 AND 32766
GROUP BY database_id
)
SELECT
[db_name] = CASE [database_id] WHEN 32767 
THEN 'Resource DB' 
ELSE DB_NAME([database_id]) END,
db_buffer_pages,
db_buffer_MB = db_buffer_pages / 128,
db_buffer_percent = CONVERT(DECIMAL(6,3), 
db_buffer_pages * 100.0 / @total_buffer)
FROM src
ORDER BY db_buffer_MB DESC;


----------------------------------------------------
--- Each object(tables) is using on buffer
----------------------------------------------------
-- WARNING --

;WITH src AS
(
    SELECT
    [Object] = o.name,
    [Type] = o.type_desc,
    [Index] = COALESCE(i.name, ''),
    [Index_Type] = i.type_desc,
    p.[object_id],
    p.index_id,
    au.allocation_unit_id
    FROM sys.partitions AS p
      INNER JOIN  sys.allocation_units AS au
        ON p.hobt_id = au.container_id
      INNER JOIN sys.objects AS o
        ON p.[object_id] = o.[object_id]
      INNER JOIN sys.indexes AS i
        ON o.[object_id] = i.[object_id]
        AND p.index_id = i.index_id
    WHERE
    au.[type] IN (1,2,3)
    AND o.is_ms_shipped = 0
    )

    SELECT
    src.[Object],
    src.[Type],
    src.[Index],
    src.Index_Type,
    buffer_pages = COUNT_BIG(b.page_id),
    buffer_mb = COUNT_BIG(b.page_id) / 128
    FROM     src
      INNER JOIN sys.dm_os_buffer_descriptors AS b
        ON src.allocation_unit_id = b.allocation_unit_id
    WHERE b.database_id = DB_ID()
    GROUP BY
    src.[Object],
    src.[Type],
    src.[Index],
    src.Index_Type
    ORDER BY buffer_pages DESC---

----------------------------------------------------
--- 15 object are most used on CACHE
----------------------------------------------------
-- WARNING --
SELECT   TOP 15      c.text AS sql_text
,         d.query_plan
,         a.memory_object_address AS CompiledPlan_MemoryObject
,         b.pages_in_bytes
,         b.type
,         b.page_size_in_bytes  
FROM sys.dm_exec_cached_plans a   
  INNER JOIN sys.dm_os_memory_objects b       
    ON a.memory_object_address = b.memory_object_address       
    OR a.memory_object_address = b.parent_address  
  CROSS APPLY sys.dm_exec_sql_text (plan_handle) c  
  CROSS APPLY sys.dm_exec_query_plan(plan_handle) d  
  WHERE cacheobjtype = 'Compiled Plan'
  ORDER BY pages_in_bytes DESC
  

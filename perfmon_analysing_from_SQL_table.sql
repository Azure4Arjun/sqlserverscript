SELECT
OBJECT_NAME(i.OBJECT_ID) AS TableName,
i.name AS IndexName,
i.index_id AS IndexID,
8 * SUM(a.used_pages) AS 'Indexsize(KB)'
FROM sys.indexes AS i
JOIN sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id
JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
GROUP BY i.OBJECT_ID,i.index_id,i.name
ORDER BY 4 desc
--ORDER BY OBJECT_NAME(i.OBJECT_ID),i.index_id




--SELECT * FROM celtrak_data.dbo.user_application
--WHERE user_rid = 70407

--SELECT * FROM celtrak_data.dbo.geo_fence WHERE rid = 7434

--=7434, 7433, 7382, 7436, 7381, 7435, 7438, 7437, 7440, 7439, 7426, 7425, 7428, 7427, 7430, 7429, 7432, 7431, 7569, 7574, 7442, 7403, 7402, 7540, 7418, 7544, 7543, 7542, 7541, 7548, 7547, 7412, 7546, 7409, 7545,	-8.0	0	NULL	70407

--SELECT * FROM celtrak_data.dbo.tk_customer WHERE rid = 61992

--SELECT * FROM performance_counters_history WHERE counter_name = 'Buffer cache hit ratio'

      WITH full_scans 
      AS
      (

      SELECT 
          t1.object_name
          , t1.counter_name
          , t1.instance_name
          , t1.date_stamp
          , (t1.cntr_value - t2.cntr_value) as reads_this_minute
          , (t1.cntr_value - t2.cntr_value)/60 as avg_per_sec
      FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 392
      WHERE (
          t1.counter_name = 'Full Scans/sec'
        )
      AND t1.object_name = 'MSSQL$SQLU9:Access Methods'
      AND t1.date_stamp > DATEADD(minute, -10000, GETDATE())

      )
      , work_tables_created
      AS
      (

      SELECT 
          t1.object_name
          , t1.counter_name
          , t1.instance_name
          , t1.date_stamp
          , (t1.cntr_value - t2.cntr_value) as writes_this_minute
          , (t1.cntr_value - t2.cntr_value)/60 as avg_per_sec
      FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 392
      WHERE (
          t1.counter_name = 'Worktables Created/sec'
        )
      AND t1.object_name = 'MSSQL$SQLU9:Access Methods'
      AND t1.date_stamp > DATEADD(minute, -10000, GETDATE())
      )
      , batch_request 
      AS
      (

      SELECT 
          t1.object_name
          , t1.counter_name
          , t1.instance_name
          , t1.date_stamp
          , (t1.cntr_value - t2.cntr_value) as batch_request_minute
          , (t1.cntr_value - t2.cntr_value)/60 as avg_per_sec
    FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 392
      WHERE (
  
        t1.counter_name = 'Batch Requests/sec'
        )
      AND t1.object_name = 'MSSQL$SQLU9:SQL Statistics'
      AND t1.date_stamp > DATEADD(minute, -10000, GETDATE())
      )
      , transactions as
        ( 
          SELECT 
          t1.object_name
          , t1.counter_name
          , t1.instance_name
          , t1.date_stamp
          , (t1.cntr_value + t2.cntr_value)/2 as cntr_value
      FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 392
      WHERE (
  
        t1.counter_name = 'Transactions'
        )
      AND t1.object_name = 'MSSQL$SQLU9:General Statistics'
      AND t1.date_stamp > DATEADD(minute, -10000, GETDATE())
      )
      , page_life_expectancy as
        ( 
          SELECT 
          t1.object_name
          , t1.counter_name
          , t1.instance_name
          , t1.date_stamp
          , (t1.cntr_value + t2.cntr_value)/2 as cntr_value
      FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 392
      WHERE (
  
        t1.counter_name = 'Page life expectancy'
        )
      AND t1.object_name = 'MSSQL$SQLU9:Buffer Manager'
      AND t1.date_stamp > DATEADD(minute, -10000, GETDATE())
      )
      , buffer_cache_hit_ratio as
        ( 
          SELECT 
          t1.object_name
          , t1.counter_name
          , t1.instance_name
          , t1.date_stamp
          , (t1.cntr_value + t2.cntr_value)/2 as cntr_value
      FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 392
      WHERE (
  
        t1.counter_name = 'Buffer cache hit ratio'
        )
      AND t1.object_name = 'MSSQL$SQLU9:Buffer Manager'
      AND t1.date_stamp > DATEADD(minute, -10000, GETDATE())
      )
      , free_list_stall_sec as
        ( 
          SELECT 
          t1.object_name
          , t1.counter_name
          , t1.instance_name
          , t1.date_stamp
          , (t1.cntr_value + t2.cntr_value) as cntr_value
          , (t1.cntr_value - t2.cntr_value)/60 as avg_per_sec
      FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 392
      WHERE (
  
        t1.counter_name = 'Free list stalls/sec'
        )
      AND t1.object_name = 'MSSQL$SQLU9:Buffer Manager'
      AND t1.date_stamp > DATEADD(minute, -10000, GETDATE())
      )
       , page_reads_sec
      AS
      (

      SELECT 
          t1.object_name
          , t1.counter_name
          , t1.instance_name
          , t1.date_stamp
          , (t1.cntr_value - t2.cntr_value) as reads_this_minute
          , (t1.cntr_value - t2.cntr_value)/60 as avg_per_sec
      FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 392
      WHERE (
          t1.counter_name = 'Page reads/sec'
        )
      AND t1.object_name = 'MSSQL$SQLU9:Buffer Manager'
      AND t1.date_stamp > DATEADD(minute, -10000, GETDATE())
      )
            , page_writes_sec
      AS
      (

      SELECT 
          t1.object_name
          , t1.counter_name
          , t1.instance_name
          , t1.date_stamp
          , (t1.cntr_value - t2.cntr_value) as writes_this_minute
          , (t1.cntr_value - t2.cntr_value)/60 as avg_per_sec
      FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 392
      WHERE (
          t1.counter_name = 'Page writes/sec'
        )
      AND t1.object_name = 'MSSQL$SQLU9:Buffer Manager'
      AND t1.date_stamp > DATEADD(minute, -10000, GETDATE())
      )
                  , Lazy_Writes_Sec
      AS
      (

      SELECT 
          t1.object_name
          , t1.counter_name
          , t1.instance_name
          , t1.date_stamp
          , (t1.cntr_value - t2.cntr_value) as Lazy_Writes_Sec_this_minute
          , (t1.cntr_value - t2.cntr_value)/60 as avg_per_sec
      FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 392
      WHERE (
          t1.counter_name = 'Lazy Writes/Sec'
        )
      AND t1.object_name = 'MSSQL$SQLU9:Buffer Manager'
      AND t1.date_stamp > DATEADD(minute, -10000, GETDATE())
      )
                  , checkpoint_pages_sec
      AS
      (

      SELECT 
          t1.object_name
          , t1.counter_name
          , t1.instance_name
          , t1.date_stamp
          , (t1.cntr_value - t2.cntr_value) as checkpoint_pages_sec_this_minute
          , (t1.cntr_value - t2.cntr_value)/60 as avg_per_sec
      FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 392
      WHERE (
          t1.counter_name = 'Checkpoint Pages/sec'
        )
      AND t1.object_name = 'MSSQL$SQLU9:Buffer Manager'
      AND t1.date_stamp > DATEADD(minute, -10000, GETDATE())
      )

                       , page_lookups_sec
      AS
      (

      SELECT 
          t1.object_name
          , t1.counter_name
          , t1.instance_name
          , t1.date_stamp
          , (t1.cntr_value - t2.cntr_value) as checkpoint_pages_sec_this_minute
          , (t1.cntr_value - t2.cntr_value)/60 as avg_per_sec
      FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 392
      WHERE (
          t1.counter_name = 'Page lookups/sec'
        )
      AND t1.object_name = 'MSSQL$SQLU9:Buffer Manager'
      AND t1.date_stamp > DATEADD(minute, -10000, GETDATE())
      )

                       , readahead_pages_sec
      AS
      (

      SELECT 
          t1.object_name
          , t1.counter_name
          , t1.instance_name
          , t1.date_stamp
          , (t1.cntr_value - t2.cntr_value) as checkpoint_pages_sec_this_minute
          , (t1.cntr_value - t2.cntr_value)/60 as avg_per_sec
      FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 392
      WHERE (
          t1.counter_name = 'Readahead pages/sec'
        )
      AND t1.object_name = 'MSSQL$SQLU9:Buffer Manager'
      AND t1.date_stamp > DATEADD(minute, -10000, GETDATE())
      )
      , cte as
      (
      SELECT 
         t1.date_stamp
       --, t1.reads_this_minute
       , t8.avg_per_sec AS page_reads_sec
       , t9.avg_per_sec AS page_writes_sec
       , t10.avg_per_sec AS Lazy_Writes_Sec
       , t1.avg_per_sec as full_scans_per_sec
       , t2.writes_this_minute
       , t2.avg_per_sec as work_tables_created_per_sec
       , t3.avg_per_sec as batch_request
       , t4.cntr_value as transactions
       , t5.cntr_value as page_life_expect
       , t6.cntr_value as buffer_cache_hit_ratio
       , t7.avg_per_sec AS free_list_stall_sec
       , t12.avg_per_sec as page_lookups_sec
       , t13.avg_per_sec as readahead_pages_sec
       , t11.avg_per_sec AS checkpoint_pages_sec
      FROM full_scans t1
        INNER JOIN work_tables_created t2
          ON t1.date_stamp = t2.date_stamp
        INNER JOIN batch_request t3
          ON t1.date_stamp = t3.date_stamp
        INNER JOIN transactions t4
          ON t4.date_stamp = t3.date_stamp
        INNER JOIN page_life_expectancy t5
          ON t5.date_stamp = t3.date_stamp
        INNER JOIN buffer_cache_hit_ratio t6
          ON t6.date_stamp = t3.date_stamp
        INNER JOIN free_list_stall_sec t7
          ON t7.date_stamp = t3.date_stamp
        INNER JOIN page_reads_sec t8
          ON t8.date_stamp = t3.date_stamp
        INNER JOIN page_writes_sec t9
          ON t9.date_stamp = t3.date_stamp
        INNER JOIN Lazy_Writes_Sec t10
          ON t10.date_stamp = t3.date_stamp
        INNER JOIN checkpoint_pages_sec t11
          ON t11.date_stamp = t3.date_stamp
        INNER JOIN page_lookups_sec t12
          ON t12.date_stamp = t3.date_stamp
        INNER JOIN readahead_pages_sec t13
          ON t13.date_stamp = t3.date_stamp
      )

      SELECT * FROM cte
      ORDER BY 1 DESC


      --SELECT TOP 100 * FROM performance.dbo.growth_database WHERE dbname = 'TKReporting' ORDER BY created DESC
      --EXEC spr_get_space tkreporting
      --dbcc inputbuffer(86)

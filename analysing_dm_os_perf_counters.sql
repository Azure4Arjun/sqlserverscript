SELECT t1.object_name
    , t1.counter_name
    , t1.instance_name
    , t1.date_stamp
    , t1.cntr_value
    , t2.cntr_value
    , t1.cntr_value - t2.cntr_value last_minute_value
FROM performance_counters_history t1 WITH (NOLOCK)
  INNER JOIN performance_counters_history t2 WITH (NOLOCK)
    ON t1.rid = t2.rid + 1770
WHERE (
    t1.counter_name = 'Page Reads/sec'
 --   OR t1.counter_name = 'Index Searches/sec'
  )
AND t1.instance_name <> '_Total'
--AND t1.object_name = 'MSSQL$SQLU9:Buffer Manager'
AND t1.date_stamp > '2016-01-24 15:00'
AND t1.date_stamp < '2016-01-25 10:00'
--ORDER BY t1.cntr_value DESC
--ORDER BY last_minute_value DESC
order by t1.rid

---------------------

--GROUPing by Minute


SELECT t1.object_name
    ,DATEPART(minute, t1.date_stamp)
    , AVG(t1.cntr_value - t2.cntr_value) last_minute_value -- ) as last_minute_value
FROM performance_counters_history_220116 t1 WITH (NOLOCK)
  INNER JOIN performance_counters_history_220116 t2 WITH (NOLOCK)
    ON t1.rid = t2.rid + 1770
WHERE t1.counter_name LIKE 'Page Reads/sec'
--OR t1.counter_name = 'Batch Requests/sec'
--AND t1.instance_name = '_Total'
AND t1.date_stamp > '2016-01-24 15:00'
AND t1.date_stamp < '2016-01-25 10:00'
GROUP BY t1.object_name
, DATEPART(minute, t1.date_stamp)
order by last_minute_value DESC
--DATEPART(minute, t1.date_stamp)


-------
---- more counters
------


      SELECT TOP 100000
          --t1.object_name
           t1.counter_name
         -- , t1.instance_name
          , t1.date_stamp
          , t1.cntr_value
          --, (t1.cntr_value - t2.cntr_value) as reads_this_minute
          --, (t1.cntr_value - t2.cntr_value)/60 as avg_per_sec
      FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 402
      WHERE (
          --t1.counter_name = 'Page Reads/sec'
          t1.object_name = 'MSSQL$SQLU9:Wait Statistics'
        )
      --AND t1.object_name = 'MSSQL$SQLU9:Buffer Manager'
      AND t1.date_stamp > DATEADD(minute, -1400, GETDATE())
      AND t1.cntr_value <> 0
      ORDER BY t1.rid DESC


      go

      
      SELECT TOP 100000
          --t1.object_name
           t1.counter_name
         -- , t1.instance_name
          , t1.date_stamp
          --, t1.cntr_value
          , (t1.cntr_value - t2.cntr_value) as transactions
          --, (t1.cntr_value - t2.cntr_value)/60 as avg_per_sec
      FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 402
      WHERE (
          t1.counter_name = 'Batch Requests/sec'
          --t1.object_name = 'MSSQL$SQLU9:Wait Statistics'
        )
      
      AND t1.date_stamp > DATEADD(minute, -11400, GETDATE())
      AND t1.cntr_value <> 0
      ORDER BY t1.rid DESC

      go

            SELECT TOP 100000
          --t1.object_name
           t1.counter_name
         , t1.instance_name
          , t1.date_stamp
          --, t1.cntr_value
          , (t1.cntr_value - t2.cntr_value) as reads_this_minute
          --, (t1.cntr_value - t2.cntr_value)/60 as avg_per_sec
      FROM performance_counters_history t1 WITH (NOLOCK)
        INNER JOIN performance_counters_history t2 WITH (NOLOCK)
          ON t1.rid = t2.rid + 402
      WHERE (
          t1.counter_name = 'Transactions/sec'
          --t1.object_name = 'MSSQL$SQLU9:Wait Statistics'
        )
      --AND t1.instance_name = '_Total'
      AND t1.date_stamp > DATEADD(minute, -1400, GETDATE())
      AND (t1.cntr_value - t2.cntr_value) <> 0
      ORDER BY t1.rid DESC
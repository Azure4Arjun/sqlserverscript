
WHILE (getdate() < '2015-06-18 17:01:16.470')
BEGIN
WAITFOR DELAY '00:00:01'

  INSERT INTO trans_per_second_drop_later3
  select getdate() as Date, *
  FROM  sys.dm_os_performance_counters
   WHERE counter_name = 'transactions/sec'

END



SELECT instance_name
    , max(cntr_value) as last
    , min(cntr_value) as first
    , count(cntr_value) as ocurrency
    , (max(cntr_value) - min(cntr_value)) / count(cntr_value) as transaction_per_second
    , max(cntr_value) - min(cntr_value)
FROM trans_per_second_drop_later3 with (nolock)
GROUP BY instance_name
ORDER BY instance_name
SELECT report_name
, CONVERT(datetime, report_second) as created
, total
FROM (
    SELECT 
		  report_name,
          CONVERT(VARCHAR, DATEPART(YEAR, created))  + '-' +
          CONVERT(VARCHAR, DATEPART(MONTH, created))  + '-' +
          CONVERT(VARCHAR, DATEPART(DAY, created))  + ' ' +
          CONVERT(VARCHAR, DATEPART(HOUR, created)) + ':' +
		  CONVERT(VARCHAR, DATEPART(minute, created)) + ':' +
		  CONVERT(VARCHAR, DATEPART(second, created)) as report_second,
--
--          CASE WHEN CONVERT(VARCHAR,(DATEPART(MINUTE, created) / 30)) = 0 THEN '00'
--               WHEN CONVERT(VARCHAR,(DATEPART(MINUTE, created) / 30)) = 1 THEN '30'
--               END hour,
          count(1) total
		FROM celtrak_data..report_execution_audit
		WHERE created >= '2015-09-11 15:54'
		AND created <= '2015-09-11 16:54'
    GROUP BY
		report_name,
          DATEPART(YEAR, created),
          DATEPART(MONTH, created),
          DATEPART(DAY, created),
          DATEPART(HOUR, created),
		  DATEPART(minute, created),
		  DATEPART(second, created)
) t1
ORDER BY created


--WHERE DATEPART(hour,hour) BETWEEN 9 AND 17
--ORDER BY created

-- PER MINUTE


SELECT 
 CONVERT(DATETIME, report_minute)
, total
FROM (
    SELECT 
          CONVERT(VARCHAR, DATEPART(YEAR, created))  + '-' +
          CONVERT(VARCHAR, DATEPART(MONTH, created))  + '-' +
          CONVERT(VARCHAR, DATEPART(DAY, created))  + ' ' +
          CONVERT(VARCHAR, DATEPART(HOUR, created)) + ':' +
		  CONVERT(VARCHAR, DATEPART(minute, created)) as report_minute,
--
--          CASE WHEN CONVERT(VARCHAR,(DATEPART(MINUTE, created) / 30)) = 0 THEN '00'
--               WHEN CONVERT(VARCHAR,(DATEPART(MINUTE, created) / 30)) = 1 THEN '30'
--               END hour,
          count(1) total
		FROM celtrak_data..tk_mu_data WITH (NOLOCK)
		WHERE   created > '2016-01-24 15:00'
    AND created < '2016-01-25 10:00'
    GROUP BY
          DATEPART(YEAR, created),
          DATEPART(MONTH, created),
          DATEPART(DAY, created),
          DATEPART(HOUR, created),
		  DATEPART(minute, created)
) t1
ORDER BY CONVERT(DATETIME, report_minute)

-- PER DAY

SELECT CONVERT(datetime, inserts_day) as created
, total
FROM (
    SELECT 
	        CONVERT(VARCHAR, DATEPART(YEAR, created))  + '-' +
          CONVERT(VARCHAR, DATEPART(MONTH, created))  + '-' +
          CONVERT(VARCHAR, DATEPART(DAY, created))  as inserts_day,
--
--          CASE WHEN CONVERT(VARCHAR,(DATEPART(MINUTE, created) / 30)) = 0 THEN '00'
--               WHEN CONVERT(VARCHAR,(DATEPART(MINUTE, created) / 30)) = 1 THEN '30'
--               END hour,
          count(1) total
		FROM celtrak_data..tk_mu_data WITH (NOLOCK)
		WHERE created >= '2016-01-01 15:54'
		AND created <= '2016-09-11 16:54'
    GROUP BY
          DATEPART(YEAR, created),
          DATEPART(MONTH, created),
          DATEPART(DAY, created)

) t1
ORDER BY created


---------------------
--------------------- INCLUDE ALL DATE, EVEN WITH NULL values
---------------------

DECLARE @ld_date_to_sum DATETIME
SET @ld_date_to_sum = '2016-04-15 15:00'
DECLARE @every_hour_table TABLE (date_hour DATETIME )

          WHILE @ld_date_to_sum < GETDATE()
          BEGIN
            INSERT INTO @every_hour_table 
            SELECT @ld_date_to_sum

            SET @ld_date_to_sum = DATEADD(hour, 1, @ld_date_to_sum)

          END

DECLARE @total_table TABLE (date_hour DATETIME, total INT)

INSERT INTO @total_table
SELECT 
 CONVERT(DATETIME, data_hour) as date_hour
, total
FROM (
    SELECT 
          CONVERT(VARCHAR, DATEPART(YEAR, data_date))  + '-' +
          CONVERT(VARCHAR, DATEPART(MONTH, data_date))  + '-' +
          CONVERT(VARCHAR, DATEPART(DAY, data_date))  + ' ' +
          CONVERT(VARCHAR, DATEPART(HOUR, data_date)) + ':00' as data_hour,
--
--          CASE WHEN CONVERT(VARCHAR,(DATEPART(MINUTE, data_date) / 30)) = 0 THEN '00'
--               WHEN CONVERT(VARCHAR,(DATEPART(MINUTE, data_date) / 30)) = 1 THEN '30'
--               END hour,
          count(1) as total
		FROM tk_mu_data WITH (NOLOCK)
		WHERE   data_date > '2016-04-15 15:00'
    GROUP BY
          DATEPART(YEAR, data_date),
          DATEPART(MONTH, data_date),
          DATEPART(DAY, data_date),
          DATEPART(HOUR, data_date)
) t1
--ORDER BY CONVERT(DATETIME, data_hour)


SELECT t1.*, ISNULL(t2.total,0) as messages
FROM @every_hour_table t1
  LEFT JOIN @total_table t2
    ON t1.date_hour = t2.date_hour
ORDER BY t1.date_hour
--ORDER BY 2 desc

--        SELECT * FROM @every_hour_table
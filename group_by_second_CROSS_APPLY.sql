SELECT report_name
, CONVERT(datetime, report_second) as created
, total
FROM (
    SELECT 
		  report_name,
      report_second,
      count(1) total
		FROM report_execution_audit WITH (NOLOCK)
    CROSS APPLY
    ( SELECT
          CONVERT(VARCHAR, DATEPART(YEAR, created))  + '-' +
          CONVERT(VARCHAR, DATEPART(MONTH, created))  + '-' +
          CONVERT(VARCHAR, DATEPART(DAY, created))  + ' ' +
          CONVERT(VARCHAR, DATEPART(HOUR, created)) + ':' +
		  CONVERT(VARCHAR, DATEPART(minute, created)) + ':' +
		  CONVERT(VARCHAR, DATEPART(second, created)) as report_second
--
--          CASE WHEN CONVERT(VARCHAR,(DATEPART(MINUTE, created) / 30)) = 0 THEN '00'
--               WHEN CONVERT(VARCHAR,(DATEPART(MINUTE, created) / 30)) = 1 THEN '30'
--               END hour,
    ) _
		WHERE created >= '2016-03-11 15:54'
		AND created <= '2016-03-11 16:54'
    GROUP BY
    report_name,
		report_second
) t1
ORDER BY created

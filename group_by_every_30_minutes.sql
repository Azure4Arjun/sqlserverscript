SELECT CONVERT(datetime, hour) as created
, total
FROM (
    SELECT 
          CONVERT(VARCHAR, DATEPART(YEAR, created))  + '-' +
          CONVERT(VARCHAR, DATEPART(MONTH, created))  + '-' +
          CONVERT(VARCHAR, DATEPART(DAY, created))  + ' ' +
          CONVERT(VARCHAR, DATEPART(HOUR, created)) + ':' +
          CASE WHEN CONVERT(VARCHAR,(DATEPART(MINUTE, created) / 30)) = 0 THEN '00'
               WHEN CONVERT(VARCHAR,(DATEPART(MINUTE, created) / 30)) = 1 THEN '30'
               END hour,
          count(1) total
    FROM tk_mu_data t1 WITH (NOLOCK)
    WHERE created > DATEADD(dd,-14,getdate())
    GROUP BY 
          DATEPART(YEAR, created),
          DATEPART(MONTH, created),
          DATEPART(DAY, created),
          DATEPART(HOUR, created),
          (DATEPART(MINUTE, created) / 30)) t1
WHERE DATEPART(hour,hour) BETWEEN 9 AND 17
ORDER BY created
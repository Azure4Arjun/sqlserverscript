  AND DATEPART(dw, t2.start_data_date) NOT IN (1, 7)  --exclude Sunday and Saturday
  AND (CONVERT(VARCHAR(8),t2.start_data_date,108) BETWEEN '17:30' AND '23:59:59'   
      OR CONVERT(VARCHAR(8),t2.start_data_date,108) BETWEEN '00:00' AND '06:29:59')
      
-- Hour diff on weekdays only.
      SELECT case_date_created,case_date_closed,
  DATEDIFF(HOUR, case_date_created, case_date_closed)
    - ( DATEDIFF(wk, case_date_created,case_date_closed)*(2*24)
        -- Start on Saturday
        +(CASE WHEN DATEPART(dw, case_date_created) = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
        -- End on Sunday
        -(CASE WHEN DATEPART(dw, case_date_closed)  = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
        -- Start on Saturday
        -(CASE WHEN DATEPART(dw, case_date_created) = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
        -- End on Saturday
        +(CASE WHEN DATEPART(dw, case_date_closed)  = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
  )
  ,DATEDIFF(wk, case_date_created,case_date_closed)*(2*24)
  FROM case_master
  WHERE case_status = 'Closed' 
  AND case_date_created > @ldt_start_date
  AND case_date_created < @ldt_end_date
  	AND DATEDIFF(Day, case_date_created, case_date_closed ) >0

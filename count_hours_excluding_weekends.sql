SELECT timing
  , count(1) as cases FROM 
  (
      SELECT case_date_created,case_date_closed,
      CASE WHEN DATEDIFF(HOUR, case_date_created, case_date_closed) < 24 THEN '<1 day'
           WHEN  DATEDIFF(HOUR, case_date_created, case_date_closed)
          - ( DATEDIFF(wk, case_date_created,case_date_closed)*(2*24)
              +(CASE WHEN DATEPART(dw, case_date_created) = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
              -(CASE WHEN DATEPART(dw, case_date_closed)  = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
              -(CASE WHEN DATEPART(dw, case_date_created) = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
              +(CASE WHEN DATEPART(dw, case_date_closed)  = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
          ) >=24 
          AND
              DATEDIFF(HOUR, case_date_created, case_date_closed)
        - ( DATEDIFF(wk, case_date_created,case_date_closed)*(2*24)
            +(CASE WHEN DATEPART(dw, case_date_created) = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
            -(CASE WHEN DATEPART(dw, case_date_closed)  = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
            -(CASE WHEN DATEPART(dw, case_date_created) = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
            +(CASE WHEN DATEPART(dw, case_date_closed)  = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
          ) < 48  THEN '>1 day <2 days'
           WHEN  DATEDIFF(HOUR, case_date_created, case_date_closed)
          - ( DATEDIFF(wk, case_date_created,case_date_closed)*(2*24)
              +(CASE WHEN DATEPART(dw, case_date_created) = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
              -(CASE WHEN DATEPART(dw, case_date_closed)  = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
              -(CASE WHEN DATEPART(dw, case_date_created) = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
              +(CASE WHEN DATEPART(dw, case_date_closed)  = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
          ) >= 48 
          AND
              DATEDIFF(HOUR, case_date_created, case_date_closed)
        - ( DATEDIFF(wk, case_date_created,case_date_closed)*(2*24)
            +(CASE WHEN DATEPART(dw, case_date_created) = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
            -(CASE WHEN DATEPART(dw, case_date_closed)  = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
            -(CASE WHEN DATEPART(dw, case_date_created) = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
            +(CASE WHEN DATEPART(dw, case_date_closed)  = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
          ) < 72  THEN '>2 days <3 days'
          WHEN  DATEDIFF(HOUR, case_date_created, case_date_closed)
          - ( DATEDIFF(wk, case_date_created,case_date_closed)*(2*24)
              +(CASE WHEN DATEPART(dw, case_date_created) = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
              -(CASE WHEN DATEPART(dw, case_date_closed)  = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
              -(CASE WHEN DATEPART(dw, case_date_created) = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
              +(CASE WHEN DATEPART(dw, case_date_closed)  = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
          ) >=72 
          AND
              DATEDIFF(HOUR, case_date_created, case_date_closed)
        - ( DATEDIFF(wk, case_date_created,case_date_closed)*(2*24)
            +(CASE WHEN DATEPART(dw, case_date_created) = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
            -(CASE WHEN DATEPART(dw, case_date_closed)  = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
            -(CASE WHEN DATEPART(dw, case_date_created) = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
            +(CASE WHEN DATEPART(dw, case_date_closed)  = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
          ) < 120  THEN '>3 days <1 week'
          WHEN  DATEDIFF(HOUR, case_date_created, case_date_closed)
          - ( DATEDIFF(wk, case_date_created,case_date_closed)*(2*24)
              +(CASE WHEN DATEPART(dw, case_date_created) = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
              -(CASE WHEN DATEPART(dw, case_date_closed)  = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
              -(CASE WHEN DATEPART(dw, case_date_created) = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
              +(CASE WHEN DATEPART(dw, case_date_closed)  = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
          ) >=120 
          AND
              DATEDIFF(HOUR, case_date_created, case_date_closed)
        - ( DATEDIFF(wk, case_date_created,case_date_closed)*(2*24)
            +(CASE WHEN DATEPART(dw, case_date_created) = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
            -(CASE WHEN DATEPART(dw, case_date_closed)  = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
            -(CASE WHEN DATEPART(dw, case_date_created) = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
            +(CASE WHEN DATEPART(dw, case_date_closed)  = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
          ) < 240  THEN '>1 week <2 weeks'
          WHEN  DATEDIFF(HOUR, case_date_created, case_date_closed)
          - ( DATEDIFF(wk, case_date_created,case_date_closed)*(2*24)
              +(CASE WHEN DATEPART(dw, case_date_created) = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
              -(CASE WHEN DATEPART(dw, case_date_closed)  = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
              -(CASE WHEN DATEPART(dw, case_date_created) = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
              +(CASE WHEN DATEPART(dw, case_date_closed)  = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
          ) >=240 
          AND
              DATEDIFF(HOUR, case_date_created, case_date_closed)
        - ( DATEDIFF(wk, case_date_created,case_date_closed)*(2*24)
            +(CASE WHEN DATEPART(dw, case_date_created) = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
            -(CASE WHEN DATEPART(dw, case_date_closed)  = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
            -(CASE WHEN DATEPART(dw, case_date_created) = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
            +(CASE WHEN DATEPART(dw, case_date_closed)  = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
          ) < 360 THEN '>2 weeks <3 weeks'
           WHEN  DATEDIFF(HOUR, case_date_created, case_date_closed)
          - ( DATEDIFF(wk, case_date_created,case_date_closed)*(2*24)
              +(CASE WHEN DATEPART(dw, case_date_created) = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
              -(CASE WHEN DATEPART(dw, case_date_closed)  = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
              -(CASE WHEN DATEPART(dw, case_date_created) = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
              +(CASE WHEN DATEPART(dw, case_date_closed)  = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
          ) >= 360 
          AND
              DATEDIFF(HOUR, case_date_created, case_date_closed)
        - ( DATEDIFF(wk, case_date_created,case_date_closed)*(2*24)
            +(CASE WHEN DATEPART(dw, case_date_created) = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
            -(CASE WHEN DATEPART(dw, case_date_closed)  = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
            -(CASE WHEN DATEPART(dw, case_date_created) = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
            +(CASE WHEN DATEPART(dw, case_date_closed)  = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
          ) < 480 THEN '>3 weeks <4 weeks'
           WHEN DATEDIFF(HOUR, case_date_created, case_date_closed)
        - ( DATEDIFF(wk, case_date_created,case_date_closed)*(2*24)
            +(CASE WHEN DATEPART(dw, case_date_created) = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
            -(CASE WHEN DATEPART(dw, case_date_closed)  = 1 THEN 24.0-DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
            -(CASE WHEN DATEPART(dw, case_date_created) = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_created),case_date_created) ELSE 0 END)
            +(CASE WHEN DATEPART(dw, case_date_closed)  = 7 THEN DATEDIFF(HOUR,CONVERT(date,case_date_closed),case_date_closed) ELSE 0 END)
          ) >= 480 THEN '>4 weeks'
      END as timing
      , DATEDIFF(HOUR, case_date_created, case_date_closed) 
	   + CASE WHEN DATEPART(dw, case_date_created) = 7 THEN 1 ELSE 0 END 
       - CASE WHEN DATEPART(dw, case_date_created) = 1 THEN 1 ELSE 0 END  
       - CASE WHEN DATEPART(dw, case_date_closed) = 1 THEN 1 ELSE 0 END 
       - (DATEDIFF(wk, case_date_created, case_date_closed) * 2 * 24)   as hours
    FROM case_master
      WHERE case_status = 'Closed' 
    AND case_date_created > @ldt_start_date
    AND case_date_created < @ldt_end_date
  	AND DATEDIFF(Day, case_date_created, case_date_closed ) >0
    ) x1
GROUP BY timing

--SELECT TOP 1000 * FROM growth_table

;WITH cte AS (
SELECT DATEPART(YEAR, data_date) as YEAR
, DATEPART(MONTH, data_date) as MONTH
, table_name
, MAX(rows) as rows
--, COUNT(1) as count
FROM growth_table WITH(NOLOCK)
GROUP BY DATEPART(YEAR, data_date)
, DATEPART(MONTH, data_date) 
, table_name
) 

SELECT t1.YEAR, t1.MONTH, t1.table_name
, t1.rows
, t2.MONTH
, t2.rows
, t3.MONTH
, t3.rows
, t4.MONTH
, t4.rows
, t5.MONTH
, t5.rows
, t6.MONTH
, t6.rows
, t7.MONTH
, t7.rows
, t8.MONTH
, t8.rows
, t9.MONTH
, t9.rows
--, t10.MONTH
--, t10.rows
, CASE WHEN (t9.rows = t1.rows) OR (t9.rows = 0 OR t1.rows = 0) THEN 0 ELSE (t9.rows - t1.rows)*100/t1.rows END growth_percentage
FROM cte t1
  INNER JOIN cte t2
    ON t1.table_name = t2.table_name
    AND t1.MONTH = t2.MONTH - 1
    AND t1.YEAR = t2.YEAR
  INNER JOIN cte t3
    ON t1.table_name = t3.table_name
    AND t1.MONTH = t3.MONTH - 2
    AND t1.YEAR = t3.YEAR
  INNER JOIN cte t4
    ON t1.table_name = t4.table_name
    AND t1.MONTH = t4.MONTH - 3
    AND t1.YEAR = t4.YEAR
  INNER JOIN cte t5
    ON t1.table_name = t5.table_name
    AND t1.MONTH = t5.MONTH - 4
    AND t1.YEAR = t5.YEAR
  INNER JOIN cte t6
    ON t1.table_name = t6.table_name
    AND t1.MONTH = t6.MONTH - 5
    AND t1.YEAR = t6.YEAR
  INNER JOIN cte t7
    ON t1.table_name = t7.table_name
    AND t1.MONTH = t7.MONTH - 6
    AND t1.YEAR = t7.YEAR
  INNER JOIN cte t8
    ON t1.table_name = t8.table_name
    AND t1.MONTH = t8.MONTH - 7
    AND t1.YEAR = t8.YEAR
  INNER JOIN cte t9
    ON t1.table_name = t9.table_name
    AND t1.MONTH = t9.MONTH - 8
    AND t1.YEAR = t9.YEAR
  --INNER JOIN cte t10
  --  ON t1.table_name = t10.table_name
  --  AND t1.MONTH = t10.MONTH - 9
  --  AND t1.YEAR = t10.YEAR

WHERE t1.YEAR = 2016
AND t1.MONTH = 01 
ORDER BY 1, 2, t1.rows DESC


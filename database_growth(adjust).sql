;with cte as (
SELECT * 
FROM growth_database t1
WHERE t1.dbname = 'celtrak_data'
AND file_name = 'celtrak_data_Data'
)
SELECT t1.*, t2.*, t2.percent_occupied - t1.percent_occupied
FROM cte t1
  INNER JOIN cte t2
    ON t1.rid = t2.rid - 49

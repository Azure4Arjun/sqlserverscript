
;with cte as
(
select * ,
ROW_NUMBER() over (order by Date) as rn
from trans_per_second_drop_later4
WHERE instance_name = '_Total'

)

SELECT t1.cntr_value - t2.cntr_value as Total_trans_last_sec,
t1.Date as created
FROM cte t1 
  INNER JOIN cte t2
    ON t1.rn = t2.rn+1

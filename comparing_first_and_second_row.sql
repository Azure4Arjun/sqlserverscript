
;with cte as
(
select * ,
ROW_NUMBER() over (order by id desc) as rn
from instance_host_history

)

SELECT COUNT(1)
FROM cte t1 
  INNER JOIN (SELECT rn + 1 as rnid
                    , id
                    , hostname
                    , date 
              FROM cte 
              WHERE rn = 1) t2
    ON t1.rn = t2.rnid
WHERE t1.hostname <> t2.hostname


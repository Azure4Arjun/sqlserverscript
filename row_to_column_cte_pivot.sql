
/*
-- switch the follow select customers to a column to each customer
SELECT t1.error_type_rid
                ,t2.short_description error_type_description
                ,CASE 
                  WHEN t5.service_manager_type_rid = 0 THEN 'Fleetwatch'
                  WHEN t5.service_manager_type_rid = 1 or t5.service_manager_type_rid = 2 THEN 'TK'
                END as Customer
                ,Count(*) as Count
                ,SUM(CASE WHEN t1.sort_order = 0 THEN 0 ELSE 1 END) RetryCount
          FROM R2Go_error_vehicle t1 WITH (NoLock)
            INNER JOIN R2Go_error_type t2 WITH (NoLock)
              ON t1.error_type_rid = t2.error_type_rid
            INNER JOIN tk_vehicle t3 WITH (NoLock)
              ON t3.rid = t1.vehicle_rid
            INNER JOIN tk_customer t4 WITH (NoLock)
              ON t4.rid = t3.customer_rid
            INNER JOIN tk_dealer t5 WITH (NoLock)
              ON t5.rid = t4.dealer_rid
          WHERE NOT (t1.error_type_rid = 13)
            AND NOT (t1.error_type_rid = 9)
            AND t3.active = 1   --added by Paul Roche on 25/09/2013
            AND t4.active = 1   --added by Paul Roche on 25/09/2013
          GROUP BY t1.error_type_rid
                  ,t2.short_description
                  , t5.service_manager_type_rid
  ORDER BY t1.error_type_rid

      
*/
WITH cte as ( SELECT t1.error_type_rid
                ,t2.short_description error_type_description
                ,CASE 
                  WHEN t5.service_manager_type_rid = 0 THEN 'Fleetwatch'
                  WHEN t5.service_manager_type_rid = 1 or t5.service_manager_type_rid = 2 THEN 'TK'
                END as Customer
                ,Count(*) as Count
                ,SUM(CASE WHEN t1.sort_order = 0 THEN 0 ELSE 1 END) RetryCount
          FROM R2Go_error_vehicle t1 WITH (NoLock)
            INNER JOIN R2Go_error_type t2 WITH (NoLock)
              ON t1.error_type_rid = t2.error_type_rid
            INNER JOIN tk_vehicle t3 WITH (NoLock)
              ON t3.rid = t1.vehicle_rid
            INNER JOIN tk_customer t4 WITH (NoLock)
              ON t4.rid = t3.customer_rid
            INNER JOIN tk_dealer t5 WITH (NoLock)
              ON t5.rid = t4.dealer_rid
          WHERE NOT (t1.error_type_rid = 13)
            AND NOT (t1.error_type_rid = 9)
            AND t3.active = 1   --added by Paul Roche on 25/09/2013
            AND t4.active = 1   --added by Paul Roche on 25/09/2013
          GROUP BY t1.error_type_rid
                  ,t2.short_description
                  , t5.service_manager_type_rid
)

SELECT error_type_rid
    , error_type_description 
    , ISNULL(Fleetwatch,0) as Fleetwatch
    , ISNULL(TK,0) as TK
--    , ISNULL(Fleetwatch,0) + ISNULL(TK,0) as error_sum
FROM ( 
    SELECT error_type_rid
        , error_type_description
        , customer
        , SUM(count) as count
    FROM cte
    GROUP BY error_type_description
          , Customer
          , error_type_rid

          ) d

PIVOT

(
  max(count)
  for customer in (Fleetwatch, TK)
      
) piv

ORDER BY error_type_rid

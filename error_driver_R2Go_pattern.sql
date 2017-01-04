-- exec R2Go_general_enquiry 356180
-- pattern
  DECLARE @ll_vehicle_rid INT
         ,@ll_tk_mu_data_rid BIGINT
         ,@ldt_tk_mu_data_created DATETIME
         ,@pl_vehicle_rid INT 

  SET @pl_vehicle_rid = 356180
  SET @ll_vehicle_rid = @pl_vehicle_rid

  SELECT TOP 1 @ll_tk_mu_data_rid = x1.start_rid
  FROM (SELECT TOP 5 t101.start_rid
    FROM R2Go_journey t101 WITH (NoLock)
    WHERE t101.vehicle_rid = @pl_vehicle_rid
    ORDER BY t101.start_rid DESC) x1
  ORDER BY x1.start_rid

  IF @ll_tk_mu_data_rid IS NULL SET @ll_tk_mu_data_rid = 0

  SELECT TOP 1 @ldt_tk_mu_data_created = t1.tk_mu_data_created
  FROM R2Go_to_process t1 WITH (NoLock)
  WHERE t1.tk_mu_data_rid < @ll_tk_mu_data_rid
    AND t1.journey_rid IS NOT NULL
  ORDER BY t1.tk_mu_data_rid DESC

  SELECT TOP 1 
        @ll_tk_mu_data_rid = t1.rid
          -- t1.rid
          --,t2.journey_rid
          --,dbo.fun$format_date_time_HHMMSS(t1.data_date) data_date
          --,dbo.fun$format_date_time_HHMMSS(t1.created) created
          --,DateDiff(minute, t1.created, t1.data_date) minute_diff
          --,DateDiff(day, t1.created, t1.data_date) date_diff
          --,t1.alarm_rid
          --,t1.ign_status
          --,t1.mileage
          --,Replace(t1.position, '~', '?') position
          --,t1.packet_counter
          --,t1.hdop
          --,t1.fix_quality
          --,t1.data_latitude
          --,t1.data_longitude
          --,t1.data_speed
          --,t1.raw_data
    FROM tk_mu_data t1 WITH (NoLock)
      LEFT OUTER JOIN R2Go_journey_detail t2 WITH (NoLock)
        ON t2.tk_mu_data_rid = t1.rid
    WHERE t1.rid >= @ll_tk_mu_data_rid
--        AND (t3.audit_type_rid IN (20, 21) OR t3.audit_type_rid IS NULL)
      AND t1.vehicle_rid = @ll_vehicle_rid
      AND NOT EXISTS (SELECT 1
                      FROM R2Go_error_tk_mu_data t101 WITH (NoLock)
                      WHERE t101.tk_mu_data_rid = t1.rid
                        AND t101.error_type_rid = 7)
    AND t1.alarm_rid = 1
    AND t1.ign_status = 1
    AND t2.journey_rid is null
    ORDER BY t1.rid

    -- setting as bad
      exec dbo.R2Go_fix_error_for_Linda 
       @ps_task_type        = 'bad_tk_mu_data_rid'
      ,@pb_commit           = 1
      ,@pl_vehicle_rid      = @pl_vehicle_rid
      ,@pl_tk_mu_data_rid   = @ll_tk_mu_data_rid


    -- deleting the error
      exec dbo.R2Go_fix_error_for_Linda 
       @ps_task_type        = 'delete_vehicle_error'
      ,@pb_commit           = 1
      ,@pl_vehicle_rid      = @pl_vehicle_rid


      /*
      --checking bad data

      SELECT TOP 1 t1.rid tk_mu_data_rid
          ,t2.journey_rid
          ,dbo.fun$format_date_time_HHMMSS(t1.data_date) data_date
          ,dbo.fun$format_date_time_HHMMSS(t1.created) created
          ,DateDiff(minute, t1.created, t1.data_date) minute_diff
          ,DateDiff(day, t1.created, t1.data_date) date_diff
          ,t1.alarm_rid
          ,t1.ign_status
          ,t1.mileage
          ,Replace(t1.position, '~', '?') position
          ,t1.packet_counter
          ,t1.hdop
          ,t1.fix_quality
          ,t1.data_latitude
          ,t1.data_longitude
          ,t1.data_speed
          ,t1.raw_data
    FROM tk_mu_data t1 WITH (NoLock)
      LEFT OUTER JOIN R2Go_journey_detail t2 WITH (NoLock)
        ON t2.tk_mu_data_rid = t1.rid
    WHERE t1.rid >= @ll_tk_mu_data_rid
--        AND (t3.audit_type_rid IN (20, 21) OR t3.audit_type_rid IS NULL)
      AND t1.vehicle_rid = @ll_vehicle_rid
      AND NOT EXISTS (SELECT 1
                      FROM R2Go_error_tk_mu_data t101 WITH (NoLock)
                      WHERE t101.tk_mu_data_rid = t1.rid
                        AND t101.error_type_rid = 7)
    AND t1.alarm_rid = 1
    AND t1.ign_status = 1
    AND t2.journey_rid is null
    ORDER BY t1.rid

      */
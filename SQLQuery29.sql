--[dbo].[R2Go_error_type]
--WHERE description like '%DriverId Alarm may be overwritten%'

--R2Go_error_vehicle
--WHERE error_description like '%DriverId Alarm may be overwritten%'
 
/* 
  SELECT  CASE 
                      WHEN t4a.service_manager_type_rid = 0 THEN 'FleetWatch'
                      WHEN t4a.service_manager_type_rid = 1 THEN 'TK US'
                      WHEN t4a.service_manager_type_rid = 2 THEN 'TK EU'
                     END as service_type
                    ,t1.vehicle_rid
                    ,t1.tk_mu_data_rid
                    ,t1.created
                    ,t1.error_type_rid
                    ,t2.short_description error_type_description
                    ,t1.error_description
                    ,LTrim(RTrim(t3.vehicle_name + ' ' + IsNull(t3.additional_vehicle_info, ''))) vehicle_name
                    ,t4.name customer_name
                    ,t5.end_created Last_R2Go_end_created
                    ,t1.sort_order
                    ,t3.fw_version
                    ,t1.updated_date
              FROM R2Go_error_vehicle t1 WITH (NoLock)
                INNER JOIN R2Go_error_type t2 WITH (NoLock)
                  ON t1.error_type_rid = t2.error_type_rid
                INNER JOIN tk_vehicle t3 WITH (NoLock)
                  ON t3.rid = t1.vehicle_rid
                INNER JOIN tk_customer t4 WITH (NoLock)
                  ON t4.rid = t3.customer_rid
                INNER JOIN tk_dealer t4a WITH (NoLock)
                  ON t4a.rid = t4.dealer_rid
                LEFT OUTER JOIN R2Go_journey t5 WITH (NoLock)
                  ON t5.vehicle_rid = t1.vehicle_rid
              WHERE t1.error_type_rid NOT IN (9, 10, 12, 13, 19, 22, 24, 25, 26, 27, 30, 31, 32, 33, 34, 39)
                AND (  t5.last_journey_flag = 1
                       OR t5.last_journey_flag IS NULL)
                AND t3.customer_rid NOT IN (1)  --anonymous
                AND t3.active = 1   --added by Paul Roche on 25/09/2013
                AND t4.active = 1   --added by Paul Roche on 25/09/2013
                AND t1.error_description like '%DriverId Alarm may be overwritten%'
              ORDER BY t1.sort_order
                      ,t5.end_created


*/

-- DEBUG part of DriverId Alarm may be overwritten
DECLARE 	@pl_debug_mode INT
SET @pl_debug_mode = 3
SET NOCOUNT ON

IF @pl_debug_mode >=3 
BEGIN
    DECLARE @ll_vehicle_rid INT
             ,@ll_tk_mu_data_rid BIGINT
             ,@ldt_tk_mu_data_created DATETIME
             ,@pl_vehicle_rid INT 
             ,@ll_tk_mu_data_rid_error BIGINT -- first tk_mu_data_rid of problem journey
             ,@ll_tk_mu_data_rid_error_end BIGINT -- first tk_mu_data_rid of problem journey
             ,@ll_last_end_tk_mu_data_rid BIGINT -- last journey tk_mu_data_rid
             ,@ll_to_process_rid INT
		         ,@ls_fw_version  NVARCHAR(50)
		         ,@ls_fw_version_short NVARCHAR(50)
             ,@lb_fw_version_is_latest TINYINT
             ,@ldt_fw_version_updated_date DATETIME
             ,@ldt_end_created DATETIME
             ,@ldt_last_end_created DATETIME       
		         ,@ll_end_tk_mu_data_rid BIGINT
             ,@ldt_end_data_date DATETIME
             ,@ll_end_mileage INT
             ,@ll_customer_rid INT        --need for map_position_parse
             ,@ll_product_rid INT
             ,@ll_product_group_type_rid INT
             ,@ll_tk_mu_data_rid_new_journey_start BIGINT


		 
      SET @pl_vehicle_rid = 358902
      SET @ll_vehicle_rid = @pl_vehicle_rid
      SET @ll_tk_mu_data_rid = 0

	    SELECT TOP 1 
        @ll_to_process_rid = t1.to_process_rid
	    FROM R2Go_to_process t1 WITH (NoLock)
	    WHERE t1.processed_date IS NULL
		    AND t1.vehicle_rid = @ll_vehicle_rid
		    ORDER BY t1.tk_mu_data_created
	          ,t1.tk_mu_data_rid

     SELECT @ll_vehicle_rid = t1.vehicle_rid
            ,@ll_end_tk_mu_data_rid = t1.tk_mu_data_rid
            ,@ldt_end_data_date = t1.tk_mu_data_data_date
            ,@ldt_end_created = t1.tk_mu_data_created
            ,@ll_end_mileage = t1.tk_mu_data_mileage
            ,@ll_customer_rid = t2.customer_rid        --need for map_position_parse
            ,@ls_fw_version = t2.fw_version
            ,@ldt_fw_version_updated_date = t2.fw_version_updated_date
            ,@ll_product_rid = t2.product_rid
            ,@ll_product_group_type_rid = t3.product_group_type_rid
      FROM R2Go_to_process t1 WITH (NoLock)
        INNER JOIN tk_vehicle t2 WITH (NoLock)
          ON t2.rid = t1.vehicle_rid
        INNER JOIN product t3 WITH (NoLock)
          ON t3.rid = t2.product_rid
	    WHERE t1.to_process_Rid = @ll_to_process_rid


      SELECT TOP 1 @ll_last_end_tk_mu_data_rid = t1.tk_mu_data_rid
                  ,@ldt_last_end_created = t1.tk_mu_data_created
      FROM R2Go_to_process t1 WITH (NoLock)
      WHERE t1.vehicle_rid = @ll_vehicle_rid
        AND t1.tk_mu_data_rid < @ll_end_tk_mu_data_rid
        AND t1.processed_date IS NOT NULL
      ORDER BY t1.tk_mu_data_rid DESC

  
    -- get the first tk_mu_data_rid of the problem journey
      SELECT TOP 1 
            @ll_tk_mu_data_rid_error = t1.rid
        FROM tk_mu_data t1 WITH (NoLock)
          LEFT OUTER JOIN R2Go_journey_detail t2 WITH (NoLock)
            ON t2.tk_mu_data_rid = t1.rid
        WHERE t1.vehicle_rid = @ll_vehicle_rid
          AND NOT EXISTS (SELECT 1
                          FROM R2Go_error_tk_mu_data t101 WITH (NoLock)
                          WHERE t101.tk_mu_data_rid = t1.rid
                            AND t101.error_type_rid = 7)
        AND t1.alarm_rid = 1
        AND t1.ign_status = 1
        AND t2.journey_rid is null
        AND t1.rid >= @ll_last_end_tk_mu_data_rid
        ORDER BY t1.rid

    -- get the last tk_mu_data_rid of the problem journey

        SELECT TOP 1
            @ll_tk_mu_data_rid_error_end = t1.rid
        FROM tk_mu_data t1 WITH (Nolock)
        WHERE t1.vehicle_rid = @ll_vehicle_rid
         AND t1.rid >= @ll_tk_mu_data_rid_error
         AND t1.alarm_rid = 2
      ORDER BY t1.rid
 
    --  SELECT just the problem journey

      SELECT 
  	    'ROLLBACK'
        ,t1.rid
        ,t1.data_date
        ,t1.data_latitude
        ,t1.data_longitude
        ,t1.alarm_rid
        ,t1.zone_rid
        ,t1.fix_quality
        ,t1.hdop
        ,t1.data_speed
        ,t1.mileage
        ,t1.raw_data
        ,t1.packet_counter
        ,t1.created
        ,t1.position
    FROM tk_mu_data t1 WITH (NOLOCK)
    WHERE t1.rid >= @ll_tk_mu_data_rid_error 
      AND t1.rid <= @ll_tk_mu_data_rid_error_end
      AND t1.vehicle_rid = @ll_vehicle_rid

  --  SELECT more data since last successful journey

      SELECT TOP 10000
  	    'ALL RECORDS'
        ,t1.rid
        ,t1.data_date
        ,t1.data_latitude
        ,t1.data_longitude
        ,t1.alarm_rid
        ,t1.zone_rid
        ,t1.fix_quality
        ,t1.hdop
        ,t1.data_speed
        ,t1.mileage
        ,t1.raw_data
        ,t1.packet_counter
        ,t1.created
        ,t1.position
    FROM tk_mu_data t1 WITH (NOLOCK)
     WHERE t1.vehicle_rid = @ll_vehicle_rid
        AND t1.rid >= @ll_last_end_tk_mu_data_rid + 1 

      SELECT TOP 1
  	    @ll_tk_mu_data_rid_new_journey_start = t1.rid
      FROM tk_mu_data t1 WITH (NOLOCK)
    WHERE t1.rid >= @ll_tk_mu_data_rid_error + 1
      AND t1.vehicle_rid = @ll_vehicle_rid

      
      PRINT '--- DEBUGGING vehicle: ' +  CONVERT(varchar,@ll_vehicle_rid)
      PRINT 'Last succesful journey end: ' + CONVERT(varchar,@ll_last_end_tk_mu_data_rid)
      PRINT 'Journey start error: ' + CONVERT(varchar,@ll_tk_mu_data_rid_error)
      PRINT 'Journey end error: ' + CONVERT(varchar,@ll_tk_mu_data_rid_error_end)
      PRINT 'Proc will set this tk_mu_data_rid as bad: ' + CONVERT(varchar,@ll_tk_mu_data_rid_error)
      PRINT 'Journey will try to start at: ' + CONVERT(varchar,@ll_tk_mu_data_rid_new_journey_start)
      PRINT '...'  
      PRINT ' '
      
      SET @ls_fw_version_short = dbo.fun$get_fw_version(@ls_fw_version)
      PRINT '..start - firmware certified?'
      PRINT '      @ls_fw_version = ' + @ls_fw_version
      PRINT '      @ls_fw_version_short = ' + @ls_fw_version_short
      PRINT '      @ldt_fw_version_updated_date = ' + dbo.fun$format_date_time_HHMMSS(@ldt_fw_version_updated_date)
      PRINT '      @ldt_end_created = ' + dbo.fun$format_date_time_HHMMSS(@ldt_end_created)
      PRINT '..  end - firmware certified?'
      PRINT '...'



END 
-- END IF @pl_debug_mode >=3 


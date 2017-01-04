   BEGIN
    --  BEGIN TRANSACTION

      DECLARE lrc_vehicle CURSOR LOCAL STATIC
      FOR
        SELECT t1.vehicle_rid
        FROM @tbl_vehicle t1
        ORDER BY t1.vehicle_rid

      OPEN lrc_vehicle
      FETCH NEXT FROM lrc_vehicle
      INTO @ll_vehicle_rid

      WHILE (@@Fetch_Status = 0)
        BEGIN
          EXEC R2Go_process_geo_fence_access @pl_vehicle_rid = @ll_vehicle_rid
                                            ,@pl_execute_to_tk_mu_data_rid = NULL
                                            ,@pl_debug_mode = 0
                                            ,@pb_use_transaction = 0
                                            ,@pb_commit = 0
          FETCH NEXT FROM lrc_vehicle
          INTO @ll_vehicle_rid
        END
    --ENDWHILE
      CLOSE lrc_vehicle
      DEALLOCATE lrc_vehicle
    END
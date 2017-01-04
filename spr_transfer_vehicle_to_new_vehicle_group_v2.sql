USE [celtrak_rafael]
GO

/****** Object:  StoredProcedure [dbo].[spr_transfer_vehicle_to_new_vehicle_group]    Script Date: 11/06/2015 08:34:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*

SELECT vehicle_group_rid, rid FROM tk_vehicle
where rid = 373243
6415	373243

[spr_transfer_vehicle_to_new_vehicle_group] 373243, NULL

Created On      Created By         Description
27/05/2015      Rafael Goncalez    This procedure will move the vehicle to a new group and also delete the
                                   user access to this vehicle in tracking list
Modified ON
11/06/2015      Rafael Goncalez     Now the procedure also accept NULL vehicle groups
*/

CREATE PROCEDURE [dbo].[spr_transfer_vehicle_to_new_vehicle_group]
  @pl_vehicle_rid INT
 ,@pl_new_vehicle_group_rid INT = NULL

 AS
  SET NOCOUNT ON
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

  BEGIN

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;


  IF @pl_new_vehicle_group_rid IS NOT NULL
    BEGIN
        --Validating if the vehicle and vehicle_group belongs to the same customer
        DECLARE @pl_vehicle_group_customer_rid INT
                 ,@pl_vehicle_customer_rid INT

        SELECT @pl_vehicle_group_customer_rid = customer_rid
        FROM vehicle_group t1 WITH (NOLOCK)
        WHERE t1.rid = @pl_new_vehicle_group_rid

        SELECT @pl_vehicle_customer_rid = customer_rid
        FROM tk_vehicle t1 WITH (NOLOCK)
        WHERE t1.rid = @pl_vehicle_rid

          BEGIN TRANSACTION

            IF (@pl_vehicle_group_customer_rid IS NULL OR @pl_vehicle_customer_rid IS NULL)
                BEGIN
                  RAISERROR ('Can''t find customer for vehicle or vehicle group', 16, 1)
                  GOTO return_with_error
                END

            IF (@pl_vehicle_group_customer_rid <> @pl_vehicle_customer_rid )
                BEGIN
                  RAISERROR ('Vehicle and vehicle group don''t belong to the same customer', 16, 1)
                  GOTO return_with_error
                END

            ELSE

              BEGIN TRY
              -- update tk_vehicle with the new vehicle group
                UPDATE t1
                SET vehicle_group_rid = @pl_new_vehicle_group_rid
                FROM tk_vehicle t1 WITH (ROWLOCK)
                WHERE t1.rid = @pl_vehicle_rid

                /*
                Tracking list with vehicle
                User does not have access to new vehicle group
                */
                DELETE t1
                FROM tracking_list t1 WITH (ROWLOCK)
                WHERE t1.vehicle_rid = @pl_vehicle_rid
                  AND NOT EXISTS (SELECT 1
                                  FROM user_vehicle_group_mapping t2 WITH (NOLOCK)
                                  WHERE t2.vehicle_group_rid = @pl_new_vehicle_group_rid
                                    AND t2.user_rid = t1.user_rid)

              COMMIT

              END TRY

              BEGIN CATCH
                --In case of failure
                --return the error
                --Raise Error

                SELECT 
                @ErrorMessage = ERROR_MESSAGE(),
                @ErrorSeverity = ERROR_SEVERITY(),
                @ErrorState = ERROR_STATE();

                RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState );
                --and rollback the transaction
                IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

              END CATCH
          END

          ELSE -- IF @pl_new_vehicle_group_rid IS NULL
             BEGIN TRY
              -- update tk_vehicle with the vehicle group NULL
                UPDATE t1
                SET vehicle_group_rid = NULL
                FROM tk_vehicle t1 WITH (ROWLOCK)
                WHERE t1.rid = @pl_vehicle_rid

                /*
                Delete this vehicle from Tracking list 
                */
                DELETE t1
                FROM tracking_list t1 WITH (ROWLOCK)
                WHERE t1.vehicle_rid = @pl_vehicle_rid

              END TRY

              BEGIN CATCH

                SELECT 
                @ErrorMessage = ERROR_MESSAGE(),
                @ErrorSeverity = ERROR_SEVERITY(),
                @ErrorState = ERROR_STATE();

                RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState );
                --and rollback the transaction
                IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

              END CATCH  
          END

  GOTO return_with_OK
        return_with_error:
          ROLLBACK
          RETURN (-1)
        return_with_OK:
          RETURN (0)
  
GO


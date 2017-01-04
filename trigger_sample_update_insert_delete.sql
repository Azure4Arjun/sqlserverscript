USE [celtrak_rafael]
GO

/****** Object:  Trigger [dbo].[trig_event_notification_config_tables_derived_alarm_rid]    Script Date: 03/06/2015 14:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


        CREATE TRIGGER [dbo].[trig_event_notification_config_tables_derived_alarm_rid] ON [dbo].[event_notification_config_derived_alarm_mapping]
        FOR INSERT, DELETE, UPDATE
        AS

        SET NOCOUNT ON
  
          DECLARE @table_name NVARCHAR(100)
                , @old_event_notification_config_rid INT
                , @old_respective_table_related_rid INT
                , @old_created_date DATETIME
                , @new_event_notification_config_rid INT
                , @new_respective_table_related_rid INT

          SELECT @table_name = 'event_notification_config_derived_alarm_mapping'
  

          IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
            BEGIN
              --UPDATE

              SELECT @old_event_notification_config_rid = t1.event_notification_config_rid
                    , @old_respective_table_related_rid = t1.derived_alarm_rid
                    , @old_created_date = t1.created
              FROM deleted t1

              SELECT @new_event_notification_config_rid = t1.event_notification_config_rid
                    , @new_respective_table_related_rid = t1.derived_alarm_rid
              FROM inserted t1

              INSERT INTO  event_notification_config_tables_audit
              ( table_name
              , updated
              , old_event_notification_config_rid
              , old_respective_table_related_rid
              , old_created_date
              , new_event_notification_config_rid
              , new_respective_table_related_rid
              , modified_date
              )
      
              VALUES
              ( @table_name
              , 1
              , @old_event_notification_config_rid
              , @old_respective_table_related_rid
              , @old_created_date
              , @new_event_notification_config_rid
              , @new_respective_table_related_rid
              , GETDATE()
              )
            END

            IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)  
              BEGIN 
              --INSERT

                  SELECT @new_event_notification_config_rid = t1.event_notification_config_rid
                        , @new_respective_table_related_rid = t1.derived_alarm_rid
                  FROM inserted t1

                  INSERT INTO  event_notification_config_tables_audit
                  ( table_name
                  , inserted
                  , old_event_notification_config_rid
                  , old_respective_table_related_rid
                  , new_event_notification_config_rid
                  , new_respective_table_related_rid
                  , modified_date
                  )
                  VALUES
                  ( @table_name
                  , 1
                  , NULL
                  , NULL
                  , @new_event_notification_config_rid
                  , @new_respective_table_related_rid
                  , GETDATE()
                  )
              END

            IF NOT EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)  
              BEGIN 
                  --DELETE

                  SELECT @old_event_notification_config_rid = t1.event_notification_config_rid
                        , @old_respective_table_related_rid = t1.derived_alarm_rid
                        , @old_created_date = t1.created
                  FROM deleted t1

                  INSERT INTO  event_notification_config_tables_audit
                  ( table_name
                  , deleted
                  , old_event_notification_config_rid
                  , old_respective_table_related_rid
                  , old_created_date
                  , new_event_notification_config_rid
                  , new_respective_table_related_rid
                  , modified_date
                  )
                  VALUES
                  ( @table_name
                  , 1
                  , @old_event_notification_config_rid
                  , @old_respective_table_related_rid
                  , @old_created_date 
                  , NULL
                  , NULL
                  , GETDATE()
                  )
              END
GO



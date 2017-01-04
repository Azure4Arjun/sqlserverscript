USE [celtrak_rafael]
GO

/****** CREATING the audit table for event_notification_config table ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[event_notification_config_audit](
	[rid] [int] IDENTITY(1,1) NOT NULL,
	[event_notification_config_rid] [int] NOT NULL,
	[statement] [char](1) NOT NULL,
	[old_name] [nvarchar](100) NULL,
	[old_customer_rid] [int] NULL,
	[old_notification_type_rid] [int] NULL,
	[old_all_shut_down] [bit] NULL,
	[old_all_check_and_prevent] [bit] NULL,
  [old_notify_on_clear_multi] [bit] NULL,
	[new_name] [nvarchar](100) NULL,
	[new_customer_rid] [int] NULL,
	[new_notification_type_rid] [int] NULL,
	[new_all_shut_down] [bit] NULL,
	[new_all_check_and_prevent] [bit] NULL,
  [new_notify_on_clear_multi] [bit] NULL,
	[modified_date] [datetime] NOT NULL,
 CONSTRAINT [PK_event_notification_config_audit] PRIMARY KEY CLUSTERED 
(
	[rid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

GO

/****** CREATING the trigger ******/

CREATE TRIGGER [dbo].[trig_event_notification_config] ON event_notification_config
FOR INSERT, DELETE, UPDATE
AS

SET NOCOUNT ON
  
  DECLARE @ll_rid INT
        , @ls_old_name NVARCHAR (100)
        , @statement CHAR(1)
        , @ll_old_customer_rid INT
        , @ll_old_notification_type_rid INT
        , @lb_old_all_shut_down BIT
        , @lb_old_all_check_and_prevent BIT
        , @lb_old_notify_on_clear_multi BIT
        , @ls_new_name NVARCHAR (100)
        , @ll_new_customer_rid INT
        , @ll_new_notification_type_rid INT
        , @lb_new_all_shut_down BIT
        , @lb_new_all_check_and_prevent BIT
        , @lb_new_notify_on_clear_multi BIT
        , @ls_sql NVARCHAR(MAX)


  IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
      -- BEGIN UPDATE
      
      SET @statement = 'U'

      SELECT *
      INTO #deleted
      FROM deleted

      SELECT *
      INTO #inserted
      FROM inserted
            
      WHILE (
             SELECT COUNT(1)
             FROM #deleted
             ) > 0
        BEGIN

          SELECT @ll_rid = MAX(t1.rid)
          FROM #deleted t1

          SELECT  @ls_old_name = t1.name
                , @ll_old_customer_rid = t1.customer_rid
                , @ll_old_notification_type_rid = t1.notification_type_rid
                , @lb_old_all_shut_down = t1.all_shut_down
                , @lb_old_all_check_and_prevent = t1.all_check_and_prevent
                , @lb_old_notify_on_clear_multi = t1.notify_on_clear_multi
          FROM #deleted t1
          WHERE t1.rid = @ll_rid
      
          SELECT  @ls_new_name = t1.name
                , @ll_new_customer_rid = t1.customer_rid
                , @ll_new_notification_type_rid = t1.notification_type_rid
                , @lb_new_all_shut_down = t1.all_shut_down
                , @lb_new_all_check_and_prevent = t1.all_check_and_prevent
                , @lb_new_notify_on_clear_multi = t1.notify_on_clear_multi
          FROM #inserted t1
          WHERE t1.rid = @ll_rid

          INSERT INTO  event_notification_config_audit
          (   event_notification_config_rid
            , [statement]
            , old_name 
            , old_customer_rid 
            , old_notification_type_rid 
            , old_all_shut_down 
            , old_all_check_and_prevent
            , old_notify_on_clear_multi
            , new_name 
            , new_customer_rid 
            , new_notification_type_rid 
            , new_all_shut_down 
            , new_all_check_and_prevent
            , new_notify_on_clear_multi
            , modified_date
          )
      
          VALUES
          (   @ll_rid
            , @statement 
            , @ls_old_name 
            , @ll_old_customer_rid 
            , @ll_old_notification_type_rid 
            , @lb_old_all_shut_down 
            , @lb_old_all_check_and_prevent
            , @lb_old_notify_on_clear_multi
            , @ls_new_name 
            , @ll_new_customer_rid 
            , @ll_new_notification_type_rid 
            , @lb_new_all_shut_down 
            , @lb_new_all_check_and_prevent
            , @lb_new_notify_on_clear_multi 
            , GETDATE()
          )
    

        DELETE 
        FROM #deleted
        WHERE rid = @ll_rid
        
        DELETE 
        FROM #inserted
        WHERE rid = @ll_rid

       END
    DROP TABLE #deleted
    DROP TABLE #inserted
    END
	-- END UPDATE
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)  
      BEGIN 
      --BEGIN INSERT
      
      SET @statement = 'I'
      
      SELECT *
      INTO #inserted1
      FROM inserted

      WHILE (
             SELECT COUNT(1)
             FROM #inserted1
             ) > 0
        BEGIN

          SELECT @ll_rid = MAX(t1.rid)
          FROM #inserted1 t1

          SELECT  @ls_new_name = t1.name
                , @ll_new_customer_rid = t1.customer_rid
                , @ll_new_notification_type_rid = t1.notification_type_rid
                , @lb_new_all_shut_down = t1.all_shut_down
                , @lb_new_all_check_and_prevent = t1.all_check_and_prevent
                , @lb_new_notify_on_clear_multi = t1.notify_on_clear_multi
          FROM #inserted1 t1
          WHERE t1.rid = @ll_rid

          INSERT INTO  event_notification_config_audit
          (   event_notification_config_rid
            , [statement]
            , old_name 
            , old_customer_rid 
            , old_notification_type_rid 
            , old_all_shut_down 
            , old_all_check_and_prevent
            , old_notify_on_clear_multi 
            , new_name 
            , new_customer_rid 
            , new_notification_type_rid 
            , new_all_shut_down 
            , new_all_check_and_prevent 
            , new_notify_on_clear_multi
            , modified_date
          )
      
          VALUES
          (   @ll_rid
            , @statement
            , NULL 
            , NULL 
            , NULL 
            , NULL 
            , NULL
            , NULL 
            , @ls_new_name 
            , @ll_new_customer_rid 
            , @ll_new_notification_type_rid 
            , @lb_new_all_shut_down 
            , @lb_new_all_check_and_prevent
            , @lb_new_notify_on_clear_multi
            , GETDATE()
          )

        DELETE 
        FROM #inserted1
        WHERE rid = @ll_rid

       END
    
      DROP TABLE #inserted1
    
    END

    IF NOT EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)  
      BEGIN 
        --BEGIN DELETE
        SET @statement = 'D'
        
        SELECT *
        INTO #deleted1
        FROM deleted

          
        WHILE (
               SELECT COUNT(1)
               FROM #deleted1
               ) > 0
          BEGIN

            SELECT @ll_rid = MAX(t1.rid)
            FROM #deleted1 t1

            SELECT  @ls_old_name = t1.name
                  , @ll_old_customer_rid = t1.customer_rid
                  , @ll_old_notification_type_rid = t1.notification_type_rid
                  , @lb_old_all_shut_down = t1.all_shut_down
                  , @lb_old_all_check_and_prevent = t1.all_check_and_prevent
                  , @lb_old_notify_on_clear_multi = t1.notify_on_clear_multi
            FROM #deleted1 t1
            WHERE t1.rid = @ll_rid

            INSERT INTO  event_notification_config_audit
            (   event_notification_config_rid
              , [statement]
              , old_name 
              , old_customer_rid 
              , old_notification_type_rid 
              , old_all_shut_down 
              , old_all_check_and_prevent
              , old_notify_on_clear_multi
              , new_name 
              , new_customer_rid 
              , new_notification_type_rid 
              , new_all_shut_down 
              , new_all_check_and_prevent 
              , new_notify_on_clear_multi
              , modified_date
            )
      
            VALUES
            (   @ll_rid
              , @statement 
              , @ls_old_name 
              , @ll_old_customer_rid 
              , @ll_old_notification_type_rid 
              , @lb_old_all_shut_down 
              , @lb_old_all_check_and_prevent 
              , @lb_old_notify_on_clear_multi
              , NULL 
              , NULL 
              , NULL
              , NULL
              , NULL
              , NULL
              , GETDATE()
            )
    

          DELETE 
          FROM #deleted1 
          WHERE rid = @ll_rid
        
          END
  		
        DROP TABLE #deleted1
        -- END DELETE
      END

    
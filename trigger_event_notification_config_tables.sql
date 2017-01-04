
USE [celtrak_rafael]
GO

/****** CREATING THE AUDIT TABLE FOR ALL event_notification_config% tables ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[event_notification_config_tables_audit](
	[rid] [int] IDENTITY(1,1) NOT NULL,
	[table_name] [nvarchar](100) NOT NULL,
	[statement] [char](1) NOT NULL,
	[event_notification_config_rid] [int] NULL,
	[pk_second_column] [int] NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [PK_event_notification_config_tables_audit] PRIMARY KEY CLUSTERED 
(
	[rid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** ALTERING event_notification_config_derived_alarm_mapping to follow the standard ******/

ALTER TABLE event_notification_config_derived_alarm_mapping 
ADD  [created] DATETIME NULL
GO

ALTER TABLE event_notification_config_derived_alarm_mapping 
ADD CONSTRAINT [DF_event_notification_config_derived_alarm_mapping_created]  DEFAULT (getdate()) FOR [created]
GO

/****** SCRIPT to create the trigger in all event_notification_config related tables ******/

  DECLARE @ls_table_name NVARCHAR(100)
        , @ls_sql NVARCHAR(MAX)
        , @ls_pk_second_column NVARCHAR(100)
        , @ll_table_id INT

  SELECT id, name           
  INTO #table_trigger                
  FROM celtrak_rafael..sysobjects as t1              
  WHERE name LIKE 'event_notification_config%'
  AND name NOT IN ('event_notification_config_tables_audit'
                 , 'event_notification_config')
  

  WHILE (               
      SELECT COUNT(1)                
      FROM #table_trigger                
        ) > 0   
               
	  BEGIN

      SELECT  @ll_table_id = MAX(id)
            , @ls_table_name = name
      FROM #table_trigger
      GROUP BY id, name

      SELECT  @ls_pk_second_column = name 
      FROM syscolumns
      WHERE id = @ll_table_id
      AND name NOT IN ('event_notification_config_rid'
      , 'created')

/****** CREATING the triggers *****/

      SET @ls_sql = '
        CREATE TRIGGER [dbo].[trig_event_notification_config_tables_$] ON [?]
        FOR INSERT, DELETE
        AS

        SET NOCOUNT ON
  
          DECLARE @ls_table_name NVARCHAR(100)
                , @ll_event_notification_config_rid INT
                , @ls_pk_second_column INT

          SELECT @ls_table_name = ''?''
  
           IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)  
             BEGIN 
              --------
              --INSERT
              --------
                SELECT *
                INTO #inserted
                FROM inserted
                                  
                WHILE (               
                SELECT COUNT(1)                
                FROM #inserted                
                    ) > 0 
                  BEGIN
                                               
                    SELECT @ll_event_notification_config_rid = t1.event_notification_config_rid
                          , @ls_pk_second_column = t1.$
                    FROM #inserted t1

                    INSERT INTO  event_notification_config_tables_audit
                    ( table_name
                    , statement
                    , event_notification_config_rid
                    , pk_second_column
                    , created
                    )
                    VALUES
                    ( @ls_table_name
                    , ''I''
                    , @ll_event_notification_config_rid
                    , @ls_pk_second_column
                    , GETDATE()
                    )
                
                    DELETE 
                    FROM #inserted
                    WHERE event_notification_config_rid = @ll_event_notification_config_rid
                    AND $ = @ls_pk_second_column
                  END
              
             END

           IF NOT EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)  
             BEGIN 
              --------
              --DELETE
              --------
                SELECT *
                INTO #deleted
                FROM deleted
                                  
                WHILE (               
                SELECT COUNT(1)                
                FROM #deleted                
                    ) > 0   
               
	              BEGIN

                  SELECT @ll_event_notification_config_rid = t1.event_notification_config_rid
                        , @ls_pk_second_column = t1.$
                  FROM #deleted t1

                  INSERT INTO  event_notification_config_tables_audit
                  ( table_name
                  , statement
                  , event_notification_config_rid
                  , pk_second_column
                  , created
                  )
                  VALUES
                  ( @ls_table_name
                  , ''D''
                  , @ll_event_notification_config_rid
                  , @ls_pk_second_column
                  , GETDATE()
                  )

                DELETE 
                FROM #deleted
                WHERE event_notification_config_rid = @ll_event_notification_config_rid
                  AND $ = @ls_pk_second_column

               END

             END'

          SET @ls_sql = REPLACE (@ls_sql,'?',@ls_table_name)
          SET @ls_sql = REPLACE (@ls_sql,'$',@ls_pk_second_column)

        EXEC (@ls_sql)

        DELETE FROM #table_trigger
        WHERE id = @ll_table_id

    END
    DROP TABLE #table_trigger
    GO

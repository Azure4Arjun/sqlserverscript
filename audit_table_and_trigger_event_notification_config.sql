CREATE TABLE [dbo].[event_notification_config_audit](
	[rid] [int] IDENTITY(1,1) NOT NULL,
	seq_no INT NOT NULL,
	from_date DATETIME NOT NULL,
 	to_date DATETIME NOT NULL,
	[event_notification_config_rid] [int] NOT NULL,
	[name] [nvarchar](100) NULL,
	[customer_rid] [int] NULL,
	[notification_type_rid] [int] NULL,
	[all_shut_down] [bit] NULL,
	[all_check_and_prevent] [bit] NULL,
  [notify_on_clear_multi] [bit] NULL,

 CONSTRAINT [PK_event_notification_config_audit] PRIMARY KEY CLUSTERED 
(
	[rid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

CREATE TRIGGER [dbo].[trig_event_notification_config] ON [dbo].[event_notification_config]
FOR INSERT, UPDATE,  DELETE
AS
SET NOCOUNT ON

  IF    UPDATE (name)
     OR UPDATE (customer_rid)
     OR UPDATE (notification_type_rid)
     OR UPDATE (all_shut_down)
     OR UPDATE (all_check_and_prevent)
     OR UPDATE (notify_on_clear_multi)
     
    BEGIN
      DECLARE @ldt_to_date DATETIME
          , @ldt_from_date DATETIME
          , @ll_seq_no INT

      SET @ldt_from_date = GetDate()
      SET @ldt_to_date = DateAdd(millisecond, -3, @ldt_from_date)

      UPDATE t1
      SET t1.to_date = @ldt_to_date
      FROM event_notification_config_audit t1
        INNER JOIN inserted t2
          ON t1.event_notification_config_rid = t2.rid
      WHERE t1.to_date = '31-Dec-2049 23:59:59'

      INSERT INTO event_notification_config_audit (
             event_notification_config_rid
            ,seq_no
            ,from_date
            ,to_date
            ,name
            ,customer_rid
            ,notification_type_rid
            ,all_shut_down
            ,all_check_and_prevent
            ,notify_on_clear_multi
            )
      SELECT t1.rid
            ,IsNull(x1.max_seq_no, 0) + 1
            ,@ldt_from_date
            ,'31-Dec-2049 23:59:59'
            ,t1.name
            ,t1.customer_rid
            ,t1.notification_type_rid
            ,t1.all_shut_down
            ,t1.all_check_and_prevent
            ,t1.notify_on_clear_multi
      FROM inserted t1
        LEFT OUTER JOIN (SELECT t101.event_notification_config_rid
                               ,Max(t101.seq_no) max_seq_no
                         FROM event_notification_config_audit t101 WITH (NoLock)
                           INNER JOIN inserted t102
                             ON t102.rid = t101.event_notification_config_rid
                         WHERE t101.to_date = @ldt_to_date
                            OR t101.to_date IS NULL
                         GROUP BY t101.event_notification_config_rid) x1
             ON x1.event_notification_config_rid = t1.rid

      END

      IF NOT EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)   
        BEGIN
        --------
        --DELETE
        --------
          UPDATE t1
          SET t1.to_date = getdate()
          FROM event_notification_config_audit t1
            INNER JOIN deleted t2
              ON t1.event_notification_config_rid = t2.rid
          WHERE t1.to_date = '31-Dec-2049 23:59:59'
        END
GO


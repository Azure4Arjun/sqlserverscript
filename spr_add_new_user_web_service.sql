/*UPDATE tk_customer
SET external_customer_id = NULL
, web_service_IP_address = NULL
WHERE rid = 61651

[spr_add_new_web_service_user] 61651, 'NICBASE'

DELETE
--SELECT * 
FROM users
where user_name = 'webservice.user@dgmcardleint.ie'

DELETE 
--SELECT * 
FROM user_web_service
WHERE user_rid = 68657

SELECT * FROM user_web_service
*/

CREATE PROCEDURE [dbo].[spr_add_new_web_service_user]
  @pl_customer_rid INT
, @ps_web_service_IP_address NVARCHAR(50) =  NULL
  AS
  SET NOCOUNT ON

  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

  /*
  Created by        Created Date    Description:
  Rafael Goncalez   08/06/2015      The procedure will create a new webservices user
  */

  /*
  ----------------------------------
    Script to get the Customer Rid 
  ----------------------------------
  SELECT 
      t1.rid as customer_rid
    , t1.name as customer_name
    , t3.[description] as service_manager_type
 --   , SUle_vehicles
  FROM tk_customer t1 WITH (NOLOCK)
    INNER JOIN tk_dealer t2 WITH (NOLOCK)
      ON t1.dealer_rid = t2.rid
    INNER JOIN [dbo].[service_manager_type] t3 WITH (NOLOCK)
      ON t2.[service_manager_type_rid] = t3.[rid]
    LEFT OUTER JOIN tk_vehicle t4 WITH (NOLOCK)
      ON t1.rid = t4.customer_rid
  WHERE t1.name LIKE '%McArdle%'
  GROUP BY 
        t1.rid 
      , t1.name 
      , t3.[description]
  */
  
  DECLARE @lx_external_customer_id UNIQUEIDENTIFIER
         ,@ls_web_service_user VARCHAR(50)
         ,@ls_web_service_password VARCHAR(15)
         ,@ll_user_rid INT
         ,@ll_role_rid INT
         ,@ls_email_domain NVARCHAR(100)
         ,@error_msg NVARCHAR (1000)

  
  --DECLARE @pl_customer_rid INT

  ------------------------------------------
  -- Setting role rid according customer ID
  ------------------------------------------
    SELECT 
      @ll_role_rid =  
      CASE 
       WHEN  t3.[description] LIKE 'TK%' THEN 193
        ELSE 192
      END
    FROM tk_customer t1 WITH (NOLOCK)
    INNER JOIN tk_dealer t2 WITH (NOLOCK)
      ON t1.dealer_rid = t2.rid 
    INNER JOIN [dbo].[service_manager_type] t3 WITH (NOLOCK)
      ON t2.[service_manager_type_rid] = t3.[rid]
    LEFT OUTER JOIN tk_vehicle t4 WITH (NOLOCK)
      ON t1.rid = t4.customer_rid
    WHERE t1.rid = @pl_customer_rid
    GROUP BY 
        t1.rid 
      , t1.name 
      , t3.[description]

  
  --------------------------------------------------------
  -- Select the most common email domain for this customer
  --------------------------------------------------------

  SELECT TOP 1 @ls_email_domain = t1.email_domain
  FROM 
      ( SELECT SUBSTRING(email_1, CHARINDEX('@', email_1) + 1, LEN(email_1)) as email_domain
            , COUNT(1) as ocurrency
      FROM contact WITH (NOLOCK)
      WHERE customer_rid = @pl_customer_rid
        AND email_1 <> ''
      GROUP BY SUBSTRING(email_1, CHARINDEX('@', email_1) + 1, LEN(email_1))

      UNION ALL

      SELECT SUBSTRING(email_2, CHARINDEX('@', email_2) + 1, LEN(email_2)) as email_domain
            , COUNT(1) as ocurrency
      FROM contact WITH (NOLOCK)
      WHERE customer_rid = @pl_customer_rid
        AND email_2 <> ''
      GROUP BY SUBSTRING(email_2, CHARINDEX('@', email_2) + 1, LEN(email_2))

      UNION ALL

      SELECT SUBSTRING(email_3, CHARINDEX('@', email_3) + 1, LEN(email_3)) as email_domain
            , COUNT(1) as ocurrency
      FROM contact WITH (NOLOCK)
      WHERE customer_rid = @pl_customer_rid
        AND email_3 <> ''
      GROUP BY SUBSTRING(email_3, CHARINDEX('@', email_3) + 1, LEN(email_3))

      UNION ALL

      SELECT SUBSTRING(email_4, CHARINDEX('@', email_4) + 1, LEN(email_4)) as email_domain
            , COUNT(1) as ocurrency
      FROM contact WITH (NOLOCK)
      WHERE customer_rid = @pl_customer_rid
        AND email_4 <> ''
      GROUP BY SUBSTRING(email_4, CHARINDEX('@', email_4) + 1, LEN(email_4))

      UNION ALL

      SELECT SUBSTRING(email_5, CHARINDEX('@', email_5) + 1, LEN(email_5)) as email_domain
            , COUNT(1) as ocurrency
      FROM contact WITH (NOLOCK)
      WHERE customer_rid = @pl_customer_rid
        AND email_5 <> ''
      GROUP BY SUBSTRING(email_5, CHARINDEX('@', email_5) + 1, LEN(email_5))
      ) t1
  ORDER BY ocurrency DESC

  SET @ls_web_service_user = 'webservice.user@' + @ls_email_domain

  -------------------------------------
  -- Check if the user name exists
  -------------------------------------
  IF EXISTS (SELECT 1 FROM [users] WITH (NOLOCK)  WHERE user_name = @ls_web_service_user )
    BEGIN
    
    SET @error_msg = 'The user name ' + @ls_web_service_user + ' already exists'
    RAISERROR (@error_msg, 20, -1) WITH LOG
    
    END
  -------------------------------------
  -- Check if the customer has an External ID 
  -------------------------------------
  IF (SELECT external_customer_id FROM tk_customer WITH (NOLOCK) WHERE rid = @pl_customer_rid) IS NOT NULL
    BEGIN
    
    SELECT @error_msg = external_customer_id 
    FROM tk_customer WITH (NOLOCK)
    WHERE rid = @pl_customer_rid

    SET @error_msg = 'This customer already has an External id: ' + @error_msg
    RAISERROR (@error_msg, 20, -1) WITH LOG
    
    END
  -------------------------------------
  -- Check if the customer has an IP Address
  -------------------------------------
  IF (SELECT web_service_IP_address FROM tk_customer WHERE rid = @pl_customer_rid) IS NOT NULL
    BEGIN
    
    SELECT @error_msg = web_service_IP_address 
    FROM tk_customer WITH (NOLOCK)
    WHERE rid = @pl_customer_rid

    SET @error_msg = 'This customer already has an IP address: ' + @error_msg
    RAISERROR (@error_msg, 20, -1) WITH LOG
    
    END
    
  -------------------------------------
  -- Setting a random password
  -------------------------------------

  SET @ls_web_service_password = 
                dbo.fun$get_random_string(7, 1, 1, 1, 0) 
              + dbo.fun$get_random_string(1, 0, 0, 0, 1) 
              + dbo.fun$get_random_string(7, 1, 1, 1, 0)
  
  -------------------------------------
  -- Setting a random external ID
  -------------------------------------
  SET @lx_external_customer_id = NEWID()
   
  
  --------------------------------------------------------------------------
  -- Updating tk_customer and tk_vehicle with the IP and External ID
  --------------------------------------------------------------------------

  UPDATE t1
  SET t1.external_customer_id = CONVERT(VARCHAR(255), @lx_external_customer_id)
     ,t1.web_service_IP_address = @ps_web_service_IP_address
  FROM tk_customer t1 WITH (RowLock)
  WHERE t1.rid = @pl_customer_rid
    AND t1.external_customer_id IS NULL
    AND t1.web_service_IP_address IS NULL

  UPDATE t1
  SET t1.external_customer_id = t1.vehicle_name
  FROM tk_vehicle t1 WITH (RowLock)
  WHERE t1.customer_rid = @pl_customer_rid
    AND IsNull(t1.external_customer_id, '') = ''

  ----------------------------------------------------
  --  Inserting the new data into users table and user_web_service table 
  -----------------------------------------------------
    
  INSERT [dbo].[users] ([user_name],[password],[user_type_rid],[active],[role_rid],[administrator],[speed_type_rid],[timezone_rid],[temperature_type_rid],[language_rid],[fuel_type_rid],[deleted],[email_authenticated])
  VALUES(@ls_web_service_user, @ls_web_service_password, 4, 1, @ll_role_rid, 0, 1, 1, 1, 2, 1, 0, 1)

  SET @ll_user_rid = @@IDENTITY
  /*
  SELECT *
  FROM users t1 WITH (Nolock)
  WHERE t1.rid = @ll_user_rid
  */
  INSERT [dbo].[user_web_service] ([user_rid],[customer_rid],[command_allowed])
  VALUES(@ll_user_rid, @pl_customer_rid, 'all')

  -----------------------------------------------------
  --  Returning external Customer ID, webservice user and webservice password
  -----------------------------------------------------

  SELECT @lx_external_customer_id as External_customer_ID
    , @ls_web_service_user as WebServices_User
    , @ls_web_service_password as WebServices_Password

GO
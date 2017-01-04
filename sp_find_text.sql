USE master
GO
/*
Created on    Created by        Description
24/05/2016    Rafael Goncalez   Return objects which contain @ps_text

*/
CREATE PROC sp_find_text 
          @ps_text VARCHAR(MAX)
        , @ps_database_to_search VARCHAR(100) = NULL
AS
BEGIN
  --SELECT DB_NAME(), DB_ID()

  DECLARE @ls_exec_command VARCHAR(MAX)
  , @ls_database_to_search VARCHAR(100)

  SET @ls_database_to_search = @ps_database_to_search

  IF @ls_database_to_search IS NULL
    BEGIN
      SELECT @ls_database_to_search = DB_NAME()
    END


  --SET @ls_exec_command = 'SELECT OBJECT_NAME(id) as object_name, * FROM ' + @ls_database_to_search + '.dbo.syscomments WHERE text LIKE ''%' + @ps_text + '%'''
  SET @ls_exec_command = 'SELECT t2.name as object_name, t1.* 
    FROM ' + @ls_database_to_search + '.dbo.syscomments t1 
      INNER JOIN ' + @ls_database_to_search + '.dbo.sysobjects t2
        ON t1.id = t2.id
    WHERE t1.text LIKE ''%' + @ps_text + '%'''

  EXEC (@ls_exec_command)
 --SELECT @ls_exec_command

END

GO

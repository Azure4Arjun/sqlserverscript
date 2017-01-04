USE [celtrak_data]
GO

/****** Object:  StoredProcedure [dbo].[spr_sysobjects]    Script Date: 29/07/2015 11:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  PROC [dbo].[spr_sysobjects] 
    @name varchar(30) = NULL
  , @type varchar(3) = NULL 
  AS

DECLARE @sql VARCHAR(MAX)

IF @type IS NULL AND @name IS NULL
  BEGIN
    SELECT * FROM sysobjects
  END
IF @type IS NULL AND @name IS NOT NULL
  BEGIN
    SET @sql = 'SELECT * FROM sysobjects
    WHERE name like ''%' + @name + '%'''
    exec (@sql)
  END
ELSE IF @type IS NOT NULL AND @name IS NOT NULL
  BEGIN 
    SET @sql = 'SELECT * FROM sysobjects
    WHERE name like ''%' + @name + '%''
    AND type = ''' + @type + ''''
    exec (@sql)
  END
ELSE 
  BEGIN 
    SET @sql = 'SELECT * FROM sysobjects
    WHERE type = ''' + @type + ''''
    exec (@sql)
  END


GO



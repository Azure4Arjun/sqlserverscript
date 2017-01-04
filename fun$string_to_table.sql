USE [GSMCostAnalysis]
GO

/****** Object:  UserDefinedFunction [dbo].[fun$string_to_table]    Script Date: 08/08/2016 10:01:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fun$string_to_table]
(
    @Line nvarchar(MAX),
    @SplitOn nvarchar(5) = ','
)
RETURNS @RtnValue table
(
    Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    element nvarchar(100) NOT NULL
)
AS
BEGIN
    IF @Line IS NULL RETURN

    DECLARE @split_on_len INT = LEN(@SplitOn)
    DECLARE @start_at INT = 1
    DECLARE @end_at INT
    DECLARE @data_len INT

    WHILE 1=1
    BEGIN
        SET @end_at = CHARINDEX(@SplitOn,@Line,@start_at)
        SET @data_len = CASE @end_at WHEN 0 THEN LEN(@Line) ELSE @end_at-@start_at END
        INSERT INTO @RtnValue (element) VALUES( SUBSTRING(@Line,@start_at,@data_len) );
        IF @end_at = 0 BREAK;
        SET @start_at = @end_at + @split_on_len
    END

    RETURN
END

GO


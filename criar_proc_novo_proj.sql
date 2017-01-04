USE MASTER
go
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_novoprojadduser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_novoprojadduser]
GO

create proc sp_novoprojadduser 
@bancologin varchar(60)
as
SET NOCOUNT ON  
SET QUOTED_IDENTIFIER ON  

declare @stmt nvarchar(1000)
declare @stmt1 nvarchar(1000)
declare @stmt2 nvarchar(1000)
declare @stmt3 nvarchar(1000)
declare @bancosenha varchar(60)
BEGIN
set @bancologin = LOWER(@bancologin)
set @bancosenha = REVERSE(@bancologin)
set @stmt = 'use master' + CHAR(10) + 'CREATE LOGIN [' + @bancologin + ']WITH PASSWORD=N'''+ @bancosenha + ''', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF'
exec  (@stmt)
set @stmt1 = 'use siscati' + CHAR(10) + 'exec sp_adduser ''' +  @bancologin + ''',''' + @bancologin + ''',db_owner;' + CHAR(10) 
+ 'alter user [' + @bancologin + '] with default_schema = dbo;' 
exec  (@stmt1)
set @stmt2 = 'use alfabase' + CHAR(10) + 'exec sp_adduser ''' +  @bancologin + ''',''' + @bancologin + ''',db_owner;' + CHAR(10) 
+ 'alter user [' + @bancologin + '] with default_schema = dbo;' 
exec  (@stmt2)
set @stmt3 = 'use [' + @bancologin + ']' + CHAR(10) + 'exec sp_adduser ''' +  @bancologin + ''',''' + @bancologin + ''',db_owner;' + CHAR(10) 
+ 'alter user [' + @bancologin + '] with default_schema = dbo;' 
exec  (@stmt3)
SET NOCOUNT OFF
SET QUOTED_IDENTIFIER OFF
END
go

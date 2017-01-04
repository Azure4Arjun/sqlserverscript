
USE master
GO
ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = templog                                                                                                                         ,
   SIZE = 10000MB)
GO


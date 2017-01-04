USE master

ALTER DATABASE celtrak_rafael ADD FILEGROUP celtrak_rafaelFileStreamFG CONTAINS FILESTREAM;
GO
--sp_helpdb celtrak_rafael

alter database celtrak_rafael
add file
  ( NAME = 'celtrak_rafael_FileStreamName', FILENAME = 'D:\sqlserver\celtrak_rafael_FileStreamName'
   )
to filegroup celtrak_rafaelFileStreamFG;
go


ALTER DATABASE celtrak_rafael 
    SET FILESTREAM ( NON_TRANSACTED_ACCESS = FULL, DIRECTORY_NAME = N'Telematics' )
    WITH NO_WAIT; 
GO

USE celtrak_rafael 

GO


CREATE TABLE invoice_file_table   AS FileTable
WITH
(
      FileTable_Directory =   'invoice_file_table',
      FileTable_Collate_Filename = database_default
);
GO


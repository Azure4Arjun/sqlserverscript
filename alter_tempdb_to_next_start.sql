ALTER DATABASE tempdb MODIFY FILE
   (NAME = 'tempdev', SIZE = 5000) 
   --Desired target size for the data file

ALTER DATABASE tempdb MODIFY FILE
   (NAME = 'tempdev1', SIZE = 5000) 
   --Desired target size for the data file
ALTER DATABASE tempdb MODIFY FILE
   (NAME = 'tempdev2', SIZE = 5000) 
   --Desired target size for the data file

ALTER DATABASE tempdb MODIFY FILE
   (NAME = 'tempdev3', SIZE = 5000) 
   --Desired target size for the data file

   ALTER DATABASE tempdb MODIFY FILE
   (NAME = 'templog', SIZE = 1000)
   --Desired target size for the log file

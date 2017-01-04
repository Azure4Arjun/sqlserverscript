SELECT 'ALTER DATABASE [' + database_name + '] SET HADR SUSPEND;',* 
FROM sys.availability_databases_cluster

SELECT 'ALTER DATABASE [' + database_name + '] SET HADR RESUME;',* 
FROM sys.availability_databases_cluster

FormatDateTime(

, DateFormat.ShortDate)
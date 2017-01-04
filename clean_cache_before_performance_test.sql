USE celtrak_data_dev
GO
CHECKPOINT; 
GO 
DBCC DROPCLEANBUFFERS; 
GO
DBCC FLUSHPROCINDB(20);
GO
dbcc freeproccache
GO
DBCC freesystemcache ('celtrak_data_dev');


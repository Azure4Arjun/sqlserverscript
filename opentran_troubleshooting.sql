exec sp_whoisactive

SELECT * FROM sys.sysprocesses WHERE open_tran = 1


DBCC INPUTBUFFER(126)
GO


SELECT * FROM sys.dm_tran_locks
where request_session_id = 100

--dbcc opentran()

--select object_name(1478556601)

--DBCC PAGE (5,1,48163469,3)

--credit_transaction


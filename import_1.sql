USE OPVD
GO

begin transaction

BULK INSERT VENDA_REAL
FROM '\\ACSWC7\SIV_BC\Suporte\Incorporacao\VENDA_REAL.txt'
WITH
	(
		ROWTERMINATOR='\n',
		FIELDTERMINATOR='|'
	)

GO

if @@error > 0
	rollback transaction
else
	commit transaction
GO
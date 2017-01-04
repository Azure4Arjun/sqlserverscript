select @@servername
go
restore database OPVD from disk = 'caminho\OPVD.bkp'
with stats
go
restore database OPVD_HIST from disk = 'caminho\OPVD_HIST.bkp'
with stats
go
restore database OPVD_WK from disk = 'caminho\OPVD_WK.bkp'
with stats
go
restore database OPTEMP from disk = 'caminho\OPTEMP.bkp'
with stats
go

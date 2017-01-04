/*
use master
go
restore database opvd from disk = 'E:\46751_restore\opvd.bkp'
with stats
go
use master
go
restore database opvd_wk from disk = 'E:\46751_restore\opvd_wk.bkp'
with stats
go
use master
go
restore database opvd_hist from disk = 'E:\46751_restore\opvd_hist.bkp'
with stats
go
use master
go
restore database optemp from disk = 'E:\46751_restore\optemp.bkp'
with stats
go
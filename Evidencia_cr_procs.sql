use opvd_wk
go
select name, crdate from sysobjects where type <> 'p' and crdate > '2011-02-16 14:30'
go

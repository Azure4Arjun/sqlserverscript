select @@servername as Servidor
go
use afaria_cluster
go
select getdate() as Data_Verificacao
go
select b.server, count(b.server)as ultima_hora from A_LOG_SESSION a, a_server b
where a.starttime >(select dateadd(hour,-1,getdate())) -- essa data precisa ser alterada sempre para o dia atual
and a.serverid = b.serverid
group by  b.server

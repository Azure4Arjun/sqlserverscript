/* 

	Script para adicionar as extended stored procedures de acesso a arquivos TXT, 
	através da PsTxtIO.DLL.
	
	Elaborado por Point Systems S/C Ltda.

	Dezembro/1998.
*/
use master
go
sp_addextendedproc 'xp_listdir', 'pstxtio.dll'
go
sp_addextendedproc 'xp_dosshell', 'pstxtio.dll'
go
sp_addextendedproc 'xp_readtext', 'pstxtio.dll'
go
sp_addextendedproc 'xp_writetext', 'pstxtio.dll'
go
sp_addextendedproc 'xp_gravartxt', 'xp_sqlitf.dll'
go
grant exec on xp_listdir to public
go
grant exec on xp_dosshell to public
go
grant exec on xp_readtext to public
go
grant exec on xp_writetext to public
go
grant exec on xp_gravartxt to public
go

/*
-- PARA COLOCAR NOVA VERSAO DA pstxtio.dll
dbcc pstxtio(free)
go
*/


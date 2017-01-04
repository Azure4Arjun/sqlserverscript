/*	Script para verificar usuários logados
	Sistema	:	SQL7.0
	Autor:		Marcelo Takeda
	Data:		23/09/2005
*/
use master
declare	@parametro varchar(30), @usuario varchar(30), @nivel int, @id int, @tempo varchar(8), @job binary(20)
--Colocar parametros de procura ############################################--
-- alterar o @tempo para saber oq consumiu de cpu no determinado intervalo @tempo.
set @parametro	=	'all'		-- all = tudo		/ baan = baan
set @usuario	=	null		-- all = loginame	/ baan = nt_username
set @nivel	=	1		-- 1 = all = * & IO	/ baan = nome
set @id		=	null		-- null = id		/ Baan = id
set @tempo	=	'00'		-- 00 = não compara	/ Tempo para compração
set @job	=	null		-- ID do job a ser procurado
--	sp_who	kill 	dbcc inputbuffer()	-- 2 = all = active	/ baan = *
--	sp_monitor	dbcc outputbuffer()	-- 3 = all = block & kill/ baan = kill
--#########################################################################--
set nocount on
select @parametro = upper(@parametro)


--	Verifica o nome dos jobs ativos
if (select @job) is not null
begin
	select	substring(sysjb.name,1,70) as job_name
	,	case sysch.freq_type
		when	1	then	'OCASIONAL'
		when	4	then	'DIARIO'
		when	8	then	'SEMANAL'
		when	16	then	'MENSAL'
		when	32	then	'MENSAL RELATIVE'
		when	64	then	'QUANDO SQLAGENT INICALIZA'
		end as freq_type
	,	substring(convert(varchar(10),sysch.next_run_date),7,2) + '/' +
		substring(convert(varchar(10),sysch.next_run_date),5,2) + '/' +
		substring(convert(varchar(10),sysch.next_run_date),1,4) as next_run_date
	,	reverse(substring(convert(varchar(10),reverse(sysch.next_run_time)),5,2)) + ':' +
		reverse(substring(convert(varchar(10),reverse(sysch.next_run_time)),3,2)) + ':' +
		reverse(substring(convert(varchar(10),reverse(sysch.next_run_time)),1,2)) as next_run_time
	,	syslg.name
	,	sysjb.date_modified
	from		msdb.dbo.sysjobs sysjb
	inner join	master.dbo.syslogins syslg
	on		syslg.sid			=	sysjb.owner_sid
	inner join	msdb.dbo.sysjobschedules sysch
	on 		sysch.job_id			=	sysjb.job_id
	where		sysjb.job_id			=	@job
	order by job_name

	select * from #temp_compara order by physical_io desc

	return
end


--	Apara a tabela temporária para se fazer uma nova pesquisa
if exists (select * from tempdb..sysobjects where name like '#temp_compara%')
	drop table #temp_compara


--	Lista todos os processos do servidor
if (select @parametro) = 'ALL'
begin
	if (select @nivel) =	1
	begin
		select	syspc.spid
		,	syspc.blocked
		,	syspc.physical_io
		,	syspc.memusage
		,	syspc.cpu
		,	substring(syspc.status,1,12) as status
		,	substring(sysdb.name,1,20) as DBname
		,	substring(syspc.loginame,1,30) as loginame
		,	substring(syspc.nt_username,1,30) as nt_username
		,	substring(convert(varchar(20),syspc.login_time),1,25) as login_time
		,	substring(convert(varchar(20),syspc.last_batch),1,25) as last_batch
		,	substring(syspc.program_name,1,100) as program_name
		,	syspc.hostprocess
		,	syspc.cmd
		,	substring(syspc.hostname,1,30) as hostname
			into	#temp_compara
			from	master.dbo.sysprocesses syspc
			inner join master.dbo.sysdatabases sysdb
			on	sysdb.dbid	=	syspc.dbid
			where	syspc.loginame	=	isnull(@usuario,syspc.loginame)
			and	syspc.spid	=	isnull(@id,syspc.spid)
			and	syspc.cmd		not in	('MIRROR HANDLER','LAZY WRITER','CHECKPOINT SLEEP','RA MANAGER','SIGNAL HANDLER','LOCK MONITOR','LOG WRITER')
			and	syspc.program_name	not in	('SQLAgent - Alert Engine','SQLAgent - Generic Refresher')
		order by syspc.physical_io desc
--		order by syspc.cpu desc


--	Mostra resultado sem consistencia
	if	(select @tempo) = '00'
	begin
		select * from #temp_compara order by physical_io desc
	end

	else
	begin
			select @tempo = '00:00:' + @tempo
			waitfor delay @tempo
	
			select	syspc.spid
			,	syspc.blocked
			,	syspc.physical_io - tempc.physical_io as physical_io
			,	syspc.memusage - tempc.memusage as memusage
			,	syspc.cpu - tempc.cpu as cpu
			,	substring(syspc.status,1,12) as status
			,	substring(sysdb.name,1,20) as DBname
			,	substring(syspc.loginame,1,30) as loginame
			,	substring(syspc.nt_username,1,30) as nt_username
			,	substring(convert(varchar(20),syspc.login_time),1,25) as login_time
			,	substring(convert(varchar(20),syspc.last_batch),1,25) as last_batch
			,	substring(syspc.program_name,1,80) as program_name
			,	syspc.hostprocess
			,	syspc.cmd
			,	substring(syspc.hostname,1,30) as hostname
				from	master.dbo.sysprocesses syspc
				inner join master.dbo.sysdatabases sysdb
				on	sysdb.dbid	=	syspc.dbid
				inner join #temp_compara tempc
				on	tempc.spid	=	syspc.spid
				where	syspc.loginame	=	isnull(@usuario,syspc.loginame)
				and	syspc.spid	=	isnull(@id,syspc.spid)
				and	syspc.cmd		not in	('MIRROR HANDLER','LAZY WRITER','CHECKPOINT SLEEP','RA MANAGER','SIGNAL HANDLER','LOCK MONITOR','LOG WRITER')
				and	syspc.program_name	not in	('SQLAgent - Alert Engine','SQLAgent - Generic Refresher')
			order by syspc.physical_io desc
	end

	end


--	Lista os processos ATIVOS do servidor
	if (select @nivel) =	2
	begin
		select	syspc.spid
		,	syspc.blocked
		,	syspc.physical_io
		,	syspc.memusage
		,	syspc.cpu
		,	substring(syspc.status,1,12) as status
		,	substring(sysdb.name,1,20) as DBnam		,	substring(syspc.loginame,1,30) as loginame
		,	substring(syspc.nt_username,1,30) as nt_username
		,	substring(convert(varchar(20),syspc.login_time),1,25) as login_time
		,	substring(convert(varchar(20),syspc.last_batch),1,25) as last_batch
		,	substring(syspc.program_name,1,80) as program_name
		,	syspc.hostprocess
		,	syspc.cmd
		,	substring(syspc.hostname,1,30) as hostname
			from	master.dbo.sysprocesses syspc
			inner join master.dbo.sysdatabases sysdb
			on	sysdb.dbid		=	syspc.dbid
			where	syspc.loginame		=	isnull(@usuario,syspc.loginame)
			and	syspc.spid		=	isnull(@id,syspc.spid)
			and	(lower(syspc.status)	<>	'sleeping'
			or	datepart(d,syspc.login_time)	<	datepart(d,getdate())
			or	datepart(hh,syspc.last_batch)	<	datepart(hh,getdate()))
			and	syspc.cmd		not in	('MIRROR HANDLER','LAZY WRITER','CHECKPOINT SLEEP','RA MANAGER','SIGNAL HANDLER','LOCK MONITOR','LOG WRITER')
			and	syspc.program_name	not in	('SQLAgent - Alert Engine','SQLAgent - Generic Refresher')
		order by syspc.cpu desc
	end


--	Lista processos bloqueados ou que devem ser parados (kill)
	if (select @nivel) =	3
	if (select @usuario) is not null
	begin
		select	spid
		,	syspc.blocked
		,	substring(status,1,12) as status
		,	cmd
		,	substring(loginame,1,30) as loginame
		,	substring(nt_username,1,30) as nt_username
		,	substring(program_name,1,30) as program_name
		,	substring(convert(varchar(20),login_time),1,20) as login_time
		,	hostprocess
		,	substring(hostname,1,50) as hostname
		,	physical_io
		,	memusage
		,	cpu
			from		master.dbo.sysprocesses syspc
			where		loginame	=	isnull(@usuario,loginame)
			and		syspc.spid	=	isnull(@id,syspc.spid)

		select 'kill '+ cast(spid as varchar(3)) + char(13) + 'go' + char(13) as COMANDO
			from	master.dbo.sysprocesses
			where	loginame	=	isnull(@usuario,loginame)
			and	spid	=	isnull(@id,spid)
	end

	else
	begin
		select blocked into #blocked_id
			from	master.dbo.sysprocesses
			where	blocked			<>	0

		select	spid
		,	sysp.blocked
		,	substring(status,1,12) as status
		,	cmd
		,	substring(loginame,1,30) as loginame
		,	substring(nt_username,1,30) as nt_username
		,	substring(program_name,1,30) as program_name
		,	substring(convert(varchar(20),login_time),1,20) as login_time
		,	hostprocess
		,	substring(hostname,1,50) as hostname
		,	physical_io
		,	memusage
		,	cpu
			from		master.dbo.sysprocesses sysp, #blocked_id bid
			where		sysp.blocked			<>	0
			or		bid.blocked			=	spid

		select 'kill '+ cast(blocked as varchar(3)) + char(13) + 'go' + char(13) as COMANDO
			from	master.dbo.sysprocesses
			where	blocked			<>	0


		drop table #blocked_id
	end
	if (select @id) is not null
		dbcc inputbuffer(@id)

end


--	Lista usuário no BaaN, excluido os usuários baan e sysmap
if (select @parametro) = 'BAAN'
begin
	if (select @nivel) =	1
	begin
		select	substring(loginame,1,10) as loginame
		,	substring(nt_username,1,40) as nt_username
		,	max(last_batch) as ultima_exec
		,	substring(program_name,1,30) as program_name
		,	hostprocess
			from	master.dbo.sysprocesses
			where	nt_username	=	isnull(@usuario,nt_username)
			and	spid		=	isnull(@id,spid)
			and	loginame	=	'baan'
--			and	nt_username	not in	('Baan','baan')--,'SysMap','sysmap')
			group by nt_username, loginame, program_name, hostprocess
			order by nt_username
	end


--	Lista detalhando os processo do Baan
	if (select @nivel) =	2
	begin
		select	spid
		,	blocked
		,	physical_io
		,	memusage
		,	cpu
		,	substring(status,1,12) as status
		,	substring(nt_username,1,30) as nt_username
		,	substring(convert(varchar(20),login_time),1,20) as login_time
		,	hostprocess
		,	substring(program_name,1,30) as program_name
		,	hostprocess
		,	cmd
		,	substring(hostname,1,30) as hostname
			from	master.dbo.sysprocesses
			where	nt_username	=	isnull(@usuario,nt_username)
			and	spid		=	isnull(@id,spid)
			and	loginame	=	'baan'
---			and	nt_username	not in	('Baan','baan','SysMap','sysmap')
			order by physical_io desc
	end


--	Lista os processo do Baan com o comando kill
	if (select @nivel) =	3
	begin
		select	spid
		,	substring(nt_username,1,40) as nt_username
			from	master.dbo.sysprocesses
			where	nt_username	=	isnull(@usuario,nt_username)
			and	spid		=	isnull(@id,spid)
			and	loginame	=	'baan'
			and	nt_username	not in	('Baan','baan','SysMap','sysmap')
			order by spid

		select 'kill '+ cast(spid as varchar(3)) + char(13) + 'go' + char(13) 
			from	master.dbo.sysprocesses
			where	nt_username	=	isnull(@usuario,nt_username)
			and	spid		=	isnull(@id,spid)
			and	loginame	=	'baan'
			and	nt_username	not in	('Baan','baan','SysMap','sysmap')
			order by spid
	end
	if (select @id) is not null
		dbcc inputbuffer(@id)

end

set nocount off

create proc sp_RetornaCodStatusDBs
as
BEGIN

exec sp_msforeachdb 'USE [?]
if (select COUNT(1) from sysobjects where name = ''tblLogDiscador'') > 0
begin 
	
	if (select count(1) from syscolumns where name = ''RetornoDiscador'' 
	and ID = OBJECT_ID(''tblLogDiscador''))<> 0
	begin 
	declare @cmd varchar(max)
	set @cmd = ''select db_name() as Projeto, 
	YEAR(dttrabalhoini) as Ano, 
	month(dttrabalhoini) as Mes, 
	day(dttrabalhoini) as Dia, 
	datepart(hour, dttrabalhoini) as Hora, 
	sum(case
		  when RetornoDiscador = ''''0'''' then 1
		  else 0
	end) as QtdeComErro,
	sum(case
		  when RetornoDiscador = ''''0'''' then 0
		  else 1
	end) as QtdeSemErro,
	sum(case
		  when RetornoDiscador = ''''4'''' then 1
		  else 0
	end) as QtdeCom4

	from tblLogDiscador with(nolock)
	where YEAR(dttrabalhoini) = 2014 and month(dttrabalhoini) = 5
	group by YEAR(dttrabalhoini), month(dttrabalhoini), day(dttrabalhoini), datepart(hour, dttrabalhoini)
	order by YEAR(dttrabalhoini), month(dttrabalhoini), day(dttrabalhoini), datepart(hour, dttrabalhoini)''
	exec (@cmd)
	end
		
	if (select count(1) from syscolumns where name = ''codRetornoDiscador''
	and ID = OBJECT_ID(''tblLogDiscador'')) <> 0
	begin
	declare @cmd1 varchar(max)
	set @cmd1 = ''select db_name() as Projeto, 
	YEAR(dttrabalhoini) as Ano, 
	month(dttrabalhoini) as Mes, 
	day(dttrabalhoini) as Dia, 
	datepart(hour, dttrabalhoini) as Hora, 
	sum(case
		  when codRetornoDiscador = ''''0'''' then 1
		  else 0
	end) as QtdeComErro,
	sum(case
		  when codRetornoDiscador = ''''0'''' then 0
		  else 1
	end) as QtdeSemErro,
	sum(case
		  when codRetornoDiscador = ''''4'''' then 1
		  else 0
	end) as QtdeCom4

	from tblLogDiscador with(nolock)
	where YEAR(dttrabalhoini) = 2014 and month(dttrabalhoini) = 5
	group by YEAR(dttrabalhoini), month(dttrabalhoini), day(dttrabalhoini), datepart(hour, dttrabalhoini)
	order by YEAR(dttrabalhoini), month(dttrabalhoini), day(dttrabalhoini), datepart(hour, dttrabalhoini)''
	end
	exec (@cmd1)
	
	end'
	END
/*	Script para a verificação do tamanho das tabelas e 
	quantidade de registros.
	   Banco de Dados	: Todos 2000 ou superior
	   Criado por		: Rafael Gonçalez
*/
set nocount on
declare @id	int			-- The object id of @objname.
,	@type	character(2)		-- The object type.
,	@pages	int			-- Working variable for size calc.
,	@objname varchar(100) 		-- Nome da tabela
--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

set @objname = null

--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

create table #spt_space
(
	rows		int null
,	data		dec(15) null
,	indexp		dec(15) null
)

create table #result
(
	name		varchar(50)
,	rows		varchar(11)
,	data_KB		dec(15)
,	indexp_KB	dec(15)
)

select id into #tableid
from		sysobjects
where		xtype		=	'U'
and		name		=	isnull(@objname, name)
order by name


set rowcount  1
-- Inicio do processo de coleta de dados
while (select count(*) from #tableid) > 0
begin
	select @id = id from #tableid

	/*
	** data: sum(dpages) where indid < 2
	**	+ sum(used) where indid = 255 (text)
	*/
	select @pages = sum(dpages)
			from sysindexes
				where indid < 2
					and id = @id
	select @pages = @pages + isnull(sum(used), 0)
		from sysindexes
			where indid = 255
				and id = @id
	insert into #spt_space (data)
		select @pages

	/* index: sum(used) where indid in (0, 1, 255) - data */
	update #spt_space
		set indexp = (select sum(used)
				from sysindexes
					where indid in (0, 1, 255)
						and id = @id)
			    - data
	update #spt_space
		set rows = i.rows
			from sysindexes i
				where i.indid < 2
					and i.id = @id

insert into #result
	select substring(object_name(@id), 1, 50),
		convert(char(11), rows),
		data * d.low / 1024,
		indexp * d.low / 1024
	from #spt_space, master.dbo.spt_values d
		where d.number = 1
		and d.type = 'E'

	delete from #tableid where id = @id
	delete from #spt_space

end

set rowcount 0

select * from #result order by data_KB desc

drop table #spt_space
drop table #tableid
drop table #result

set nocount off


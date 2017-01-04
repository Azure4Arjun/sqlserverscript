use msdb
go
select * from (
select distinct  
	sj.name as Job,
	case when (sj.enabled = 1) then 'Habilitado' else 'Desabilitado' end as Status,
	Case 
	  When ssch.freq_type = 1 then 'Uma vez'
	  When ssch.freq_type = 4 then 'Diariamente'
	  When ssch.freq_type = 8 then 'Semanalmente'
	  When ssch.freq_type = 16 then 'Mensalmente'
	  When ssch.freq_type = 32 then 'Mensalmente (Relativo)'
	  When ssch.freq_type = 64 then 'Quando SQL Server Agent é iniciado'
	End as Frequencia,
	(select case
		when len(cast(sum(last_run_duration) AS varchar(10))) = 1 then '00:0' + SUBSTRING(cast(sum(last_run_duration) as varchar(10)),1,1)
		when len(cast(sum(last_run_duration) AS varchar(10))) = 2 then '00:' + SUBSTRING(cast(sum(last_run_duration) as varchar(10)),1,2)
		when len(cast(sum(last_run_duration) AS varchar(10))) = 3 then '0' + SUBSTRING(cast(sum(last_run_duration) as varchar(10)),1,1) + ':0' + SUBSTRING(cast(sum(last_run_duration) as varchar(10)),3,2)
		when len(cast(sum(last_run_duration) AS varchar(10))) = 4 then SUBSTRING(cast(sum(last_run_duration) as varchar(10)),1,2) + ':00'
		else cast(sum(last_run_duration) AS varchar(10))
		end
		from sysjobsteps where job_id = sj.job_id) AS Duração_Última_Execução,
	Case 
	  When Len(sjs.next_run_time) = 1 then '0' + Cast(sjs.next_run_time as varchar(1)) + ':00:00'
	  When Len(sjs.next_run_time) = 5 then '0' + Substring(Cast(sjs.next_run_time as varchar(15)),1,1) + ':' + Substring(Cast(sjs.next_run_time as varchar(15)),2,2) + ':' + Substring(Cast(sjs.next_run_time as varchar(15)),4,2)
	  When Len(sjs.next_run_time) = 5 then Substring(Cast(sjs.next_run_time as varchar(15)),1,2) + ':' + Substring(Cast(sjs.next_run_time as varchar(15)),3,2) + ':' + Substring(Cast(sjs.next_run_time as varchar(15)),5,2)
	  When LEN(sjs.next_run_time) > 5 then Substring(Cast(sjs.next_run_time as varchar(15)),1,2) + ':' + Substring(Cast(sjs.next_run_time as varchar(15)),3,2) + ':' + Substring(Cast(sjs.next_run_time as varchar(15)),5,2)
	Else
	  --'00:00:00'
	  cast(sjs.next_run_time as varchar(15))
	End  as Próxima_Execução,
GETDATE() AS Data_Checagem
from
	sysjobs sj 
inner join
	sysjobschedules sjs
on
	sj.job_id = sjs.job_id
inner join 
	sysschedules ssch
on
	sjs.schedule_id = ssch.schedule_id
) sql where Frequencia <> 'Mensalmente' order by Próxima_Execução asc--and CAST(substring(Próxima_Execução,1,2) as int) > 18
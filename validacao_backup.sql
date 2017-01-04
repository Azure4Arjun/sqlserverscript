select @@servername as Server
go
select top 9 	@@servername as servidor,
		database_name,
		backup_start_date, 
		backup_finish_date, 
		type,  
		tempo_duracao = 	  Convert(VarChar(10), DATEDIFF(MI, backup_start_date, backup_finish_date) / 60) + ':' + 
                Right(Replicate('0', 2) + Convert(VarChar(10), DATEDIFF(MI, backup_start_date, backup_finish_date) % 60), 2)+':'+
		Right(Replicate('0', 2) + Convert(VarChar(10), DATEDIFF(SS, backup_start_date, backup_finish_date) % 60), 2)
		
from msdb..backupset
where type = 'D'
and backup_start_date >= '2011-10-03'
order by backup_start_date desc
go

 

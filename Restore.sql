========================================================================================================================
-- Restore em que servidor Destino é diferente do Origem
========================================================================================================================

RESTORE DATABASE DTB_COMUNICACAO -- nome do banco
FROM DISK = 'H:\MSSQL2005\Restore_INC966404\DTB_RH_INTRANET_200801.bkp' -- caminho do arquivo de BKP
WITH 																							
MOVE 		'DTB_COMUNICACAO_Data' TO 'F:\MSSQL2005\MSSQL.1\MSSQL\Data\DTB_COMUNICACAO_Data.MDF',-- com
			-- Mover o arquivo para o caminho onde ficará o arquivo de dados
MOVE 		'DTB_COMUNICACAO_Log' TO 'F:\MSSQL2005\LOG\DTB_COMUNICACAO_LOG.LDF',
			-- Mover o arquivo de log para onde ficará o arquivo de log
STATS = 1,	-- o STATS mostra a porcentagem de conclusão 
replace		-- o Replace, caso o arquivo exista ela sobrepõe o antigo
		
GO

========================================================================================================================
-- Mostrar nome lógico dos arquivos a serem restaudaros
========================================================================================================================

restore filelistonly from disk = '<Caminho do backup/nome do backup.bkp>'
-- Irá retornar o nome lógico do arquivo

========================================================================================================================
-- Restore com Stripes
========================================================================================================================

restore database <nome do banco> 
from	disk = '<caminho do bkp>',
		disk = '<caminho do bkp>'
with 
move '<nome lógico do mdf>' to '<caminho onde ficará o .mdf>',
move '<nome lógico do ldf>' to '<caminho onde ficará o .ldf>', 

--Exemplo:

restore database MACCHIPS 
from 
disk = 'I:\CHANGE - 806719\MACCHIPS_0.bkp',
disk = 'J:\CHANGE - 806719\MACCHIPS_1.bkp'
with 
move	'macchips_data' 	 	 to 'I:\Dados\MSSQL\MACCHIPS\macchips_Data.mdf',
move	'macchips_log'		 to 'I:\Dados\MSSQL\MACCHIPS\macchips_Log.ldf', 
stats

========================================================================================================================
-- Acertar usuários do Banco Restaurado
========================================================================================================================

sp_change_users_login 'UPDATE_ONE','<login>','<usuário>'

--Exemplo
sp_change_users_login 'UPDATE_ONE','user_rh','user_rh'

========================================================================================================================
-- Montar Script para acerto de usuários
========================================================================================================================

set nocount on
select 'sp_change_users_login "update_one", "'+ name +'", "'+ name + '"' + char(13) + 'go' + char(13) from sysusers where status = 2
set nocount off

========================================================================================================================
-- Confirmar se o restore foi ok 

use msdb
select * from restorehistory where restore_date >= '2010-04-13 00:00:00' 

========================================================================================================================

USE t4bdb01
GO

declare @bkpPath varchar(255),
		@msg varchar(2000)

set @bkpPath = '### INSIRA AQUI O DIRETÓRIO DOS BACKUPS, SEM A BARRA (\) NO FINAL ###'

if @bkpPath = '### INSIRA AQUI O DIRETÓRIO DOS BACKUPS, SEM A BARRA (\) NO FINAL ###'		-- Não alterar esta linha
begin
	select @msg = 'Por favor, informe o diretório dos backups no local indicado.'
	RAISERROR(@msg, 16, 1)
end
else
begin
	INSERT INTO t4b_procadm_param (
		SERVER,
		DBNAME,
		ACTIVE,
		BACKUP_PATH,
		BACKUP_LG_PATH,
		BACKUP_FULL,
		BACKUP_LOG,
		BACKUP_DIFF,
		SPACE_DB_MON,
		SPACE_LG_MON,
		SPACE_LG_SIZE,
		SPACE_DB_GROWTH,
		SPACE_TAB_GROWTH,
		UPDATE_STATS,
		CHECK_DB,
		REINDEX,
		QTD_BACKUP_STRIPES,
		QTD_BACKUP_DIFF,
		CTR_BACKUP_DIFF,
		THRESH_DB_SPACE,
		THRESH_LG_SPACE,
		THRESH_LG_SIZE,
		THRESH_REINDEX,
		DF_VALUE,
		DF_TIMESTAMP
	)
	select @@SERVERNAME, 'master', 1, @bkpPath + '\BKPSQLCOMP\', @bkpPath + '\BKPSQLLOG\', 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 90, 60, 0, 90, NULL, NULL
	union all
	select @@SERVERNAME, 'model', 1, @bkpPath + '\BKPSQLCOMP\', @bkpPath + '\BKPSQLLOG\', 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 90, 60, 0, 90, NULL, NULL
	union all
	select @@SERVERNAME, 'msdb', 1, @bkpPath + '\BKPSQLCOMP\', @bkpPath + '\BKPSQLLOG\', 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 90, 60, 0, 90, NULL, NULL
	union all
	select @@SERVERNAME, 't4bdb01', 1, @bkpPath + '\BKPSQLCOMP\', @bkpPath + '\BKPSQLLOG\', 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0, 90, 60, 0, 90, NULL, NULL
end
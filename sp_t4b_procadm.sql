/*********************************************************************************************************
	POSSÕVEIS PAR¬METROS PARA A VARI¡VEL @param:
		* 'BACKUP_IND'				->		Backup individual de um banco
		* 'BACKUP_IND_RET'			->		Backup individual de um banco, com retenÁ„o
		* 'BACKUP_FULL_NOSTRIPE'		->		Backup sem divis„o em stripes
		* 'BKP_FULL_NOSTRP_RET'			->		Backup sem divis„o em stripes, com retenÁ„o
		* 'BACKUP_FULL'				->		Backup de todos os bancos
		* 'BACKUP_FULL_RET'			->		Backup de todos os bancos, com retenÁ„o
		* 'BACKUP_FULL_TDP'			->		Backup de todos os bancos, via TDP
		* 'BACKUP_LOG_TDP'			->		Backup de log de todos os bancos, via TDP
		* 'BACKUP_LOG'				->		Backup de log de todos os bancos
		* 'BACKUP_DIFF'				->		Backup diferencial de todos os bancos
		* 'BACKUP_DIFF_RET'			->		Backup diferencial de todos os bancos, com retenÁ„o
		* 'UPDATE_STATS'			->		
		* 'CHECK_DB'				->		
		* 'REINDEX'				->		
		* 'SPACE_DB_MON'			->		
		* 'SPACE_LG_MON'			->		
		* 'SPACE_DB_GROWTH'			->			
		* 'SPACE_TAB_GROWTH'			->		
		* 'DISKSPACE'				->		
		* 'HOUSEKEEPING'			->		
		* 'SHRINK_LOG'				->		
*********************************************************************************************************/
CREATE PROCEDURE [dbo].[sp_t4b_procadm] (
	@param CHAR(50),
	@param_db NVARCHAR(128) = NULL
)
AS

SET NOCOUNT ON

DECLARE
	@server NVARCHAR(128),
	@dbname nvarchar(128),
	@backup_path NVARCHAR(600),
	@backup_full_path NVARCHAR(600),
	@msg NVARCHAR(512),
	@currdate VARCHAR(20),
	@qtd_stripes TINYINT,
	@controle_backup_diff TINYINT,
	@cont TINYINT,
	@cmd VARCHAR(8000),
	@etime INT,
	@etime1 DATETIME,
	@etime2 DATETIME,
	@avg_etime_1wk INT,
	@avg_etime_1mm INT,
	@avg_etime_3mm INT,
	@avg_etime_1yy INT,
	@hk_days INT,
	@rows INT,
	@del_cmd VARCHAR(500),
	@sql_text NVARCHAR(1000),
	@collation_tempdb varchar(50)

SELECT @server = @@SERVERNAME

-- Obtendo collation do tempdb, para npo dar problema na comparatpo entre os campos data tabela temporﬂria e os da t4b_procadm_param
CREATE TABLE #Collation (
	coll varchar(50)
)

IF NOT REPLACE(@@VERSION, '  ', ' ') LIKE 'Microsoft SQL Server 7%'
BEGIN
	insert into #Collation (coll)
	exec('SELECT CONVERT(varchar, DATABASEPROPERTYEX(''tempdb'', ''Collation''))')
END

SELECT @collation_tempdb = ISNULL(coll, '') FROM #Collation

DROP TABLE #Collation


IF @param = 'BACKUP_IND'
BEGIN

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de backup do database ' + @param_db
	PRINT @msg

	SELECT	@dbname = DBNAME,
			@backup_path = BACKUP_PATH,
			@qtd_stripes = QTD_BACKUP_STRIPES
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND DBNAME = @param_db

	IF @dbname IS NULL
	BEGIN

		SELECT @msg = ' [%s][%s] Database ' + @param_db + ' inexistente no servidor'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		RETURN

	END

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do backup full do database ' + @dbname + ' para ' + @backup_path
	PRINT @msg

	IF (SELECT ([status] & 32) from master..sysdatabases WHERE [name] = @dbname) = 0	-- Se o banco nao estiver em loading...
	BEGIN
		IF @qtd_stripes = 1
		BEGIN

			SELECT @backup_full_path = @backup_path + @dbname + '.bkp'

			SELECT @etime1 = GETDATE()

			SELECT @cmd = 'BACKUP DATABASE ' + QUOTENAME(@dbname) + ' TO DISK=''' + @backup_full_path + ''' WITH INIT, STATS'

			EXEC (@cmd)

			IF @@ERROR != 0
			BEGIN
	
				SELECT @msg = ' [%s][%s] Erro no processo de backup database ' + @dbname
				SELECT @currdate = CONVERT(VARCHAR, GETDATE())
				RAISERROR (@msg, 16,1, @currdate, @server)

				RETURN 1

			END

			SELECT @etime2 = GETDATE()
			SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

			INSERT INTO [t4bdb01].[dbo].[t4b_info_backup]
			VALUES (GETDATE(),@dbname,@etime,@param)

			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup full do database ' + @dbname
			PRINT @msg
	
			UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
			SET CTR_BACKUP_DIFF = 0
			WHERE SERVER = @server
			AND DBNAME = @dbname
			AND BACKUP_FULL = 1
			AND BACKUP_DIFF = 1
	
		END

		ELSE

		BEGIN

			SELECT @cont = 0,
				   @cmd = ''
	
			WHILE @cont < @qtd_stripes
			BEGIN

				SELECT @backup_full_path = @backup_path + @dbname + '_' + CONVERT(VARCHAR,@cont) + '.bkp'
				SELECT @cmd = @cmd + 'DISK = ''' + @backup_full_path + ''','
				SELECT @cont = @cont + 1
		
			END
	
			SELECT @cmd = SUBSTRING(@cmd,1,LEN(@cmd)-1)
			SELECT @cmd = 'BACKUP DATABASE ' + QUOTENAME(@dbname) + ' TO ' + @cmd + ' WITH INIT, STATS'

			SELECT @etime1 = GETDATE()

			EXEC (@cmd)

			IF @@ERROR != 0
			BEGIN

				SELECT @msg = ' [%s][%s] Erro no processo de backup, database ' + @dbname
				SELECT @currdate = CONVERT(VARCHAR, GETDATE())
				RAISERROR (@msg, 16,1, @currdate, @server)
				RETURN 1
			END
	
			SELECT @etime2 = GETDATE()
			SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

			INSERT INTO [t4bdb01].[dbo].[t4b_info_backup]
			VALUES (GETDATE(),@dbname,@etime,@param)
	
			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup full do database ' + @dbname
			PRINT @msg
	
			UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
			SET CTR_BACKUP_DIFF = 0
			WHERE SERVER = @server
			AND DBNAME = @dbname
			AND BACKUP_FULL = 1
			AND BACKUP_DIFF = 1
		END

	END
	
	RETURN

END

ELSE IF @param = 'BACKUP_IND_RET'
BEGIN

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de backup do database ' + @param_db
	PRINT @msg
	
	-- Monta a string da data atual, para compor o nome do arquivo de backup:
	SELECT @currdate = CONVERT(VARCHAR,YEAR(GETDATE())) +
	RIGHT('00' + CONVERT(VARCHAR,MONTH(GETDATE())),2) +
	RIGHT('00' + CONVERT(VARCHAR,DAY(GETDATE())),2) + '_' +
	RIGHT('00' + CONVERT(VARCHAR, DATEPART(hh, GETDATE())),2) +
	RIGHT('00' + CONVERT(VARCHAR, DATEPART(mi, GETDATE())),2) +
	RIGHT('00' + CONVERT(VARCHAR, DATEPART(ss, GETDATE())),2)

	SELECT	@dbname = DBNAME,
			@backup_path = BACKUP_PATH,
			@qtd_stripes = QTD_BACKUP_STRIPES
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND DBNAME = @param_db

	IF @dbname IS NULL
	BEGIN

		SELECT @msg = ' [%s][%s] Database ' + @param_db + ' inexistente no servidor'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		RETURN

	END

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do backup full do database ' + @dbname + ' para ' + @backup_path
	PRINT @msg

	IF (SELECT ([status] & 32) from master..sysdatabases WHERE [name] = @dbname) = 0	-- Se o banco nao estiver em loading...
	BEGIN
		IF @qtd_stripes = 1
		BEGIN

			-- O nome do arquivo de backup È composto pelo nome do banco + a data, semelhante ao backup de log:
			SELECT @backup_full_path = @backup_path + @dbname + '_' + @currdate + '.bkp'

			SELECT @etime1 = GETDATE()

			SELECT @cmd = 'BACKUP DATABASE ' + QUOTENAME(@dbname) + ' TO DISK=''' + @backup_full_path + ''' WITH INIT, STATS'

			EXEC (@cmd)

			IF @@ERROR != 0
			BEGIN
	
				SELECT @msg = ' [%s][%s] Erro no processo de backup database ' + @dbname
				SELECT @currdate = CONVERT(VARCHAR, GETDATE())
				RAISERROR (@msg, 16,1, @currdate, @server)

				RETURN 1

			END

			SELECT @etime2 = GETDATE()
			SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

			INSERT INTO [t4bdb01].[dbo].[t4b_info_backup]
			VALUES (GETDATE(),@dbname,@etime,@param)

			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup full do database ' + @dbname
			PRINT @msg
	
			UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
			SET CTR_BACKUP_DIFF = 0
			WHERE SERVER = @server
			AND DBNAME = @dbname
			AND BACKUP_FULL = 1
			AND BACKUP_DIFF = 1
	
		END

		ELSE

		BEGIN

			SELECT @cont = 0,
				   @cmd = ''
	
			WHILE @cont < @qtd_stripes
			BEGIN

				SELECT @backup_full_path = @backup_path + @dbname + '_' + @currdate + '_' + CONVERT(VARCHAR,@cont) + '.bkp'
				SELECT @cmd = @cmd + 'DISK = ''' + @backup_full_path + ''','
				SELECT @cont = @cont + 1
		
			END
	
			SELECT @cmd = SUBSTRING(@cmd,1,LEN(@cmd)-1)
			SELECT @cmd = 'BACKUP DATABASE ' + QUOTENAME(@dbname) + ' TO ' + @cmd + ' WITH INIT, STATS'

			SELECT @etime1 = GETDATE()

			EXEC (@cmd)

			IF @@ERROR != 0
			BEGIN

				SELECT @msg = ' [%s][%s] Erro no processo de backup, database ' + @dbname
				SELECT @currdate = CONVERT(VARCHAR, GETDATE())
				RAISERROR (@msg, 16,1, @currdate, @server)
				RETURN 1
			END
	
			SELECT @etime2 = GETDATE()
			SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

			INSERT INTO [t4bdb01].[dbo].[t4b_info_backup]
			VALUES (GETDATE(),@dbname,@etime,@param)
	
			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup full do database ' + @dbname
			PRINT @msg
	
			UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
			SET CTR_BACKUP_DIFF = 0
			WHERE SERVER = @server
			AND DBNAME = @dbname
			AND BACKUP_FULL = 1
			AND BACKUP_DIFF = 1
		END

	END
	
	RETURN

END

ELSE IF @param = 'BACKUP_FULL_NOSTRIPE'
BEGIN

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de backup full'
	PRINT @msg

	DECLARE cur_db CURSOR FOR
	SELECT	DBNAME,
			BACKUP_PATH
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND BACKUP_FULL = 1
	AND ACTIVE = 1
	ORDER BY SIZE DESC

	OPEN cur_db

	IF @@CURSOR_ROWS = 0
	BEGIN

		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para realizar o backup full sem stripe'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		CLOSE cur_db
		DEALLOCATE cur_db

		RETURN

	END

	FETCH cur_db
	INTO @dbname,
		 @backup_path

	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF (SELECT ([status] & 32) from master..sysdatabases WHERE [name] = @dbname) = 0	-- Se o banco nao estiver em loading...
		BEGIN
			SELECT @del_cmd = 'del /q ' + @backup_path + @dbname + '_?.bkp'
			
			EXEC master..xp_cmdshell @del_cmd, no_output

			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do backup full do database ' + @dbname + ' para ' + @backup_path
			PRINT @msg

			SELECT @backup_full_path = @backup_path + @dbname + '.bkp'
	
			SELECT @cmd = 'BACKUP DATABASE ' + QUOTENAME(@dbname) + ' TO DISK=''' + @backup_full_path + ''' WITH INIT, STATS'

			SELECT @etime1 = GETDATE()

			EXEC (@cmd)

			IF @@ERROR != 0
			BEGIN

				SELECT @msg = ' [%s][%s] Erro no processo de backup, database ' + @dbname
				SELECT @currdate = CONVERT(VARCHAR, GETDATE())
				RAISERROR (@msg, 16,1, @currdate, @server)

				CLOSE cur_db
				DEALLOCATE cur_db

				RETURN 1
			END

			SELECT @etime2 = GETDATE()
			SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

			INSERT INTO [t4bdb01].[dbo].[t4b_info_backup]
			VALUES (GETDATE(),@dbname,@etime,@param)
	
			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup full do database ' + @dbname
			PRINT @msg
	
			UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
			SET CTR_BACKUP_DIFF = 0
			WHERE SERVER = @server
			AND DBNAME = @dbname
			AND BACKUP_FULL = 1
			AND BACKUP_DIFF = 1
	
		END

		FETCH cur_db
		INTO @dbname,
			 @backup_path

	END

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do processo de backup full'
	PRINT @msg

	CLOSE cur_db
	DEALLOCATE cur_db

	RETURN

END

ELSE IF @param = 'BKP_FULL_NOSTRP_RET'
BEGIN

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de backup full'
	PRINT @msg

	-- Monta a string da data atual, para compor o nome do arquivo de backup:
	SELECT @currdate = CONVERT(VARCHAR,YEAR(GETDATE())) +
	RIGHT('00' + CONVERT(VARCHAR,MONTH(GETDATE())),2) +
	RIGHT('00' + CONVERT(VARCHAR,DAY(GETDATE())),2) + '_' +
	RIGHT('00' + CONVERT(VARCHAR, DATEPART(hh, GETDATE())),2) +
	RIGHT('00' + CONVERT(VARCHAR, DATEPART(mi, GETDATE())),2) +
	RIGHT('00' + CONVERT(VARCHAR, DATEPART(ss, GETDATE())),2)

	DECLARE cur_db CURSOR FOR
	SELECT	DBNAME,
			BACKUP_PATH
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND BACKUP_FULL = 1
	AND ACTIVE = 1
	ORDER BY SIZE DESC

	OPEN cur_db

	IF @@CURSOR_ROWS = 0
	BEGIN

		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para realizar o backup full sem stripes'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		CLOSE cur_db
		DEALLOCATE cur_db

		RETURN

	END

	FETCH cur_db
	INTO @dbname,
		 @backup_path

	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF (SELECT ([status] & 32) from master..sysdatabases WHERE [name] = @dbname) = 0	-- Se o banco nao estiver em loading...
		BEGIN
			--SELECT @del_cmd = 'del /q ' + @backup_path + @dbname + '_?.bkp'
			
			--EXEC master..xp_cmdshell @del_cmd, no_output

			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do backup full do database ' + @dbname + ' para ' + @backup_path
			PRINT @msg

			-- O nome do arquivo de backup È composto pelo nome do banco + a data, semelhante ao backup de log:
			SELECT @backup_full_path = @backup_path + @dbname + '_' + @currdate + '.bkp'
	
			SELECT @cmd = 'BACKUP DATABASE ' + QUOTENAME(@dbname) + ' TO DISK=''' + @backup_full_path + ''' WITH INIT, STATS'

			SELECT @etime1 = GETDATE()

			EXEC (@cmd)

			IF @@ERROR != 0
			BEGIN

				SELECT @msg = ' [%s][%s] Erro no processo de backup, database ' + @dbname
				SELECT @currdate = CONVERT(VARCHAR, GETDATE())
				RAISERROR (@msg, 16,1, @currdate, @server)

				CLOSE cur_db
				DEALLOCATE cur_db

				RETURN 1
			END

			SELECT @etime2 = GETDATE()
			SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

			INSERT INTO [t4bdb01].[dbo].[t4b_info_backup]
			VALUES (GETDATE(),@dbname,@etime,@param)
	
			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup full do database ' + @dbname
			PRINT @msg
	
			UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
			SET CTR_BACKUP_DIFF = 0
			WHERE SERVER = @server
			AND DBNAME = @dbname
			AND BACKUP_FULL = 1
			AND BACKUP_DIFF = 1
	
		END

		FETCH cur_db
		INTO @dbname,
			 @backup_path

	END

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do processo de backup full'
	PRINT @msg

	CLOSE cur_db
	DEALLOCATE cur_db

	RETURN

END

ELSE IF @param = 'BACKUP_FULL'
BEGIN

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de backup full'
	PRINT @msg

	DECLARE cur_db CURSOR FOR
	SELECT  DBNAME,
			BACKUP_PATH,
			QTD_BACKUP_STRIPES
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND BACKUP_FULL = 1
	AND ACTIVE = 1
	ORDER BY SIZE DESC

	OPEN cur_db

	IF @@CURSOR_ROWS = 0
	BEGIN

		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para realizar o backup full'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		CLOSE cur_db
		DEALLOCATE cur_db

		RETURN

	END

	FETCH cur_db
	INTO @dbname,
		 @backup_path,
		 @qtd_stripes

	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF (SELECT ([status] & 32) from master..sysdatabases WHERE [name] = @dbname) = 0	-- Se o banco nao estiver em loading...
		BEGIN
			SELECT @del_cmd = 'del /q ' + @backup_path + @dbname + '_?.bkp'
			
			EXEC master..xp_cmdshell @del_cmd, no_output
	
			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do backup full do database ' + @dbname + ' para ' + @backup_path
			PRINT @msg
	
			IF @qtd_stripes = 1
			BEGIN

				SELECT @backup_full_path = @backup_path + @dbname + '.bkp'
	
				SELECT @cmd = 'BACKUP DATABASE ' + QUOTENAME(@dbname) + ' TO DISK=''' + @backup_full_path + ''' WITH INIT, STATS'

				SELECT @etime1 = GETDATE()

				EXEC (@cmd)

				IF @@ERROR != 0
				BEGIN

					SELECT @msg = ' [%s][%s] Erro no processo de backup database ' + @dbname
					SELECT @currdate = CONVERT(VARCHAR, GETDATE())
					RAISERROR (@msg, 16,1, @currdate, @server)

					CLOSE cur_db
					DEALLOCATE cur_db
	
					RETURN 1

				END
	
				SELECT @etime2 = GETDATE()
				SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

				INSERT INTO [t4bdb01].[dbo].[t4b_info_backup]
				VALUES (GETDATE(),@dbname,@etime,@param)

				SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup full do database ' + @dbname
				PRINT @msg
	
				UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
				SET CTR_BACKUP_DIFF = 0
				WHERE SERVER = @server
				AND DBNAME = @dbname
				AND BACKUP_FULL = 1
				AND BACKUP_DIFF = 1
	
			END

			ELSE

			BEGIN

				SELECT  @cont = 0,
						@cmd = ''
	
				WHILE @cont < @qtd_stripes
				BEGIN

					SELECT @backup_full_path = @backup_path + @dbname + '_' + CONVERT(VARCHAR,@cont) + '.bkp'
					SELECT @cmd = @cmd + 'DISK = ''' + @backup_full_path + ''','
	
					SELECT @cont = @cont + 1

				END

				SELECT @del_cmd = 'del /q ' + @backup_path + @dbname + '_?.bkp'
			
				EXEC master..xp_cmdshell @del_cmd, no_output

				SELECT @cmd = SUBSTRING(@cmd,1,LEN(@cmd)-1)
				SELECT @cmd = 'BACKUP DATABASE ' + QUOTENAME(@dbname) + ' TO ' + @cmd + ' WITH INIT, STATS'

				SELECT @etime1 = GETDATE()

				EXEC (@cmd)

				IF @@ERROR != 0
				BEGIN

					SELECT @msg = ' [%s][%s] Erro no processo de backup database ' + @dbname
					SELECT @currdate = CONVERT(VARCHAR, GETDATE())
					RAISERROR (@msg, 16,1, @currdate, @server)

					CLOSE cur_db
					DEALLOCATE cur_db

					RETURN 1

				END
	
				SELECT @etime2 = GETDATE()
				SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

				INSERT INTO [t4bdb01].[dbo].[t4b_info_backup]
				VALUES (GETDATE(),@dbname,@etime,@param)
	
				SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup full do database ' + @dbname
				PRINT @msg

				UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
				SET CTR_BACKUP_DIFF = 0
				WHERE SERVER = @server
				AND DBNAME = @dbname
				AND BACKUP_FULL = 1
				AND BACKUP_DIFF = 1

			END

		END

		FETCH cur_db
		INTO @dbname,
			 @backup_path,
			 @qtd_stripes

	END

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do processo de backup full'
	PRINT @msg

	CLOSE cur_db
	DEALLOCATE cur_db

	RETURN

END

ELSE IF @param = 'BACKUP_FULL_RET'
BEGIN

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de backup full'
	PRINT @msg
	
	-- Monta a string da data atual, para compor o nome do arquivo de backup:
	SELECT @currdate = CONVERT(VARCHAR,YEAR(GETDATE())) +
	RIGHT('00' + CONVERT(VARCHAR,MONTH(GETDATE())),2) +
	RIGHT('00' + CONVERT(VARCHAR,DAY(GETDATE())),2) + '_' +
	RIGHT('00' + CONVERT(VARCHAR, DATEPART(hh, GETDATE())),2) +
	RIGHT('00' + CONVERT(VARCHAR, DATEPART(mi, GETDATE())),2) +
	RIGHT('00' + CONVERT(VARCHAR, DATEPART(ss, GETDATE())),2)

	DECLARE cur_db CURSOR FOR
	SELECT  DBNAME,
			BACKUP_PATH,
			QTD_BACKUP_STRIPES
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND BACKUP_FULL = 1
	AND ACTIVE = 1
	ORDER BY SIZE DESC

	OPEN cur_db

	IF @@CURSOR_ROWS = 0
	BEGIN

		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para realizar o backup full'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		CLOSE cur_db
		DEALLOCATE cur_db

		RETURN

	END

	FETCH cur_db
	INTO @dbname,
		 @backup_path,
		 @qtd_stripes

	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF (SELECT ([status] & 32) from master..sysdatabases WHERE [name] = @dbname) = 0	-- Se o banco n„o estiver em loading...
		BEGIN
			--SELECT @del_cmd = 'del /q ' + @backup_path + @dbname + '_?.bkp'
			
			--EXEC master..xp_cmdshell @del_cmd, no_output
	
			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do backup full do database ' + @dbname + ' para ' + @backup_path
			PRINT @msg
	
			IF @qtd_stripes = 1
			BEGIN

				-- O nome do arquivo de backup È composto pelo nome do banco + a data, semelhante ao backup de log:
				SELECT @backup_full_path = @backup_path + @dbname + '_' + @currdate + '.bkp'
	
				SELECT @cmd = 'BACKUP DATABASE ' + QUOTENAME(@dbname) + ' TO DISK=''' + @backup_full_path + ''' WITH INIT, STATS'

				SELECT @etime1 = GETDATE()

				EXEC (@cmd)

				IF @@ERROR != 0
				BEGIN

					SELECT @msg = ' [%s][%s] Erro no processo de backup database ' + @dbname
					SELECT @currdate = CONVERT(VARCHAR, GETDATE())
					RAISERROR (@msg, 16,1, @currdate, @server)

					CLOSE cur_db
					DEALLOCATE cur_db
	
					RETURN 1

				END
	
				SELECT @etime2 = GETDATE()
				SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

				INSERT INTO [t4bdb01].[dbo].[t4b_info_backup]
				VALUES (GETDATE(),@dbname,@etime,@param)

				SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup full do database ' + @dbname
				PRINT @msg
	
				UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
				SET CTR_BACKUP_DIFF = 0
				WHERE SERVER = @server
				AND DBNAME = @dbname
				AND BACKUP_FULL = 1
				AND BACKUP_DIFF = 1
	
			END

			ELSE

			BEGIN

				SELECT  @cont = 0,
						@cmd = ''
	
				WHILE @cont < @qtd_stripes
				BEGIN

					SELECT @backup_full_path = @backup_path + @dbname + '_' + @currdate + '_' + CONVERT(VARCHAR,@cont) + '.bkp'
					SELECT @cmd = @cmd + 'DISK = ''' + @backup_full_path + ''','
	
					SELECT @cont = @cont + 1

				END

				--SELECT @del_cmd = 'del /q ' + @backup_path + @dbname + '_?.bkp'
			
				--EXEC master..xp_cmdshell @del_cmd, no_output

				SELECT @cmd = SUBSTRING(@cmd,1,LEN(@cmd)-1)
				SELECT @cmd = 'BACKUP DATABASE ' + QUOTENAME(@dbname) + ' TO ' + @cmd + ' WITH INIT, STATS'

				SELECT @etime1 = GETDATE()

				EXEC (@cmd)

				IF @@ERROR != 0
				BEGIN

					SELECT @msg = ' [%s][%s] Erro no processo de backup database ' + @dbname
					SELECT @currdate = CONVERT(VARCHAR, GETDATE())
					RAISERROR (@msg, 16,1, @currdate, @server)

					CLOSE cur_db
					DEALLOCATE cur_db

					RETURN 1

				END
	
				SELECT @etime2 = GETDATE()
				SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

				INSERT INTO [t4bdb01].[dbo].[t4b_info_backup]
				VALUES (GETDATE(),@dbname,@etime,@param)
	
				SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup full do database ' + @dbname
				PRINT @msg

				UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
				SET CTR_BACKUP_DIFF = 0
				WHERE SERVER = @server
				AND DBNAME = @dbname
				AND BACKUP_FULL = 1
				AND BACKUP_DIFF = 1

			END

		END

		FETCH cur_db
		INTO @dbname,
			 @backup_path,
			 @qtd_stripes

	END

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do processo de backup full'
	PRINT @msg

	CLOSE cur_db
	DEALLOCATE cur_db

	RETURN

END

ELSE IF @param = 'BACKUP_FULL_TDP'
BEGIN

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de backup full via TDP'
	PRINT @msg

	DECLARE cur_db CURSOR FOR
	SELECT  DBNAME
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND BACKUP_FULL = 1
	AND ACTIVE = 1
	ORDER BY SIZE DESC

	OPEN cur_db

	IF @@CURSOR_ROWS = 0
	BEGIN
		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para realizar o backup full'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		CLOSE cur_db
		DEALLOCATE cur_db

		RETURN
	END

	FETCH cur_db INTO @dbname

	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		IF (SELECT ([status] & 32) from master..sysdatabases WHERE [name] = @dbname) = 0	-- Se o banco nao estiver em loading...
		BEGIN
			select @sql_text = 'EXEC master..xp_cmdshell ' + '''' + (select replace([PARAM], '$DBNAME$', @dbname) from t4bdb01..t4b_tdp where [TIPO] = 'FULL') + ''''
			exec sp_executesql @sql_text

			IF @@ERROR != 0
			BEGIN
				SELECT @msg = ' [%s][%s] Erro no processo de backup database ' + @dbname + ' via TDP'
				SELECT @currdate = CONVERT(VARCHAR, GETDATE())
				RAISERROR (@msg, 16,1, @currdate, @server)

				CLOSE cur_db
				DEALLOCATE cur_db

				RETURN 1
			END

			SELECT @etime2 = GETDATE()
			SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

			INSERT INTO [t4bdb01].[dbo].[t4b_info_backup]
			VALUES (GETDATE(),@dbname,@etime,@param)

			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup full do database ' + @dbname + ' via TDP'
			PRINT @msg
		
			UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
			SET CTR_BACKUP_DIFF = 0
			WHERE SERVER = @server
			AND DBNAME = @dbname
			AND BACKUP_FULL = 1
			AND BACKUP_DIFF = 1
		END

		FETCH cur_db INTO @dbname
	END

	CLOSE cur_db
	DEALLOCATE cur_db

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de backup full via TDP'
	PRINT @msg

END

ELSE IF @param = 'BACKUP_LOG_TDP'
BEGIN
	IF @param_db IS NOT NULL
	BEGIN
		IF (SELECT BACKUP_LOG FROM t4bdb01..t4b_procadm_param WHERE DBNAME = @param_db) = 0
		BEGIN
			SELECT @msg = ' [%s][%s] O database ' + @param_db + ' npo estﬂ configurado para backup transacional'
			SELECT @currdate = CONVERT(VARCHAR, GETDATE())
			RAISERROR (@msg, 16,1, @currdate, @server)

			RETURN 1
		END

		IF (SELECT ([status] & 32) from master..sysdatabases WHERE [name] = @param_db) = 0	-- Se o banco nao estiver em loading...
		BEGIN
			IF DATABASEPROPERTY(@param_db, 'IsTruncLog') = 0
			BEGIN
				SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do backup transacional via TDP do database ' + @param_db
				PRINT @msg

				select @sql_text = 'EXEC master..xp_cmdshell ' + '''' + (select replace([PARAM], '$DBNAME$', @param_db) from t4bdb01..t4b_tdp where [TIPO] = 'LOG') + ''''
				exec sp_executesql @sql_text

				IF @@ERROR != 0
				BEGIN
					SELECT @msg = ' [%s][%s] Erro no processo de backup transacional via TDP, database ' + @param_db
					SELECT @currdate = CONVERT(VARCHAR, GETDATE())
					RAISERROR (@msg, 16,1, @currdate, @server)

					RETURN 1				
				END

				INSERT INTO [t4bdb01].[dbo].[t4b_info_backup_log]
				VALUES (GETDATE(),@param_db,@backup_full_path,'BACKUP LOG')

				SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup transacional via TDP do database ' + @param_db
				PRINT @msg
	
				RETURN

			END
		END
	END
	ELSE
	BEGIN
		SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de backup transacional via TDP'
		PRINT @msg

		DECLARE cur_db CURSOR FOR
		SELECT DBNAME
		FROM [t4bdb01].[dbo].[t4b_procadm_param]
		WHERE SERVER = @server
		AND BACKUP_LOG = 1
		AND ACTIVE = 1

		OPEN cur_db

		IF @@CURSOR_ROWS = 0
		BEGIN
			SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para executar um backup transacional'
			SELECT @currdate = CONVERT(VARCHAR, GETDATE())
			RAISERROR (@msg, 16,1, @currdate, @server)

			CLOSE cur_db
			DEALLOCATE cur_db

			RETURN
		END

		FETCH cur_db INTO @dbname

		WHILE @@FETCH_STATUS = 0
		BEGIN

			IF (SELECT ([status] & 32) from master..sysdatabases WHERE [name] = @dbname) = 0	-- Se o banco nao estiver em loading...
			BEGIN
				IF DATABASEPROPERTY(@dbname, 'IsTruncLog') = 0
				BEGIN
					SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do backup transacional via TDP do database ' + @dbname
					PRINT @msg

					select @sql_text = 'EXEC master..xp_cmdshell ' + '''' + (select replace([PARAM], '$DBNAME$', @dbname) from t4bdb01..t4b_tdp where [TIPO] = 'LOG') + ''''
					exec sp_executesql @sql_text

					IF @@ERROR != 0
					BEGIN
						SELECT @msg = ' [%s][%s] Erro no processo de backup transacional via TDP, database ' + @dbname
						SELECT @currdate = CONVERT(VARCHAR, GETDATE())
						RAISERROR (@msg, 16,1, @currdate, @server)

						CLOSE cur_db
						DEALLOCATE cur_db

						RETURN 1				
					END

					INSERT INTO [t4bdb01].[dbo].[t4b_info_backup_log]
					VALUES (GETDATE(),@dbname,@backup_full_path,'BACKUP LOG')

					SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup transacional via TDP do database ' + @dbname
					PRINT @msg
				END
			END

			FETCH cur_db INTO @dbname
		END

		SELECT @msg = '[' + CONVERT(VARCHAR, GETDATE()) + '][' + @server + '] Fim do processo de backup transacional via TDP'
		PRINT @msg

		CLOSE cur_db
		DEALLOCATE cur_db

		RETURN

	END
END

ELSE IF @param = 'BACKUP_LOG'
BEGIN

	IF @param_db IS NOT NULL
	BEGIN

		SELECT @backup_path = BACKUP_LG_PATH
		FROM [t4bdb01].[dbo].[t4b_procadm_param]
		WHERE SERVER = @@SERVERNAME
		AND DBNAME = @param_db
		AND ACTIVE = 1

		IF (SELECT ([status] & 32) from master..sysdatabases WHERE [name] = @param_db) = 0	-- Se o banco nao estiver em loading...
		BEGIN
			IF DATABASEPROPERTY(@param_db, 'IsTruncLog') = 0	-- Recovery model full
			BEGIN

				SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do backup transacional do database ' + @dbname + ' para ' + @backup_path
				PRINT @msg
	
				SELECT @currdate = CONVERT(VARCHAR,YEAR(GETDATE())) +
				RIGHT('00' + CONVERT(VARCHAR,MONTH(GETDATE())),2) +
				RIGHT('00' + CONVERT(VARCHAR,DAY(GETDATE())),2) + '_' +
				RIGHT('00' + CONVERT(VARCHAR, DATEPART(hh, GETDATE())),2) + 


				RIGHT('00' + CONVERT(VARCHAR, DATEPART(mi, GETDATE())),2) +
				RIGHT('00' + CONVERT(VARCHAR, DATEPART(ss, GETDATE())),2)
	
				SELECT @backup_full_path = @backup_path + @currdate + '_' + @param_db + '.bkp'

				SELECT @cmd = 'BACKUP LOG ' + QUOTENAME(@param_db) + ' TO DISK=''' + @backup_full_path + ''' WITH INIT, STATS'

				EXEC (@cmd)

				IF @@ERROR != 0
				BEGIN

					SELECT @msg = ' [%s][%s] Erro no processo de backup transacional, database ' + @param_db
					SELECT @currdate = CONVERT(VARCHAR, GETDATE())
					RAISERROR (@msg, 16,1, @currdate, @server)

					RETURN 1

				END

				INSERT INTO [t4bdb01].[dbo].[t4b_info_backup_log]
				VALUES (GETDATE(),@param_db,@backup_full_path,'BACKUP LOG')
	
				RETURN

			END

			ELSE

			BEGIN
			
				IF NOT REPLACE(@@VERSION, '  ', ' ') LIKE 'Microsoft SQL Server 2008%'
				BEGIN

					SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do backup transacional (WITH TRUNCATE_ONLY) do database ' + @param_db
					PRINT @msg

					SELECT @cmd = 'BACKUP LOG ' + QUOTENAME(@param_db) + ' WITH TRUNCATE_ONLY'

					EXEC (@cmd)
		
					IF @@ERROR != 0
					BEGIN

						SELECT @msg = ' [%s][%s] Erro no processo de backup transacional, database ' + @param_db
						SELECT @currdate = CONVERT(VARCHAR, GETDATE())
						RAISERROR (@msg, 16,1, @currdate, @server)

						RETURN 1
					END
		
					INSERT INTO [t4bdb01].[dbo].[t4b_info_backup_log]
						VALUES (GETDATE(),@param_db,NULL,'BACKUP LOG - TRUNCATE ONLY')
					
				END

				RETURN

			END
		END
	END

	ELSE

	BEGIN

		SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de backup transacional'
		PRINT @msg

		DECLARE cur_db CURSOR FOR
		SELECT DBNAME,
			   BACKUP_LG_PATH
		FROM [t4bdb01].[dbo].[t4b_procadm_param]
		WHERE SERVER = @server
		AND BACKUP_LOG = 1
		AND ACTIVE = 1

		OPEN cur_db

		IF @@CURSOR_ROWS = 0
		BEGIN

			SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para executar um backup transacional'
			SELECT @currdate = CONVERT(VARCHAR, GETDATE())
			RAISERROR (@msg, 16,1, @currdate, @server)

			CLOSE cur_db
			DEALLOCATE cur_db

			RETURN

		END

		FETCH cur_db
		INTO @dbname,
			 @backup_path

		WHILE @@FETCH_STATUS = 0
		BEGIN

			IF (SELECT ([status] & 32) from master..sysdatabases WHERE [name] = @dbname) = 0	-- Se o banco nao estiver em loading...
			BEGIN
				IF DATABASEPROPERTY(@dbname, 'IsTruncLog') = 0		-- Recovery model full
				BEGIN

					SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do backup transacional do database ' + @dbname + ' para ' + @backup_path
					PRINT @msg

					SELECT @currdate = CONVERT(VARCHAR,YEAR(GETDATE())) +
					RIGHT('00' + CONVERT(VARCHAR,MONTH(GETDATE())),2) +
					RIGHT('00' + CONVERT(VARCHAR,DAY(GETDATE())),2) + '_' +
					RIGHT('00' + CONVERT(VARCHAR, DATEPART(hh, GETDATE())),2) +
					RIGHT('00' + CONVERT(VARCHAR, DATEPART(mi, GETDATE())),2) +
					RIGHT('00' + CONVERT(VARCHAR, DATEPART(ss, GETDATE())),2)

					SELECT @backup_full_path = @backup_path + @currdate + '_' + @dbname + '.bkp'

					SELECT @cmd = 'BACKUP LOG ' + QUOTENAME(@dbname) + ' TO DISK=''' + @backup_full_path + ''' WITH INIT, STATS'

					EXEC (@cmd)

					IF @@ERROR != 0
					BEGIN

						SELECT @msg = ' [%s][%s] Erro no processo de backup transacional, database ' + @dbname
						SELECT @currdate = CONVERT(VARCHAR, GETDATE())
						RAISERROR (@msg, 16,1, @currdate, @server)

						CLOSE cur_db
						DEALLOCATE cur_db

						RETURN 1
					END

					INSERT INTO [t4bdb01].[dbo].[t4b_info_backup_log]
					VALUES (GETDATE(),@dbname,@backup_full_path,'BACKUP LOG')

				END

				ELSE

				BEGIN
				
					IF NOT REPLACE(@@VERSION, '  ', ' ') LIKE 'Microsoft SQL Server 2008%'
					BEGIN

						SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do backup transacional (WITH TRUNCATE_ONLY) do database ' + @dbname + ' para ' + @backup_path
						PRINT @msg
						
						SELECT @sql_text = 'BACKUP LOG ' + @dbname + ' WITH TRUNCATE_ONLY'
						EXEC(@sql_text)

						IF @@ERROR != 0
						BEGIN

							SELECT @msg = ' [%s][%s] Erro no processo de backup transacional, database ' + @dbname
							SELECT @currdate = CONVERT(VARCHAR, GETDATE())
							RAISERROR (@msg, 16,1, @currdate, @server)

							CLOSE cur_db
							DEALLOCATE cur_db

							RETURN 1

						END

						INSERT INTO [t4bdb01].[dbo].[t4b_info_backup_log]
						VALUES (GETDATE(),@param_db,NULL,'BACKUP LOG - TRUNCATE ONLY')
					
					END

				END
			END

			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup transacional do banco ' + @dbname
			PRINT @msg

			FETCH cur_db
			INTO @dbname, @backup_path

		END

		SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do processo de backup transacional'
		PRINT @msg

		CLOSE cur_db
		DEALLOCATE cur_db

		RETURN

	END

END

ELSE IF @param = 'BACKUP_DIFF'
BEGIN

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de backup diferencial'
	PRINT @msg

	DECLARE cur_db CURSOR FOR
	SELECT DBNAME,
		   BACKUP_PATH,
		   CTR_BACKUP_DIFF
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND BACKUP_DIFF = 1
	AND CTR_BACKUP_DIFF < QTD_BACKUP_DIFF
	AND ACTIVE = 1

	OPEN cur_db

	IF @@CURSOR_ROWS = 0
	BEGIN

		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para realizar o backup diferencial'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		CLOSE cur_db
		DEALLOCATE cur_db

		RETURN

	END

	FETCH cur_db
	INTO @dbname,
		 @backup_path,
		 @controle_backup_diff

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT @qtd_stripes = QTD_BACKUP_STRIPES
		FROM [t4bdb01].[dbo].[t4b_procadm_param]
		WHERE SERVER = @server
		AND DBNAME = @dbname

		IF @qtd_stripes = 1
		BEGIN

			SET @backup_full_path = @backup_path + @dbname + '_DIFF_' + CONVERT(VARCHAR,@controle_backup_diff) + '.bkp'

			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do backup diferencial do database ' + @dbname + ' para ' + @backup_path
			PRINT @msg

			SELECT @cmd = 'BACKUP DATABASE ' + QUOTENAME(@dbname) + ' TO DISK=''' + @backup_full_path + ''' WITH INIT, DIFFERENTIAL, STATS'

			SELECT @etime1 = GETDATE()

			EXEC (@cmd)

			IF @@ERROR != 0
			BEGIN

				SELECT @msg = ' [%s][%s] Erro no processo de backup diferencial, database ' + @dbname
				SELECT @currdate = CONVERT(VARCHAR, GETDATE())
				RAISERROR (@msg, 16,1, @currdate, @server)

				CLOSE cur_db
				DEALLOCATE cur_db

				RETURN 1

			END

			SELECT @etime2 = GETDATE()
			SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

			INSERT INTO [t4bdb01].[dbo].[t4b_info_backup]
			VALUES (GETDATE(),@dbname,@etime,@param)

			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup diferencial do database ' + @dbname
			PRINT @msg

			UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
			SET CTR_BACKUP_DIFF = CTR_BACKUP_DIFF + 1
			WHERE SERVER = @server
			AND DBNAME = @dbname
			AND BACKUP_FULL = 1
			AND BACKUP_DIFF = 1

		END

		ELSE

		BEGIN

			SELECT @cont = 0,
				   @cmd = ''

			WHILE @cont < @qtd_stripes
			BEGIN

				SELECT @backup_full_path = @backup_path + @dbname + '_DIFF_' + CONVERT(VARCHAR,@controle_backup_diff) + '_' + CONVERT(VARCHAR,@cont) + '.bkp'
				SELECT @cmd = @cmd + 'DISK = ''' + @backup_full_path + ''','

				SELECT @cont = @cont + 1

			END

			SELECT @cmd = SUBSTRING(@cmd,1,LEN(@cmd)-1)
			SELECT @cmd = 'BACKUP DATABASE ' + QUOTENAME(@dbname) + ' TO ' + @cmd + ' WITH INIT, DIFFERENTIAL, STATS'

			SELECT @etime1 = GETDATE()

			EXEC (@cmd)

			IF @@ERROR != 0
			BEGIN

				SELECT @msg = ' [%s][%s] Erro no processo de backup diferencial, database ' + @dbname
				SELECT @currdate = CONVERT(VARCHAR, GETDATE())
				RAISERROR (@msg, 16,1, @currdate, @server)

				CLOSE cur_db
				DEALLOCATE cur_db

				RETURN 1

			END

			SELECT @etime2 = GETDATE()
			SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

			INSERT INTO [t4bdb01].[dbo].[t4b_info_backup]
			VALUES (GETDATE(),@dbname,@etime,@param)

			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup diferencial do banco ' + @dbname
			PRINT @msg

			UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
			SET CTR_BACKUP_DIFF = CTR_BACKUP_DIFF + 1
			WHERE SERVER = @server
			AND DBNAME = @dbname
			AND BACKUP_FULL = 1
			AND BACKUP_DIFF = 1

		END

		FETCH cur_db
		INTO @dbname,
			 @backup_path,
			 @controle_backup_diff

	END

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do processo de backup diferencial'
	PRINT @msg

	CLOSE cur_db
	DEALLOCATE cur_db

	RETURN

END

ELSE IF @param = 'BACKUP_DIFF_RET'
BEGIN

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de backup diferencial'
	PRINT @msg

	-- Monta a string da data atual, para compor o nome do arquivo de backup:
	SELECT @currdate = CONVERT(VARCHAR,YEAR(GETDATE())) +
	RIGHT('00' + CONVERT(VARCHAR,MONTH(GETDATE())),2) +
	RIGHT('00' + CONVERT(VARCHAR,DAY(GETDATE())),2) + '_' +
	RIGHT('00' + CONVERT(VARCHAR, DATEPART(hh, GETDATE())),2) +
	RIGHT('00' + CONVERT(VARCHAR, DATEPART(mi, GETDATE())),2) +
	RIGHT('00' + CONVERT(VARCHAR, DATEPART(ss, GETDATE())),2)

	DECLARE cur_db CURSOR FOR
	SELECT DBNAME,
		   BACKUP_PATH,
		   CTR_BACKUP_DIFF
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND BACKUP_DIFF = 1
	AND CTR_BACKUP_DIFF < QTD_BACKUP_DIFF
	AND ACTIVE = 1

	OPEN cur_db

	IF @@CURSOR_ROWS = 0
	BEGIN

		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para realizar o backup diferencial'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		CLOSE cur_db
		DEALLOCATE cur_db

		RETURN

	END

	FETCH cur_db
	INTO @dbname,
		 @backup_path,
		 @controle_backup_diff

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT @qtd_stripes = QTD_BACKUP_STRIPES
		FROM [t4bdb01].[dbo].[t4b_procadm_param]
		WHERE SERVER = @server
		AND DBNAME = @dbname

		IF @qtd_stripes = 1
		BEGIN

			-- O nome do arquivo de backup È composto pelo nome do banco + a data, semelhante ao backup de log:
			SELECT @backup_full_path = @backup_path + @dbname + '_DIFF_' + @currdate + '.bkp'

			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do backup diferencial do database ' + @dbname + ' para ' + @backup_path
			PRINT @msg

			SELECT @cmd = 'BACKUP DATABASE ' + QUOTENAME(@dbname) + ' TO DISK=''' + @backup_full_path + ''' WITH INIT, DIFFERENTIAL, STATS'

			SELECT @etime1 = GETDATE()

			EXEC (@cmd)

			IF @@ERROR != 0
			BEGIN

				SELECT @msg = ' [%s][%s] Erro no processo de backup diferencial, database ' + @dbname
				SELECT @currdate = CONVERT(VARCHAR, GETDATE())
				RAISERROR (@msg, 16,1, @currdate, @server)

				CLOSE cur_db
				DEALLOCATE cur_db

				RETURN 1

			END

			SELECT @etime2 = GETDATE()
			SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

			INSERT INTO [t4bdb01].[dbo].[t4b_info_backup]
			VALUES (GETDATE(),@dbname,@etime,@param)

			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup diferencial do database ' + @dbname
			PRINT @msg

			UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
			SET CTR_BACKUP_DIFF = CTR_BACKUP_DIFF + 1
			WHERE SERVER = @server
			AND DBNAME = @dbname
			AND BACKUP_FULL = 1
			AND BACKUP_DIFF = 1

		END

		ELSE

		BEGIN

			SELECT @cont = 0,
				   @cmd = ''

			WHILE @cont < @qtd_stripes
			BEGIN

				-- O nome do arquivo de backup È composto pelo nome do banco + a data, semelhante ao backup de log:
				SELECT @backup_full_path = @backup_path + @dbname + '_DIFF_' + @currdate + '.bkp'
				SELECT @cmd = @cmd + 'DISK = ''' + @backup_full_path + ''','

				SELECT @cont = @cont + 1

			END

			SELECT @cmd = SUBSTRING(@cmd,1,LEN(@cmd)-1)
			SELECT @cmd = 'BACKUP DATABASE ' + QUOTENAME(@dbname) + ' TO ' + @cmd + ' WITH INIT, DIFFERENTIAL, STATS'

			SELECT @etime1 = GETDATE()

			EXEC (@cmd)

			IF @@ERROR != 0
			BEGIN

				SELECT @msg = ' [%s][%s] Erro no processo de backup diferencial, database ' + @dbname
				SELECT @currdate = CONVERT(VARCHAR, GETDATE())
				RAISERROR (@msg, 16,1, @currdate, @server)

				CLOSE cur_db
				DEALLOCATE cur_db

				RETURN 1

			END

			SELECT @etime2 = GETDATE()
			SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

			INSERT INTO [t4bdb01].[dbo].[t4b_info_backup]
			VALUES (GETDATE(),@dbname,@etime,@param)

			SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do backup diferencial do banco ' + @dbname
			PRINT @msg

			UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
			SET CTR_BACKUP_DIFF = CTR_BACKUP_DIFF + 1
			WHERE SERVER = @server
			AND DBNAME = @dbname
			AND BACKUP_FULL = 1
			AND BACKUP_DIFF = 1

		END

		FETCH cur_db
		INTO @dbname,
			 @backup_path,
			 @controle_backup_diff

	END

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do processo de backup diferencial'
	PRINT @msg

	CLOSE cur_db
	DEALLOCATE cur_db

	RETURN

END

ELSE IF @param = 'UPDATE_STATS'
BEGIN

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de UPDATE STATISTICS'
	PRINT @msg

	DECLARE cur_db CURSOR FOR
	SELECT DBNAME
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND UPDATE_STATS = 1
	AND ACTIVE = 1
	ORDER BY SIZE DESC

	OPEN cur_db

	IF @@CURSOR_ROWS = 0
	BEGIN

		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para executar o processo de UPDATE_STATISTICS'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		CLOSE cur_db
		DEALLOCATE cur_db

		RETURN

	END

	FETCH cur_db
	INTO @dbname

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de UPDATE STATISTICS, database ' + @dbname
		PRINT @msg

		SELECT @etime1 = GETDATE()

		SELECT @cmd = 'EXEC ' + QUOTENAME(@dbname) + '..sp_MSforeachtable @command1 = ''UPDATE STATISTICS ?'''

		EXEC (@cmd)

		IF @@ERROR != 0
		BEGIN

			SELECT ''
			SELECT @msg = ' [%s][%s] Erros encontrados no processo de UPDATE STATISTICS, database ' + @dbname
			SELECT @currdate = CONVERT(VARCHAR, GETDATE())
			RAISERROR (@msg, 16,1, @currdate, @server)

			CLOSE cur_db
			DEALLOCATE cur_db

			RETURN 1

		END

		SELECT @cmd = 'EXEC ' + QUOTENAME(@dbname) + '..sp_MSforeachtable @command1 = ''EXEC sp_recompile "?"'''

		EXEC (@cmd)

		IF @@ERROR != 0
		BEGIN

			SELECT ''
			SELECT @msg = ' [%s][%s] Erros encontrados no processo de UPDATE STATISTICS, database ' + @dbname
			SELECT @currdate = CONVERT(VARCHAR, GETDATE())
			RAISERROR (@msg, 16,1, @currdate, @server)

			CLOSE cur_db
			DEALLOCATE cur_db

			RETURN 1

		END

		SELECT @etime2 = GETDATE()
		SELECT @etime = DATEDIFF(mi, @etime1, @etime2)

		INSERT INTO t4bdb01..t4b_info_upstats
		VALUES (@@SERVERNAME,@etime1,@etime2,@dbname,@etime)

		SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do processo de UPDATE STATISTICS, database ' + @dbname
		PRINT @msg

		FETCH cur_db
		INTO @dbname

	END

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do processo de UPDATE STATISTICS'
	PRINT @msg

	CLOSE cur_db
	DEALLOCATE cur_db

	RETURN

END

ELSE IF @param = 'CHECK_DB'
BEGIN

	SET QUOTED_IDENTIFIER ON
	SET ARITHABORT ON
	SET ARITHIGNORE ON

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de DBCC CHECKDB'
	PRINT @msg

	DECLARE cur_db CURSOR FOR
	SELECT DBNAME
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND CHECK_DB = 1
	AND ACTIVE = 1
	ORDER BY SIZE DESC

	OPEN cur_db

	IF @@CURSOR_ROWS = 0
	BEGIN

		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para executar o processo de DBCC CHECKDB'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		CLOSE cur_db
		DEALLOCATE cur_db

		RETURN

	END

	FETCH cur_db
	INTO @dbname

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de DBCC CHECKDB, database ' + @dbname
		PRINT @msg

		SELECT @etime1 = GETDATE()

		DBCC CHECKDB(@dbname) WITH NO_INFOMSGS

		IF @@ERROR != 0
		BEGIN

			SELECT ''
			SELECT @msg = ' [%s][%s] Erros encontrados no processo de DBCC CHECKDB, database ' + @dbname
			SELECT @currdate = CONVERT(VARCHAR, GETDATE())
			RAISERROR (@msg, 16,1, @currdate, @server)

			CLOSE cur_db
			DEALLOCATE cur_db

			RETURN 1

		END

		SELECT @etime2 = GETDATE()
		SELECT @etime = DATEDIFF(mi, @etime1, @etime2)
		SELECT @avg_etime_1wk = AVG(ETIME) FROM [t4bdb01].[dbo].[t4b_info_checkdb] WHERE TIMESTAMP >= DATEADD(wk,-1,GETDATE()) AND DBNAME = @dbname
		SELECT @avg_etime_1mm = AVG(ETIME) FROM [t4bdb01].[dbo].[t4b_info_checkdb] WHERE TIMESTAMP >= DATEADD(mm,-1,GETDATE()) AND DBNAME = @dbname
		SELECT @avg_etime_3mm = AVG(ETIME) FROM [t4bdb01].[dbo].[t4b_info_checkdb] WHERE TIMESTAMP >= DATEADD(mm,-3,GETDATE()) AND DBNAME = @dbname
		SELECT @avg_etime_1yy = AVG(ETIME) FROM [t4bdb01].[dbo].[t4b_info_checkdb] WHERE TIMESTAMP >= DATEADD(yy,-1,GETDATE()) AND DBNAME = @dbname

		INSERT INTO [t4bdb01].[dbo].[t4b_info_checkdb]
		VALUES (GETDATE(),@dbname,@etime,@avg_etime_1wk,@avg_etime_1mm,@avg_etime_3mm,@avg_etime_1yy)

		SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do processo de DBCC CHECKDB, database ' + @dbname
		PRINT @msg

		FETCH cur_db
		INTO @dbname

	END

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do processo de DBCC CHECKDB'
	PRINT @msg

	CLOSE cur_db
	DEALLOCATE cur_db

	SET QUOTED_IDENTIFIER OFF
	SET ARITHABORT OFF
	SET ARITHIGNORE OFF

	RETURN

END

ELSE IF @param = 'REINDEX'
BEGIN

	SELECT @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Inicio do processo de DBCC DBREINDEX'
	PRINT @msg

	IF ( SELECT COUNT(*)
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND REINDEX = 1
	AND ACTIVE = 1) = 0

	BEGIN

		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para executar o processo de DBCC DBREINDEX'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		RETURN

	END

	BEGIN

		CREATE TABLE #showcontig_temp (
		OBJECTNAME nvarchar(128) NULL,
		OBJECTID [INT] NULL,
		INDEXNAME nvarchar(128) NULL,
		INDEXID [INT] NULL,
		[LEVEL] [INT] NULL,
		PAGES [INT] NULL,
		ROWS [INT] NULL,
		MINIMUMRECORDSIZE [INT] NULL,
		MAXIMUMRECORDSIZE [INT] NULL,
		AVERAGERECORDSIZE [FLOAT] NULL,
		FORWARDEDRECORDS [FLOAT] NULL,
		EXTENTS [INT] NULL,
		EXTENTSSWITCHES [INT] NULL,
		AVERAGEFREEBYTES [FLOAT] NULL,
		AVERAGEPAGEDENSITY [FLOAT] NULL,
		SCANDENSITY [FLOAT] NULL,
		BESTCOUNT [INT] NULL,
		ACTUALCOUNT [INT] NULL,
		LOGICALFRAGMENTATION [FLOAT] NULL,
		EXTENTFRAGMENTATION [FLOAT] NULL)

		CREATE TABLE #showcontig_temp_db (
		DBNAME nvarchar(128) NULL,
		OBJECTNAME nvarchar(128) NULL,
		INDEXID [INT] NULL,
		ROWS [INT] NULL,
		SCANDENSITY [FLOAT] NULL)

		CREATE TABLE #t4b_reindex (
		HOSTNAME nvarchar(128),
		DBNAME nvarchar(128),
		OBJECTNAME nvarchar(128),
		ROWS [INT])

		CREATE TABLE #t4b_reindex_cursor (
		OBJECTNAME nvarchar(128),
		ROWS [INT])

		CREATE TABLE #t4b_spaceused (
		[NAME] nvarchar(128) NULL,
		[ROWS] [INT] NULL,
		[RESERVED] [VARCHAR](20) NULL,
		[DATA] [VARCHAR](20) NULL,
		[INDEX_SIZE] [VARCHAR](20) NULL,
		[UNUSED] [VARCHAR](20) NULL)

		-- GRAVA O TAMANHO DO LOGFILE NA t4b_procadm_param PARA RETORNAR O LOG AP+S O REINDEX.
		CREATE TABLE #t4b_logspace (
		banco nvarchar(128),
		logS decimal(15,8),
		logU decimal(15,8),
		status int)

		INSERT INTO #t4b_logspace
			EXEC('DBCC SQLPERF(LOGSPACE)')

		IF NOT REPLACE(@@VERSION, '  ', ' ') LIKE 'Microsoft SQL Server 7%'
		BEGIN
			SELECT @sql_text = '
				UPDATE t4b_procadm_param
					SET t4b_procadm_param.THRESH_LG_SIZE = CEILING(#t4b_logspace.logS)
				FROM t4b_procadm_param
				INNER JOIN #t4b_logspace ON t4b_procadm_param.[DBNAME] COLLATE ' + @collation_tempdb + ' = #t4b_logspace.banco'
		END
		ELSE
		BEGIN
			SELECT @sql_text = '
				UPDATE t4b_procadm_param
					SET t4b_procadm_param.THRESH_LG_SIZE = CEILING(#t4b_logspace.logS)
				FROM t4b_procadm_param
				INNER JOIN #t4b_logspace ON t4b_procadm_param.[DBNAME] = #t4b_logspace.banco'
		END
		
		EXEC (@sql_text)

		DECLARE cur_db CURSOR FOR
		SELECT DBNAME
		FROM t4b_procadm_param
		WHERE REINDEX = 1
		AND ACTIVE = 1
		ORDER BY SIZE DESC

		OPEN cur_db

		FETCH cur_db INTO @dbname

		WHILE @@FETCH_STATUS = 0
		BEGIN


			SELECT @cmd = 'EXEC ' + QUOTENAME(@dbname) + '..sp_t4b_fragmentacao'

			EXEC (@cmd)

			FETCH cur_db INTO @dbname

		END

		CLOSE cur_db
		DEALLOCATE cur_db

		DROP TABLE #t4b_logspace
/*
		SELECT  @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do processo de DBCC DBREINDEX, database ' + @dbname
		PRINT   @msg
*/
		SELECT  @msg = '[' + CONVERT(VARCHAR,GETDATE()) + '][' + @server + '] Fim do processo de DBCC DBREINDEX'
		PRINT   @msg

		RETURN

	END

END

ELSE IF @param = 'SPACE_DB_MON'
BEGIN

	DECLARE cur_gdb CURSOR FOR
    SELECT DBNAME
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SPACE_DB_MON = 1
	AND ACTIVE = 1

	OPEN cur_gdb

	IF @@CURSOR_ROWS = 0
	BEGIN

		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para monitorar o espaco ocupado pelo banco'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		CLOSE cur_gdb
		DEALLOCATE cur_gdb

		RETURN

	END

	CREATE TABLE #datafilestats (
	[DBNAME] nvarchar(128),
	[DBID] [INT],
	[FILEID] [TINYINT],
	[FILEGROUP] [TINYINT],
	[TOTALEXTENTS] [DEC](20,2),
	[USEDEXTENTS] [DEC](20,2),
	[NAME] [VARCHAR](255),
	[FILENAME] [VARCHAR](400))

	CREATE TABLE #dbfileinfo(
	[SERVERNAME] [VARCHAR](255),
	[DBNAME] nvarchar(128),
	[LOGICALFILENAME] [VARCHAR](400),
	[USAGETYPE] [VARCHAR](30),
	[SIZE_MB] [DEC](20,2),
	[SPACEUSED_MB] [DEC](20,2),
	[FILEID] [SMALLINT],
	[GROUPID] [SMALLINT],
	[PHYSICALFILENAME] [VARCHAR](400),
	[DATECHECKED] [DATETIME])

	CREATE TABLE #dbfileinfo1(
	[DBNAME] nvarchar(128) NULL,
	[TOTAL] [DEC](20,2) NULL,
	[USED] [DEC](20,2) NULL)

	CREATE TABLE #db_growth(
	[DBNAME] nvarchar(128) NULL,
	[TOTAL] [DEC](20,2) NULL,
	[USED] [DEC](20,2) NULL,
	[FREE] [DEC](20,2) NULL,
	[PCT] [DEC](5,2) NULL)

	CREATE TABLE #t4b_info_ocup_db(
	[TIMESTAMP] [DATETIME] NULL,
	[SERVERNAME] [VARCHAR](255),
	[DBNAME] nvarchar(128) NULL,
	[TOTAL] [DEC](20,2) NULL,
	[USED] [DEC](20,2) NULL,
	[FREE] [DEC](20,2) NULL,
	[PCT] [DEC](5,2) NULL)

	CREATE TABLE #tab_bool (cod int)

	DECLARE @sqlstring NVARCHAR(3000),
			@actual_size DEC(20,2),
			@actual_free DEC(20,2)

	FETCH cur_gdb INTO @dbname

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT @sqlstring =
		'SELECT SERVERNAME = @@SERVERNAME,'+
		' DBNAME = '''+@dbname+''','+
		' LOGICALFILENAME = [name],'+
		' USAGETYPE = CASE WHEN (64&[status])=64 THEN ''LOG'' ELSE ''DATA'' END,'+
		' SIZE_MB = [size]*8/1024.00,'+
		' SPACEUSED_MB = NULL,'+
		' FILEID = [fileid],'+
		' GROUPID = [groupid],'+
		' PHYSICALFILENAME= [filename],'+
		' CURTIMESTAMP = GETDATE()'+
		'FROM ' + QUOTENAME(@dbname) + '..sysfiles'

		INSERT INTO #dbfileinfo
		EXEC (@sqlstring)

		SELECT @sqlstring = 'USE ' + QUOTENAME(@dbname) + ' DBCC SHOWFILESTATS WITH NO_INFOMSGS'

		INSERT #datafilestats ([FILEID],[FILEGROUP],[TOTALEXTENTS],[USEDEXTENTS],[NAME],[FILENAME])
		EXECUTE(@sqlstring)

		UPDATE #dbfileinfo
		SET [SPACEUSED_MB] = S.[USEDEXTENTS]*64/1024.00
		FROM #dbfileinfo AS F
		INNER JOIN #datafilestats AS S
		ON F.[FILEID] = S.[FILEID]
		AND F.[GROUPID] = S.[FILEGROUP]
		AND F.[DBNAME] = @dbname

		INSERT INTO #dbfileinfo1
		SELECT [DBNAME],
		SUM([SIZE_MB]),
		SUM([SPACEUSED_MB])
		FROM #dbfileinfo
		WHERE USAGETYPE = 'DATA'
		GROUP BY [DBNAME]
		ORDER BY [DBNAME]

		SELECT @actual_size = USED FROM #dbfileinfo1 WHERE DBNAME = @dbname
		SELECT @actual_free = TOTAL - USED FROM #dbfileinfo1 WHERE DBNAME = @dbname

		INSERT INTO #db_growth
		SELECT DBNAME,
			   TOTAL,
			   @actual_size,
			   TOTAL - @actual_size,
			   ROUND(( USED * 100 ) / TOTAL, 2 )
		FROM #dbfileinfo1

		TRUNCATE TABLE #dbfileinfo
		TRUNCATE TABLE #dbfileinfo1
		TRUNCATE TABLE #datafilestats

		FETCH cur_gdb INTO @dbname

	END

	CLOSE cur_gdb
	DEALLOCATE cur_gdb

	INSERT INTO #t4b_info_ocup_db
	SELECT GETDATE(),
		   @@SERVERNAME,
		   DBNAME,
		   TOTAL,
		   USED,
		   FREE,
		   CASE
			WHEN PCT = 100
			THEN 99.99
		   ELSE PCT
		   END
	FROM #db_growth

	IF NOT REPLACE(@@VERSION, '  ', ' ') LIKE 'Microsoft SQL Server 7%'
	BEGIN
		SELECT @sqlstring =
			'SELECT 1
			   FROM #db_growth gdb, [t4bdb01].[dbo].[t4b_procadm_param] tpp
			   WHERE gdb.DBNAME = tpp.DBNAME COLLATE ' + @collation_tempdb + '
			   AND gdb.PCT > tpp.THRESH_DB_SPACE'
	
		INSERT INTO #tab_bool
			EXEC (@sqlstring)

		IF EXISTS(SELECT * FROM #tab_bool)
		BEGIN
			SELECT ''

			SELECT @sqlstring = '
			SELECT CONVERT(CHAR(30),@@SERVERNAME) ''SERVERNAME'',
				   CONVERT(CHAR(30),gdb.DBNAME) ''DBNAME'',
				   CONVERT(CHAR(10),gdb.TOTAL) ''TOTAL(MB)'',
				   CONVERT(CHAR(10),gdb.USED) ''USED(MB)'',
				   CONVERT(CHAR(10),gdb.FREE) ''FREE(MB)'',
				   CONVERT(CHAR(10),gdb.PCT) ''USED(%)''
			FROM #db_growth gdb, [t4bdb01].[dbo].[t4b_procadm_param] tpp
			WHERE gdb.DBNAME = tpp.DBNAME COLLATE ' + @collation_tempdb + '
			AND gdb.PCT > tpp.THRESH_DB_SPACE'

			EXEC (@sqlstring)

			SELECT ''
			SELECT @msg = ' [%s][%s] Espato ocupado pelo banco de dados acima do threshold'
			SELECT @currdate = CONVERT(VARCHAR, GETDATE())
			RAISERROR (@msg, 16,1, @currdate, @server)
			RETURN 1
		END

	END
	ELSE
	BEGIN
		SELECT @sqlstring =
			'SELECT 1
			   FROM #db_growth gdb, [t4bdb01].[dbo].[t4b_procadm_param] tpp
			   WHERE gdb.DBNAME = tpp.DBNAME
			 AND gdb.PCT > tpp.THRESH_DB_SPACE'
	
		INSERT INTO #tab_bool
			EXEC (@sqlstring)

		IF EXISTS(SELECT * FROM #tab_bool)
		BEGIN
			SELECT ''

			SELECT @sqlstring = '
			SELECT CONVERT(CHAR(30),@@SERVERNAME) ''SERVERNAME'',
				   CONVERT(CHAR(30),gdb.DBNAME) ''DBNAME'',
				   CONVERT(CHAR(10),gdb.TOTAL) ''TOTAL(MB)'',
				   CONVERT(CHAR(10),gdb.USED) ''USED(MB)'',
				   CONVERT(CHAR(10),gdb.FREE) ''FREE(MB)'',
				   CONVERT(CHAR(10),gdb.PCT) ''USED(%)''
			FROM #db_growth gdb, [t4bdb01].[dbo].[t4b_procadm_param] tpp
			WHERE gdb.DBNAME = tpp.DBNAME
			AND gdb.PCT > tpp.THRESH_DB_SPACE'

			EXEC (@sqlstring)

			SELECT ''
			SELECT @msg = ' [%s][%s] Espato ocupado pelo banco de dados acima do threshold'
			SELECT @currdate = CONVERT(VARCHAR, GETDATE())
			RAISERROR (@msg, 16,1, @currdate, @server)
			RETURN 1
		END
	END

	drop table #tab_bool

	RETURN

END

ELSE IF @param = 'SPACE_LG_MON'
BEGIN

	IF OBJECT_ID('t4b_tdp') IS NOT NULL
	BEGIN
		IF (SELECT COUNT(*) FROM t4b_tdp) > 0
		BEGIN
			GOTO Log_TDP
		END
	END

	IF ( SELECT COUNT(*)
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND SPACE_LG_MON = 1
	AND ACTIVE = 1) = 0

	BEGIN

		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para monitorar o espaco ocupado pelo log'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		RETURN

	END

	CREATE TABLE #lgspace(
	DBNAME nvarchar(128),
	SIZE [FLOAT],
	PCT [FLOAT],
	STATUS [INT])

	CREATE TABLE #lgspace1(
	DBNAME nvarchar(128),
	SIZE [FLOAT],
	PCT [FLOAT])

	INSERT INTO #lgspace
	EXEC ('DBCC SQLPERF(LOGSPACE)')


	IF REPLACE(@@version, '  ', ' ') like 'Microsoft SQL Server 7%'
	BEGIN
		SET @sql_text = 'SELECT lg.DBNAME,
						lg.SIZE,
						lg.PCT
						FROM #lgspace lg, [t4bdb01].[dbo].[t4b_procadm_param] tpp
						WHERE lg.DBNAME = tpp.DBNAME
						AND lg.DBNAME not in (''tempdb'')
						AND lg.PCT > tpp.THRESH_LG_SPACE
						AND tpp.SPACE_LG_MON = 1
						AND tpp.ACTIVE = 1'
	END
	ELSE
	BEGIN
		SET @sql_text = 'SELECT lg.DBNAME,
						lg.SIZE,
						lg.PCT
						FROM #lgspace lg, [t4bdb01].[dbo].[t4b_procadm_param] tpp
						WHERE lg.DBNAME = tpp.DBNAME COLLATE ' + @collation_tempdb +'
						AND lg.DBNAME not in (''tempdb'')
						AND lg.PCT > tpp.THRESH_LG_SPACE
						AND tpp.SPACE_LG_MON = 1
						AND tpp.ACTIVE = 1'
	END

	INSERT INTO #lgspace1
		exec(@sql_text)
/*
		-- O SELECT abaixo apresenta erro de collation:
		SELECT lg.DBNAME,
		lg.SIZE,
		lg.PCT
		FROM #lgspace lg, [t4bdb01].[dbo].[t4b_procadm_param] tpp
		WHERE lg.DBNAME = tpp.DBNAME
		AND lg.PCT > tpp.THRESH_LG_SPACE
		AND tpp.SPACE_LG_MON = 1
		AND tpp.ACTIVE = 1
*/
	INSERT INTO [t4bdb01].[dbo].[t4b_info_space_lg_mon]
	SELECT GETDATE(),
		   @@SERVERNAME,
		   DBNAME,
		   SIZE,
		   (( PCT * SIZE ) / 100.00 ) 'USED',
		   PCT
	FROM #lgspace1

	IF EXISTS(SELECT 1
			  FROM #lgspace1)

	BEGIN

		SELECT ''
		SELECT CONVERT(CHAR(65),@@SERVERNAME) 'SERVERNAME',
			   CONVERT(CHAR(128),DBNAME) 'DBNAME',
			   CONVERT(CHAR(10),CONVERT(INT,SIZE)) 'SIZE(MB)',
			   CONVERT(CHAR(10),CONVERT(INT,(( PCT * SIZE ) / 100.00 ))) 'USED(MB)',
			   CONVERT(CHAR(10),CONVERT(INT,PCT)) 'USED(%)'
		FROM #lgspace1

		DECLARE cur_db CURSOR STATIC FOR
		SELECT DBNAME
		FROM #lgspace1
		WHERE DBNAME NOT IN ('tempdb')
		FOR READ ONLY

		OPEN cur_db

		IF @@CURSOR_ROWS > 0
		BEGIN

			FETCH cur_db INTO @dbname

			SELECT ''

			WHILE @@FETCH_STATUS = 0
			BEGIN

				INSERT INTO [t4bdb01].[dbo].[t4b_info_backup_log]
				VALUES (GETDATE(),@param_db,NULL,'SPACE_LG_MON')

				EXEC sp_t4b_procadm 'BACKUP_LOG', @dbname

				IF @@ERROR != 0
				BEGIN
					SELECT @msg = ' [%s][%s] Espaco ocupado pelo log do banco de dados encontra-se acima do threshold'
					SELECT @currdate = CONVERT(VARCHAR, GETDATE())
					RAISERROR (@msg, 16,1, @currdate, @server)
			
					CLOSE cur_db
					DEALLOCATE cur_db
			
					RETURN
				END

				FETCH cur_db INTO @dbname

			END

		END

	END

	RETURN

	Log_TDP:
	DECLARE @db_name nvarchar(128)

	CREATE TABLE #logspace (
		dbname nvarchar(128),
		log_size FLOAT,
		log_used_pct FLOAT,
		status  INT
	)

	INSERT INTO #logspace
		EXEC ('dbcc sqlperf(logspace)')

	SELECT lg.dbname, lg.log_size, lg.log_used_pct
	FROM #logspace lg, [t4bdb01].[dbo].[t4b_procadm_param] tpp
	WHERE lg.DBNAME = tpp.DBNAME
	AND lg.log_used_pct > tpp.THRESH_LG_SPACE
	-- AND log_used_pct > 60
	AND tpp.SPACE_LG_MON = 1
	AND tpp.ACTIVE = 1

	DECLARE cur_db CURSOR STATIC FOR
		SELECT lg.dbname
		FROM #logspace lg, [t4bdb01].[dbo].[t4b_procadm_param] tpp
		WHERE lg.DBNAME = tpp.DBNAME
		AND lg.log_used_pct > tpp.THRESH_LG_SPACE
		-- log_used_pct > 60
	FOR READ ONLY

	OPEN cur_db

	IF @@CURSOR_ROWS > 0
	BEGIN
		FETCH cur_db
		INTO @db_name

		WHILE @@FETCH_STATUS = 0
		BEGIN
			select @sql_text = 'EXEC master..xp_cmdshell ' + '''' + (select replace([PARAM], '$DBNAME$', @db_name) from t4bdb01..t4b_tdp where [TIPO] = 'LOG') + ''''
			exec sp_executesql @sql_text

			IF @@ERROR <> 0
			BEGIN
				SELECT @msg = ' [%s][%s] Bancos com percentual de ocupacao do log acima do threshold.'
				SELECT @currdate = CONVERT(VARCHAR, GETDATE())
				RAISERROR (@msg, 16,1, @currdate, @server)
				RETURN
			END

			FETCH cur_db
			INTO @db_name
		END

		CLOSE cur_db
		DEALLOCATE cur_db

		RETURN
	END
	ELSE
	BEGIN
		CLOSE cur_db
		DEALLOCATE cur_db
		RETURN
	END

	DROP TABLE #logspace

END

ELSE IF @param = 'SPACE_DB_GROWTH'
BEGIN

	IF ( SELECT COUNT(*)
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND SPACE_DB_GROWTH = 1
	AND ACTIVE = 1) = 0

	BEGIN

		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para monitorar o crescimento dos bancos'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		RETURN

	END

	DECLARE
		@gdb_sqlstring [NVARCHAR](3000),
		@gdb_last_size [INT],
		@gdb_actual_size [DEC](20,2),
		@gdb_actual_free [DEC](20,2),
		@gdb_growth_size [INT],
		@gdb_avg_size_1wk [INT],
		@gdb_avg_size_1mm [INT],
		@gdb_avg_size_3mm [INT],
		@gdb_avg_size_1yy [INT],
		@gdb_lifetime_1wk [INT],
		@gdb_lifetime_1mm [INT],
		@gdb_lifetime_3mm [INT],
		@gdb_lifetime_1yy [INT],
		@gdb_lg [DEC](20,2)

	CREATE TABLE #gdb_datafilestats(
	[DBNAME] nvarchar(128),
	[DBID] [INT],
	[FILEID] [TINYINT],
	[FILEGROUP] [TINYINT],
	[TOTALEXTENTS] [DEC](20,2),
	[USEDEXTENTS] [DEC](20,2),
	[NAME] [VARCHAR](255),
	[FILENAME] [VARCHAR](400))

	CREATE TABLE #gdb_dbfileinfo(
	[SERVERNAME] [VARCHAR](255),
	[DBNAME] nvarchar(128),
	[LOGICALFILENAME] [VARCHAR](400),
	[USAGETYPE] [VARCHAR](30),
	[SIZE_MB] [DEC](20,2),
	[SPACEUSED_MB] [DEC](20,2),
	[FILEID] [SMALLINT],
	[GROUPID] [SMALLINT],
	[PHYSICALFILENAME] [VARCHAR](400),
	[DATECHECKED] [DATETIME])

	CREATE TABLE #gdb_dbfileinfo1(
	[DBNAME] nvarchar(128) NULL,
	[TOTAL] [DEC](20,2) NULL,
	[USED] [DEC](20,2) NULL)

	CREATE TABLE #gdb_growth(
	[DBNAME] nvarchar(128) NULL,
	[TOTAL] [DEC](20,2) NULL,
	[USED] [DEC](20,2) NULL,
	[FREE] [DEC](20,2) NULL,
	[PCT] [DEC](5,2) NULL,
	[LOGSIZE] [DEC](20,2) NULL,
	[GROWTH] [INT] NULL,
	[AVG_SIZE_1WK] [INT] NULL,
	[AVG_SIZE_1MM] [INT] NULL,
	[AVG_SIZE_3MM] [INT] NULL,
	[AVG_SIZE_1YY] [INT] NULL,
	[LIFETIME_1WK] [INT] NULL,
	[LIFETIME_1MM] [INT] NULL,
	[LIFETIME_3MM] [INT] NULL,
	[LIFETIME_1YY] [INT] NULL)

	CREATE TABLE #gdb_lgsp(
	DBNAME nvarchar(128),
	SIZE [FLOAT],
	PCT [FLOAT],
	STATUS [INT])

	INSERT INTO #gdb_lgsp
	EXEC ('DBCC SQLPERF(LOGSPACE)')

	DECLARE cur_gdb CURSOR FOR
	SELECT DBNAME
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SPACE_DB_GROWTH = 1
	AND ACTIVE = 1

	OPEN cur_gdb

	FETCH cur_gdb INTO @dbname

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT @gdb_sqlstring =
		'SELECT SERVERNAME = @@SERVERNAME,'+
		' DBNAME = '''+@dbname+''','+
		' LOGICALFILENAME = [name],'+
		' USAGETYPE = CASE WHEN (64&[status])=64 THEN ''LOG'' ELSE ''DATA'' END,'+
		' SIZE_MB = [size]*8/1024.00,'+
		' SPACEUSED_MB = NULL,'+
		' FILEID = [fileid],'+
		' GROUPID = [groupid],'+
		' PHYSICALFILENAME = [filename],'+
		' CURTIMESTAMP = GETDATE()'+
		'FROM ' + QUOTENAME(@dbname) + '..sysfiles'

		INSERT INTO #gdb_dbfileinfo
		EXEC (@gdb_sqlstring)

		SELECT @gdb_sqlstring = 'USE ' + QUOTENAME(@dbname) + ' DBCC SHOWFILESTATS WITH NO_INFOMSGS'

		INSERT #gdb_datafilestats ([FILEID],[FILEGROUP],[TOTALEXTENTS],[USEDEXTENTS],[NAME],[FILENAME])
		EXECUTE(@gdb_sqlstring)

		UPDATE #gdb_dbfileinfo
		SET [SPACEUSED_MB] = S.[USEDEXTENTS]*64/1024.00
		FROM #gdb_dbfileinfo AS F
		INNER JOIN #gdb_datafilestats AS S
		ON F.[FILEID] = S.[FILEID]
		AND F.[GROUPID] = S.[FILEGROUP]
		AND F.[DBNAME] = @dbname

		INSERT INTO #gdb_dbfileinfo1
		SELECT [DBNAME],
			   SUM([SIZE_MB]),
			   SUM([SPACEUSED_MB])
		FROM #gdb_dbfileinfo
		WHERE [USAGETYPE] = 'DATA'
		GROUP BY [DBNAME]
		ORDER BY [DBNAME]

		SELECT @gdb_last_size = [USED] FROM [t4bdb01].[dbo].[t4b_info_ocup_db] WHERE TIMESTAMP >= DATEADD(hh,-26,GETDATE()) AND DBNAME = @dbname
		SELECT @gdb_actual_size = [USED] FROM #gdb_dbfileinfo1 WHERE DBNAME = @dbname
		SELECT @gdb_actual_free = [TOTAL] - [USED] FROM #gdb_dbfileinfo1 WHERE DBNAME = @dbname
		SELECT @gdb_growth_size = @gdb_actual_size - @gdb_last_size
		SELECT @gdb_avg_size_1wk = AVG(GROWTH) FROM [t4bdb01].[dbo].[t4b_info_ocup_db] WHERE TIMESTAMP >= DATEADD(wk,-1,GETDATE()) AND DBNAME = @dbname
		SELECT @gdb_avg_size_1mm = AVG(GROWTH) FROM [t4bdb01].[dbo].[t4b_info_ocup_db] WHERE TIMESTAMP >= DATEADD(mm,-1,GETDATE()) AND DBNAME = @dbname
		SELECT @gdb_avg_size_3mm = AVG(GROWTH) FROM [t4bdb01].[dbo].[t4b_info_ocup_db] WHERE TIMESTAMP >= DATEADD(mm,-3,GETDATE()) AND DBNAME = @dbname
		SELECT @gdb_avg_size_1yy = AVG(GROWTH) FROM [t4bdb01].[dbo].[t4b_info_ocup_db] WHERE TIMESTAMP >= DATEADD(yy,-1,GETDATE()) AND DBNAME = @dbname
		SELECT @gdb_lg = [SIZE] FROM #gdb_lgsp WHERE DBNAME = @dbname

		IF @gdb_avg_size_1wk <= 0
		BEGIN

			SELECT @gdb_lifetime_1wk = 0

		END

		ELSE

		BEGIN

			SELECT @gdb_lifetime_1wk = @gdb_actual_free / @gdb_avg_size_1wk

		END

		IF @gdb_avg_size_1mm <= 0
		BEGIN

			SELECT @gdb_lifetime_1mm = 0

		END

		ELSE

		BEGIN

			SELECT @gdb_lifetime_1mm = @gdb_actual_free / @gdb_avg_size_1mm

		END

		IF @gdb_avg_size_3mm <= 0
		BEGIN

			SELECT @gdb_lifetime_3mm = 0

		END

		ELSE

		BEGIN

			SELECT @gdb_lifetime_3mm = @gdb_actual_free / @gdb_avg_size_3mm

		END

		IF @gdb_avg_size_1yy <= 0
		BEGIN

			SELECT @gdb_lifetime_1yy = 0

		END

		ELSE

		BEGIN

			SELECT @gdb_lifetime_1yy = @gdb_actual_free / @gdb_avg_size_1yy

		END

		INSERT INTO #gdb_growth
		SELECT DBNAME,
			   TOTAL,
			   @gdb_actual_size,
			   TOTAL - @gdb_actual_size,
			   ROUND(( USED * 100 ) / TOTAL, 2 ),
			   @gdb_lg,
			   @gdb_growth_size,
			   @gdb_avg_size_1wk,
			   @gdb_avg_size_1mm,
			   @gdb_avg_size_3mm,
			   @gdb_avg_size_1yy,
			   @gdb_lifetime_1wk,
			   @gdb_lifetime_1mm,
			   @gdb_lifetime_3mm,
			   @gdb_lifetime_1yy
		FROM #gdb_dbfileinfo1

		TRUNCATE TABLE #gdb_dbfileinfo

		TRUNCATE TABLE #gdb_dbfileinfo1
		TRUNCATE TABLE #gdb_datafilestats

		FETCH cur_gdb INTO @dbname

	END

	CLOSE cur_gdb
	DEALLOCATE cur_gdb

	INSERT INTO [t4bdb01].[dbo].[t4b_info_ocup_db]
	SELECT GETDATE(),
		   @@SERVERNAME,
		   DBNAME,
		   TOTAL,
		   USED,
		   FREE,
		   CASE
			WHEN PCT = 100
			THEN 99.99
			ELSE PCT
		   END,
		   LOGSIZE,
		   GROWTH,
		   AVG_SIZE_1WK,
		   AVG_SIZE_1MM,
		   AVG_SIZE_3MM,
		   AVG_SIZE_1YY,
		   LIFETIME_1WK,
		   LIFETIME_1MM,
		   LIFETIME_3MM,
		   LIFETIME_1YY
	FROM #gdb_growth

END

ELSE IF @param = 'SPACE_TAB_GROWTH'
BEGIN
	declare @i int,
			@iMax int

	IF ( SELECT COUNT(*)
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND SPACE_TAB_GROWTH = 1
	AND ACTIVE = 1) = 0

	BEGIN

		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para monitorar o crescimento das tabs'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		RETURN

	END

	CREATE TABLE #t4b_gtb(
	[ROWTOTAL] [INT] NULL,
	[RESERVED] [DEC](15) NULL,
	[DATA] [DEC](15) NULL,
	[INDEX_SIZE] [DEC](15) NULL,
	[UNUSED] [DEC](15) NULL)

	CREATE TABLE #tab_loop_db (
	cod int IDENTITY(1,1),
	banco nvarchar(128))

	INSERT INTO #tab_loop_db
		SELECT DBNAME
		FROM [t4bdb01].[dbo].[t4b_procadm_param]
		WHERE SPACE_TAB_GROWTH = 1
		AND ACTIVE = 1

	SET @i = 0
	SELECT @iMax = MAX(cod) FROM #tab_loop_db
	
	WHILE @i < @iMax
	BEGIN

		SET @i = @i + 1

		SELECT @dbname = banco FROM #tab_loop_db WHERE cod = @i

		SELECT @cmd = 'EXEC ' + QUOTENAME(@dbname) + '..sp_t4b_adm_growth_tb ' + '''' + @dbname + ''''

		EXEC (@cmd)

		IF @@ERROR != 0
		BEGIN
			SELECT @msg = ' [%s][%s] Erro no processo de monitoratpo de crescimento das tabs. Database ' + @dbname
			SELECT @currdate = CONVERT(VARCHAR, GETDATE())
			RAISERROR (@msg, 16,1, @currdate, @server)

			CLOSE cur_gtb
			DEALLOCATE cur_gtb

			RETURN 1
		END

	END

END

ELSE IF @param = 'DISKSPACE'
BEGIN
	CREATE TABLE #spaces_disk (
		time_stamp	DATETIME,
		drive CHAR(1),
		totalBytes	DECIMAL(16,0),
		freeBytes	DECIMAL(16,0))

	DECLARE @time_stamp DATETIME,
			@fs	INT,
			@drive INT,
			@hr INT,
			@src VARCHAR(255),
			@desc VARCHAR(255),
			@driveLetter VARCHAR(255),
			@totalBytes	DECIMAL(16,0),
			@freeBytes	DECIMAL(16,0),
			@usedBytes	DECIMAL(16,0),
			@pctUsed	DECIMAL(5,2),
			@volume		varchar(60)

	SELECT	@time_stamp = GETDATE()

	EXEC @hr = sp_OACreate 'Scripting.FileSystemObject', @fs OUT;
	IF @hr <> 0
	BEGIN
	   EXEC sp_OAGetErrorInfo @fs, @src OUT, @desc OUT
	   RAISERROR('Error Creating COM Component 0x%x, %s, %s',16,1, @hr, @src, @desc)
		RETURN
	END

	DECLARE cur_drive CURSOR FOR
	SELECT	DISTINCT SUBSTRING(filename, 1,1)
	FROM	master..sysaltfiles
	WHERE	size > 0
	ORDER BY 1
	FOR READ ONLY

	OPEN cur_drive

	FETCH cur_drive INTO @driveLetter

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC @hr = sp_OAMethod @fs, 'GetDrive', @drive OUT, @driveLetter
		IF @hr <> 0
		BEGIN
			PRINT 'GetDrive'
			EXEC sp_OAGetErrorInfo @fs
			GOTO Cleanup
		END

		DECLARE @property varchar(255)
		EXEC @hr = sp_OAMethod @drive, 'TotalSize', @property OUT
		IF @hr <> 0
		BEGIN
			PRINT 'Total'
			EXEC sp_OAGetErrorInfo @fs
			GOTO Cleanup
		END
		
		SET @totalBytes = CONVERT(DECIMAL(16,0),@property)

		EXEC @hr = sp_OAMethod @drive, 'FreeSpace', @property OUT
		IF @hr <> 0
		BEGIN
			PRINT 'Free'
			EXEC sp_OAGetErrorInfo @fs
			GOTO Cleanup
		END
		
		SET @freeBytes = CONVERT(DECIMAL(16,0),@property)

		------------------------------------------------------------
		EXEC @hr = sp_OAMethod @drive, 'VolumeName', @property OUT
		IF @hr <> 0
		BEGIN
			PRINT 'VolumeName'
			EXEC sp_OAGetErrorInfo @fs
			GOTO Cleanup
		END
		
		SET @volume = CONVERT(VARCHAR,@property)
		------------------------------------------------------------

		EXEC sp_OADestroy @drive
/*
		INSERT INTO t4b_disk_space (time_stamp, disk, total, free)
		SELECT @time_stamp, @driveLetter, @totalBytes, @freeBytes
*/

		SET @freeBytes = @freeBytes / (1024 * 1024)
		SET @totalBytes = @totalBytes / (1024 * 1024)
		SET @usedBytes = @totalBytes - @freeBytes
		SET @pctUsed = 100 - ( CONVERT([NUMERIC](5,2),((CONVERT([NUMERIC](9,0),@freeBytes) / CONVERT([NUMERIC](9,0),@totalBytes)) * 100)) )

		--100 - ( CONVERT([NUMERIC](5,2),((CONVERT([NUMERIC](9,0),[FREESPACE]) / CONVERT([NUMERIC](9,0),[TOTALSPACE])) * 100)) )

		INSERT INTO [t4b_info_diskspace](
			DRIVELETTER,
			FREESPACE_MB,
			LABEL,
			PERCENTAGE_USED,
			[SERVER],
			[TIMESTAMP],
			TOTALSPACE_MB,
			USEDSPACE_MB
		) VALUES (
			@driveLetter,
			@freeBytes,
			@volume,
			@pctUsed,
			@@servername,
			@time_stamp,
			@totalBytes,
			@usedBytes
		)
		FETCH cur_drive INTO @driveLetter
	END

	GOTO Cleanup

	Cleanup:

	CLOSE cur_drive
	DEALLOCATE cur_drive

	DROP TABLE #spaces_disk

	EXEC sp_OADestroy @drive
	EXEC sp_OADestroy @fs	
END

ELSE IF @param = 'SPACE_LG_SIZE'
BEGIN

	IF ( SELECT COUNT(*)
	FROM [t4bdb01].[dbo].[t4b_procadm_param]
	WHERE SERVER = @server
	AND SPACE_LG_SIZE = 1
	AND ACTIVE = 1) = 0

	BEGIN

		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para monitorar o espato alocado para o logfile'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		RETURN

	END

	CREATE TABLE #lgsize(
	DBNAME nvarchar(128),
	SIZE [FLOAT],
	PCT [FLOAT],
	STATUS [INT])

	CREATE TABLE #lgsize1(
	DBNAME nvarchar(128),
	SIZE [FLOAT],
	PCT [FLOAT])

	INSERT INTO #lgsize
	EXEC ('DBCC SQLPERF(LOGSPACE)')

	INSERT INTO #lgsize1
	SELECT lg.DBNAME,
		   lg.SIZE,
		   lg.PCT
	FROM #lgsize lg, [t4bdb01].[dbo].[t4b_procadm_param] tpp
	WHERE lg.DBNAME = tpp.DBNAME
	AND lg.SIZE > tpp.THRESH_LG_SIZE
	AND tpp.SPACE_LG_SIZE = 1
	AND tpp.ACTIVE = 1

	IF EXISTS(SELECT 1
			  FROM #lgsize1)

	BEGIN

		SELECT ''
		SELECT CONVERT(CHAR(65),@@SERVERNAME) 'SERVERNAME',
			   CONVERT(CHAR(128),DBNAME) 'DBNAME',
			   CONVERT(CHAR(10),CONVERT(INT,SIZE)) 'SIZE(MB)'
		FROM #lgsize1
		ORDER BY DBNAME

		SELECT ''
		SELECT @msg = ' [%s][%s] Log do banco de dados acima do threshold'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

	END

	RETURN

END

ELSE IF @param = 'HOUSEKEEPING'
BEGIN

	IF ( SELECT COUNT(*)
	FROM [t4bdb01].[dbo].[t4b_procadm_param_hk]
	WHERE SERVER = @server
	AND ACTIVE = 1) = 0
	BEGIN

		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para realizar o housekeeping dos dados historicos'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		RETURN

	END

	DECLARE cur_hk CURSOR FOR
	SELECT DBNAME
	FROM [t4bdb01].[dbo].[t4b_procadm_param_hk]
	WHERE ACTIVE = 1

	OPEN cur_hk

	FETCH NEXT FROM cur_hk INTO @dbname

	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- BACKUP_TYPE

		IF (SELECT BACKUP_TYPE FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname AND BACKUP_TYPE = 1) = 1
		BEGIN

			SELECT @hk_days = HK_BACKUP_TYPE FROM [t4b_procadm_param_hk] WHERE DBNAME = @dbname

			SET ROWCOUNT 1000

			DELETE FROM [t4bdb01].[dbo].[t4b_info_backup]
			WHERE TIMESTAMP < DATEADD(DD,-@hk_days,GETDATE())

			SELECT @rows = @@ROWCOUNT

			WHILE @rows > 0
			BEGIN

				DELETE FROM [t4bdb01].[dbo].[t4b_info_backup]
				WHERE TIMESTAMP < DATEADD(DD,-@hk_days,GETDATE())

				SELECT @rows = @@ROWCOUNT
				
			END

			SET ROWCOUNT 0

		END

		-- BACKUP_LOG

		IF (SELECT BACKUP_LOG FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname AND BACKUP_LOG = 1) = 1
		BEGIN

			SELECT @hk_days = HK_BACKUP_LOG FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname

			SET ROWCOUNT 1000

			DELETE FROM [t4bdb01].[dbo].[t4b_info_backup_log]
			WHERE TIMESTAMP < DATEADD(DD,-@hk_days,GETDATE())

			SELECT @rows = @@ROWCOUNT

			WHILE @rows > 0
			BEGIN

				DELETE FROM [t4bdb01].[dbo].[t4b_info_backup_log]
				WHERE TIMESTAMP < DATEADD(DD,-@hk_days,GETDATE())

				SELECT @rows = @@ROWCOUNT
				
			END

			SET ROWCOUNT 0

		END

		-- SPACE_LG_MON

		IF (SELECT SPACE_LG_MON FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname AND SPACE_LG_MON = 1) = 1
		BEGIN

			SELECT @hk_days = HK_SPACE_LG_MON FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname

			SET ROWCOUNT 1000

			DELETE FROM [t4bdb01].[dbo].[t4b_info_space_lg_mon]
			WHERE TIMESTAMP < DATEADD(DD,-@hk_days,GETDATE())

			SELECT @rows = @@ROWCOUNT

			WHILE @rows > 0
			BEGIN

				DELETE FROM [t4bdb01].[dbo].[t4b_info_space_lg_mon]
				WHERE TIMESTAMP < DATEADD(DD,-@hk_days,GETDATE())

				SELECT @rows = @@ROWCOUNT
				
			END

			SET ROWCOUNT 0

		END

		-- SPACE_DB_GROWTH

		IF (SELECT SPACE_DB_GROWTH FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname AND SPACE_DB_GROWTH = 1) = 1
		BEGIN

			SELECT @hk_days = HK_SPACE_DB_GROWTH FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname

			SET ROWCOUNT 1000

			DELETE FROM [t4bdb01].[dbo].[t4b_info_ocup_db]
			WHERE TIMESTAMP < DATEADD(DD,-@hk_days,GETDATE())

			SELECT @rows = @@ROWCOUNT

			WHILE @rows > 0
			BEGIN

				DELETE FROM [t4bdb01].[dbo].[t4b_info_ocup_db]
				WHERE TIMESTAMP < DATEADD(DD,-@hk_days,GETDATE())

				SELECT @rows = @@ROWCOUNT
				
			END

			SET ROWCOUNT 0

		END

		-- SPACE_TAB_GROWTH

		IF (SELECT SPACE_TAB_GROWTH FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname AND SPACE_TAB_GROWTH = 1) = 1
		BEGIN

			SELECT @hk_days = HK_SPACE_TAB_GROWTH FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname

			SET ROWCOUNT 1000

			DELETE FROM [t4bdb01].[dbo].[t4b_info_ocup_tab]
			WHERE TIMESTAMP < DATEADD(DD,-@hk_days,GETDATE())

			SELECT @rows = @@ROWCOUNT

			WHILE @rows > 0
			BEGIN

				DELETE FROM [t4bdb01].[dbo].[t4b_info_ocup_tab]
				WHERE TIMESTAMP < DATEADD(DD,-@hk_days,GETDATE())

				SELECT @rows = @@ROWCOUNT
				
			END

			SET ROWCOUNT 0

		END

		-- UPDATE_STATS

		IF (SELECT UPDATE_STATS FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname AND UPDATE_STATS = 1) = 1
		BEGIN

			SELECT @hk_days = HK_UPDATE_STATS FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname

			SET ROWCOUNT 1000

			DELETE FROM [t4bdb01].[dbo].[t4b_info_upstats]
			WHERE STARTTIME < DATEADD(DD,-@hk_days,GETDATE())

			SELECT @rows = @@ROWCOUNT

			WHILE @rows > 0
			BEGIN

				DELETE FROM [t4bdb01].[dbo].[t4b_info_upstats]
				WHERE STARTTIME < DATEADD(DD,-@hk_days,GETDATE())

				SELECT @rows = @@ROWCOUNT
				
			END

			SET ROWCOUNT 0

		END

		-- CHECK_DB

		IF (SELECT CHECK_DB FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname AND CHECK_DB = 1) = 1
		BEGIN

			SELECT @hk_days = HK_CHECK_DB FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname

			SET ROWCOUNT 1000

			DELETE FROM [t4bdb01].[dbo].[t4b_info_checkdb]
			WHERE TIMESTAMP < DATEADD(DD,-@hk_days,GETDATE())

			SELECT @rows = @@ROWCOUNT

			WHILE @rows > 0
			BEGIN

				DELETE FROM [t4bdb01].[dbo].[t4b_info_checkdb]
				WHERE TIMESTAMP < DATEADD(DD,-@hk_days,GETDATE())

				SELECT @rows = @@ROWCOUNT
				
			END

			SET ROWCOUNT 0

		END

		-- REINDEX

		IF (SELECT REINDEX FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname AND REINDEX = 1) = 1
		BEGIN

			SELECT @hk_days = HK_REINDEX FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname

			SET ROWCOUNT 1000

			DELETE FROM [t4bdb01].[dbo].[t4b_info_reindex]
			WHERE STARTTIME < DATEADD(DD,-@hk_days,GETDATE())

			SELECT @rows = @@ROWCOUNT

			WHILE @rows > 0
			BEGIN

				DELETE FROM [t4bdb01].[dbo].[t4b_info_reindex]
				WHERE STARTTIME < DATEADD(DD,-@hk_days,GETDATE())

				SELECT @rows = @@ROWCOUNT
				
			END

			SET ROWCOUNT 0

		END

		-- DISKSPACE

		IF (SELECT DISKSPACE FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname AND DISKSPACE = 1) = 1
		BEGIN

			SELECT @hk_days = HK_DISKSPACE FROM [t4bdb01].[dbo].[t4b_procadm_param_hk] WHERE DBNAME = @dbname

			SET ROWCOUNT 1000

			DELETE FROM [t4bdb01].[dbo].[t4b_info_diskspace]
			WHERE TIMESTAMP < DATEADD(DD,-@hk_days,GETDATE())

			SELECT @rows = @@ROWCOUNT

			WHILE @rows > 0
			BEGIN

				DELETE FROM [t4bdb01].[dbo].[t4b_info_diskspace]
				WHERE TIMESTAMP < DATEADD(DD,-@hk_days,GETDATE())

				SELECT @rows = @@ROWCOUNT
				
			END

			SET ROWCOUNT 0

		END

	FETCH NEXT FROM cur_hk INTO @dbname

	END

END

ELSE IF @param = 'SHRINK_LOG'
BEGIN

	DECLARE @filename nvarchar(50),
			@fsize int

	SELECT @server = @@SERVERNAME

	-- Popula o cursor com os bancos cujo log excede o threshold:
	DECLARE cur_db CURSOR FOR
		SELECT
			DBNAME,
			THRESH_LG_SIZE
		FROM t4b_procadm_param AS tpp
			INNER JOIN master..sysaltfiles saf
				ON db_id(tpp.DBNAME) = saf.dbid
				AND fileid = 2
		WHERE SERVER = @server
			AND tpp.THRESH_LG_SIZE < (saf.size * 8) / 1024

	OPEN cur_db

	IF @@CURSOR_ROWS = 0
	BEGIN
		SELECT @msg = ' [%s][%s] Nenhum banco de dados selecionado para realizar o shrink de log.'
		SELECT @currdate = CONVERT(VARCHAR, GETDATE())
		RAISERROR (@msg, 16,1, @currdate, @server)

		CLOSE cur_db
		DEALLOCATE cur_db

		RETURN
	END

	FETCH FROM cur_db INTO
		@dbname,
		@fsize

	WHILE @@FETCH_STATUS = 0
	BEGIN	

		SELECT @filename = [name]
		FROM master..sysaltfiles
		WHERE dbid = db_id(@dbname)
		
		--Caso o nome do Database inicie-se com n˙mero, insere-o dentro de colchetes para que n„o ocorram erros de sintaxe no T-SQL
		IF ISNUMERIC(SUBSTRING(@dbname, 1, 1)) = 1
			SELECT @dbname = '[' + @dbname + ']'
		--Caso o path do arquivo inicie-se com n˙mero, insere-o dentro de colchetes para que n„o ocorram erros de sintaxe no T-SQL	
		IF ISNUMERIC(SUBSTRING(@filename, 1, 1)) = 1
			SELECT @filename = '[' + @filename + ']'
		
			
		SET @sql_text = 'USE ' + @dbname + '; ' +
						'DBCC SHRINKFILE (' + @filename + ', ' + CONVERT(varchar, @fsize) + ');'
	
		EXEC(@sql_text)
	
		IF @@ERROR != 0
		BEGIN
			SELECT @msg = ' [%s][%s] Erro no processo de shrink de log do banco ' + @dbname + '.'
			SELECT @currdate = CONVERT(VARCHAR, GETDATE())
			RAISERROR (@msg, 16,1, @currdate, @server)

			CLOSE cur_db
			DEALLOCATE cur_db

			RETURN  1
		END

		FETCH FROM cur_db INTO
			@dbname,
			@fsize
	END

	CLOSE cur_db
	DEALLOCATE cur_db

	RETURN

END

ELSE
BEGIN
	SELECT @msg = 'PAR¬METRO INV¡LIDO'
	SELECT @currdate = CONVERT(VARCHAR, GETDATE())
	RAISERROR (@msg, 16,1, @currdate, @server)

	RETURN 1
END

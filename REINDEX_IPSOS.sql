SET NOCOUNT ON 

DECLARE @Database VARCHAR(255)   
DECLARE @Table VARCHAR(255)  
DECLARE @cmd NVARCHAR(500)
DECLARE @sql_text NVARCHAR(500)  
DECLARE @fillfactor INT 
DECLARE @fsize int
DECLARE @inicioR NVARCHAR(50)  
DECLARE @fimR NVARCHAR(50)  

SET @fillfactor = 90 

DECLARE DatabaseCursor CURSOR FOR  
SELECT name FROM master.dbo.sysdatabases   
WHERE name NOT IN ('master','msdb','tempdb','model','distribution','t4bdb01')   
ORDER BY 1  

-- CRIA TABELA QUE PARA ATUALIZAR O TAMANHO DO LOG NA T4B_PROCADM_PARAM
		CREATE TABLE #t4b_logspace (
		banco nvarchar(128),
		logS decimal(15,8),
		logU decimal(15,8),
		status int)

		INSERT INTO #t4b_logspace
			EXEC('DBCC SQLPERF(LOGSPACE)')

		BEGIN
			SELECT @sql_text = '
				UPDATE [t4bdb01].[dbo].[t4b_procadm_param]
					SET t4b_procadm_param.THRESH_LG_SIZE = CEILING(#t4b_logspace.logS)
				FROM [t4bdb01].[dbo].[t4b_procadm_param]
				INNER JOIN #t4b_logspace ON t4b_procadm_param.[DBNAME] = #t4b_logspace.banco'
		END
		
		EXEC (@sql_text)
-- FIM DA ATUALIZACAO DA T4B_PROCADM_PARAM
-- INICIO DO CURSOR PARA BANCO
OPEN DatabaseCursor  
FETCH NEXT FROM DatabaseCursor INTO @Database  
WHILE @@FETCH_STATUS = 0  
BEGIN  
   SET @fsize = (SELECT top 1 THRESH_LG_SIZE FROM t4bdb01..t4b_procadm_param where dbname = @Database)
   SET @fsize = @fsize*0.9
   SET @cmd = 'DECLARE TableCursor CURSOR FOR SELECT ''['' + table_catalog + ''].['' + table_schema + ''].['' + 
  table_name + '']'' as tableName FROM [' + @Database + '].INFORMATION_SCHEMA.TABLES 
  WHERE table_type = ''BASE TABLE''' + CHAR(10) + 'ALTER DATABASE [' + @Database + '] SET RECOVERY SIMPLE' 
-- CREATE TABLE CURSOR  
  exec (@cmd)  
  

   OPEN TableCursor   

   FETCH NEXT FROM TableCursor INTO @Table   
   WHILE @@FETCH_STATUS = 0   
   BEGIN   

       IF (@@MICROSOFTVERSION / POWER(2, 24) >= 9)
       BEGIN
           -- SQL 2005 or higher command 
           set @inicioR = GETDATE()
           select 'Rebuilding dos Indexes da tabela ' + @Table + ' do Banco ' + @Database
           set @cmd = ' ALTER INDEX ALL ON ' + @Table + ' REBUILD WITH (FILLFACTOR = ' + CONVERT(VARCHAR(3),@fillfactor) + ')'
           exec (@cmd)
           set @fimR = GETDATE()
           select @Table as tabela, @inicioR as Inicio, @fimR as Fim
          
           
       END
       ELSE
       BEGIN
          -- SQL 2000 command 
          DBCC DBREINDEX(@Table,' ',@fillfactor)  
       END

       FETCH NEXT FROM TableCursor INTO @Table   
   END   
   
   SET @cmd = 'ALTER DATABASE [' + @Database + '] SET RECOVERY FULL' 
   exec (@cmd)
   select 'Shrink do Log do banco ' + @Database + ' para o tamanho ' + CONVERT(VARCHAR,@fsize)
   set @cmd = 'USE [' + @Database +'];' + CHAR(10) + 'DBCC SHRINKFILE (2,' + CONVERT(VARCHAR,@fsize) + ');'
   exec (@cmd)
   
   
   CLOSE TableCursor   
   DEALLOCATE TableCursor  
   
  
   FETCH NEXT FROM DatabaseCursor INTO @Database  
END  
CLOSE DatabaseCursor   
DEALLOCATE DatabaseCursor
DROP TABLE #t4b_logspace
SET NOCOUNT OFF
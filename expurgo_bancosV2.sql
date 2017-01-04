CREATE PROC sp_expurgoBancos_v2
as
--nesta versao v2, foi adicionado a quantidade de linhas apagadas
begin

declare @cmd varchar(max)
declare @cmd1 varchar(max)
declare @linhasAntes int
declare @linhasDepois int
declare @linhasAtuais int	
declare @BancoExpurgo varchar(100)
declare @WhileDurante varchar(max)
declare @Ciclos varchar(20)
declare @LinhasPorCiclo varchar(20)
declare @tabelaExpurgo varchar(100)
declare @WhereCondicao varchar(max)
declare @id_tblExpurgoBancos int
declare @result table (rowcount1 int)
                
 -- Tabelas a serem limpas                
 Select *            
 into #LimpezaTabelas                
 from t4bdb01..tblExpurgoBancos as t1              
 where FlagLimpeza = 1
 
  while (                
  Select count(1)                
  from #LimpezaTabelas                
  ) > 0               
	
	BEGIN
	  Select @id_tblExpurgoBancos = min( id_tblExpurgoBancos )         
	  from #LimpezaTabelas    
	  
	  Select @BancoExpurgo = BancoExpurgo,
	  @TabelaExpurgo = TabelaExpurgo,
	  @Ciclos = Ciclos,
	  @LinhasPorCiclo = LinhasPorCiclo,
	  @WhileDurante = WhileDurante,
	  @WhereCondicao = WhereCondicao
	  from #LimpezaTabelas  
	  where id_tblExpurgoBancos = @id_tblExpurgoBancos
	  
	BEGIN TRY
		update t4bdb01..tblExpurgoBancos 
		set tblExpurgoBancos.DtInicioUltimaLimpeza = GETDATE()
		where id_tblExpurgoBancos = @id_tblExpurgoBancos
		
		--salva quantas linhas tem antes
		set @cmd1 = 'select count(1) from ' + @BancoExpurgo + '..' + @tabelaExpurgo + ' with (nolock)'
		insert into @result (rowcount1) exec (@cmd1)
		select @linhasAntes = rowcount1 from @result
		
				
		set @cmd = 

				'ALTER DATABASE ' + @BancoExpurgo + ' SET RECOVERY SIMPLE
				print ''' + @tabelaExpurgo + '''
				BEGIN TRY
				USE ' + @BancoExpurgo + CHAR(10) + 
				@WhileDurante + char(10) + 
				'begin
				declare @ciclos int
				set @ciclos = ' + @Ciclos + CHAR(10)+
				'set rowcount ' + @LinhasPorCiclo + CHAR(10)+
				'while @ciclos > 0
				begin
				delete from ' + @tabelaExpurgo + CHAR(10)+
				@WhereCondicao + CHAR(10)+
				'set @ciclos = @ciclos - 1
				print @ciclos
				end
				end
				insert into t4bdb01..tblExpurgoLog (DtLog,idTabelaExpurgo,MsgExecucao)
				values (getdate(),'+ CONVERT(varchar, @id_tblExpurgoBancos) + ',''Sucesso'')
				END TRY
				BEGIN CATCH
				declare @error varchar(max)
				select @error = ERROR_MESSAGE()
				insert into t4bdb01..tblExpurgoLog (DtLog,idTabelaExpurgo,MsgExecucao)
				values (getdate(),' + CONVERT(varchar, @id_tblExpurgoBancos) + ', @error)
				END CATCH
				ALTER DATABASE ' + @BancoExpurgo + ' SET RECOVERY FULL'
		
		exec (@cmd)		
		--select @cmd
		
		set @cmd1 = 'select count(1) from ' + @BancoExpurgo + '..' + @tabelaExpurgo + ' with (nolock)'
		insert into @result (rowcount1) exec (@cmd1)
		select @linhasDepois = rowcount1 from @result
				
		set @linhasAtuais = @linhasAntes - @linhasDepois
	
		
		update t4bdb01..tblExpurgoBancos 
		set tblExpurgoBancos.DtFimUltimaLimpeza = GETDATE(), 
		tblExpurgoBancos.LinhasApagadasUltLimp = @linhasAtuais,
		MsgErro = 'SUCESSO'
		where id_tblExpurgoBancos = @id_tblExpurgoBancos 
		


	END TRY
	BEGIN CATCH
		declare @error varchar(max)
		select @error = ERROR_MESSAGE()

		update t4bdb01..tblExpurgoBancos 
		set DtFimUltimaLimpeza = GETDATE()
		where id_tblExpurgoBancos = @id_tblExpurgoBancos 

		update t4bdb01..tblExpurgoBancos 
		set MsgErro = @error
		where id_tblExpurgoBancos = @id_tblExpurgoBancos 
	END CATCH
	
	delete from #LimpezaTabelas  
	where id_tblExpurgoBancos = @id_tblExpurgoBancos
	END

	drop table #LimpezaTabelas  
END
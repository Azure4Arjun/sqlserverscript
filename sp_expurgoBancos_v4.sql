CREATE PROC sp_expurgoBancos_v4
AS
--na versao v2, foi adicionado a quantidade de linhas apagadas
--na versao v3, foi adicionado a leitura da frequencia e a ordenacao das tabelas
--na versao v4, foi adicionado o insert de linhas apagadas na tblLog
BEGIN

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
declare @diaNum	int
declare @LinhasLog int
declare @idLog int
declare @error varchar(max)
 -- drop table #LimpezaTabelas                
 --											 DOM   SEG	 TER	QUA   QUI	 SEX	SAB
 -- Salvando numero do dia seguindo a logica 2^0=1,2^1=2,2^2=4,2^3=8,2^4=16,2^5=32,2^6=64, caso queira uma combinacao de dias, faco a soma dos respectivos
 --	pega o numero do dia, subtrai 1 e eleva 2 a este numero
	set @diaNum = POWER(2,(datepart(dw,getdate()-1)))

 -- Tabelas a serem limpas                
 Select *            
 into #LimpezaTabelas                
 from t4bdb01..tblExpurgoBancos as t1              
 where FlagLimpeza = 1
 and (t1.Frequencia & @diaNum) > 0
 order by t1.BancoExpurgo,t1.OrdemExec desc


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
				insert into t4bdb01..tblExpurgoLog (DtLog,idTabelaExpurgo,MsgExecucao,LinhasApagadas)
				values (getdate(),'+ CONVERT(varchar, @id_tblExpurgoBancos) + ',''Sucesso'',1)
				END TRY
				BEGIN CATCH
				declare @error varchar(max)
				select @error = ERROR_MESSAGE()
				insert into t4bdb01..tblExpurgoLog (DtLog,idTabelaExpurgo,MsgExecucao,LinhasApagadas)
				values (getdate(),' + CONVERT(varchar, @id_tblExpurgoBancos) + ', @error,1)
				END CATCH
				ALTER DATABASE ' + @BancoExpurgo + ' SET RECOVERY FULL'
				
		
		exec (@cmd)		
		--select @cmd
		
		-- calculo das linhas apagadas
		set @cmd1 = 'select count(1) from ' + @BancoExpurgo + '..' + @tabelaExpurgo + ' with (nolock)'
		insert into @result (rowcount1) exec (@cmd1)
		select @linhasDepois = rowcount1 from @result
				
		set @linhasAtuais = @linhasAntes - @linhasDepois
		
		-- insere linhas apagadas na tabela de log
		set rowcount 1
		select @idLog = idLog from tblExpurgoLog
		order by DtLog desc
		set rowcount 0
		
		update t4bdb01..tblExpurgoLog
		set LinhasApagadas = @linhasAtuais
		where idLog = @idLog
		
		update t4bdb01..tblExpurgoBancos 
		set tblExpurgoBancos.DtFimUltimaLimpeza = GETDATE(), 
		tblExpurgoBancos.LinhasApagadasUltLimp = @linhasAtuais,
		tblExpurgoBancos.MsgErro = 'SUCESSO'
		where id_tblExpurgoBancos = @id_tblExpurgoBancos 
		
		

	END TRY
	BEGIN CATCH
	
		-- calculo das linhas apagadas
		set @cmd1 = 'select count(1) from ' + @BancoExpurgo + '..' + @tabelaExpurgo + ' with (nolock)'
		insert into @result (rowcount1) exec (@cmd1)
		select @linhasDepois = rowcount1 from @result
				
		set @linhasAtuais = @linhasAntes - @linhasDepois
		
		-- insere linhas apagadas na tabela de log
		set rowcount 1
		select @idLog = idLog from tblExpurgoLog
		order by DtLog desc
		set rowcount 0
		
		update t4bdb01..tblExpurgoLog
		set LinhasApagadas = @linhasAtuais
		where idLog = @idLog
	
		
		select @error = ERROR_MESSAGE()

		update t4bdb01..tblExpurgoBancos 
		set tblExpurgoBancos.DtFimUltimaLimpeza = GETDATE(), 
		tblExpurgoBancos.LinhasApagadasUltLimp = @linhasAtuais,
		tblExpurgoBancos.MsgErro = @error
		where id_tblExpurgoBancos = @id_tblExpurgoBancos 

		
	END CATCH
	
	delete from #LimpezaTabelas  
	where id_tblExpurgoBancos = @id_tblExpurgoBancos
	END

	drop table #LimpezaTabelas  
END
--select * from tblbancopermissao

begin
 declare @idPermissaoDia int,
  @login nVarChar(255),          
  @Banco varchar(255),          
   @Servidor varchar (250),  
  @CodBancoPermissao varchar (250),  
  @DtConcessao varchar (250),  
  @DtExpiracao varchar (250),  
  @FlagLiberado varchar (250),  
  @ServidorAT varchar(250),  
  @Command varchar (2000),
  @error varchar (20) 


select * into #BancoServer 
from tblbancoPermissao
where servidor in ('latbrspodb05',
'latbrspodb08\sql2008',
'ambrsaosql1',
'ambrsaosql2')
and DtExpiracao <= GETDATE ()


while (
select COUNT (1)
from #BancoServer ) > 0 


begin          
		Select @CodBancoPermissao = min( CodBancoPermissao )   
		from #BancoServer    
				    
		select @login  = Login,           
		@Banco = Banco,           
		@Servidor = Servidor  
		from #BancoServer          
		where CodBancoPermissao = @CodBancoPermissao  

		set @Servidor = 'LATBRSPODB05'
		begin  
			-- se o servidor nao for o DB05, usar linked server  
			if upper(@Servidor) = 'LATBRSPODB05'  
				begin  
                  set @servidorAT = ''  
				end  
			-- se for DB05 não precisa Linked Server
			if upper(@Servidor) <> 'LATBRSPODB05'  
				begin  
                  set @servidorAT = ' AT [' + @servidor + ']'  
				end  
		
		
		set @Command = 	'EXECUTE ( ''use master; select * from sysdatabases where name = ''''' + @Banco + ''''''')' + @servidorAT + ''
		select (@Command)
		if (@@ROWCOUNT = 0)
		begin 
		--o banco ja foi migrado e expirou a permissao , vamos remover de todos os servidores novos
			declare @CodBancoPermissaoServidor varchar (500)
			
			select * into #servers from tblBancoPermissaoServidor
			where Servidor in ('ambrsaosql3\sql3',
			'ambrsaosql4\sql4',
			'ambrsaosql5\sql5')
			
			while (select COUNT(1) 
			from #servers) > 0
			
				begin
					Select @CodBancoPermissaoServidor = min( CodBancoPermissaoServidor )   
					from #servers 
					select @Servidor = servidor
					from #servers 
					where CodBancoPermissaoServidor = @CodBancoPermissaoServidor
					
					set @servidorAT = ' AT [' + @servidor + ']'  
					
					begin  
						begin try          
							set @Command = 'EXECUTE ( ''use ['+ @Banco + '] ; DROP USER [' + @login + ']'')'  + @ServidorAT  
							select (@Command) 
						end try          
						begin catch          
						end catch
					end
				delete from #servers
				where CodBancoPermissao = @CodBancoPermissao 
				end
		delete from #BancoServer
		where CodBancoPermissao = @CodBancoPermissao	
			
		end
		else
		begin 
		--print 'trouxe 1 ou mais'
		delete from #BancoServer
		where CodBancoPermissao = @CodBancoPermissao
	
		end
		end
		

		
end
		if (select object_id ('tempdb.dbo.#BancoServer')) is not null 
		begin
		drop table #BancoServer
		end
		if ( select object_id ('tempdb.dbo.#servers')) is not null
		begin
		drop table #servers
		end
end


USE [AlfaSenha]
GO
/****** Object:  StoredProcedure [dbo].[pr_AplicaPermissoes_v3]    Script Date: 02/06/2014 09:32:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[pr_AplicaPermissoes_v1]        
as        
begin        
        
 declare @idPermissaoDia int        
 declare @login nVarChar(255),        
  @Banco varchar(255),        
  @TipoPermissao varchar(8000),
  @Servidor varchar (250),
  @CodBancoPermissao varchar (250),
  @DtConcessao varchar (250),
  @DtExpiracao varchar (250),
  @FlagLiberado varchar (250),
  @ServidorAT varchar(250),
  @CommandLibera varchar (1000)


        
 -- permissões para liberar        
 Select *    
 into #LiberaAcesso        
 from tblBancoPermissao as t1          
 where GetDate() between DtConcessao and DtExpiracao and        
  FlagLiberado = 0 
      
        
 -- permissões para remover        
 select *       
 into #RemoveAcesso        
 from tblBancoPermissao as t1        
 where (GetDate() not between DtConcessao and DtExpiracao)  and
FlagLiberado = 1
   
        
 -- Libera as permissões.        
 while (        
  Select count(1)        
  from #LiberaAcesso        
  ) > 0       
  
 
 begin        
  Select @CodBancoPermissao = min( CodBancoPermissao ) 
  from #LiberaAcesso  
  
  select @login  = Login,         
   @Banco = Banco,         
   @TipoPermissao = TipoPermissao,
   @Servidor = Servidor
   --@CodBancoPermissao = CodBancoPermissao       
  from #LiberaAcesso        
  where CodBancoPermissao = @CodBancoPermissao
  
        
        
  begin
  -- se o servidor nao for o DB05, usar linked server
      if upper(@Servidor) = 'LATBRSPODB05'
            begin
                  set @servidorAT = ''
            end

      if upper(@Servidor) <> 'LATBRSPODB05'
            begin
                  set @servidorAT = ' AT [' + @servidor + ']'
            end



       begin
       begin try        
            -- Libera os acessos        
            -- select @login, @Banco, @TipoPermissao      
            set @CommandLibera = 'EXECUTE ( ''use [master] ; create login [' + @login + '] from Windows' + ''')'  + @ServidorAT
            exec (@CommandLibera)
		end try        
		begin catch        
		end catch
        begin try        
            -- Libera os acessos        
            -- select @login, @Banco, @TipoPermissao      
            set @CommandLibera = 'EXECUTE ( ''use [' + @Banco + '] ; create user [' + @login + '] from login [' + @login + '] ; exec sp_addrolemember ' + @TipoPermissao + ', [' + @login + ']'')'  + @ServidorAT
            exec (@CommandLibera)
		    update tblBancoPermissao        
			set FlagLiberado = 1        
			where CodBancoPermissao = @CodBancoPermissao        
		end try        
		begin catch        
		end catch
		end
           
      
		delete #LiberaAcesso        
		where CodBancoPermissao = @CodBancoPermissao        
		end 
		end
		  
        
 -- Remove as permissões         
 while (        
  Select count(1)        
  from #RemoveAcesso        
  ) > 0  
        
 begin        
  Select @CodBancoPermissao = min( CodBancoPermissao ) 
  from #RemoveAcesso        
        
  Select @login = Login,        
   @Banco = Banco,
   @Servidor = Servidor
  from #RemoveAcesso        
  where CodBancoPermissao = @CodBancoPermissao        
           
          begin
  -- se o servidor nao for o DB05, usar linked server
      if upper(@Servidor) = 'LATBRSPODB05'
            begin
                  set @servidorAT = ''
            end

      if upper(@Servidor) <> 'LATBRSPODB05'
            begin
                  set @servidorAT = ' AT [' + @servidor + ']'
            end
		begin
  
            begin try        
			set @CommandLibera = 'EXECUTE ( ''use [' + @Banco + '] ; drop user [' + @login + ']'')'  + @ServidorAT
            exec (@CommandLibera)
            end try        
			begin catch        
			end catch        
			insert into tblLogBancoPermissao (CodBancoPermissao, login, Servidor, Banco, TipoPermissao, DtConcessao , DtExpiracao ,  FlagLiberado, DtInclusaoLog ) select CodBancoPermissao, login, Servidor, Banco, TipoPermissao, DtConcessao , DtExpiracao ,  FlagLiberado, GETDATE() from #RemoveAcesso where CodBancoPermissao = @CodBancoPermissao
            delete from tblBancoPermissao
            where CodBancoPermissao = @CodBancoPermissao     
		end
		end
		
  
              
  delete #RemoveAcesso        
  where CodBancoPermissao = @CodBancoPermissao      
   end    
 drop table #LiberaAcesso
 drop table #RemoveAcesso
 end
 
 
 
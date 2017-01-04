CREATE PROC sp_envia_email_anexo 
 (@BancoOrigem as varchar(100),
 @emailDest as varchar(50),
 @emailRem as varchar (50),
 @serverRem as varchar (50),
 @nomeJob as varchar (50),
 @CorpoEmail as varchar (1000),
 @nomeArquivo as varchar(500),
 @extensao as varchar (5))
 
 as
 BEGIN
 
 DECLARE
 @conteudo varchar(1000),
 @criaQuickEmail nvarchar (max),
 @addAnexo nvarchar (max),
 @CodEmailEnvio int
 
 --@BancoOrigem nvarchar(100),
 --@emailDest nvarchar(50),
 --@emailRem nvarchar (50),
 --@serverRem nvarchar (50),
 --@nomeJob nvarchar (50),
 --@CorpoEmail nvarchar (1000),
 --@nomeArquivo nvarchar(500)
 --@extensao nvarchar(5),  
 
 --set @BancoOrigem = 'DA'
 --set @emailDest = 'rafael.goncalez3@ipsos.com'
 --set @emailRem = 'sqlserver@ipsos.com'
 --set @serverRem = 'AMBRSAOSQL5/SQL5'
 --set @nomeJob = 'MAINTENCE_NEW_DB'
 --set @CorpoEmail = ''
 ----set @nomeArquivo = '\\ambrsaosql5.ipsosgroup.ipsos.com\dba\MAINTENANCE_NEW_DB.log'
 --set @nomeArquivo = 'E:\dba\MAINTENANCE_NEW_DB.log'
 --set @extensao = 'log'
 
 

set @criaQuickEmail =
'exec [latbrspodb05].IpsosMail.dbo.sp_InsereNovoQuickEmail @BancoOrigem = ''' + @BancoOrigem + 
''', @CodEmailBancoOrigem = 0, @CodCliente = 0, @Destinatario = ''' + @emailDest + 
''', @Remetente = ''' + @emailRem + 
''', @NRemetente = ''' + @serverRem + 
''', @Assunto = ''[' + convert(varchar, getdate(), 100) + '] - [' + @nomeJob + 
']'', @CorpoHTML = ''' + @CorpoEmail + 
''', @CorporTexto = '''', @CodLote = 0, @CCo = '''''

begin try 
--select (@criaQuickEmail)
declare @out table 
( out int)
insert into @out
exec (@criaQuickEmail)
end try
begin catch
select   ERROR_NUMBER() AS ErrorNumber
        ,ERROR_MESSAGE() AS ErrorMessage
        ,@criaQuickEmail
end catch 
--pega o codEmailEnvio gerado quando criou um quickEmail
select @CodEmailEnvio = out from @out

--Conteudo do arquivo a ser anexado
set @conteudo = ' bulkcolumn from openrowset (bulk ''' + @nomeArquivo + ''', single_blob) as blob'
set @addAnexo = 'insert into [latbrspodb05].IpsosMail.dbo.tblEmailAnexo (codEmailEnvio, extensao, nome, conteudo) select ''' + CONVERT(nvarchar, @CodEmailEnvio) + ''',''' + @extensao + ''',''' + @nomeArquivo + ''',' + @conteudo
--select @extensao, @conteudo,@CodEmailEnvio,@nomeArquivo
begin try 
exec (@addAnexo)
end try
begin catch
select   ERROR_NUMBER() AS ErrorNumber
        ,ERROR_MESSAGE() AS ErrorMessage
        ,@addAnexo
end catch

END


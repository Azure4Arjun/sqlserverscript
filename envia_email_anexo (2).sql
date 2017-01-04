 DECLARE
 @CodEmailEnvio as varchar(30),      
 @extensao as varchar(5),      
 @nomeArquivo as varchar(500),      
 @conteudo as varbinary(max),
 @criaQuickEmail as varchar (1000),
 @BancoOrigem as varchar(100),
 @emailDest as varchar(50),
 @emailRem as varchar (50),
 @serverRem as varchar (50),
 @nomeJob as varchar (50), 
 

set @criaQuickEmail =
'exec [latbrspodb05].IpsosMail.dbo.sp_InsereNovoQuickEmail @BancoOrigem = ' + @BancoOrigem + ', @CodEmailBancoOrigem = 0, @CodCliente = 0, @Destinatario = ' + @emailDest + ', @Remetente = ' + @emailRem + ', @NRemetente = ' + @serverRem + ', @Assunto = [' + GETDATE() + '] - [' + @nomeJob +'], @CorpoHTML = '" & CorpoEmail & "', @CorporTexto = '', @CodLote = 0, @CCo = '''
exec (@criaQuickEmail)

set @conteudo = ' bulkcolumn from openrowset (bulk ' + @nomeArquivo + ', single_blob) as blob'
set @addAnexo = 
'insert into [latbrspodb05].IpsosMail.dbo.tblEmailAnexo (codEmailEnvio, extensao, nome, conteudo) values (' + @CodEmailEnvio + ',' + @extensao + ',' + @nomeArquivo + ',' + @conteudo + ')'
select * from tblEmailAnexo

sp_helptext sp_InsereAnexo
      


--insert into IpsosMail.dbo.tblEmailAnexo (codEmailEnvio, extensao, nome, conteudo) values (@CodEmailEnvio, @extensao, @nomeArquivo, @conteudo)

--insert into t4bdb01..tblteste_binario (codFile, BinFile) select 1, bulkcolumn from openrowset (bulk 'C:\t4b\ERRORLOG.txt', single_blob) as blob

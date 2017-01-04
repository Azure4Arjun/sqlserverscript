USE [t4bdb01]
GO
/****** Object:  Table [dbo].[tblExpurgoLog]    Script Date: 05/22/2014 11:33:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblExpurgoLog](
	[idLog] [int] IDENTITY(1,1) NOT NULL,
	[DtLog] [datetime] NOT NULL,
	[idTabelaExpurgo] [int] NOT NULL,
	[MsgExecucao] [varchar](max) NOT NULL,
	[LinhasApagadas] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[tblExpurgoLog] ON
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (228, CAST(0x0000A33300BA7D77 AS DateTime), 4, N'Sucesso', 777532)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (229, CAST(0x0000A33300BA97CA AS DateTime), 5, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (231, CAST(0x0000A33300BAB524 AS DateTime), 7, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (232, CAST(0x0000A33300BAB972 AS DateTime), 8, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (233, CAST(0x0000A33300BAC7F8 AS DateTime), 9, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (234, CAST(0x0000A33300BAD800 AS DateTime), 10, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (235, CAST(0x0000A33300BAE54D AS DateTime), 11, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (236, CAST(0x0000A33300BB674F AS DateTime), 12, N'Sucesso', 813)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (237, CAST(0x0000A33300BB67B2 AS DateTime), 13, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (238, CAST(0x0000A33300BB6BE8 AS DateTime), 15, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (239, CAST(0x0000A33300BB6C31 AS DateTime), 16, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (240, CAST(0x0000A33300BB6E38 AS DateTime), 18, N'Sucesso', 287)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (241, CAST(0x0000A33300BD7F92 AS DateTime), 21, N'Sucesso', 15420)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (230, CAST(0x0000A33300BAB01C AS DateTime), 6, N'Sucesso', 0)
SET IDENTITY_INSERT [dbo].[tblExpurgoLog] OFF
/****** Object:  Table [dbo].[tblExpurgoBancos]    Script Date: 05/22/2014 11:33:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblExpurgoBancos](
	[id_tblExpurgoBancos] [int] IDENTITY(1,1) NOT NULL,
	[BancoExpurgo] [varchar](100) NOT NULL,
	[TabelaExpurgo] [varchar](100) NOT NULL,
	[Ciclos] [varchar](50) NOT NULL,
	[LinhasPorCiclo] [varchar](50) NOT NULL,
	[WhileDurante] [varchar](max) NULL,
	[WhereCondicao] [varchar](max) NOT NULL,
	[FlagLimpeza] [bit] NOT NULL,
	[DtInicioUltimaLimpeza] [datetime] NULL,
	[DtFimUltimaLimpeza] [datetime] NULL,
	[LinhasApagadasUltLimp] [int] NULL,
	[MsgErro] [varchar](max) NULL,
	[DtAdicaoTabela] [datetime] NOT NULL,
	[OrdemExec] [tinyint] NOT NULL,
	[Frequencia] [tinyint] NOT NULL,
 CONSTRAINT [PK_tblExpurgoBancos_1] PRIMARY KEY CLUSTERED 
(
	[BancoExpurgo] ASC,
	[TabelaExpurgo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[tblExpurgoBancos] ON
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (5, N'IndicadoresIntegracaoNew', N'tblAgenda', N'10', N'10000', N'while (   select count(*) 
	from tblAgenda with(nolock)    
	where not exists(select 1 from tblClienteDetalhe with(nolock) 
	where tblAgenda.CodCliente = tblClienteDetalhe.CodCliente)   
	and not exists (select 1 from tblLog with(nolock) 
	where tblAgenda.CodCliente = tblLog.CodCliente)) 
	> 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblAgenda.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblAgenda.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A33300BA94A9 AS DateTime), CAST(0x0000A33300BA97E7 AS DateTime), 0, N'SUCESSO', CAST(0x0000A31D0116C9A0 AS DateTime), 99, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (15, N'IndicadoresIntegracaoNew', N'tblAgendaHistorico', N'10', N'10000', N'while (
	select count(1) from tblAgendaHistorico with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblAgendaHistorico.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblAgendaHistorico.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblAgendaHistorico.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblAgendaHistorico.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A33300BB67E4 AS DateTime), CAST(0x0000A33300BB6BFF AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FB74E1 AS DateTime), 90, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (21, N'IndicadoresIntegracaoNew', N'tblCliente', N'10', N'1000000', N'while (
	select count(1) from tblCliente with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblCliente.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblCliente.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblCliente.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblCliente.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A33300BB6E46 AS DateTime), CAST(0x0000A33300BD8049 AS DateTime), 15420, N'SUCESSO', CAST(0x0000A32300B038C7 AS DateTime), 87, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (4, N'IndicadoresIntegracaoNew', N'tblClienteDetalhe', N'30', N'10000000', N'while (
	select count(*) from tblClienteDetalhe with(nolock) 
	where exists(select 1 from tblCliente with(nolock) 
		where tblClienteDetalhe.codcliente = tblcliente.codcliente and 
		codstatus <> 102 and
		DtInclusao <= DATEADD(MM,-6,GETDATE()) 
		)) > 0', N'where exists(select 1 from tblCliente with(nolock)    
	where tblClienteDetalhe.codcliente = tblcliente.codcliente and     codstatus <> 102 and    DtInclusao <= DATEADD(MM,-6,GETDATE()))', 1, CAST(0x0000A33300B908D4 AS DateTime), CAST(0x0000A33300BA94A8 AS DateTime), 777532, N'SUCESSO', CAST(0x0000A31D0116ACDC AS DateTime), 100, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (12, N'IndicadoresIntegracaoNew', N'tblLogDiscador', N'10', N'10000', N'while (
	select count(1) from tblLogDiscador with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblLogDiscador.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogDiscador.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblLogDiscador.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogDiscador.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A33300BAE5BA AS DateTime), CAST(0x0000A33300BB6795 AS DateTime), 813, N'SUCESSO', CAST(0x0000A32200FAC3CD AS DateTime), 92, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (16, N'IndicadoresIntegracaoNew', N'tblLogTrocaTelefone', N'10', N'10000', N'while (
	select count(1) from tblLogTrocaTelefone with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblLogTrocaTelefone.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogTrocaTelefone.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblLogTrocaTelefone.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogTrocaTelefone.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A33300BB6BFF AS DateTime), CAST(0x0000A33300BB6C44 AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FB85E4 AS DateTime), 89, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (13, N'IndicadoresIntegracaoNew', N'tblLogVolta', N'10', N'10000', N'while (
	select count(1) from tblLogVolta with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblLogVolta.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogVolta.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblLogVolta.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogVolta.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A33300BB6795 AS DateTime), CAST(0x0000A33300BB67E4 AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FAD4AC AS DateTime), 91, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (18, N'IndicadoresIntegracaoNew', N'tblLogVoltaChavePeriodo', N'10', N'10000', N'while (
	select count(1) from tblLogVoltaChavePeriodo with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblLogVoltaChavePeriodo.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogVoltaChavePeriodo.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblLogVoltaChavePeriodo.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogVoltaChavePeriodo.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A33300BB6C45 AS DateTime), CAST(0x0000A33300BB6E46 AS DateTime), 287, N'SUCESSO', CAST(0x0000A32300A343AE AS DateTime), 88, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (7, N'IndicadoresIntegracaoNew', N'tblLogVoltaRegistro', N'10', N'10000', N'while (
	select count(1) from tblLogVoltaRegistro with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblLogVoltaRegistro.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogVoltaRegistro.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblLogVoltaRegistro.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogVoltaRegistro.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A33300BAB09F AS DateTime), CAST(0x0000A33300BAB56A AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FA6D61 AS DateTime), 97, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (6, N'IndicadoresIntegracaoNew', N'tblResposta', N'10', N'10000', N'while (
	select count(1) from tblResposta with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblResposta.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblResposta.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblResposta.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblResposta.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A33300BA97E8 AS DateTime), CAST(0x0000A33300BAB09F AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FA5549 AS DateTime), 98, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (10, N'IndicadoresIntegracaoNew', N'tblRespostaAud', N'10', N'10000', N'while (
	select count(1) from tblRespostaAud with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblRespostaAud.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaAud.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblRespostaAud.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaAud.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A33300BAC95C AS DateTime), CAST(0x0000A33300BAD85E AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FAA923 AS DateTime), 94, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (8, N'IndicadoresIntegracaoNew', N'tblRespostaCritica', N'10', N'10000', N'while (
	select count(1) from tblRespostaCritica with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblRespostaCritica.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaCritica.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblRespostaCritica.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaCritica.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A33300BAB56B AS DateTime), CAST(0x0000A33300BAB991 AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FA8A2F AS DateTime), 96, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (9, N'IndicadoresIntegracaoNew', N'tblRespostaTAG', N'10', N'10000', N'while (
	select count(1) from tblRespostaTAG with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblRespostaTAG.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaTAG.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblRespostaTAG.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaTAG.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A33300BAB992 AS DateTime), CAST(0x0000A33300BAC95B AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FA9DAE AS DateTime), 95, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (11, N'IndicadoresIntegracaoNew', N'tblRespostaTempo', N'10', N'10000', N'while (
	select count(1) from tblRespostaTempo with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblRespostaTempo.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaTempo.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblRespostaTempo.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaTempo.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A33300BAD85E AS DateTime), CAST(0x0000A33300BAE5B9 AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FAB6C6 AS DateTime), 93, 127)
SET IDENTITY_INSERT [dbo].[tblExpurgoBancos] OFF

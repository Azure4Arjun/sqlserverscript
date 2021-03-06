USE [t4bdb01]
GO
/****** Object:  Table [dbo].[tblExpurgoLog]    Script Date: 09/16/2014 14:47:26 ******/
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
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (270, CAST(0x0000A33400AFC3E9 AS DateTime), 4, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (271, CAST(0x0000A33400AFDE01 AS DateTime), 5, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (272, CAST(0x0000A33400AFE71B AS DateTime), 6, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (273, CAST(0x0000A33400AFEC24 AS DateTime), 7, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (274, CAST(0x0000A33400AFF05A AS DateTime), 8, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (275, CAST(0x0000A33400AFFEE9 AS DateTime), 9, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (276, CAST(0x0000A33400B00E75 AS DateTime), 10, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (277, CAST(0x0000A33400B01BB3 AS DateTime), 11, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (278, CAST(0x0000A33400B026C6 AS DateTime), 12, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (279, CAST(0x0000A33400B02723 AS DateTime), 13, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (280, CAST(0x0000A33400B02B2B AS DateTime), 15, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (281, CAST(0x0000A33400B02B78 AS DateTime), 16, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (282, CAST(0x0000A33400B02BC4 AS DateTime), 18, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (283, CAST(0x0000A33400B044C4 AS DateTime), 21, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (284, CAST(0x0000A33F00A4D2D6 AS DateTime), 4, N'Sucesso', 14230979)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (285, CAST(0x0000A33F00A52D83 AS DateTime), 5, N'Sucesso', 4)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (286, CAST(0x0000A33F00A5AF56 AS DateTime), 6, N'Sucesso', 10)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (287, CAST(0x0000A33F00A5E8F7 AS DateTime), 7, N'Sucesso', 2)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (288, CAST(0x0000A33F00A5ECEB AS DateTime), 8, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (289, CAST(0x0000A33F00A5FD87 AS DateTime), 9, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (290, CAST(0x0000A33F00A6660D AS DateTime), 10, N'Sucesso', 11)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (291, CAST(0x0000A33F00A66CBF AS DateTime), 11, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (292, CAST(0x0000A33F00A6FAB5 AS DateTime), 12, N'Sucesso', 56947)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (293, CAST(0x0000A33F00A6FB2D AS DateTime), 13, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (294, CAST(0x0000A33F00A72785 AS DateTime), 15, N'Sucesso', 2)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (295, CAST(0x0000A33F00A728DA AS DateTime), 16, N'Sucesso', 1)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (296, CAST(0x0000A33F00A72A08 AS DateTime), 18, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (297, CAST(0x0000A33F00A9D047 AS DateTime), 21, N'Sucesso', 308348)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (298, CAST(0x0000A34100BE2E1D AS DateTime), 4, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (299, CAST(0x0000A34100BE6401 AS DateTime), 5, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (300, CAST(0x0000A34100BE8CC8 AS DateTime), 6, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (301, CAST(0x0000A34100BE967D AS DateTime), 7, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (302, CAST(0x0000A34100BE9AB9 AS DateTime), 8, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (303, CAST(0x0000A34100BEAB20 AS DateTime), 9, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (304, CAST(0x0000A34100BEBB21 AS DateTime), 10, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (305, CAST(0x0000A34100BEC1E2 AS DateTime), 11, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (306, CAST(0x0000A34100BEE1D1 AS DateTime), 12, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (307, CAST(0x0000A34100BEE243 AS DateTime), 13, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (308, CAST(0x0000A34100BEE572 AS DateTime), 15, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (309, CAST(0x0000A34100BEE5CB AS DateTime), 16, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (310, CAST(0x0000A34100BEE70A AS DateTime), 18, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (311, CAST(0x0000A34100BF2D29 AS DateTime), 21, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (312, CAST(0x0000A34200B07A23 AS DateTime), 4, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (313, CAST(0x0000A34200B0AEF7 AS DateTime), 5, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (314, CAST(0x0000A34200B0D650 AS DateTime), 6, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (315, CAST(0x0000A34200B0DFF2 AS DateTime), 7, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (316, CAST(0x0000A34200B0E3D9 AS DateTime), 8, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (317, CAST(0x0000A34200B0F416 AS DateTime), 9, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (318, CAST(0x0000A34200B1042F AS DateTime), 10, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (319, CAST(0x0000A34200B10AF5 AS DateTime), 11, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (320, CAST(0x0000A34200B12AF7 AS DateTime), 12, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (321, CAST(0x0000A34200B12B73 AS DateTime), 13, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (322, CAST(0x0000A34200B12EAF AS DateTime), 15, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (323, CAST(0x0000A34200B12F12 AS DateTime), 16, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (324, CAST(0x0000A34200B13047 AS DateTime), 18, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (325, CAST(0x0000A34200B175B2 AS DateTime), 21, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (326, CAST(0x0000A3610119BC46 AS DateTime), 4, N'Sucesso', 260160753)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (327, CAST(0x0000A361012250CE AS DateTime), 5, N'Sucesso', 34)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (328, CAST(0x0000A3610122E948 AS DateTime), 6, N'Sucesso', 38)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (329, CAST(0x0000A36101242BCC AS DateTime), 7, N'Sucesso', 1060229)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (330, CAST(0x0000A36101244B50 AS DateTime), 8, N'Sucesso', 6)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (331, CAST(0x0000A3610126C9B1 AS DateTime), 9, N'Sucesso', 69)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (332, CAST(0x0000A361012781EB AS DateTime), 10, N'Sucesso', 134)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (333, CAST(0x0000A3610127D4DC AS DateTime), 11, N'Sucesso', 94)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (334, CAST(0x0000A361012A4C9A AS DateTime), 12, N'Sucesso', 532841)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (335, CAST(0x0000A361012A4D27 AS DateTime), 13, N'Sucesso', 2)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (336, CAST(0x0000A361012A7122 AS DateTime), 15, N'Sucesso', 17)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (337, CAST(0x0000A361012A7249 AS DateTime), 16, N'Sucesso', 6)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (338, CAST(0x0000A361012A746A AS DateTime), 18, N'Sucesso', 11718)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (339, CAST(0x0000A3610137E649 AS DateTime), 21, N'The DELETE statement conflicted with the REFERENCE constraint "FK_tblLogCodigo_tblCliente". The conflict occurred in database "IndicadoresIntegracaoNew", table "dbo.tblLogCodigo", column ''CodCliente''.', 12000000)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (340, CAST(0x0000A36400EE9523 AS DateTime), 4, N'Sucesso', 8831094)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (341, CAST(0x0000A36400EEC1FA AS DateTime), 5, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (342, CAST(0x0000A36400EF0F33 AS DateTime), 6, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (343, CAST(0x0000A36400EF3BB6 AS DateTime), 7, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (344, CAST(0x0000A36400EF599D AS DateTime), 8, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (345, CAST(0x0000A36400EFA761 AS DateTime), 9, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (346, CAST(0x0000A36400EFD7A2 AS DateTime), 10, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (347, CAST(0x0000A36400F0054E AS DateTime), 11, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (348, CAST(0x0000A36400F0B7AF AS DateTime), 12, N'Sucesso', 20480)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (349, CAST(0x0000A36400F0B8CE AS DateTime), 13, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (350, CAST(0x0000A36400F0C9EC AS DateTime), 15, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (351, CAST(0x0000A36400F0CB10 AS DateTime), 16, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (352, CAST(0x0000A36400F0CCA0 AS DateTime), 18, N'Sucesso', 2558)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (353, CAST(0x0000A36400F10307 AS DateTime), 21, N'The DELETE statement conflicted with the REFERENCE constraint "FK_tblLogCodigo_tblCliente". The conflict occurred in database "IndicadoresIntegracaoNew", table "dbo.tblLogCodigo", column ''CodCliente''.', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (354, CAST(0x0000A36400F40556 AS DateTime), 4, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (355, CAST(0x0000A36400F4443C AS DateTime), 5, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (356, CAST(0x0000A36400F47FA7 AS DateTime), 6, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (357, CAST(0x0000A36400F48E03 AS DateTime), 7, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (358, CAST(0x0000A36400F4A162 AS DateTime), 8, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (359, CAST(0x0000A36400F4CD59 AS DateTime), 9, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (360, CAST(0x0000A36400F4EB04 AS DateTime), 10, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (361, CAST(0x0000A36400F4F05F AS DateTime), 11, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (362, CAST(0x0000A36400F50184 AS DateTime), 12, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (363, CAST(0x0000A36400F5020E AS DateTime), 13, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (364, CAST(0x0000A36400F50AC4 AS DateTime), 15, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (365, CAST(0x0000A36400F50AFC AS DateTime), 16, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (366, CAST(0x0000A36400F50C1C AS DateTime), 18, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (367, CAST(0x0000A36400F543CC AS DateTime), 21, N'The DELETE statement conflicted with the REFERENCE constraint "FK_tblLogCodigo_tblCliente". The conflict occurred in database "IndicadoresIntegracaoNew", table "dbo.tblLogCodigo", column ''CodCliente''.', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (368, CAST(0x0000A36400F54558 AS DateTime), 22, N'Sucesso', 1)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (369, CAST(0x0000A36500AB35AB AS DateTime), 4, N'Sucesso', 0)
GO
print 'Processed 100 total records'
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (370, CAST(0x0000A36500AB6CCF AS DateTime), 5, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (371, CAST(0x0000A36500ABA62C AS DateTime), 6, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (372, CAST(0x0000A36500ABAC11 AS DateTime), 7, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (373, CAST(0x0000A36500ABAEA2 AS DateTime), 8, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (374, CAST(0x0000A36500ABCE70 AS DateTime), 9, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (375, CAST(0x0000A36500ABDA88 AS DateTime), 10, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (376, CAST(0x0000A36500ABDEA0 AS DateTime), 11, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (377, CAST(0x0000A36500ABEEE3 AS DateTime), 12, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (378, CAST(0x0000A36500ABEF7E AS DateTime), 13, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (379, CAST(0x0000A36500ABF7C4 AS DateTime), 15, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (380, CAST(0x0000A36500ABF7F7 AS DateTime), 16, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (381, CAST(0x0000A36500ABF903 AS DateTime), 18, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (382, CAST(0x0000A36500AE6728 AS DateTime), 21, N'Sucesso', 565900)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (383, CAST(0x0000A36500AE6960 AS DateTime), 22, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (384, CAST(0x0000A365010AD186 AS DateTime), 4, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (386, CAST(0x0000A365010B4EA1 AS DateTime), 6, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (387, CAST(0x0000A365010B550F AS DateTime), 7, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (388, CAST(0x0000A365010B57DC AS DateTime), 8, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (389, CAST(0x0000A365010B665C AS DateTime), 9, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (390, CAST(0x0000A365010B702A AS DateTime), 10, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (391, CAST(0x0000A365010B7451 AS DateTime), 11, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (392, CAST(0x0000A365010B8614 AS DateTime), 12, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (393, CAST(0x0000A365010B865F AS DateTime), 13, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (394, CAST(0x0000A365010B8B63 AS DateTime), 15, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (395, CAST(0x0000A365010B8BA6 AS DateTime), 16, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (396, CAST(0x0000A365010B8C8B AS DateTime), 18, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (397, CAST(0x0000A365010BC2F6 AS DateTime), 21, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (398, CAST(0x0000A365010BC475 AS DateTime), 22, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (399, CAST(0x0000A3680107C784 AS DateTime), 4, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (400, CAST(0x0000A3680107E290 AS DateTime), 5, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (401, CAST(0x0000A3680107F725 AS DateTime), 6, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (402, CAST(0x0000A3680107FBC1 AS DateTime), 7, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (403, CAST(0x0000A3680107FDF2 AS DateTime), 8, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (404, CAST(0x0000A36801080B65 AS DateTime), 9, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (405, CAST(0x0000A368010811B8 AS DateTime), 10, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (406, CAST(0x0000A3680108158D AS DateTime), 11, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (407, CAST(0x0000A36801082866 AS DateTime), 12, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (408, CAST(0x0000A368010828D5 AS DateTime), 13, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (409, CAST(0x0000A36801082C07 AS DateTime), 15, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (410, CAST(0x0000A36801082C3F AS DateTime), 16, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (411, CAST(0x0000A36801082CFD AS DateTime), 18, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (412, CAST(0x0000A36801085D57 AS DateTime), 21, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (413, CAST(0x0000A36801085E33 AS DateTime), 22, N'Sucesso', 0)
INSERT [dbo].[tblExpurgoLog] ([idLog], [DtLog], [idTabelaExpurgo], [MsgExecucao], [LinhasApagadas]) VALUES (385, CAST(0x0000A365010B0BDA AS DateTime), 5, N'Sucesso', 0)
SET IDENTITY_INSERT [dbo].[tblExpurgoLog] OFF
/****** Object:  Table [dbo].[tblExpurgoBancos]    Script Date: 09/16/2014 14:47:26 ******/
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
	and not exists (select 1 from tblLog with(nolock) where tblAgenda.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A3680107D715 AS DateTime), CAST(0x0000A3680107E29B AS DateTime), 0, N'SUCESSO', CAST(0x0000A31D0116C9A0 AS DateTime), 99, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (15, N'IndicadoresIntegracaoNew', N'tblAgendaHistorico', N'10', N'10000', N'while (
	select count(1) from tblAgendaHistorico with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblAgendaHistorico.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblAgendaHistorico.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblAgendaHistorico.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblAgendaHistorico.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A368010828D7 AS DateTime), CAST(0x0000A36801082C11 AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FB74E1 AS DateTime), 90, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (21, N'IndicadoresIntegracaoNew', N'tblCliente', N'10', N'1000000', N'while (
	select count(1) from tblCliente with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblCliente.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblCliente.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblCliente.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblCliente.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A36801082D00 AS DateTime), CAST(0x0000A36801085E18 AS DateTime), 0, N'SUCESSO', CAST(0x0000A32300B038C7 AS DateTime), 87, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (4, N'IndicadoresIntegracaoNew', N'tblClienteDetalhe', N'30', N'10000000', N'while (
	select count(*) from tblClienteDetalhe with(nolock) 
	where exists(select 1 from tblCliente with(nolock) 
		where tblClienteDetalhe.codcliente = tblcliente.codcliente and 
		codstatus <> 102 and
		DtInclusao <= DATEADD(MM,-6,GETDATE()) 
		)) > 0', N'where exists(select 1 from tblCliente with(nolock)    
	where tblClienteDetalhe.codcliente = tblcliente.codcliente and     codstatus <> 102 and    DtInclusao <= DATEADD(MM,-6,GETDATE()))', 1, CAST(0x0000A3680107B04B AS DateTime), CAST(0x0000A3680107D70B AS DateTime), 0, N'SUCESSO', CAST(0x0000A31D0116ACDC AS DateTime), 101, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (22, N'IndicadoresIntegracaoNew', N'tblLogCodigo', N'10', N'10000', N'while (   select count(*) 
	from tblLogCodigo with(nolock)    
	where not exists(select 1 from tblClienteDetalhe with(nolock) 
	where tblLogCodigo.CodCliente = tblClienteDetalhe.CodCliente)   
	and not exists (select 1 from tblLog with(nolock) 
	where tblLogCodigo.CodCliente = tblLog.CodCliente)) 
	> 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblLogCodigo.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogCodigo.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A36801085E1B AS DateTime), CAST(0x0000A36801085E36 AS DateTime), 0, N'SUCESSO', CAST(0x0000A36400EB62FF AS DateTime), 100, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (12, N'IndicadoresIntegracaoNew', N'tblLogDiscador', N'10', N'10000', N'while (
	select count(1) from tblLogDiscador with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblLogDiscador.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogDiscador.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblLogDiscador.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogDiscador.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A368010815C9 AS DateTime), CAST(0x0000A3680108288A AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FAC3CD AS DateTime), 92, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (16, N'IndicadoresIntegracaoNew', N'tblLogTrocaTelefone', N'10', N'10000', N'while (
	select count(1) from tblLogTrocaTelefone with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblLogTrocaTelefone.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogTrocaTelefone.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblLogTrocaTelefone.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogTrocaTelefone.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A36801082C12 AS DateTime), CAST(0x0000A36801082C42 AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FB85E4 AS DateTime), 89, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (13, N'IndicadoresIntegracaoNew', N'tblLogVolta', N'10', N'10000', N'while (
	select count(1) from tblLogVolta with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblLogVolta.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogVolta.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblLogVolta.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogVolta.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A3680108288B AS DateTime), CAST(0x0000A368010828D7 AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FAD4AC AS DateTime), 91, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (18, N'IndicadoresIntegracaoNew', N'tblLogVoltaChavePeriodo', N'10', N'10000', N'while (
	select count(1) from tblLogVoltaChavePeriodo with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblLogVoltaChavePeriodo.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogVoltaChavePeriodo.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblLogVoltaChavePeriodo.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogVoltaChavePeriodo.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A36801082C42 AS DateTime), CAST(0x0000A36801082D00 AS DateTime), 0, N'SUCESSO', CAST(0x0000A32300A343AE AS DateTime), 88, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (7, N'IndicadoresIntegracaoNew', N'tblLogVoltaRegistro', N'10', N'10000', N'while (
	select count(1) from tblLogVoltaRegistro with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblLogVoltaRegistro.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogVoltaRegistro.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblLogVoltaRegistro.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblLogVoltaRegistro.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A3680107F773 AS DateTime), CAST(0x0000A3680107FBEA AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FA6D61 AS DateTime), 97, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (6, N'IndicadoresIntegracaoNew', N'tblResposta', N'10', N'10000', N'while (
	select count(1) from tblResposta with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblResposta.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblResposta.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblResposta.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblResposta.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A3680107E29B AS DateTime), CAST(0x0000A3680107F771 AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FA5549 AS DateTime), 98, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (10, N'IndicadoresIntegracaoNew', N'tblRespostaAud', N'10', N'10000', N'while (
	select count(1) from tblRespostaAud with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblRespostaAud.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaAud.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblRespostaAud.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaAud.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A36801080C46 AS DateTime), CAST(0x0000A368010811EA AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FAA923 AS DateTime), 94, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (8, N'IndicadoresIntegracaoNew', N'tblRespostaCritica', N'10', N'10000', N'while (
	select count(1) from tblRespostaCritica with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblRespostaCritica.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaCritica.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblRespostaCritica.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaCritica.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A3680107FBEA AS DateTime), CAST(0x0000A3680107FE05 AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FA8A2F AS DateTime), 96, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (9, N'IndicadoresIntegracaoNew', N'tblRespostaTAG', N'10', N'10000', N'while (
	select count(1) from tblRespostaTAG with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblRespostaTAG.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaTAG.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblRespostaTAG.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaTAG.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A3680107FE06 AS DateTime), CAST(0x0000A36801080C46 AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FA9DAE AS DateTime), 95, 127)
INSERT [dbo].[tblExpurgoBancos] ([id_tblExpurgoBancos], [BancoExpurgo], [TabelaExpurgo], [Ciclos], [LinhasPorCiclo], [WhileDurante], [WhereCondicao], [FlagLimpeza], [DtInicioUltimaLimpeza], [DtFimUltimaLimpeza], [LinhasApagadasUltLimp], [MsgErro], [DtAdicaoTabela], [OrdemExec], [Frequencia]) VALUES (11, N'IndicadoresIntegracaoNew', N'tblRespostaTempo', N'10', N'10000', N'while (
	select count(1) from tblRespostaTempo with(nolock) 
	where not exists(select 1 from tblClienteDetalhe with(nolock) where tblRespostaTempo.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaTempo.CodCliente = tblLog.CodCliente)) > 0', N'where not exists (select 1 from tblClienteDetalhe with(nolock) where tblRespostaTempo.CodCliente = tblClienteDetalhe.CodCliente)
	and not exists (select 1 from tblLog with(nolock) where tblRespostaTempo.CodCliente = tblLog.CodCliente)', 1, CAST(0x0000A368010811EA AS DateTime), CAST(0x0000A368010815C9 AS DateTime), 0, N'SUCESSO', CAST(0x0000A32200FAB6C6 AS DateTime), 93, 127)
SET IDENTITY_INSERT [dbo].[tblExpurgoBancos] OFF

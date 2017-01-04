CREATE procedure [dbo].[sp_dba_email_aprova_notas] as      
BEGIN      
      
SET NOCOUNT ON      
      
--tabela temporaria com a query do corpo      
create table #criarcorpo (BU nvarchar(100) collate Latin1_General_CI_AS_KS_WS, corpo text)      
    
--BU Responsavel    
insert into #criarcorpo select        
 t1.nvarchar6,       
 '<tr><td>' + t1.nvarchar1 +       
 '</td><td>' + t1.nvarchar8 +       
 '</td><td>' + t1.nvarchar5 +       
 '</td><td>' + 'BU Responsável' +       
 '</td><td>' + '<a href=http://latbrspodb02.latam.ipsos/gestaodefornecedores/Financeiro/Lists/Demonstrativos/DispForm.aspx?ID=' +       
 convert(varchar, t1.tp_id) +       
 '&Source=http%3A%2F%2Flatbrspodb02%2Fgestaodefornecedores%2FFinanceiro%2FLists%2FDemonstrativos%2FAllItems%2Easpx>Link</a>' +      
  '</td></tr>'    
from WSS_Content_80.dbo.AllUSerData t1      
--where tp_created = getdate()      
where convert(varchar, tp_Created, 112) = convert(varchar, getdate(), 112)      
and tp_isCurrent = 1      
    
--BU Secundária    
insert into #criarcorpo select        
 t1.nvarchar15,       
 '<tr><td>' + t1.nvarchar1 +       
 '</td><td>' + t1.nvarchar8 +       
 '</td><td>' + t1.nvarchar5 +       
 '</td><td>' + 'BU Secundária' +       
 '</td><td>' + '<a href=http://latbrspodb02.latam.ipsos/gestaodefornecedores/Financeiro/Lists/Demonstrativos/DispForm.aspx?ID=' +       
 convert(varchar, t1.tp_id) +       
 '&Source=http%3A%2F%2Flatbrspodb02%2Fgestaodefornecedores%2FFinanceiro%2FLists%2FDemonstrativos%2FAllItems%2Easpx>Link</a>' +       
 '</td></tr>'    
from WSS_Content_80.dbo.AllUSerData t1      
--where tp_created = getdate()      
where convert(varchar, tp_Created, 112) = convert(varchar, getdate(), 112)      
and tp_isCurrent = 1    
and isnull(t1.nvarchar15, '') <> ''    
    
    
    
      
-- inicio recursividade      
;WITH RangeTabelaFilho ( Bu, Rnk, Corpo)       
AS (       
     SELECT    t2.BU,    
                ROW_NUMBER() OVER(PARTITION BY t2.BU ORDER BY t2.BU) as IncrementoPorBu,    
                CAST(t2.corpo AS NVARCHAR(MAX))       
         FROM #criarcorpo t2    
               
    )       
,AncoraDoRank (Bu, Rnk, Corpo)       
AS       
(       
            SELECT Bu, Rnk, Corpo      
            FROM RangeTabelaFilho        WHERE rnk = 1       
)      
,RecursoRanqueamento (Bu, Rnk, Corpo)      
AS       
(      
      
        SELECT Bu, Rnk, Corpo      
        FROM AncoraDoRank      
        UNION ALL      
        SELECT    RangeTabelaFilho.Bu, RangeTabelaFilho.rnk,      
                        RecursoRanqueamento.Corpo + RangeTabelaFilho.Corpo      
                  FROM RangeTabelaFilho      
            INNER JOIN RecursoRanqueamento      
            ON RangeTabelaFilho.Bu = RecursoRanqueamento.Bu      
            AND RangeTabelaFilho.rnk = RecursoRanqueamento.rnk + 1       
 )      
      
INSERT INTO latbrspodb05.ipsosmail.dbo.tblemailenvio (CodCampanha, CodLoteEnvio, CodEmailBancoOrigem, CodCliente, Destinatario, Remetente, NomeRemetente, Assunto, Corpo, CorpoTexto, CodStatus, DtInclusao, DtLido, DtAtualizaStatusOrigem, CCO)      
      
SELECT '49', null, '3', '0', te.email, 'noreply@ipsos.com', 'Sistema de aprovação de notas', 'Aprovacao de notas (Financeiro)', 'Segue lista de Notas Fiscais cadastradas em ' + convert(varchar, getdate(), 103) + ' <br /><br /> <table border="1">' +     
MAX( Corpo ) + '</table>', null, null, getdate(), null, null, null FROM RecursoRanqueamento rr        
inner join WSS_Content_80.dbo.tblBUEmail te on rr.bu = te.bu      
GROUP BY rr.Bu, te.email      
      
OPTION (maxrecursion 0)      
      
DROP TABLE #criarcorpo      
SET NOCOUNT OFF      
END 
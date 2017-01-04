;WITH RangeTabelaFilho ( Cnpj, rnk, Filho ) 
AS ( 
      SELECT    f.cnpj as Cnpj,
                ROW_NUMBER() OVER(PARTITION BY f.cnpj ORDER BY f.cnpj ) as IncrementoPorCNPJ,
                CAST(f.tel AS VARCHAR(8000))
         FROM tb_telefones f
         join tb_clientes p
         on f.cnpj = p.cnpj
    )
,AncoraDoRank (Cnpj, rnk, Filho) 
AS 
( 
            SELECT Cnpj,rnk,Filho 
            FROM RangeTabelaFilho        WHERE rnk = 1 
)
,RecursoRanqueamento (Cnpj, rnk, Filho)
AS 
(

        SELECT Cnpj , rnk, Filho
        FROM AncoraDoRank
        UNION ALL
        SELECT    RangeTabelaFilho.Cnpj, RangeTabelaFilho.rnk,
                        RecursoRanqueamento.Filho + '; ' + RangeTabelaFilho.Filho
                  FROM RangeTabelaFilho
            INNER JOIN RecursoRanqueamento
            ON RangeTabelaFilho.Cnpj = RecursoRanqueamento.Cnpj
            AND RangeTabelaFilho.rnk = RecursoRanqueamento.rnk + 1 
 )

SELECT Cnpj, MAX( Filho ) AS NomeFilhos FROM RecursoRanqueamento  GROUP BY Cnpj;
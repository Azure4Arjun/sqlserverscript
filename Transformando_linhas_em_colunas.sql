28 de setembro
Transformando Linhas em Colunas com o SQL Server 2005
Boa Noite, 

A necessidade de transformar linhas em colunas � bastante presente. Acho que desde os iniciantes nas primeiras aulas de SQL at� os mais experientes se deparam com essa necessidade de tempos em tempos. De fato a SQL em si n�o prev� (at� ent�o) algum operador para fazer isso e em tese isso tem suas raz�es j� que transformar linhas em colunas n�o muda a recupera��o dos dados em si, mas fundamentalmente o seu formato, ou seja, os dados s�o os mesmos mas o que muda � como eles s�o exibidos. 

Ainda que uma camada de banco de dados seja necess�ria idealmente apenas para gravar e recuperar dados, a necessidade de transformar linhas e colunas continua comum e muita embora a camada de aplica��o / apresenta��o deve ser a respons�vel por fazer essa convers�o, seria muito mais f�cil se uma consulta no banco de dados pudesse retornar os dados dispostos dessa forma. H� alternativas como o OWC, o Reporting Services e ferramentas de BI, mas quase sempre elas n�o s�o solu��es fact�veis dependendo da sua ferramenta de desenvolvimento, da arquitetura de sua aplica��o ou do seu or�amento. 

Ainda acho que n�o deveria ser o banco de dados o respons�vel por transformar linhas em colunas. Toda vez que o banco de dados faz algum trabalho que n�o seja recuperar e gravar dados, ele ir� gastar recursos em outras atividades e n�o ir� recuperar e gravar dados t�o rapidamente quanto deveria. Idealmente falando isso est� correto, mas insistir nessa id�ia � contrariar a vontade de muitos e por mais que esteja correto, sempre existir�o aqueles que ir�o fazer o contr�rio (seja por desconhecimento, vontade ou necessidade). 

H� algum tempo atr�s fiz um webcast intitulado Dicas e Truques sobre consultas complexas no SQL Server. Nesse webcast eu demonstrei como fazer isso no SQL Server atrav�s do operador PIVOT. Demonstrei tamb�m como contornar as limita��es desse operador e fazer algo mais din�mico. 

De uns dias pra c� estou vendo essa d�vida com uma freq��ncia muito grande nos f�runs de SQL Server que participo. Sempre que posso indico a solu��o que postei no Webcast (inclusive disponibilizo o c�digo no blog), mas pelos feedbacks, me parece que o c�digo n�o est� t�o claro quanto os usu�rios gostariam. Talvez seja falta de uma explica��o mais clara ou ent�o de fato o c�digo possui mais complexidades do que deveria. 

No intuito de ajudar aqueles que passam por essa d�vida (ou que certamente ir�o passar), resolvi uma entrada aqui no blog para tratar dessa necessidade. Na verdade n�o demonstrarei somente como transformar linhas em colunas, mas apresentarei uma solu��o mais completa. Irei criar duas tabelas com os dados necess�rios para exemplificar. 

-- Cria as tabelas
CREATE TABLE tblClientes (
    IDCliente INT IDENTITY(1,1),
    NomeCliente VARCHAR(80)) 

CREATE TABLE tblPedidos (
    IDPedido INT IDENTITY(1,1),
    IDCliente INT,
    DataPedido SMALLDATETIME) 

-- Cria as constraints
ALTER TABLE tblClientes ADD CONSTRAINT PK_Clientes PRIMARY KEY (IDCliente)
ALTER TABLE tblPedidos ADD CONSTRAINT PK_Pedidos PRIMARY KEY (IDPedido)
ALTER TABLE tblPedidos ADD CONSTRAINT FK_Clientes_Pedidos
FOREIGN KEY (IDCliente) REFERENCES tblClientes (IDCliente) 

-- Insere clientes
INSERT INTO tblClientes (NomeCliente) VALUES ('Amanda')
INSERT INTO tblClientes (NomeCliente) VALUES ('Ivone')
INSERT INTO tblClientes (NomeCliente) VALUES ('Regiane')
INSERT INTO tblClientes (NomeCliente) VALUES ('Mariana') 

-- Insere pedidos para o cliente 1
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (1,'20080115')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (1,'20080328')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (1,'20080406')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (1,'20080410')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (1,'20080523')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (1,'20080524')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (1,'20080712')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (1,'20080812')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (1,'20080818')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (1,'20080828') 

-- Insere pedidos para o cliente 2
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (2,'20080411')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (2,'20080417')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (2,'20080422')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (2,'20080430')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (2,'20080711')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (2,'20080901')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (2,'20080903')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (2,'20080907')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (2,'20080914') 

-- Insere pedidos para o cliente 3
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (3,'20080122')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (3,'20080408')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (3,'20080502')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (3,'20080510')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (3,'20080519')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (3,'20080702')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (3,'20080703')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (3,'20080712')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (3,'20080713')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (3,'20080718')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (3,'20080723')
INSERT INTO tblPedidos (IDCliente, DataPedido) VALUES (3,'20080729') 


Imagine ent�o que seja desejado um relat�rio com o seguinte formato (clientes e total de pedidos por m�s): 

Cliente  01/2008  02/2008  03/2008  04/2008  05/2008  06/2008  07/2008  08/2008  09/2008  
Amanda  1  0  1  2  2  0  1  3  0  
Ivone  0  0  0  4  0  0  1  0  4  
Regiane  1  0  0  1  3  0  7  0  0  
Mariana  0  0  0  0  0  0  0  0  0 


Desconsiderando a formata��o dos nomes e dos per�odos, tenho certeza de alguns devem estar pensando "� justamente isso que eu preciso". � poss�vel chegar nesse resultado, mas h� um consider�vel trabalho at� ent�o. Vamos ent�o realizar o passo a passo para que a partir dos dados nas tabelas de clientes e pedidos possamos chegar nesse relat�rio. Antes de propriamente utilizar os recursos do SQL Server 2005, vejamos uma forma de resolver esse problema com base nos recursos do SQL Server 2000 (possivelmente port�vel para outros SGBDs). 

-- Rela��o de Clientes
SELECT NomeCliente AS Cliente, 

-- Vendas de Janeiro
(SELECT COUNT(*) FROM tblPedidos AS P WHERE C.IdCliente = P.IdCliente
AND YEAR(DataPedido)=2008 AND MONTH(DataPedido)=1) AS [01/2008], 

-- Vendas de Fevereiro
(SELECT COUNT(*) FROM tblPedidos AS P WHERE C.IdCliente = P.IdCliente
AND YEAR(DataPedido)=2008 AND MONTH(DataPedido)=2) AS [02/2008], 

-- Coloque aqui os dados dos outros meses alterando m�s 

-- Vendas de Setembro
(SELECT COUNT(*) FROM tblPedidos AS P WHERE C.IdCliente = P.IdCliente
AND YEAR(DataPedido)=2008 AND MONTH(DataPedido)=9) AS [09/2008] 

FROM tblClientes AS C 

Essa abordagem retorna o resultado do quadro acima, mas possui algumas fortes desvantagens: 


H� uma gradativa perda de desempenho no uso das fun��es YEAR e MONTH (quantos mais registros mais forte � a perda) 
O quadro foi montado, mas foi necess�rio conhecer previamente todos os meses e codific�-los um a um

A quest�o do desempenho pode ser resolvida com uso de um �ndice na coluna data e o uso do Between com essa coluna ao inv�s das fun��es MONTH e YEAR, mas o grande problema � resolver a segunda limita��o. Como montar o quadro sem saber previamente que os registros iniciavam em janeiro de 2008 e terminavam em setembro de 2008 ? E se aparecesse um registro de dezembro de 2007 ? A consulta iria simplesmente ignor�-lo. 

Para resolver esse problema, � necess�rio para cada m�s, construir uma nova subquery com o c�digo abaixo: 

-- Vendas do m�s X
(SELECT COUNT(*) FROM tblPedidos AS P WHERE C.IdCliente = P.IdCliente
AND YEAR(DataPedido)=AnoX AND MONTH(DataPedido)=MesX) AS [MesX / AnoX] 

Onde "M�s X" e "Ano X" devem ser obtidos dinamicamente a partir da lista de meses de tblPedidos. Em todo caso, n�o vou desenvolver esse script j� que a id�ia � utilizar os novos recursos do SQL Server 2005. 

O primeiro passo � gerar uma consulta para simplificar os resultados, afinal n�o � interessante fazer o JOIN entre Clientes e Pedidos todas as vezes que for necess�rio. Assim sendo utilizarei uma View para fazer essa jun��o. A view abaixo contempla todos os clientes quer tenham pedidos ou n�o. 

CREATE VIEW vPedidos (IDPedido, NomeCliente, Mes, Ano)
AS
SELECT
    IDPedido, NomeCliente, MONTH(DataPedido), YEAR(DataPedido)
FROM tblClientes C LEFT JOIN tblPedidos P
    ON C.IdCliente = P.IdCliente 

O SQL Server 2005 disp�e do operador PIVOT para transformar linhas em colunas. Atrav�s do exemplo abaixo, podemos ver uma utiliza��o b�sica. 

SELECT NomeCliente AS Cliente, [1], [2], [3], [4]
FROM 
(SELECT NomeCliente, IDPedido, Mes
    FROM vPedidos) AS TBO
PIVOT
(COUNT(IDPedido) FOR Mes IN ([1], [2], [3], [4])) AS TPVT 

Nesse exemplo, podemos ver o retorno de todos os clientes para o meses 1, 2, 3 e 4 respectivamente janeiro, fevereiro, mar�o e abril. A primeira subquery derived table (TBO) � a tabela de origem e contem os campos necess�rios para montarmos o relat�rio e mostrarmos os resultados. A coluna NomeCliente e Mes ser�o exibidas, mas a coluna IDPedido � necess�ria para fazer a contagem. Na segunda subquery (TPVT) � a Pivot Table e para os meses 1, 2, 3 e 4 ir� contar o total de Pedidos. Cada um desses meses ser� uma coluna. 

Essa sintaxe � menor do que a proposta para o SQL Server 2000, mas em todo caso, carece de algumas limita��es. A principal limita��o � que assim como a proposta anterior, tivemos que saber previamente os meses desejados. Outra limita��o nessa primeira constru��o � que o m�s � considerado separadamente. Se tiv�ssemos pedidos em janeiro de 2007, esses tamb�m fariam parte da contagem deprezando o ano (n�o faria diferen�a se fosse 2007 ou 2008). 

Antes de propriamente resolvermos a limita��o de especifica��o pr�via dos valores, � importante resolver a quest�o do ano. Para isso, faremos algumas adapta��es na view vPedidos e na consulta de pivoteamento. 

ALTER VIEW vPedidos (IDPedido, NomeCliente, Periodo)
AS
SELECT
    IDPedido, NomeCliente, YEAR(DataPedido) * 100 + MONTH(DataPedido)
FROM tblClientes C LEFT JOIN tblPedidos P
    ON C.IdCliente = P.IdCliente
GO 

SELECT NomeCliente AS Cliente, [200801], [200802], [200803], [200804]
FROM 
(SELECT NomeCliente, IDPedido, Periodo
    FROM vPedidos) AS TBO
PIVOT
(COUNT(IDPedido) FOR Periodo IN ([200801], [200802], [200803],[200804])) AS TPVT 

Com essas altera��es, j� est� inclu�do no per�odo tanto o ano quanto o m�s. Assim, n�o h� mais problemas em termos ordens do mesmo m�s (mas de diferentes anos) serem contabilizadas da mesma forma. A grande limita��o � que tivemos que especificar os meses previamente. 

Se notarmos a consulta, perceberemos que a �nica parte que precisava realmente ser din�mica � a especifica��o dos meses. Se observamos, tanto o primeiro SELECT quanto o �ltimo, tem a rela��o dos meses que necessitamos. Se pudermos construir essa instru��o dinamicamente, pode-se montar uma instru��o SQL para executar o comando. Para delimitarmos o per�odo completamente, bastaria especificar os per�odos inicial e final. O c�digo abaixo faz essa montagem dos per�odos dinamicamente. 

DECLARE @menorPeriodo INT, @maiorPeriodo INT, @Periodos VARCHAR(500) 

-- Captura os per�odos e inicializa as vari�veis
SELECT @menorPeriodo = MIN(Periodo), @maiorPeriodo = MAX(Periodo),
@Periodos = '' FROM vPedidos 

-- Montagem dos per�odos
WHILE @menorPeriodo <= @maiorPeriodo
BEGIN
    SET @Periodos = @Periodos + '[' + CAST(@menorPeriodo AS CHAR(6)) + '],'
    SET @menorPeriodo = @menorPeriodo + 1
END 

-- Exibe os per�odos
SET @Periodos = LEFT(@Periodos,LEN(@Periodos)-1)
PRINT @Periodos 

Podemos perceber que ap�s a execu��o do c�digo, obtivemos a rela��o de todos os per�odos existentes iniciando em 200801 at� 200809. Com essa parte do comando, podemos disparar uma execu��o din�mica. Claro que essa � apenas uma demonstra��o (do jeito que o c�digo est� montado, poder�amos chegar a absurda situa��o de 13/2008). Al�m de corrigir esse BUG, ainda devemos fazer algumas adapta��es no c�digo, afinal o formato do ano est� YYYYMM e o desejado era MM/YYYY. Ent�o fa�amos a altera��o na View e posteriormente na montagem dos meses. 

ALTER VIEW vPedidos (IDPedido, NomeCliente, Periodo)
AS
SELECT
    IDPedido, NomeCliente, RIGHT(CONVERT(CHAR(10),DataPedido,103),7)
FROM tblClientes C LEFT JOIN tblPedidos P
    ON C.IdCliente = P.IdCliente
GO 

DECLARE @menorPeriodo SMALLDATETIME, @maiorPeriodo SMALLDATETIME, @Periodos VARCHAR(500) 

-- Captura os per�odos e inicializa as vari�veis
SELECT @menorPeriodo = MIN(DataPedido), @maiorPeriodo = MAX(DataPedido),
@Periodos = '' FROM tblPedidos 

-- Retira os dias das respectivas datas
SET @menorPeriodo = DATEADD(D,-DAY(@menorPeriodo)+1,@menorPeriodo)
SET @maiorPeriodo = DATEADD(D,-DAY(@maiorPeriodo)+1,@maiorPeriodo) 

-- Montagem dos per�odos
WHILE @menorPeriodo <= @maiorPeriodo
BEGIN
    -- Captura o m�s e o dia
    SET @Periodos = @Periodos + '[' + RIGHT(CONVERT(CHAR(10),@menorPeriodo,103),7) + '],' 

    -- Adiciona um m�s ao menor per�odo
    SET @menorPeriodo = DATEADD(M,1,@menorPeriodo)
END 

-- Exibe os per�odos
SET @Periodos = LEFT(@Periodos,LEN(@Periodos)-1) 

PRINT @Periodos 

Agora o formato est� correto e podemos montar o comando dinamicamente, vamos a solu��o final. 

DECLARE @menorPeriodo SMALLDATETIME, @maiorPeriodo SMALLDATETIME,
@Periodos VARCHAR(500), @cmdSQL VARCHAR(1000) 

-- Captura os per�odos e inicializa as vari�veis
SELECT @menorPeriodo = MIN(DataPedido), @maiorPeriodo = MAX(DataPedido),
@Periodos = '' FROM tblPedidos 

-- Inicializa a vari�vel @cmdSQL com a montagem do PIVOT
-- O caract�r ? ser� substitu�do pelo per�odo obtido dinamicamente
SET @cmdSQL = 'SELECT NomeCliente AS Cliente, ?
FROM 
(SELECT NomeCliente, IDPedido, Periodo
    FROM vPedidos) AS TBO
PIVOT
(COUNT(IDPedido) FOR Periodo IN (?)) AS TPVT' 

-- Retira os dias das respectivas datas
SET @menorPeriodo = DATEADD(D,-DAY(@menorPeriodo)+1,@menorPeriodo)
SET @maiorPeriodo = DATEADD(D,-DAY(@maiorPeriodo)+1,@maiorPeriodo) 

-- Montagem dos per�odos
WHILE @menorPeriodo <= @maiorPeriodo
BEGIN
    -- Captura o m�s e o dia
    SET @Periodos = @Periodos + '[' + RIGHT(CONVERT(CHAR(10),@menorPeriodo,103),7) + '],' 

    -- Adiciona um m�s ao menor per�odo
    SET @menorPeriodo = DATEADD(M,1,@menorPeriodo)
END 

-- Monta os per�odos
SET @Periodos = LEFT(@Periodos,LEN(@Periodos)-1) 

-- Substitui o ? pelo per�odo montado dinamicamente
SET @cmdSQL = REPLACE(@cmdSQL,'?',@Periodos) 

-- Executa o comando, opcionalmente d� um PRINT
-- PRINT @cmdSQL
EXEC (@cmdSQL)


Bom, acho que agora os princ�pios de tornar o pivot mais din�mico est� devidamente explicado. Com certeza, outras necessidades parecidas ir�o aparecer. Em todo caso, lembre-se de que essa transforma��o est� dividida em tr�s etapas. A primeira etapa � a formata��o das colunas (no caso convertemos a data para MM/YYYY) a segunda etapa � a montagem din�mica do nome das colunas e a �ltima � a montagem din�mica do comando. Provavelmente as necessidades ir�o diferir na primeira etapa (alguns v�o desejar colocar o nome do m�s ao inv�s do ano). 

Alguns ir�o indagar a certa do desempenho dessa consulta. Aplicar fun��es como YEAR e MONTH v�o denegr�-la, mas lembre-se que as mesmas foram aplicadas em uma cl�usula SELECT e n�o em uma cl�usula WHERE como foi a proposta do SQL Server 2000. Em todo caso, uma coisa � certa sobre o desempenho. Quanto maior for o per�odo analisado, maior ser�o as transforma��es e menor ser� o desempenho. A chave para tornar essa consulta fact�vel do ponto de vista de desempenho � utilizar um filtro nas datas em tblPedido (prevendo que essa coluna possui um �ndice). A consulta abaixo filtra previamente os registros entre janeiro e agosto (setembro n�o est� inclu�do). 

ALTER VIEW vPedidos (IDPedido, NomeCliente, DataPedido, Periodo)
AS
SELECT
    IDPedido, NomeCliente, DataPedido, YEAR(DataPedido) * 100 + MONTH(DataPedido)
FROM tblClientes C LEFT JOIN tblPedidos P
    ON C.IdCliente = P.IdCliente
GO 

SELECT NomeCliente AS Cliente, <Especifi��o dos meses>
FROM 
(SELECT NomeCliente, IDPedido, Periodo
    FROM vPedidos WHERE DataPedido >= '20080101' AND DataPedido < '20080901' ) AS TBO
PIVOT
(COUNT(IDPedido) FOR Periodo IN <Especifica��o dos meses>) AS TPVT 

Essa foi uma alternativa para tornar o c�digo do PIVOT din�mico atrav�s do Transact SQL. Em todo caso, voc� pode ter a disposi��o outras formas de apresentar esse resultado. Embora bastante tentador, tente evitar esse tipo de constru��o dentro do banco de dados. N�o � atribui��o do banco de dados formatar os dados. Lembre-se que enquanto linhas s�o formatadas e transformadas em colunas, outras consultas podem estar rodando mais lentamente j� que recursos foram desviados para pivotear o resultado. 

Quem estiver animado e tiver entendido perfeitamento o c�digo do pivot din�mico, cabe um desafio final. Experimente tentar colocar uma coluna de totaliza��o somando os pedidos de todos os clientes por m�s. Essa � para quem realmente tem o dom�nio desse c�digo.

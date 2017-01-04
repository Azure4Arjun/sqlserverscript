28 de setembro
Transformando Linhas em Colunas com o SQL Server 2005
Boa Noite, 

A necessidade de transformar linhas em colunas é bastante presente. Acho que desde os iniciantes nas primeiras aulas de SQL até os mais experientes se deparam com essa necessidade de tempos em tempos. De fato a SQL em si não prevê (até então) algum operador para fazer isso e em tese isso tem suas razões já que transformar linhas em colunas não muda a recuperação dos dados em si, mas fundamentalmente o seu formato, ou seja, os dados são os mesmos mas o que muda é como eles são exibidos. 

Ainda que uma camada de banco de dados seja necessária idealmente apenas para gravar e recuperar dados, a necessidade de transformar linhas e colunas continua comum e muita embora a camada de aplicação / apresentação deve ser a responsável por fazer essa conversão, seria muito mais fácil se uma consulta no banco de dados pudesse retornar os dados dispostos dessa forma. Há alternativas como o OWC, o Reporting Services e ferramentas de BI, mas quase sempre elas não são soluções factíveis dependendo da sua ferramenta de desenvolvimento, da arquitetura de sua aplicação ou do seu orçamento. 

Ainda acho que não deveria ser o banco de dados o responsável por transformar linhas em colunas. Toda vez que o banco de dados faz algum trabalho que não seja recuperar e gravar dados, ele irá gastar recursos em outras atividades e não irá recuperar e gravar dados tão rapidamente quanto deveria. Idealmente falando isso está correto, mas insistir nessa idéia é contrariar a vontade de muitos e por mais que esteja correto, sempre existirão aqueles que irão fazer o contrário (seja por desconhecimento, vontade ou necessidade). 

Há algum tempo atrás fiz um webcast intitulado Dicas e Truques sobre consultas complexas no SQL Server. Nesse webcast eu demonstrei como fazer isso no SQL Server através do operador PIVOT. Demonstrei também como contornar as limitações desse operador e fazer algo mais dinâmico. 

De uns dias pra cá estou vendo essa dúvida com uma freqüência muito grande nos fóruns de SQL Server que participo. Sempre que posso indico a solução que postei no Webcast (inclusive disponibilizo o código no blog), mas pelos feedbacks, me parece que o código não está tão claro quanto os usuários gostariam. Talvez seja falta de uma explicação mais clara ou então de fato o código possui mais complexidades do que deveria. 

No intuito de ajudar aqueles que passam por essa dúvida (ou que certamente irão passar), resolvi uma entrada aqui no blog para tratar dessa necessidade. Na verdade não demonstrarei somente como transformar linhas em colunas, mas apresentarei uma solução mais completa. Irei criar duas tabelas com os dados necessários para exemplificar. 

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


Imagine então que seja desejado um relatório com o seguinte formato (clientes e total de pedidos por mês): 

Cliente  01/2008  02/2008  03/2008  04/2008  05/2008  06/2008  07/2008  08/2008  09/2008  
Amanda  1  0  1  2  2  0  1  3  0  
Ivone  0  0  0  4  0  0  1  0  4  
Regiane  1  0  0  1  3  0  7  0  0  
Mariana  0  0  0  0  0  0  0  0  0 


Desconsiderando a formatação dos nomes e dos períodos, tenho certeza de alguns devem estar pensando "é justamente isso que eu preciso". É possível chegar nesse resultado, mas há um considerável trabalho até então. Vamos então realizar o passo a passo para que a partir dos dados nas tabelas de clientes e pedidos possamos chegar nesse relatório. Antes de propriamente utilizar os recursos do SQL Server 2005, vejamos uma forma de resolver esse problema com base nos recursos do SQL Server 2000 (possivelmente portável para outros SGBDs). 

-- Relação de Clientes
SELECT NomeCliente AS Cliente, 

-- Vendas de Janeiro
(SELECT COUNT(*) FROM tblPedidos AS P WHERE C.IdCliente = P.IdCliente
AND YEAR(DataPedido)=2008 AND MONTH(DataPedido)=1) AS [01/2008], 

-- Vendas de Fevereiro
(SELECT COUNT(*) FROM tblPedidos AS P WHERE C.IdCliente = P.IdCliente
AND YEAR(DataPedido)=2008 AND MONTH(DataPedido)=2) AS [02/2008], 

-- Coloque aqui os dados dos outros meses alterando mês 

-- Vendas de Setembro
(SELECT COUNT(*) FROM tblPedidos AS P WHERE C.IdCliente = P.IdCliente
AND YEAR(DataPedido)=2008 AND MONTH(DataPedido)=9) AS [09/2008] 

FROM tblClientes AS C 

Essa abordagem retorna o resultado do quadro acima, mas possui algumas fortes desvantagens: 


Há uma gradativa perda de desempenho no uso das funções YEAR e MONTH (quantos mais registros mais forte é a perda) 
O quadro foi montado, mas foi necessário conhecer previamente todos os meses e codificá-los um a um

A questão do desempenho pode ser resolvida com uso de um índice na coluna data e o uso do Between com essa coluna ao invés das funções MONTH e YEAR, mas o grande problema é resolver a segunda limitação. Como montar o quadro sem saber previamente que os registros iniciavam em janeiro de 2008 e terminavam em setembro de 2008 ? E se aparecesse um registro de dezembro de 2007 ? A consulta iria simplesmente ignorá-lo. 

Para resolver esse problema, é necessário para cada mês, construir uma nova subquery com o código abaixo: 

-- Vendas do mês X
(SELECT COUNT(*) FROM tblPedidos AS P WHERE C.IdCliente = P.IdCliente
AND YEAR(DataPedido)=AnoX AND MONTH(DataPedido)=MesX) AS [MesX / AnoX] 

Onde "Mês X" e "Ano X" devem ser obtidos dinamicamente a partir da lista de meses de tblPedidos. Em todo caso, não vou desenvolver esse script já que a idéia é utilizar os novos recursos do SQL Server 2005. 

O primeiro passo é gerar uma consulta para simplificar os resultados, afinal não é interessante fazer o JOIN entre Clientes e Pedidos todas as vezes que for necessário. Assim sendo utilizarei uma View para fazer essa junção. A view abaixo contempla todos os clientes quer tenham pedidos ou não. 

CREATE VIEW vPedidos (IDPedido, NomeCliente, Mes, Ano)
AS
SELECT
    IDPedido, NomeCliente, MONTH(DataPedido), YEAR(DataPedido)
FROM tblClientes C LEFT JOIN tblPedidos P
    ON C.IdCliente = P.IdCliente 

O SQL Server 2005 dispõe do operador PIVOT para transformar linhas em colunas. Através do exemplo abaixo, podemos ver uma utilização básica. 

SELECT NomeCliente AS Cliente, [1], [2], [3], [4]
FROM 
(SELECT NomeCliente, IDPedido, Mes
    FROM vPedidos) AS TBO
PIVOT
(COUNT(IDPedido) FOR Mes IN ([1], [2], [3], [4])) AS TPVT 

Nesse exemplo, podemos ver o retorno de todos os clientes para o meses 1, 2, 3 e 4 respectivamente janeiro, fevereiro, março e abril. A primeira subquery derived table (TBO) é a tabela de origem e contem os campos necessários para montarmos o relatório e mostrarmos os resultados. A coluna NomeCliente e Mes serão exibidas, mas a coluna IDPedido é necessária para fazer a contagem. Na segunda subquery (TPVT) é a Pivot Table e para os meses 1, 2, 3 e 4 irá contar o total de Pedidos. Cada um desses meses será uma coluna. 

Essa sintaxe é menor do que a proposta para o SQL Server 2000, mas em todo caso, carece de algumas limitações. A principal limitação é que assim como a proposta anterior, tivemos que saber previamente os meses desejados. Outra limitação nessa primeira construção é que o mês é considerado separadamente. Se tivéssemos pedidos em janeiro de 2007, esses também fariam parte da contagem deprezando o ano (não faria diferença se fosse 2007 ou 2008). 

Antes de propriamente resolvermos a limitação de especificação prévia dos valores, é importante resolver a questão do ano. Para isso, faremos algumas adaptações na view vPedidos e na consulta de pivoteamento. 

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

Com essas alterações, já está incluído no período tanto o ano quanto o mês. Assim, não há mais problemas em termos ordens do mesmo mês (mas de diferentes anos) serem contabilizadas da mesma forma. A grande limitação é que tivemos que especificar os meses previamente. 

Se notarmos a consulta, perceberemos que a única parte que precisava realmente ser dinâmica é a especificação dos meses. Se observamos, tanto o primeiro SELECT quanto o último, tem a relação dos meses que necessitamos. Se pudermos construir essa instrução dinamicamente, pode-se montar uma instrução SQL para executar o comando. Para delimitarmos o período completamente, bastaria especificar os períodos inicial e final. O código abaixo faz essa montagem dos períodos dinamicamente. 

DECLARE @menorPeriodo INT, @maiorPeriodo INT, @Periodos VARCHAR(500) 

-- Captura os períodos e inicializa as variáveis
SELECT @menorPeriodo = MIN(Periodo), @maiorPeriodo = MAX(Periodo),
@Periodos = '' FROM vPedidos 

-- Montagem dos períodos
WHILE @menorPeriodo <= @maiorPeriodo
BEGIN
    SET @Periodos = @Periodos + '[' + CAST(@menorPeriodo AS CHAR(6)) + '],'
    SET @menorPeriodo = @menorPeriodo + 1
END 

-- Exibe os períodos
SET @Periodos = LEFT(@Periodos,LEN(@Periodos)-1)
PRINT @Periodos 

Podemos perceber que após a execução do código, obtivemos a relação de todos os períodos existentes iniciando em 200801 até 200809. Com essa parte do comando, podemos disparar uma execução dinâmica. Claro que essa é apenas uma demonstração (do jeito que o código está montado, poderíamos chegar a absurda situação de 13/2008). Além de corrigir esse BUG, ainda devemos fazer algumas adaptações no código, afinal o formato do ano está YYYYMM e o desejado era MM/YYYY. Então façamos a alteração na View e posteriormente na montagem dos meses. 

ALTER VIEW vPedidos (IDPedido, NomeCliente, Periodo)
AS
SELECT
    IDPedido, NomeCliente, RIGHT(CONVERT(CHAR(10),DataPedido,103),7)
FROM tblClientes C LEFT JOIN tblPedidos P
    ON C.IdCliente = P.IdCliente
GO 

DECLARE @menorPeriodo SMALLDATETIME, @maiorPeriodo SMALLDATETIME, @Periodos VARCHAR(500) 

-- Captura os períodos e inicializa as variáveis
SELECT @menorPeriodo = MIN(DataPedido), @maiorPeriodo = MAX(DataPedido),
@Periodos = '' FROM tblPedidos 

-- Retira os dias das respectivas datas
SET @menorPeriodo = DATEADD(D,-DAY(@menorPeriodo)+1,@menorPeriodo)
SET @maiorPeriodo = DATEADD(D,-DAY(@maiorPeriodo)+1,@maiorPeriodo) 

-- Montagem dos períodos
WHILE @menorPeriodo <= @maiorPeriodo
BEGIN
    -- Captura o mês e o dia
    SET @Periodos = @Periodos + '[' + RIGHT(CONVERT(CHAR(10),@menorPeriodo,103),7) + '],' 

    -- Adiciona um mês ao menor período
    SET @menorPeriodo = DATEADD(M,1,@menorPeriodo)
END 

-- Exibe os períodos
SET @Periodos = LEFT(@Periodos,LEN(@Periodos)-1) 

PRINT @Periodos 

Agora o formato está correto e podemos montar o comando dinamicamente, vamos a solução final. 

DECLARE @menorPeriodo SMALLDATETIME, @maiorPeriodo SMALLDATETIME,
@Periodos VARCHAR(500), @cmdSQL VARCHAR(1000) 

-- Captura os períodos e inicializa as variáveis
SELECT @menorPeriodo = MIN(DataPedido), @maiorPeriodo = MAX(DataPedido),
@Periodos = '' FROM tblPedidos 

-- Inicializa a variável @cmdSQL com a montagem do PIVOT
-- O caractér ? será substituído pelo período obtido dinamicamente
SET @cmdSQL = 'SELECT NomeCliente AS Cliente, ?
FROM 
(SELECT NomeCliente, IDPedido, Periodo
    FROM vPedidos) AS TBO
PIVOT
(COUNT(IDPedido) FOR Periodo IN (?)) AS TPVT' 

-- Retira os dias das respectivas datas
SET @menorPeriodo = DATEADD(D,-DAY(@menorPeriodo)+1,@menorPeriodo)
SET @maiorPeriodo = DATEADD(D,-DAY(@maiorPeriodo)+1,@maiorPeriodo) 

-- Montagem dos períodos
WHILE @menorPeriodo <= @maiorPeriodo
BEGIN
    -- Captura o mês e o dia
    SET @Periodos = @Periodos + '[' + RIGHT(CONVERT(CHAR(10),@menorPeriodo,103),7) + '],' 

    -- Adiciona um mês ao menor período
    SET @menorPeriodo = DATEADD(M,1,@menorPeriodo)
END 

-- Monta os períodos
SET @Periodos = LEFT(@Periodos,LEN(@Periodos)-1) 

-- Substitui o ? pelo período montado dinamicamente
SET @cmdSQL = REPLACE(@cmdSQL,'?',@Periodos) 

-- Executa o comando, opcionalmente dê um PRINT
-- PRINT @cmdSQL
EXEC (@cmdSQL)


Bom, acho que agora os princípios de tornar o pivot mais dinâmico está devidamente explicado. Com certeza, outras necessidades parecidas irão aparecer. Em todo caso, lembre-se de que essa transformação está dividida em três etapas. A primeira etapa é a formatação das colunas (no caso convertemos a data para MM/YYYY) a segunda etapa é a montagem dinâmica do nome das colunas e a última é a montagem dinâmica do comando. Provavelmente as necessidades irão diferir na primeira etapa (alguns vão desejar colocar o nome do mês ao invés do ano). 

Alguns irão indagar a certa do desempenho dessa consulta. Aplicar funções como YEAR e MONTH vão denegrí-la, mas lembre-se que as mesmas foram aplicadas em uma cláusula SELECT e não em uma cláusula WHERE como foi a proposta do SQL Server 2000. Em todo caso, uma coisa é certa sobre o desempenho. Quanto maior for o período analisado, maior serão as transformações e menor será o desempenho. A chave para tornar essa consulta factível do ponto de vista de desempenho é utilizar um filtro nas datas em tblPedido (prevendo que essa coluna possui um índice). A consulta abaixo filtra previamente os registros entre janeiro e agosto (setembro não está incluído). 

ALTER VIEW vPedidos (IDPedido, NomeCliente, DataPedido, Periodo)
AS
SELECT
    IDPedido, NomeCliente, DataPedido, YEAR(DataPedido) * 100 + MONTH(DataPedido)
FROM tblClientes C LEFT JOIN tblPedidos P
    ON C.IdCliente = P.IdCliente
GO 

SELECT NomeCliente AS Cliente, <Especifição dos meses>
FROM 
(SELECT NomeCliente, IDPedido, Periodo
    FROM vPedidos WHERE DataPedido >= '20080101' AND DataPedido < '20080901' ) AS TBO
PIVOT
(COUNT(IDPedido) FOR Periodo IN <Especificação dos meses>) AS TPVT 

Essa foi uma alternativa para tornar o código do PIVOT dinâmico através do Transact SQL. Em todo caso, você pode ter a disposição outras formas de apresentar esse resultado. Embora bastante tentador, tente evitar esse tipo de construção dentro do banco de dados. Não é atribuição do banco de dados formatar os dados. Lembre-se que enquanto linhas são formatadas e transformadas em colunas, outras consultas podem estar rodando mais lentamente já que recursos foram desviados para pivotear o resultado. 

Quem estiver animado e tiver entendido perfeitamento o código do pivot dinâmico, cabe um desafio final. Experimente tentar colocar uma coluna de totalização somando os pedidos de todos os clientes por mês. Essa é para quem realmente tem o domínio desse código.

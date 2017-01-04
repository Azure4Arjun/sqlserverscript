SET NOCOUNT ON

SELECT 'EXEC t4bdb01..sp_t4b_ins_BD_rotinas_adm ''' + name + '''' + char(10)+ 'GO'+Char(10)
FROM master..sysdatabases
WHERE name not in ('master', 'model', 'msdb', 'tempdb', 't4bdb01', 'pubs')

SET NOCOUNT OFF

SELECT *--[ObjectType (UDF/SP)],OBJECTNAME,count(1) 
FROM (
SELECT SCHEMA_NAME(SCHEMA_ID) AS [Schema], 
SO.name AS [ObjectName],
SO.Type_Desc AS [ObjectType (UDF/SP)],
P.parameter_id AS [ParameterID],
P.name AS [ParameterName],
TYPE_NAME(P.user_type_id) AS [ParameterDataType],
P.max_length AS [ParameterMaxBytes],
P.is_output AS [IsOutPutParameter]
FROM sys.objects AS SO
INNER JOIN sys.parameters AS P 
ON SO.OBJECT_ID = P.OBJECT_ID
WHERE SO.OBJECT_ID IN ( SELECT OBJECT_ID 
FROM sys.objects
WHERE TYPE IN ('P','FN'))

) x1
WHERE objectName like 'R2Go%'
--group by [ObjectType (UDF/SP)],OBJECTNAME
--ORDER BY count(1) desc
AND ParameterName LIKE '%vehicle%'
GO
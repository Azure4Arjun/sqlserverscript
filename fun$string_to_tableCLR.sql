--CREATE ASSEMBLY fun_split_string   
--FROM <system_drive>:\Program Files\Microsoft SQL Server\100\Samples\HelloWorld\CS\HelloWorld\bin\debug\fun_split_string.dll  
--WITH PERMISSION_SET = SAFE;  


CREATE FUNCTION dbo.fun_split_string
(
   @List      nvarchar(MAX),
   @Delimiter nvarchar(255)
)
RETURNS TABLE ( element nvarchar(4000) )
EXTERNAL NAME fun_split_string.UserDefinedFunctions.SplitString_Multi;
--EXTERNAL NAME MyAssemblyName.UserDefinedFunctions.FunctionNameInDllFile


GO
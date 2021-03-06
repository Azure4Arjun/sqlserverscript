-- Script para ser rodado no servidor principal
Use Master
go

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'tech4bmaster!@#$';
GO

USE master;
CREATE CERTIFICATE MASTER_BRJAGCCCISQLP01_cert 
   WITH SUBJECT = 'Master_BRJAGCCCISQLP01 certificado para o servidor PRINCIPAL',
   EXPIRY_DATE = '12/30/2029';
GO

CREATE ENDPOINT Mirroring
   STATE = STARTED
   AS TCP (
      LISTENER_PORT=5024
      , LISTENER_IP = ALL
   ) 
   FOR DATABASE_MIRRORING ( 
      AUTHENTICATION = CERTIFICATE MASTER_BRJAGCCCISQLP01_cert
      , ENCRYPTION = REQUIRED ALGORITHM RC4
      , ROLE = ALL
   );
GO

BACKUP CERTIFICATE MASTER_BRJAGCCCISQLP01_cert TO FILE = 'D:\config_mirror\MASTER_BRJAGCCCISQLP01_cert.cer';
GO

USE master;
CREATE LOGIN MIRROR_BRJAGCCCISQLP02_login WITH PASSWORD = 'tech4bmaster!@#$';
GO

CREATE USER MIRROR_BRJAGCCCISQLP02_user FOR LOGIN MIRROR_BRJAGCCCISQLP02_login;
GO

CREATE CERTIFICATE MIRROR_BRJAGCCCISQLP02_cert
   AUTHORIZATION MIRROR_BRJAGCCCISQLP02_user
   FROM FILE = 'D:\config_mirror\MIRROR_BRJAGCCCISQLP02_cert.cer' 
GO

GRANT CONNECT ON ENDPOINT::Mirroring TO [MIRROR_BRJAGCCCISQLP02_login];
GO
ALTER DATABASE cmcSiteCaue 
    SET PARTNER = 'TCP://BRJAGCCCISQLP02.GCC.COM:5024';
GO
ALTER DATABASE SharedServices1_Search_DB 
    SET PARTNER = 'TCP://BRJAGCCCISQLP02.GCC.COM:5024';
GO
ALTER DATABASE SharedServicesCaue_DB 
    SET PARTNER = 'TCP://BRJAGCCCISQLP02.GCC.COM:5024';
GO
ALTER DATABASE "SharePoint_AdminContent_327c740f-49cf-4034-9e34-4fd444e9db5a" 
    SET PARTNER = 'TCP://BRJAGCCCISQLP02.GCC.COM:5024';
GO
ALTER DATABASE SharePoint_Config 
    SET PARTNER = 'TCP://BRJAGCCCISQLP02.GCC.COM:5024';
GO
ALTER DATABASE WSS_Content 
    SET PARTNER = 'TCP://BRJAGCCCISQLP02.GCC.COM:5024';
GO
ALTER DATABASE WSS_Search_BRJAGCCCISQLP02 
    SET PARTNER = 'TCP://BRJAGCCCISQLP02.GCC.COM:5024';
GO

ALTER DATABASE t4bdb01 
    SET PARTNER = 'TCP://BRJAGCCCISQLP02.GCC.COM:5024';
GO


USE master;
CREATE LOGIN WITNESS_BRJAGCCCISQLP02_login WITH PASSWORD = 'tech4bmaster!@#$';
GO

CREATE USER WITNESS_BRJAGCCCISQLP02_user FOR LOGIN WITNESS_BRJAGCCCISQLP02_login;
GO

CREATE CERTIFICATE WITNESS_BRJAGCCCISQLP02_cert
   AUTHORIZATION WITNESS_BRJAGCCCISQLP02_user
   FROM FILE = 'D:\config_mirror\WITNESS_BRJAGCCCISQLP02_cert.cer' 
GO

GRANT CONNECT ON ENDPOINT::Mirroring TO [WITNESS_BRJAGCCCISQLP02_login];
GO


ALTER DATABASE cmcSiteCaue 
    SET WITNESS = 'TCP://BRJAGCCCISQLP02.GCC.COM:7022';
GO
ALTER DATABASE SharedServices1_Search_DB 
    SET WITNESS = 'TCP://BRJAGCCCISQLP02.GCC.COM:7022';
GO
ALTER DATABASE SharedServicesCaue_DB 
    SET WITNESS = 'TCP://BRJAGCCCISQLP02.GCC.COM:7022';
GO
ALTER DATABASE "SharePoint_AdminContent_327c740f-49cf-4034-9e34-4fd444e9db5a" 
    SET WITNESS = 'TCP://BRJAGCCCISQLP02.GCC.COM:7022';
GO
ALTER DATABASE SharePoint_Config 
    SET WITNESS = 'TCP://BRJAGCCCISQLP02.GCC.COM:7022';
GO
ALTER DATABASE WSS_Content 
    SET WITNESS = 'TCP://BRJAGCCCISQLP02.GCC.COM:7022';
GO
ALTER DATABASE WSS_Search_BRJAGCCCIIISP01 
    SET WITNESS = 'TCP://BRJAGCCCISQLP02.GCC.COM:7022';
GO

ALTER DATABASE t4bdb01 
    SET WITNESS = 'TCP://BRJAGCCCISQLP02.GCC.COM:7022';
GO
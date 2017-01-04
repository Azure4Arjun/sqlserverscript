-- Script para ser rodado no servidor espelho
Use Master
go

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'tech4bmaster!@#$';
GO

USE master;
CREATE CERTIFICATE MIRROR_STANLEYSQL2012_cert 
   WITH SUBJECT = 'MIRROR_STANLEYSQL2012 certificado para o servidor MIRROR',
   EXPIRY_DATE = '12/30/2029';
GO

CREATE ENDPOINT Mirroring
   STATE = STARTED
   AS TCP (
      LISTENER_PORT=5024
      , LISTENER_IP = ALL
   ) 
   FOR DATABASE_MIRRORING ( 
      AUTHENTICATION = CERTIFICATE MIRROR_STANLEYSQL2012_cert
      , ENCRYPTION = REQUIRED ALGORITHM RC4
      , ROLE = ALL
   );
GO

BACKUP CERTIFICATE MIRROR_STANLEYSQL2012_cert TO FILE = 'C:\mirror\MIRROR_STANLEYSQL2012_cert.cer';
GO

USE master;
CREATE LOGIN MIRROR_RAFAEL2012_login WITH PASSWORD = 'tech4bmaster!@#$';
GO

CREATE USER MIRROR_RAFAEL2012_login FOR LOGIN MIRROR_RAFAEL2012_login;
GO
-- criar a certificação utilizando aquela gerada no master

CREATE CERTIFICATE MASTER_RAFAEL2012_cert
   AUTHORIZATION MIRROR_RAFAEL2012_login
   FROM FILE = 'c:\mirror\MASTER_RAFAEL2012_cert.cer' 
GO

GRANT CONNECT ON ENDPOINT::Mirroring TO MIRROR_RAFAEL2012_login;
GO


restore database rafa_mirror_db from disk = 'c:\mirror\rafa_mirror_db.bkp'
with move 'rafa_mirror_db' to 'C:\temp\rafa_mirror_db.mdf',
move 'rafa_mirror_db_log' to 'C:\temp\rafa_mirror_db_log.mdf',
replace, norecovery


ALTER DATABASE rafa_mirror_db 
    SET PARTNER = 'TCP://10.255.11.16:5024';
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
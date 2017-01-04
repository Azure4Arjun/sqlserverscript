--https://www.toadworld.com/platforms/sql-server/b/weblog/archive/2012/10/15/multilanguage-table-how-to-insert-different-language-text-in-table

SELECT name, description
FROM fn_helpcollations();

CREATE TABLE i18n_language_translation
(rid INT IDENTITY NOT NULL
, key_name NVARCHAR(MAX)
, i18n_en NVARCHAR(MAX)		--english
, i18n_en_us NVARCHAR(MAX)	--english us
, i18n_cs NVARCHAR(MAX)		--czech
, i18n_nl NVARCHAR(MAX)		--dutch
, i18n_fi NVARCHAR(MAX)		--Finnish
, i18n_fr NVARCHAR(MAX)		--french
, i18n_de NVARCHAR(MAX)		--deutsch (german)
, i18n_el NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1253_CI_AI --greek
, i18n_it NVARCHAR(MAX)		--italian
, i18n_pl NVARCHAR(MAX)		--polish
, i18n_pt NVARCHAR(MAX)		--portuguese
, i18n_ru NVARCHAR(MAX) COLLATE Cyrillic_General_CI_AS_KS --russian
, i18n_es NVARCHAR(MAX)		--spanish
, i18n_sv NVARCHAR(MAX)		--swedish
, CONSTRAINT i18n_language_translationPK PRIMARY KEY (rid)
)

CREATE TABLE i18n_users (
rid INT IDENTITY NOT NULL
,username NVARCHAR(200) NOT NULL
,password NVARCHAR(200) NOT NULL
,active BIT NOT NULL
, CONSTRAINT i18n_usersPK PRIMARY KEY (rid)
)





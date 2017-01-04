ALTER TABLE imp_KoreDetail ADD rid INT

DECLARE @rid INT
SET @rid = 1


WHILE EXISTS (SELECT 1 FROM imp_KoreDetail WHERE rid IS NULL)
  BEGIN
    SET ROWCOUNT 1
    UPDATE t1
    SET rid = @rid
    FROM imp_KoreDetail t1
    WHERE rid IS NULL
    
    SET @rid = @rid + 1

  END


  --ALTER TABLE imp_KoreDetail DROP COLUMN rid 
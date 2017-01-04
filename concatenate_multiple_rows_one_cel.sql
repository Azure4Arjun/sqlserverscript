

DECLARE @payload VARCHAR(500)
DECLARE @row_number INT
DECLARE @request_rid INT
DECLARE @pdt_end_time DATETIME

SET @pdt_end_time = getdate()

CREATE TABLE #test (request_rid INT, payload VARCHAR(MAX))
CREATE TABLE #request_rid (request_rid INT)

INSERT INTO #request_rid
  SELECT t1.request_rid
  FROM Linda.dbo.request t1 WITH (NOLOCK)
   WHERE t1.request_status_rid IN (8,9)
    AND t1.created > DATEADD(dd,-21,@pdt_end_time)
    AND t1.created < @pdt_end_time


WHILE (SELECT count(1) FROM #request_rid) > 0
  BEGIN 
    
    SELECT TOP 1
    @request_rid = request_rid
    FROM #request_rid
    ORDER BY 1

    SELECT @row_number = ROW_NUMBER() OVER(PARTITION BY request_rid ORDER BY request_step_no ), 			--main concatenation
    @payload = ISNULL(@payload, '') + CHAR(13) + 'Step' + CONVERT(varchar(20),@row_number) + ':' + payload	--main concatenation
    FROM request_step																						--main concatenation
    WHERE request_rid = @request_rid																		--main concatenation

    INSERT INTO #test
    VALUES(@request_rid, @payload)

    SET @payload = NULL
    SET @row_number = NULL

    DELETE FROM #request_rid
    WHERE request_rid = @request_rid
END

SELECT * FROM #test

DROP TABLE #test
DROP TABLE #request_rid
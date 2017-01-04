/*
Remove hours minutes seconds
*/
SELECT dateadd(dd, datediff(dd,0, getDate()), 0)

/*
Remove minutes and seconds
*/
SELECT DATEADD(hour, DATEDIFF(hour, 0, getdate()), 0)

/*
Remove seconds
*/
SELECT DATEADD(minute, DATEDIFF(minute, 0, getdate()), 0)
/*
Get day of week
*/
select datename(dw,getdate()) --Friday

/*
Extract just hour and minutes from DATETIME
*/
SELECT CONVERT(VARCHAR(8),DATEADD(minute, DATEDIFF(minute, 0, getdate()), 0),108) AS hour_minute

/*
Get first date of month from datetime
*/
 */
SELECT DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0)

/*
Get last date of the month
*/
SELECT DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,getdate())+1,0))

/*
Populate a table with list of month end dates
*/
DECLARE @ltbl_month_end_date TABLE (
			month_end_date DATETIME)
INSERT INTO  @ltbl_month_end_date SELECT '2015-01-31 23:59:59.000'

DECLARE @last_month_end_date DATETIME
			,	@max_month_end_date DATETIME
SET			@max_month_end_date = '2015-12-31 23:59:59.000'

SELECT  @last_month_end_date = MAX(month_end_date)
FROM @ltbl_month_end_date

WHILE @last_month_end_date < @max_month_end_date
	BEGIN
		SELECT	@last_month_end_date as last_month_end_date
					,	DATEADD(dd,+1,@last_month_end_date) as last_month_end_date_plus_one_day
					, DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,DATEADD(dd,+1,@last_month_end_date))+1,0)) as last_month_end_date_plus_one_month

		INSERT INTO @ltbl_month_end_date SELECT DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,DATEADD(dd,+1,@last_month_end_date))+1,0))

		SELECT  @last_month_end_date = MAX(month_end_date)
		FROM @ltbl_month_end_date

	END

SELECT * FROM @ltbl_month_end_date
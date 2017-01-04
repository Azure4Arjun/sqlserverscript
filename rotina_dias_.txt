declare @var int
select @var = case datename(dw,getdate())
    WHEN 'SUNDAY' THEN 128
    WHEN 'MONDAY'  THEN 2
    WHEN 'TUESDAY'  THEN 4
    WHEN 'WEDNESDAY'  THEN 8
    WHEN 'THURSDAY' THEN 16
    WHEN 'FRIDAY' THEN  32  
    WHEN 'SATURDAY'  THEN 64
END 

select @var

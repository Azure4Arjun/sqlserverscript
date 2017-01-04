from WSS_Content_80.dbo.AllUSerData t1    
--where tp_created = getdate()    
where tp_Created >= DateAdd(Day, DateDiff(Day, 0, GetDate()), 0)

-- o codigo acima é melhor, pois usa o índice
OU where datediff (day, tp_Created, getdate()) = 0
http://www.sqlteam.com/forums/topic.asp?TOPIC_ID=60281
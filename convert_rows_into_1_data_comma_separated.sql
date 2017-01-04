create table cars (id int, brand varchar(50), owner varchar(50))

insert into cars VALUES (5, 'BMW', 'Jack')



select
    g1.owner
    , stuff((
        select ', ' + g.brand
        from cars g        
        where g.owner = g1.owner        
        order by g.brand
        for xml path('')
    ),1,2,'') as brands
from cars g1
group by g1.owner
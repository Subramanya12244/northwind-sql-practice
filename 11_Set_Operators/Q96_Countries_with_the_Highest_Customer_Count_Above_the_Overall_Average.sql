/* Q96. Countries with the Highest Customer Count Above the Overall Average */

-- Correct Approach
with total_count as (
  SELECT c.country,
  sum(case when c.country is not null then 1 else 0 end) as total_cust
  from customers c
  group by c.country
),
avg_count as (
  select avg(total_cust) as avg_count
  from total_count
) ,
max_count as (
  select max(total_cust) as max_count
  from total_count
)
select t.country,
t.total_cust,
a.avg_count,
m.max_count
from total_count t CROSS JOIN
avg_count a CROSS JOIN 
max_count m
where t.total_cust>a.avg_count
and t.total_cust=m.max_count;

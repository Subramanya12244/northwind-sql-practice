/* Q97. Countries with More Customers Than Their Entity Average */

-- Correct Approach
with data_set as (
  select e.country,
  'employees' as Entity
  from employees e
  Union all
  select c.country,
  'customers' as Entity
  from customers c
  UNION all
  select s.country,
  'suppliers' as Entity
  from suppliers s
),
total_count_as_per_entity as(
  select d.country,
  sum(case when d.entity='employees' then 1 else 0 end) as total_employee,
  sum(case when d.entity='customers' then 1 else 0 end) as total_customers,
  sum(case when d.entity='suppliers' then 1 else 0 end) as total_suppliers
  from data_set d
  group by d.country
  ),
  average_entity as (
    select t.country,
  (t.total_employee+t.total_customers+t.total_suppliers)/3.0 as entity_average
    from total_count_as_per_entity t
  )
  select t.country,t.total_employee,t.total_customers,t.total_suppliers ,a.entity_average
  from total_count_as_per_entity t inner join 
  average_entity a on t.country=a.country
  where t.total_customers>a.entity_average;

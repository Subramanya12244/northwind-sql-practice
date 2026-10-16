/* =====================================================================
   Q97 · Countries with More Customers Than Their Entity Average
   Category : Set Operators (UNION ALL) + Multi-level Aggregation  Difficulty : Expert
   Concepts : UNION ALL · CTE · SUM+CASE · GROUP BY · Derived metric · WHERE
   ---------------------------------------------------------------------
   PROBLEM : Return countries where total_customers is greater than the
             average of that country's three entity counts
             (employees, suppliers, customers).
   APPROACH:
     1. data_set CTE — UNION ALL of (country, entity) from all three tables.
     2. total_count_as_per_entity CTE — SUM(CASE ...) per entity, per country.
     3. average_entity CTE — (emp + cust + supp)/3.0 per country (real division).
     4. Join counts to the per-country average; keep total_customers > avg.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
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

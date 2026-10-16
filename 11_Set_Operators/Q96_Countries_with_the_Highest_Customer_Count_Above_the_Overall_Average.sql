/* =====================================================================
   Q96 · Countries with the Highest Customer Count Above the Overall Average
   Category : Multi-stage Aggregation     Difficulty : Expert
   Concepts : CTE · COUNT · AVG · MAX · Subquery · CROSS JOIN · WHERE
   ---------------------------------------------------------------------
   PROBLEM : Return the country/countries with the highest customer count
             among countries whose customer count is above the overall
             average (tie-safe — return all leaders).
   APPROACH:
     1. total_count CTE — customers per country (GROUP BY country).
     2. avg_count CTE — AVG of the per-country counts.
     3. max_count CTE — MAX of the per-country counts.
     4. CROSS JOIN the three, filter total_cust > avg AND total_cust = max.
        Comparing to MAX (not LIMIT 1) keeps ties.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
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

/* =====================================================================
   Q93 · Countries with Balanced Business Entities
   Category : Set Operators (UNION ALL + Conditional Aggregation)  Difficulty : Advanced
   Concepts : UNION ALL · CTE · SUM+CASE · GROUP BY · HAVING
   ---------------------------------------------------------------------
   PROBLEM : Return countries that contain at least one employee, one
             supplier, and one customer, with each entity count shown.
   APPROACH:
     1. CTE: UNION ALL of (country, entity) from employees/suppliers/customers.
     2. Conditional aggregation: SUM(CASE ...) per entity type.
     3. GROUP BY country.
     4. HAVING each per-entity SUM(CASE ...) != 0 → all three present.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
WITH cte AS (
     SELECT    e.country,
     'employees' AS entity
     FROM      employees e
     UNION all
     SELECT    s.country,
     'supplier' AS entity
     FROM      suppliers s
     UNION all
     SELECT    c.country,
     'customers' AS entity
     FROM      customers c
     )
SELECT country,
       sum(
       CASE
       WHEN entity = 'employees' THEN 1
       ELSE 0
       END
       ) as total_employees,
       sum(
       CASE
       WHEN entity = 'supplier' THEN 1
       ELSE 0
       END
       ) as total_suppliers,
       sum(
       CASE
       WHEN entity = 'customers' THEN 1
       ELSE 0
       END
       ) as total_customers
FROM cte
GROUP BY country
HAVING sum(
       CASE
       WHEN entity = 'employees' THEN 1
       ELSE 0
       END
       ) != 0
AND sum(
    CASE
    WHEN entity = 'supplier' THEN 1
    ELSE 0
    END
    ) != 0
AND sum(
       CASE
       WHEN entity = 'customers' THEN 1
       ELSE 0
       END
       ) != 0;

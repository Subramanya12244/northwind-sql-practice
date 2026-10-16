/* =====================================================================
   Q92 · Countries with More Customers Than Employees and Suppliers
   Category : Set Operators (UNION ALL) + Conditional Aggregation + HAVING
   Difficulty : Hard
   Concepts : CTE · UNION ALL · GROUP BY · SUM+CASE · HAVING · ORDER BY (multi-col)
   ---------------------------------------------------------------------
   PROBLEM : Return countries where total customers exceed the combined
             total of employees and suppliers in that country.
   APPROACH:
     1. CTE: UNION ALL of (country, entity) from all three tables.
     2. Outer: SUM(CASE ...) per entity type, GROUP BY country.
     3. HAVING compares customers > employees + suppliers (full exprs).
     4. ORDER BY total_customers DESC, country ASC (deterministic ties).
   MISTAKES I MADE (SQL logic correct from Attempt 1 — format rejections):
     • A1: wrong aliases (employees_count vs total_employees), no ORDER BY.
     • A2: correct aliases, ORDER BY missing entirely.
     • A3: ORDER BY one column only (missing country ASC tie-breaker).
     • A4: ORDER BY used SUM(CASE..) expression instead of alias.
     • A5: fully correct; rejected by a platform formatting/data quirk.
     Lesson: match expected column names AND sort order exactly.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (Attempt 1 — wrong aliases, no ORDER BY) ────
-- WITH cte AS (
--     SELECT e.country, 'employee' AS entity FROM employees e
--     UNION ALL
--     SELECT s.country, 'suppliers' AS entity FROM suppliers s
--     UNION ALL
--     SELECT c.country, 'customers' AS entity FROM customers c
-- )
-- SELECT country,
--     SUM(CASE WHEN entity = 'employee' THEN 1 ELSE 0 END) AS employees_count,
--     SUM(CASE WHEN entity = 'suppliers' THEN 1 ELSE 0 END) AS suppliers_count,
--     SUM(CASE WHEN entity = 'customers' THEN 1 ELSE 0 END) AS customers_count
-- FROM cte
-- GROUP BY country
-- HAVING SUM(CASE WHEN entity = 'customers' THEN 1 ELSE 0 END)
--      > SUM(CASE WHEN entity = 'employee' THEN 1 ELSE 0 END)
--      + SUM(CASE WHEN entity = 'suppliers' THEN 1 ELSE 0 END);

-- ── FINAL CORRECT SOLUTION ───────────────────────────────────────────
WITH cte AS (
    SELECT e.country, 'employee' AS entity
    FROM employees e
    UNION ALL
    SELECT s.country, 'suppliers' AS entity
    FROM suppliers s
    UNION ALL
    SELECT c.country, 'customers' AS entity
    FROM customers c
)
SELECT
    country,
    SUM(CASE WHEN entity = 'employee' THEN 1 ELSE 0 END) AS total_employees,
    SUM(CASE WHEN entity = 'suppliers' THEN 1 ELSE 0 END) AS total_suppliers,
    SUM(CASE WHEN entity = 'customers' THEN 1 ELSE 0 END) AS total_customers
FROM cte
GROUP BY country
HAVING SUM(CASE WHEN entity = 'customers' THEN 1 ELSE 0 END)
     > SUM(CASE WHEN entity = 'employee' THEN 1 ELSE 0 END)
     + SUM(CASE WHEN entity = 'suppliers' THEN 1 ELSE 0 END)
ORDER BY total_customers DESC, country ASC;

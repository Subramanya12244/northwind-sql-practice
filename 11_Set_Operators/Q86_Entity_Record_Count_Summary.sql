/* =====================================================================
   Q86 · Entity Record Count Summary
   Category : Set Operators (UNION ALL + Aggregation)   Difficulty : Hard
   Concepts : UNION ALL (inside CTE) · CTE · GROUP BY · COUNT
   ---------------------------------------------------------------------
   PROBLEM : Return the total number of records per entity type
             (Customer, Supplier, Employee) in a single query.
   APPROACH:
     1. First attempt: UNION three pre-aggregated COUNT(*) queries.
     2. Correct: CTE stacks one label row per source record with UNION ALL,
        then outer query GROUP BY Entity_Type with COUNT(*).
     3. "Standardise first (UNION ALL), then summarise (GROUP BY)."
   MISTAKES I MADE:
     • 'employee' lowercase instead of 'Employee' → inconsistent labels.
     • Used UNION between pre-aggregated queries (only coincidentally right);
       correct pattern is CTE + UNION ALL. UNION inside the CTE would
       collapse identical label rows → COUNT(*) returns 1 instead of N.
       Fix: CTE + UNION ALL + GROUP BY.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (first attempt — 'employee' lowercase, UNION) ──
-- select 'employee' as Entity_Type, count(*) from employees e
-- union
-- select 'Supplier' as Entity_Type, count(*) from suppliers s
-- union
-- select 'Customer' as Entity_Type, count(*) from customers c;

-- ── FINAL CORRECT SOLUTION (CTE + UNION ALL + GROUP BY) ──────────────
WITH cte_1 AS
(
    SELECT 'Employee' AS Entity_Type
    FROM employees
    UNION ALL
    SELECT 'Supplier' AS Entity_Type
    FROM suppliers
    UNION ALL
    SELECT 'Customer' AS Entity_Type
    FROM customers
)
SELECT Entity_Type,
       COUNT(*) AS Total_Records
FROM cte_1
GROUP BY Entity_Type;

/*
Question:
Return a summary showing the total number of records for each entity
type (Customer, Supplier, Employee) in a single query.

Business Requirement:
The management team wants to know how many records exist per entity
in one unified report — without running three separate queries manually.

---
APPROACH 1 — First attempt: UNION of pre-aggregated queries
---
Produces correct results but has two issues:
1. 'employee' is lowercase — inconsistent with 'Customer' / 'Supplier'
2. Semantically incorrect to use UNION here (should be UNION ALL);
   only works coincidentally because three distinct entity types
   produce three distinct rows that won't be deduplicated.
3. Does not follow the "standardise first, then summarise" pattern.

select 'employee' as Entity_Type, count(*) from employees e
union
select 'Supplier' as Entity_Type, count(*) from suppliers s
union
select 'Customer' as Entity_Type, count(*) from customers c

---
APPROACH 2 — Correct: CTE with UNION ALL, then GROUP BY (preferred)
---

Why UNION ALL inside the CTE (critical):
   The CTE stacks all rows from all three tables into one flat list.
   Every employee row has Entity_Type = 'Employee'.
   UNION would deduplicate all identical Entity_Type rows — collapsing
   all 9 employee rows into 1, so COUNT(*) would return 1 instead of 9.
   UNION ALL preserves every row → COUNT(*) returns correct totals. ✅

Why this approach scales better:
   Step 1 (CTE): standardise — bring all entities into one flat format.
   Step 2 (outer query): summarise — aggregate the unified dataset.
   This "ETL pipeline" pattern extends cleanly to multi-dimensional
   analysis (add country, city, date range) without restructuring.

Expected Output:
| Entity_Type | Total_Records |
|-------------|---------------|
| Customer    | 91            |
| Supplier    | 29            |
| Employee    | 9             |

Concepts Used:
- UNION ALL (inside CTE — mandatory, not UNION)
- CTE (Common Table Expression)
- GROUP BY
- Aggregate Functions (COUNT)

Complexity:
Hard
*/

-- First attempt (correct result, minor issues — see notes above):
-- select 'employee' as Entity_Type, count(*) from employees e
-- union
-- select 'Supplier' as Entity_Type, count(*) from suppliers s
-- union
-- select 'Customer' as Entity_Type, count(*) from customers c;

-- Correct approach (preferred — CTE + UNION ALL + GROUP BY):
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

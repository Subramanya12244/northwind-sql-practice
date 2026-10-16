/* =====================================================================
   Q21 · Employees Above Average Revenue Using Multiple CTEs
   Category : Common Table Expressions (CTEs)     Difficulty : Medium
   Concepts : CTE (multiple) · INNER JOIN (non-equality) · GROUP BY · SUM/AVG
   ---------------------------------------------------------------------
   PROBLEM : Return employees whose revenue exceeds the average employee
             revenue, using two CTEs joined via an inequality condition.
   APPROACH:
     1. CTE employee_revenue: per-employee discounted revenue.
     2. CTE avg_revenue: single AVG(total_revenue) over the first CTE.
     3. Join on er.total_revenue > ar.avg_rev (the comparison IS the join).
     4. ORDER BY total_revenue DESC.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
WITH employee_revenue AS (
    SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
    FROM employees e
    JOIN orders o ON o.employee_id = e.employee_id
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY e.employee_id, e.first_name, e.last_name
),
avg_revenue AS (
    SELECT AVG(total_revenue) AS avg_rev
    FROM employee_revenue
)
SELECT er.*
FROM employee_revenue er
JOIN avg_revenue ar ON er.total_revenue > ar.avg_rev
ORDER BY er.total_revenue DESC;

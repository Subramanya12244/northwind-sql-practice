/* =====================================================================
   Q22 · Top Employee by Revenue Using 3 CTEs
   Category : Common Table Expressions (CTEs)     Difficulty : Medium
   Concepts : CTE (chained) · GROUP BY · SUM/MAX · Tie Handling · INNER JOIN
   ---------------------------------------------------------------------
   PROBLEM : Find the employee(s) with the single highest total revenue,
             returning all ties (not an arbitrary one).
   APPROACH:
     1. CTE employee_revenue: discounted revenue per employee.
     2. CTE max_revenue: single MAX(total_revenue) across employees.
     3. CTE ranked_employees: join first two on total_revenue = max_rev
        (equality naturally includes every tied employee).
     4. SELECT and ROUND the final result.
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
max_revenue AS (
    SELECT MAX(total_revenue) AS max_rev
    FROM employee_revenue
),
ranked_employees AS (
    SELECT er.*
    FROM employee_revenue er
    JOIN max_revenue mr ON er.total_revenue = mr.max_rev
)
SELECT
    employee_id,
    first_name,
    last_name,
    ROUND(total_revenue::numeric, 2) AS total_revenue
FROM ranked_employees;

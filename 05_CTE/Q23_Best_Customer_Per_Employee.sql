/* =====================================================================
   Q23 · Best Customer per Employee
   Category : Common Table Expressions (CTEs)     Difficulty : Hard
   Concepts : CTE · Window Functions (RANK) · PARTITION BY · GROUP BY
              · SUM · Tie Handling · INNER JOIN
   ---------------------------------------------------------------------
   PROBLEM : For every employee, return the customer(s) generating the
             highest revenue from orders that employee handled (ties kept).
   APPROACH:
     1. CTE employee_customer_revenue: revenue per employee-customer pair.
     2. CTE ranked: RANK() OVER (PARTITION BY employee_id
        ORDER BY total_revenue DESC).
     3. Filter rnk = 1 (keeps ties); join employees & customers for names.
     4. ORDER BY employee_id.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
WITH employee_customer_revenue AS (
    SELECT
        o.employee_id,
        o.customer_id,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY o.employee_id, o.customer_id
),
ranked AS (
    SELECT
        ecr.*,
        RANK() OVER (PARTITION BY employee_id ORDER BY total_revenue DESC) AS rnk
    FROM employee_customer_revenue ecr
)
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    r.customer_id,
    cu.company_name,
    ROUND(r.total_revenue::numeric, 2) AS total_revenue
FROM ranked r
JOIN employees e ON e.employee_id = r.employee_id
JOIN customers cu ON cu.customer_id = r.customer_id
WHERE r.rnk = 1
ORDER BY e.employee_id;

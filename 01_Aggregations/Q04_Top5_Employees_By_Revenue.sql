/* =====================================================================
   Q04 · Top 5 Employees by Revenue
   Category : Aggregations & Revenue Analysis     Difficulty : Easy
   Concepts : INNER JOIN (multi-table) · GROUP BY · SUM · ORDER BY · LIMIT
   ---------------------------------------------------------------------
   PROBLEM : Top 5 employees by total discounted revenue of orders handled.
   APPROACH:
     1. employees -> orders (employee_id) -> order_details (order_id).
     2. SUM revenue grouped by employee.
     3. ORDER BY revenue DESC, then LIMIT 5.
   MISTAKES I MADE:
     • none recorded
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue
FROM employees e
JOIN orders o ON o.employee_id = e.employee_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_revenue DESC
LIMIT 5;

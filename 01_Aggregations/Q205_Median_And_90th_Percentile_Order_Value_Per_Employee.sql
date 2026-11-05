/* =====================================================================
   Q205 · Median And 90th Percentile Order Value Per Employee
   Category : Aggregations (Ordered-Set Aggregates)     Difficulty : Hard
   Concepts : PERCENTILE_CONT · WITHIN GROUP · Mean vs median · CTE · ROUND with numeric
   ---------------------------------------------------------------------
   PROBLEM : For each employee, compute their order count, mean, median and 90th-percentile net order value (all 2 dp), highest median first.
   APPROACH:
     1. CTE: net value per order (order_id, employee_id).
     2. Group by employee: AVG, PERCENTILE_CONT(0.5) and PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY order_value).
     3. Join employees for names; order by median.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH order_values AS (
    SELECT o.order_id, o.employee_id,
           SUM(d.unit_price * d.quantity * (1 - d.discount))::numeric AS order_value
    FROM orders o
    JOIN order_details d ON d.order_id = o.order_id
    GROUP BY o.order_id, o.employee_id
)
SELECT e.employee_id, e.first_name, e.last_name,
       COUNT(*)                                                                  AS orders,
       ROUND(AVG(order_value), 2)                                                AS mean_value,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY order_value)::numeric, 2) AS median_value,
       ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY order_value)::numeric, 2) AS p90_value
FROM order_values ov
JOIN employees e ON e.employee_id = ov.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY median_value DESC, e.employee_id;

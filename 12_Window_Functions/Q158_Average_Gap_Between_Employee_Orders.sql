/* =====================================================================
   Q158 · Average Gap Between Employee Orders
   Category : Window Functions (Offset + Aggregation)     Difficulty : Hard
   Concepts : LAG · PARTITION BY · Date Arithmetic · AVG · AVG() OVER () · Multi-step CTE
   ---------------------------------------------------------------------
   PROBLEM : For each employee, compute the number of orders, the average and maximum days between consecutive orders, and the difference between their average gap and the average of all employees' averages.
   APPROACH:
     1. CTE order_gaps: order_date - LAG(order_date) OVER (PARTITION BY employee_id ORDER BY order_date, order_id).
     2. CTE employee_gaps: per employee COUNT(*), AVG(gap_days), MAX(gap_days).
     3. Outer query: avg_gap_days - AVG(avg_gap_days) OVER (); join employees; order by avg_gap_days, employee_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH order_gaps AS (
    SELECT
        o.employee_id,
        o.order_id,
        o.order_date,
        o.order_date - LAG(o.order_date) OVER (PARTITION BY o.employee_id
                                               ORDER BY o.order_date, o.order_id) AS gap_days
    FROM orders o
),
employee_gaps AS (
    SELECT
        employee_id,
        COUNT(*)                         AS total_orders,
        ROUND(AVG(gap_days)::numeric, 2) AS avg_gap_days,
        MAX(gap_days)                    AS max_gap_days
    FROM order_gaps
    GROUP BY employee_id
)
SELECT
    eg.employee_id,
    e.first_name,
    e.last_name,
    eg.total_orders,
    eg.avg_gap_days,
    eg.max_gap_days,
    ROUND(eg.avg_gap_days - AVG(eg.avg_gap_days) OVER (), 2) AS diff_vs_team_avg
FROM employee_gaps eg
JOIN employees e ON e.employee_id = eg.employee_id
ORDER BY avg_gap_days, employee_id;

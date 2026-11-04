/* =====================================================================
   Q157 · Employee Revenue Percentile Rank
   Category : Window Functions (Distribution)     Difficulty : Hard
   Concepts : PERCENT_RANK · CUME_DIST · GROUP BY · CTE
   ---------------------------------------------------------------------
   PROBLEM : For each employee with orders, return total revenue, PERCENT_RANK() and CUME_DIST() (both ordered by revenue ascending, 4 dp).
   APPROACH:
     1. CTE employee_revenue: net revenue per employee.
     2. Compute PERCENT_RANK() and CUME_DIST() over ORDER BY revenue (ascending, so higher = better).
     3. Join employees, round, order by revenue descending then employee_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH employee_revenue AS (
    SELECT
        o.employee_id,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS revenue
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY o.employee_id
)
SELECT
    er.employee_id,
    e.first_name,
    e.last_name,
    ROUND(er.revenue::numeric, 2) AS total_revenue,
    ROUND(PERCENT_RANK() OVER (ORDER BY er.revenue)::numeric, 4) AS percent_rank,
    ROUND(CUME_DIST()    OVER (ORDER BY er.revenue)::numeric, 4) AS cume_dist
FROM employee_revenue er
JOIN employees e ON e.employee_id = er.employee_id
ORDER BY total_revenue DESC, employee_id;

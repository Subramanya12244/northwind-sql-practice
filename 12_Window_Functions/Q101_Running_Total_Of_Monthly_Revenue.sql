/* =====================================================================
   Q101 · Running Total Of Monthly Revenue
   Category : Window Functions (Aggregate Windows)     Difficulty : Easy
   Concepts : SUM OVER · ROWS BETWEEN UNBOUNDED PRECEDING · DATE_TRUNC · CTE
   ---------------------------------------------------------------------
   PROBLEM : Return one row per order month with its revenue and the running total of revenue to date.
   APPROACH:
     1. CTE monthly: DATE_TRUNC('month', order_date) and sum net revenue per month.
     2. Outer query: SUM(revenue) OVER (ORDER BY order_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW).
     3. Round both values and order by month.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::date AS order_month,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS revenue
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT
    order_month,
    ROUND(revenue::numeric, 2) AS monthly_revenue,
    ROUND(SUM(revenue) OVER (ORDER BY order_month
                             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)::numeric, 2) AS running_revenue
FROM monthly
ORDER BY order_month;

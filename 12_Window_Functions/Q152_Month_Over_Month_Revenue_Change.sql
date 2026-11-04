/* =====================================================================
   Q152 · Month Over Month Revenue Change
   Category : Window Functions (Offset)     Difficulty : Medium
   Concepts : LAG · NULLIF · Percent Change · DATE_TRUNC · CTE
   ---------------------------------------------------------------------
   PROBLEM : For each order month, return revenue, previous month revenue (via LAG), absolute change, and percent change rounded to 2 dp.
   APPROACH:
     1. CTE monthly: revenue per month.
     2. CTE with_prev: add LAG(revenue) OVER (ORDER BY order_month).
     3. Compute change and 100.0 * change / NULLIF(prev, 0); round and order by month.
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
),
with_prev AS (
    SELECT
        order_month,
        revenue,
        LAG(revenue) OVER (ORDER BY order_month) AS prev_revenue
    FROM monthly
)
SELECT
    order_month,
    ROUND(revenue::numeric, 2)                  AS monthly_revenue,
    ROUND(prev_revenue::numeric, 2)             AS prev_month_revenue,
    ROUND((revenue - prev_revenue)::numeric, 2) AS revenue_change,
    ROUND((100.0 * (revenue - prev_revenue) / NULLIF(prev_revenue, 0))::numeric, 2) AS pct_change
FROM with_prev
ORDER BY order_month;

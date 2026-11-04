/* =====================================================================
   Q102 · Three Month Moving Average Revenue
   Category : Window Functions (Sliding Frames)     Difficulty : Medium
   Concepts : AVG OVER · ROWS BETWEEN 2 PRECEDING · Named WINDOW · DATE_TRUNC · CTE
   ---------------------------------------------------------------------
   PROBLEM : Return each order month's revenue, the number of months in its trailing window, and the 3-month trailing moving average.
   APPROACH:
     1. CTE monthly: revenue per DATE_TRUNC('month', order_date).
     2. Define WINDOW w AS (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW).
     3. Compute AVG(revenue) OVER w and COUNT(*) OVER w; round and order by month.
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
    COUNT(*) OVER w AS months_in_window,
    ROUND(AVG(revenue) OVER w::numeric, 2) AS moving_avg_3m
FROM monthly
WINDOW w AS (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
ORDER BY order_month;

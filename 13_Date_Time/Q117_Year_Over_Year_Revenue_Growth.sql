/* =====================================================================
   Q117 · Year Over Year Revenue Growth
   Category : Date & Time (Window Functions over Periods)          Difficulty : Hard
   Concepts : CTE · LAG · Window Functions · NULLIF · Percentage Calculation · ROUND
   ---------------------------------------------------------------------
   PROBLEM : Return yearly net revenue, previous year's revenue and YoY growth % (all rounded to 2 decimals).
   APPROACH:
     1. CTE yearly: sum net revenue per EXTRACT(YEAR ...)::int.
     2. Use LAG(revenue) OVER (ORDER BY order_year) for the prior year.
     3. Growth % = (revenue - prev) * 100.0 / NULLIF(prev, 0).
     4. Round each output column and order by year.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH yearly AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date)::int AS order_year,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS revenue
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY EXTRACT(YEAR FROM o.order_date)
)
SELECT
    order_year,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY order_year)::numeric, 2) AS prev_year_revenue,
    ROUND(((revenue - LAG(revenue) OVER (ORDER BY order_year)) * 100.0
           / NULLIF(LAG(revenue) OVER (ORDER BY order_year), 0))::numeric, 2) AS yoy_growth_pct
FROM yearly
ORDER BY order_year;

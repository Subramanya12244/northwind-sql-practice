/* =====================================================================
   Q160 · Revenue By Quarter
   Category : Date & Time (Quarterly Aggregation)          Difficulty : Easy
   Concepts : EXTRACT(QUARTER) · JOIN · SUM · COUNT DISTINCT · ROUND
   ---------------------------------------------------------------------
   PROBLEM : Return order count and net revenue (rounded to 2 decimals) per year and quarter.
   APPROACH:
     1. Join orders to order_details on order_id.
     2. Extract year and quarter from order_date.
     3. SUM the net line revenue and COUNT(DISTINCT order_id).
     4. Round revenue with ROUND(...::numeric, 2) and order by year, quarter.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    EXTRACT(YEAR FROM o.order_date)::int    AS order_year,
    EXTRACT(QUARTER FROM o.order_date)::int AS order_quarter,
    COUNT(DISTINCT o.order_id)              AS order_count,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS revenue
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
GROUP BY EXTRACT(YEAR FROM o.order_date), EXTRACT(QUARTER FROM o.order_date)
ORDER BY order_year, order_quarter;

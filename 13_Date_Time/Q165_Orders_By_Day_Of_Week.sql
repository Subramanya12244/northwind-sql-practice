/* =====================================================================
   Q165 · Orders By Day Of Week
   Category : Date & Time (Weekday Patterns)          Difficulty : Medium
   Concepts : EXTRACT(ISODOW) · TO_CHAR · TRIM · JOIN · COUNT DISTINCT · SUM
   ---------------------------------------------------------------------
   PROBLEM : Return order count and net revenue for each day of the week, ordered Monday through Sunday.
   APPROACH:
     1. Join orders to order_details.
     2. Derive EXTRACT(ISODOW ...)::int and TRIM(TO_CHAR(order_date, 'Day')).
     3. Group by both; count distinct orders and sum net revenue.
     4. Order by day_number.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    EXTRACT(ISODOW FROM o.order_date)::int AS day_number,
    TRIM(TO_CHAR(o.order_date, 'Day'))     AS day_name,
    COUNT(DISTINCT o.order_id)             AS order_count,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS revenue
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
GROUP BY EXTRACT(ISODOW FROM o.order_date), TRIM(TO_CHAR(o.order_date, 'Day'))
ORDER BY day_number;

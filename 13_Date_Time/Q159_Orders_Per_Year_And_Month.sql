/* =====================================================================
   Q159 · Orders Per Year And Month
   Category : Date & Time (Grouping by Period)          Difficulty : Easy
   Concepts : EXTRACT · GROUP BY · COUNT · Integer Casting
   ---------------------------------------------------------------------
   PROBLEM : Return the number of orders placed per calendar year and month, with year and month as integers.
   APPROACH:
     1. Extract the year and month from order_date with EXTRACT(...)::int.
     2. Group by both parts and COUNT(*) the orders.
     3. Order by year, then month.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    EXTRACT(YEAR FROM order_date)::int  AS order_year,
    EXTRACT(MONTH FROM order_date)::int AS order_month,
    COUNT(*)                            AS order_count
FROM orders
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY order_year, order_month;

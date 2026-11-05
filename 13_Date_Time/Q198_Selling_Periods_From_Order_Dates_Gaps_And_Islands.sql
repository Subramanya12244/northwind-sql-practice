/* =====================================================================
   Q198 · Selling Periods From Order Dates (Gaps And Islands)
   Category : Date & Time (Gaps and Islands)     Difficulty : Hard
   Concepts : Gaps and islands · LAG · Running SUM as a group id · Date arithmetic · CTE pipeline
   ---------------------------------------------------------------------
   PROBLEM : Group order dates into periods in which consecutive order dates are at most 7 days apart. For each period show its number, start date, end date, orders and revenue (2 dp), in date order.
   APPROACH:
     1. Aggregate to one row per order date (orders, revenue).
     2. Flag a new period when the gap to the previous date (LAG) is over 7 days or there is no previous date.
     3. Running SUM of the flags gives each row its period number; group by it.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH days AS (
    SELECT o.order_date,
           COUNT(DISTINCT o.order_id)                                   AS orders,
           SUM(d.unit_price * d.quantity * (1 - d.discount))::numeric   AS revenue
    FROM orders o
    JOIN order_details d ON d.order_id = o.order_id
    GROUP BY o.order_date
),
flagged AS (
    SELECT *,
           CASE WHEN order_date - LAG(order_date) OVER (ORDER BY order_date) <= 7 THEN 0 ELSE 1 END AS new_period
    FROM days
),
numbered AS (
    SELECT *, SUM(new_period) OVER (ORDER BY order_date) AS period_no
    FROM flagged
)
SELECT period_no,
       MIN(order_date)          AS period_start,
       MAX(order_date)          AS period_end,
       SUM(orders)              AS orders,
       ROUND(SUM(revenue), 2)   AS revenue
FROM numbered
GROUP BY period_no
ORDER BY period_no;

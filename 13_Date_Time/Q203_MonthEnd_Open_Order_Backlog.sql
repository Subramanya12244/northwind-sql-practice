/* =====================================================================
   Q203 · Month-End Open Order Backlog
   Category : Date & Time (Calendar Series and Point-in-Time State)     Difficulty : Hard
   Concepts : GENERATE_SERIES · Month-end dates · Point-in-time join conditions · LEFT JOIN · COALESCE
   ---------------------------------------------------------------------
   PROBLEM : For each month end in 1997, count orders that were open at that date and their average age in days (1 dp, 0 when none), in date order.
   APPROACH:
     1. GENERATE_SERIES over the 12 months, converted to month-end dates.
     2. LEFT JOIN orders where order_date <= month_end AND (shipped_date IS NULL OR shipped_date > month_end).
     3. Count orders and average month_end − order_date per month end.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH month_ends AS (
    SELECT (DATE_TRUNC('month', d) + INTERVAL '1 month - 1 day')::date AS month_end
    FROM GENERATE_SERIES(DATE '1997-01-01', DATE '1997-12-01', INTERVAL '1 month') AS d
)
SELECT me.month_end,
       COUNT(o.order_id) AS open_orders,
       COALESCE(ROUND(AVG(me.month_end - o.order_date), 1), 0) AS avg_age_days
FROM month_ends me
LEFT JOIN orders o
       ON o.order_date <= me.month_end
      AND (o.shipped_date IS NULL OR o.shipped_date > me.month_end)
GROUP BY me.month_end
ORDER BY me.month_end;

/* =====================================================================
   Q208 · Weekly Revenue For Q1 1997 With A Sargable Filter
   Category : Date & Time (Sargable Ranges and Calendar Fill)     Difficulty : Hard
   Concepts : Sargable range predicate · DATE_TRUNC('week') · GENERATE_SERIES · LEFT JOIN · COALESCE · Query optimization
   ---------------------------------------------------------------------
   PROBLEM : Show net revenue (2 dp, 0 for weeks without orders) for every Monday-starting week overlapping Q1 1997, from the week of 1996-12-30 to the week of 1997-03-24.
   APPROACH:
     1. GENERATE_SERIES produces every Monday from 1996-12-30 to 1997-03-24.
     2. A CTE sums revenue per DATE_TRUNC('week', order_date) for orders in [1997-01-01, 1997-04-01).
     3. LEFT JOIN the weeks to the totals and COALESCE missing weeks to 0.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH weeks AS (
    SELECT w::date AS week_start
    FROM GENERATE_SERIES(DATE '1996-12-30', DATE '1997-03-24', INTERVAL '7 days') AS w
),
q1 AS (
    SELECT DATE_TRUNC('week', o.order_date)::date AS week_start,
           SUM(d.unit_price * d.quantity * (1 - d.discount))::numeric AS revenue
    FROM orders o
    JOIN order_details d ON d.order_id = o.order_id
    WHERE o.order_date >= DATE '1997-01-01'
      AND o.order_date <  DATE '1997-04-01'
    GROUP BY 1
)
SELECT w.week_start, COALESCE(ROUND(q1.revenue, 2), 0) AS revenue
FROM weeks w
LEFT JOIN q1 ON q1.week_start = w.week_start
ORDER BY w.week_start;

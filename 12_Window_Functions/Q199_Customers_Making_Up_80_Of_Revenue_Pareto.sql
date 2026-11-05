/* =====================================================================
   Q199 · Customers Making Up 80% Of Revenue (Pareto)
   Category : Window Functions (Cumulative Share)     Difficulty : Hard
   Concepts : SUM() OVER (ORDER BY …) · ROWS frame · SUM() OVER () · Pareto analysis · Tie-breaking
   ---------------------------------------------------------------------
   PROBLEM : List the smallest set of top customers whose combined revenue reaches 80% of all revenue, with each customer's revenue (2 dp) and the cumulative share in percent (1 dp), largest first.
   APPROACH:
     1. CTE: net revenue per customer.
     2. Running SUM ordered by revenue DESC, customer_id with ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW; total with SUM() OVER ().
     3. Keep customers whose running total before them is still under 80% of the total.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH revenue AS (
    SELECT o.customer_id,
           SUM(d.unit_price * d.quantity * (1 - d.discount))::numeric AS rev
    FROM orders o
    JOIN order_details d ON d.order_id = o.order_id
    GROUP BY o.customer_id
),
ranked AS (
    SELECT customer_id, rev,
           SUM(rev) OVER (ORDER BY rev DESC, customer_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running,
           SUM(rev) OVER () AS total
    FROM revenue
)
SELECT customer_id,
       ROUND(rev, 2)                       AS revenue,
       ROUND(100 * running / total, 1)     AS cumulative_pct
FROM ranked
WHERE running - rev < 0.8 * total
ORDER BY rev DESC, customer_id;

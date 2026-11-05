/* =====================================================================
   Q200 · Customer Buying Episodes (Sessionization)
   Category : Window Functions (Sessionization)     Difficulty : Hard
   Concepts : LAG · PARTITION BY · Running SUM of flags · COUNT DISTINCT · Date arithmetic
   ---------------------------------------------------------------------
   PROBLEM : For each customer with at least two orders, count their buying episodes, their orders, and the days between their first and last order; most episodes first.
   APPROACH:
     1. LAG(order_date) per customer gives the gap to their previous order.
     2. Flag 1 when the gap is NULL (first order) or over 60 days; a running SUM per customer numbers the episodes.
     3. Group by customer: COUNT(DISTINCT episode), COUNT(*), MAX − MIN date.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH gaps AS (
    SELECT customer_id, order_id, order_date,
           order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS gap
    FROM orders
    WHERE customer_id IS NOT NULL
),
flagged AS (
    SELECT *, SUM(CASE WHEN gap IS NULL OR gap > 60 THEN 1 ELSE 0 END)
                OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS episode
    FROM gaps
)
SELECT customer_id,
       COUNT(DISTINCT episode)                       AS buying_episodes,
       COUNT(*)                                      AS orders,
       MAX(order_date) - MIN(order_date)             AS span_days
FROM flagged
GROUP BY customer_id
HAVING COUNT(*) >= 2
ORDER BY buying_episodes DESC, orders DESC, customer_id;

/* =====================================================================
   Q98 · Latest Order Per Customer
   Category : Window Functions (Ranking)     Difficulty : Easy
   Concepts : ROW_NUMBER · PARTITION BY · ORDER BY DESC · Top-1 per Group · CTE
   ---------------------------------------------------------------------
   PROBLEM : For every customer who has ordered, return exactly one row describing their latest order (latest order_date; if two orders share a date, the higher order_id wins).
   APPROACH:
     1. Number each customer's orders with ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC, order_id DESC).
     2. Keep only rn = 1 in the outer query (window results cannot be filtered in the same WHERE).
     3. Join customers for the company name and sort by customer_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH ranked_orders AS (
    SELECT
        o.customer_id,
        o.order_id,
        o.order_date,
        o.employee_id,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id
                           ORDER BY o.order_date DESC, o.order_id DESC) AS rn
    FROM orders o
)
SELECT
    r.customer_id,
    c.company_name,
    r.order_id   AS latest_order_id,
    r.order_date AS latest_order_date,
    r.employee_id
FROM ranked_orders r
JOIN customers c ON c.customer_id = r.customer_id
WHERE r.rn = 1
ORDER BY customer_id;

/* =====================================================================
   Q107 · First And Latest Product Per Customer
   Category : Window Functions (Value Functions)     Difficulty : Hard
   Concepts : FIRST_VALUE · LAST_VALUE · Window Frame · ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING · DISTINCT
   ---------------------------------------------------------------------
   PROBLEM : For each customer, return the product on their earliest order line and the product on their latest order line (ordered by order date, then order ID, then product ID).
   APPROACH:
     1. Join orders, order lines and products.
     2. Define a window per customer ordered by order_date, order_id, product_id with frame ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING.
     3. Take FIRST_VALUE(product_name) and LAST_VALUE(product_name).
     4. Collapse to one row per customer with DISTINCT; join customers; order by customer_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH customer_lines AS (
    SELECT
        o.customer_id,
        o.order_date,
        o.order_id,
        p.product_name,
        FIRST_VALUE(p.product_name) OVER w AS first_product,
        LAST_VALUE(p.product_name)  OVER w AS latest_product
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    JOIN products p       ON p.product_id = od.product_id
    WINDOW w AS (PARTITION BY o.customer_id
                 ORDER BY o.order_date, o.order_id, od.product_id
                 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
)
SELECT DISTINCT
    cl.customer_id,
    c.company_name,
    cl.first_product,
    cl.latest_product
FROM customer_lines cl
JOIN customers c ON c.customer_id = cl.customer_id
ORDER BY customer_id;

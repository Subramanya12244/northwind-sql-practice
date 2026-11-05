/* =====================================================================
   Q201 · Each Customer's Favourite Product With LATERAL
   Category : Correlated Subqueries (LATERAL Top-1 per Group)     Difficulty : Hard
   Concepts : CROSS JOIN LATERAL · Correlated subquery in FROM · ORDER BY + LIMIT 1 · Tie-breaking
   ---------------------------------------------------------------------
   PROBLEM : For every customer who has ordered, show the product they bought the most units of (ties broken by product name) and the units, highest first.
   APPROACH:
     1. FROM customers c CROSS JOIN LATERAL (subquery).
     2. The subquery sums units per product for c.customer_id, orders by units DESC, product_name, LIMIT 1.
     3. Order the result by units, then customer_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT c.customer_id, c.company_name, top.product_name, top.units
FROM customers c
CROSS JOIN LATERAL (
    SELECT p.product_name, SUM(d.quantity) AS units
    FROM orders o
    JOIN order_details d ON d.order_id = o.order_id
    JOIN products p ON p.product_id = d.product_id
    WHERE o.customer_id = c.customer_id
    GROUP BY p.product_name
    ORDER BY units DESC, p.product_name
    LIMIT 1
) AS top
ORDER BY top.units DESC, c.customer_id;

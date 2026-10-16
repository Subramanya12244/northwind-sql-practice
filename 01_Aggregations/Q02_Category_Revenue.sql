/* =====================================================================
   Q02 · Category Revenue
   Category : Aggregations & Revenue Analysis     Difficulty : Easy
   Concepts : INNER JOIN (multi-table) · GROUP BY · SUM
   ---------------------------------------------------------------------
   PROBLEM : Total discounted revenue per product category.
   APPROACH:
     1. categories -> products (category_id) -> order_details (product_id).
     2. Compute per-line revenue; SUM() grouped by category.
     3. ROUND to 2 dp; ORDER BY revenue DESC.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    c.category_id,
    c.category_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue
FROM categories c
JOIN products p ON p.category_id = c.category_id
JOIN order_details od ON od.product_id = p.product_id
GROUP BY c.category_id, c.category_name
ORDER BY total_revenue DESC;

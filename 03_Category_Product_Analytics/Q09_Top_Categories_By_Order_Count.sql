/* =====================================================================
   Q09 · Top Categories by Number of Orders
   Category : Category & Product Analytics     Difficulty : Medium
   Concepts : INNER JOIN (multi-table) · GROUP BY · COUNT(DISTINCT) · ORDER BY · LIMIT
   ---------------------------------------------------------------------
   PROBLEM : Find the 5 categories appearing in the highest number of
             distinct orders (category reach/popularity).
   APPROACH:
     1. Join categories -> products -> order_details -> orders.
     2. COUNT(DISTINCT o.order_id) per category.
     3. GROUP BY category.
     4. ORDER BY order_count DESC, LIMIT 5.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    c.category_id,
    c.category_name,
    COUNT(DISTINCT o.order_id) AS order_count
FROM categories c
JOIN products p ON p.category_id = c.category_id
JOIN order_details od ON od.product_id = p.product_id
JOIN orders o ON o.order_id = od.order_id
GROUP BY c.category_id, c.category_name
ORDER BY order_count DESC
LIMIT 5;

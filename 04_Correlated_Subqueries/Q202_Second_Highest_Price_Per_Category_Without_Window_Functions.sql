/* =====================================================================
   Q202 · Second Highest Price Per Category Without Window Functions
   Category : Correlated Subqueries (Nth Value by Counting)     Difficulty : Hard
   Concepts : Correlated subquery · COUNT(DISTINCT) · Nth highest value · Ties
   ---------------------------------------------------------------------
   PROBLEM : For each category, list the product(s) priced at the second-highest distinct price, with the price, by category and product name.
   APPROACH:
     1. For each product, count the distinct prices in its category that are higher than its own.
     2. Keep products where that count is exactly 1.
     3. Join categories for the name and order by category, product.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT c.category_name, p.product_name, p.unit_price
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE 1 = (
    SELECT COUNT(DISTINCT p2.unit_price)
    FROM products p2
    WHERE p2.category_id = p.category_id
      AND p2.unit_price > p.unit_price
)
ORDER BY c.category_name, p.product_name;

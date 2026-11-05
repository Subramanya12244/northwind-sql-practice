/* =====================================================================
   Q192 · Categories With A Wide Price Spread
   Category : GROUP BY & HAVING (Multiple Aggregate Conditions)     Difficulty : Medium
   Concepts : GROUP BY · HAVING · MIN · MAX · AVG · Multiple aggregate conditions
   ---------------------------------------------------------------------
   PROBLEM : List categories that contain at least one product under 10 and at least one product over 40, with the product count, cheapest and dearest price and the average price (2 dp), widest spread first.
   APPROACH:
     1. Join products to categories and group by category.
     2. Keep groups where MIN(unit_price) < 10 AND MAX(unit_price) > 40 (HAVING).
     3. Order by the spread MAX − MIN, descending, then by name.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT c.category_name,
       COUNT(*)                     AS product_count,
       MIN(p.unit_price)            AS min_price,
       MAX(p.unit_price)            AS max_price,
       ROUND(AVG(p.unit_price), 2)  AS avg_price
FROM products p
JOIN categories c ON c.category_id = p.category_id
GROUP BY c.category_name
HAVING MIN(p.unit_price) < 10
   AND MAX(p.unit_price) > 40
ORDER BY MAX(p.unit_price) - MIN(p.unit_price) DESC, c.category_name;

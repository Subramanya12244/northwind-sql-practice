/* =====================================================================
   Q204 · Products Shipped To Germany And The USA But Not France
   Category : Set Operators (INTERSECT and EXCEPT Together)     Difficulty : Hard
   Concepts : INTERSECT · EXCEPT · Operator precedence · IN subquery
   ---------------------------------------------------------------------
   PROBLEM : List products that appear on orders shipped to Germany and on orders shipped to the USA, but never on orders shipped to France, by product id.
   APPROACH:
     1. Three SELECTs of product_id from order lines filtered by ship_country.
     2. Combine: Germany INTERSECT USA EXCEPT France.
     3. Use the combined set in WHERE product_id IN (...).
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT p.product_id, p.product_name
FROM products p
WHERE p.product_id IN (
    SELECT d.product_id FROM order_details d JOIN orders o ON o.order_id = d.order_id WHERE o.ship_country = 'Germany'
    INTERSECT
    SELECT d.product_id FROM order_details d JOIN orders o ON o.order_id = d.order_id WHERE o.ship_country = 'USA'
    EXCEPT
    SELECT d.product_id FROM order_details d JOIN orders o ON o.order_id = d.order_id WHERE o.ship_country = 'France'
)
ORDER BY p.product_id;

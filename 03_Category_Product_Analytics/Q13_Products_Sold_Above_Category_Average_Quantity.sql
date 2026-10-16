/* =====================================================================
   Q13 · Products Sold Above Category Average Quantity
   Category : Category & Product Analytics     Difficulty : Hard
   Concepts : CTE · GROUP BY · SUM/AVG · Window Functions (alt) · Compare-to-peer-group
   ---------------------------------------------------------------------
   PROBLEM : Products whose total quantity sold exceeds the average
             quantity sold within their OWN category (not company-wide).
   APPROACH:
     1. CTE product_qty: SUM(quantity) per product, retain category_id.
     2. CTE category_avg: AVG(total_qty) per category from product_qty.
     3. Join product_qty to category_avg on category_id.
     4. Filter total_qty > avg_qty_in_category.
     5. ORDER BY category_id, total_qty DESC.
     6. (Alt: AVG(SUM(..)) OVER (PARTITION BY category_id) in one pass.)
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
WITH product_qty AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        SUM(od.quantity) AS total_qty
    FROM products p
    JOIN order_details od ON od.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category_id
),
category_avg AS (
    SELECT
        category_id,
        AVG(total_qty) AS avg_qty_in_category
    FROM product_qty
    GROUP BY category_id
)
SELECT
    pq.product_id,
    pq.product_name,
    pq.category_id,
    pq.total_qty,
    ca.avg_qty_in_category
FROM product_qty pq
JOIN category_avg ca ON ca.category_id = pq.category_id
WHERE pq.total_qty > ca.avg_qty_in_category
ORDER BY pq.category_id, pq.total_qty DESC;

-- Equivalent single-pass version using a window function:
-- SELECT *
-- FROM (
--     SELECT
--         p.product_id,
--         p.product_name,
--         p.category_id,
--         SUM(od.quantity) AS total_qty,
--         AVG(SUM(od.quantity)) OVER (PARTITION BY p.category_id) AS avg_qty_in_category
--     FROM products p
--     JOIN order_details od ON od.product_id = p.product_id
--     GROUP BY p.product_id, p.product_name, p.category_id
-- ) sub
-- WHERE total_qty > avg_qty_in_category
-- ORDER BY category_id, total_qty DESC;

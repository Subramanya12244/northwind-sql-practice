/*
Question:
Find products whose total quantity sold exceeds the average quantity sold by products *within the same category* (not the company-wide average).

Business Requirement:
The business wants to find products whose quantity sold is greater than the average quantity sold within their own category, to flag relative over-performers for inventory and reordering prioritization.

Approach:
1. Build a CTE (product_qty) that sums total quantity sold per product, retaining category_id.
2. Build a second CTE (category_avg) that averages total_qty per category, using the first CTE as its source.
3. Join product_qty to category_avg on category_id.
4. Filter to products where total_qty > avg_qty_in_category.
5. Sort by category and then by quantity descending.
6. (Alternative shown: a window function version using AVG(SUM(quantity)) OVER (PARTITION BY category_id) achieves the same result in one pass.)

Expected Output:
| product_id | product_name | category_id | total_qty | avg_qty_in_category |
|------------|--------------|-------------|-----------|---------------------|
| 24 | Guaraná Fantástica | 1 | 858 | 626.4 |
| 75 | Rhönbräu Klosterbier | 1 | 541 | 626.4 |
| 59 | Raclette Courdavault | 4 | 1496 | 672.7 |

Concepts Used:
- CTE
- GROUP BY
- Aggregate Functions (SUM, AVG)
- Window Functions (alternative)
- Self-comparison within group

Complexity:
Hard
*/

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

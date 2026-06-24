/*
Question:
Return only the products that have never appeared in any order, with no aggregation needed — just the filtered list of products themselves.

Business Requirement:
The business wants to identify products that have never appeared in order_details, to support discontinuation, repricing, or catalog cleanup decisions.

Approach:
1. LEFT JOIN products to order_details on product_id, preserving every product regardless of sales history.
2. Filter to rows where od.order_id IS NULL, which identifies products with no matching order line item at all.
3. (Alternative shown: NOT EXISTS, an equally valid and often more efficient approach.)

Expected Output:
| product_id | product_name |
|------------|--------------|
| 9 | Mishi Kobe Niku |
| 17 | Alice Mutton |

Concepts Used:
- LEFT JOIN
- NULL Handling
- WHERE
- NOT EXISTS (alternative)

Complexity:
Easy
*/

SELECT
    p.product_id,
    p.product_name
FROM products p
LEFT JOIN order_details od ON od.product_id = p.product_id
WHERE od.order_id IS NULL;

-- Equivalent alternative using NOT EXISTS:
-- SELECT
--     p.product_id,
--     p.product_name
-- FROM products p
-- WHERE NOT EXISTS (
--     SELECT 1 FROM order_details od WHERE od.product_id = p.product_id
-- );

/*
Question:
Return every product and the total quantity sold across all orders, displaying 0 for products that have never appeared in any order.

Business Requirement:
The business wants total quantity sold per product, with products never ordered explicitly displayed as 0 rather than blank or NULL, to flag dead inventory.

Approach:
1. Start from products and LEFT JOIN to order_details on product_id.
2. Aggregate using SUM(od.quantity), wrapped in COALESCE(..., 0) to convert the NULL result (from products with no matching order_details rows) into a literal 0.
3. Group by product.
4. Sort by total quantity sold descending.

Expected Output:
| product_id | product_name | total_quantity_sold |
|------------|--------------|---------------------|
| 59 | Raclette Courdavault | 1496 |
| 38 | Côte de Blaye | 623 |
| 9 | Mishi Kobe Niku | 0 |

Concepts Used:
- LEFT JOIN
- GROUP BY
- Aggregate Functions (SUM)
- NULL Handling
- COALESCE

Complexity:
Medium
*/

SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(od.quantity), 0) AS total_quantity_sold
FROM products p
LEFT JOIN order_details od ON od.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC;

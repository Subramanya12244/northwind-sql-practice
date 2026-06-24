/*
Question:
Identify the 5 categories that appear in the highest number of distinct orders.

Business Requirement:
The business wants to know which categories are most frequently purchased across distinct orders, to guide merchandising and promotional focus.

Approach:
1. Join categories to products, then to order_details, then to orders.
2. Count distinct order_id values per category using COUNT(DISTINCT o.order_id).
3. Aggregate by category.
4. Sort by order count descending and limit to the top 5.

Expected Output:
| category_id | category_name | order_count |
|-------------|---------------|-------------|
| 1 | Beverages | 186 |
| 4 | Dairy Products | 164 |
| 3 | Confections | 169 |

Concepts Used:
- INNER JOIN (multi-table)
- GROUP BY
- Aggregate Functions (COUNT DISTINCT)
- ORDER BY
- LIMIT

Complexity:
Medium
*/

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

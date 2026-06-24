/*
Question:
Identify the 10 customers who have purchased from the highest number of distinct product categories.

Business Requirement:
The business wants to identify customers with the broadest category purchasing behavior, which can indicate strong cross-category engagement opportunities.

Approach:
1. Join customers to orders, orders to order_details, and order_details to products.
2. Count distinct category_id values per customer using COUNT(DISTINCT p.category_id).
3. Aggregate by customer.
4. Sort by category count descending and limit to the top 10.

Expected Output:
| customer_id | company_name | category_count |
|-------------|--------------|----------------|
| SAVEA | Save-a-lot Markets | 8 |
| ERNSH | Ernst Handel | 8 |
| QUICK | QUICK-Stop | 8 |

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
    cu.customer_id,
    cu.company_name,
    COUNT(DISTINCT p.category_id) AS category_count
FROM customers cu
JOIN orders o ON o.customer_id = cu.customer_id
JOIN order_details od ON od.order_id = o.order_id
JOIN products p ON p.product_id = od.product_id
GROUP BY cu.customer_id, cu.company_name
ORDER BY category_count DESC
LIMIT 10;

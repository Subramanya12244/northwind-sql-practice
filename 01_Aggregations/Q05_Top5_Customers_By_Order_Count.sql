/*
Question:
Identify the 5 customers who placed the highest number of distinct orders.

Business Requirement:
The business wants to identify customers who order most frequently, which can indicate strong engagement or a candidate for bulk/subscription contract offers.

Approach:
1. Join customers to orders on customer_id.
2. Count distinct orders per customer using COUNT(DISTINCT order_id).
3. Aggregate by customer.
4. Sort by order count descending.
5. Limit to the top 5 customers.

Expected Output:
| customer_id | company_name | order_count |
|-------------|--------------|-------------|
| SAVEA | Save-a-lot Markets | 31 |
| ERNSH | Ernst Handel | 30 |
| QUICK | QUICK-Stop | 28 |

Concepts Used:
- INNER JOIN
- GROUP BY
- Aggregate Functions (COUNT)
- ORDER BY
- LIMIT

Complexity:
Easy
*/

SELECT
    cu.customer_id,
    cu.company_name,
    COUNT(DISTINCT o.order_id) AS order_count
FROM customers cu
JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.company_name
ORDER BY order_count DESC
LIMIT 5;

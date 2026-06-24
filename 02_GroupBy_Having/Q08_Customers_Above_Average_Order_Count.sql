/*
Question:
Return all customers whose order count exceeds the average order count computed across all customers.

Business Requirement:
The business wants to find customers whose order count is greater than the average order count, to identify highly engaged, frequently-ordering accounts.

Approach:
1. Build a CTE (customer_orders) that counts orders per customer.
2. Select from that CTE.
3. Filter using a scalar subquery computing AVG(order_count) over the whole CTE.
4. Sort by order count descending.

Expected Output:
| customer_id | company_name | order_count |
|-------------|--------------|-------------|
| SAVEA | Save-a-lot Markets | 31 |
| ERNSH | Ernst Handel | 30 |
| QUICK | QUICK-Stop | 28 |

Concepts Used:
- INNER JOIN
- GROUP BY
- CTE
- Aggregate Functions (COUNT, AVG)
- Subquery

Complexity:
Medium
*/

WITH customer_orders AS (
    SELECT
        cu.customer_id,
        cu.company_name,
        COUNT(o.order_id) AS order_count
    FROM customers cu
    JOIN orders o ON o.customer_id = cu.customer_id
    GROUP BY cu.customer_id, cu.company_name
)
SELECT *
FROM customer_orders
WHERE order_count > (SELECT AVG(order_count) FROM customer_orders)
ORDER BY order_count DESC;

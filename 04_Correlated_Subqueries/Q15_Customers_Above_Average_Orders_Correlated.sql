/*
Question:
Return customers whose order count exceeds the average order count across all customers, computed via a subquery referenced directly inside HAVING.

Business Requirement:
The business wants to find customers whose order count is above the average order count across customers, using a HAVING + subquery approach as an alternative to the CTE-based solution.

Approach:
1. Join customers to orders and count orders per customer.
2. In HAVING, compare that count against a subquery computing AVG(order_count).
3. Since aggregates can't nest directly, that subquery itself wraps a derived table that first computes COUNT(order_id) GROUP BY customer_id.
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
- HAVING
- Subquery (non-correlated)
- Aggregate Functions (COUNT, AVG)

Complexity:
Medium
*/

SELECT
    cu.customer_id,
    cu.company_name,
    COUNT(o.order_id) AS order_count
FROM customers cu
JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.company_name
HAVING COUNT(o.order_id) > (
    SELECT AVG(order_count)
    FROM (
        SELECT COUNT(order_id) AS order_count
        FROM orders
        GROUP BY customer_id
    ) sub
)
ORDER BY order_count DESC;

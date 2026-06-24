/*
Question:
Return all customers whose total revenue is strictly greater than the average total revenue computed across all customers.

Business Requirement:
The business wants to identify customers whose total revenue is greater than the average customer revenue, to differentiate above-average accounts from below-average ones.

Approach:
1. Build a CTE (customer_revenue) that calculates each customer's total discounted revenue.
2. In the outer query, select from that CTE.
3. Filter using a scalar subquery that computes AVG(total_revenue) across the entire CTE.
4. Sort by total revenue descending.

Expected Output:
| customer_id | company_name | total_revenue |
|-------------|--------------|---------------|
| QUICK | QUICK-Stop | 117483.39 |
| ERNSH | Ernst Handel | 104874.98 |
| SAVEA | Save-a-lot Markets | 104361.95 |

Concepts Used:
- INNER JOIN
- GROUP BY
- CTE
- Aggregate Functions (SUM, AVG)
- Subquery

Complexity:
Medium
*/

WITH customer_revenue AS (
    SELECT
        cu.customer_id,
        cu.company_name,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
    FROM customers cu
    JOIN orders o ON o.customer_id = cu.customer_id
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY cu.customer_id, cu.company_name
)
SELECT *
FROM customer_revenue
WHERE total_revenue > (SELECT AVG(total_revenue) FROM customer_revenue)
ORDER BY total_revenue DESC;

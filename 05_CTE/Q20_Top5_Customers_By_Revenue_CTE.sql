/*
Question:
Use a CTE to calculate per-customer revenue, then return the top 5 customers by revenue from that CTE.

Business Requirement:
The business wants the top 5 customers by revenue, expressed via a CTE for clarity and to set up patterns reused in later, more advanced queries.

Approach:
1. Build a CTE (customer_revenue) that aggregates discounted revenue per customer.
2. Select all columns from the CTE.
3. Sort by total revenue descending.
4. Limit to the top 5 rows.

Expected Output:
| customer_id | company_name | total_revenue |
|-------------|--------------|---------------|
| QUICK | QUICK-Stop | 117483.39 |
| ERNSH | Ernst Handel | 104874.98 |
| SAVEA | Save-a-lot Markets | 104361.95 |

Concepts Used:
- CTE
- INNER JOIN
- GROUP BY
- Aggregate Functions (SUM)
- ORDER BY
- LIMIT

Complexity:
Easy
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
ORDER BY total_revenue DESC
LIMIT 5;

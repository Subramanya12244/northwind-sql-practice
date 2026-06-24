/*
Question:
Use a CTE to calculate per-customer revenue, and a second CTE to calculate the overall average, then return customers exceeding that average.

Business Requirement:
The business wants customers whose revenue exceeds the overall average customer revenue, computed using a clean two-CTE structure for readability.

Approach:
1. Build a CTE (customer_revenue) for per-customer discounted revenue.
2. Build a second CTE (overall_avg) that computes a single scalar: the average of total_revenue across the first CTE.
3. In the final SELECT, combine both CTEs (the second produces one row, broadcast across the first) and filter where total_revenue > avg_revenue.
4. Sort by total revenue descending.

Expected Output:
| customer_id | company_name | total_revenue |
|-------------|--------------|---------------|
| QUICK | QUICK-Stop | 117483.39 |
| ERNSH | Ernst Handel | 104874.98 |
| SAVEA | Save-a-lot Markets | 104361.95 |

Concepts Used:
- CTE (multiple)
- INNER JOIN
- GROUP BY
- Aggregate Functions (SUM, AVG)
- Cross Join (implicit, scalar)

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
),
overall_avg AS (
    SELECT AVG(total_revenue) AS avg_revenue
    FROM customer_revenue
)
SELECT cr.*
FROM customer_revenue cr, overall_avg oa
WHERE cr.total_revenue > oa.avg_revenue
ORDER BY cr.total_revenue DESC;

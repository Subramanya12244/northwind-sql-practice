/*
Question:
For each employee, return the customers whose revenue (from orders handled by that employee) exceeds the average revenue of all customers handled by that same employee.

Business Requirement:
For each employee, the business wants to find customers whose revenue is greater than the average revenue of customers handled by that specific employee — enabling employee-level account prioritization.

Approach:
1. Build a CTE (employee_customer_revenue) that aggregates revenue per employee-customer pair.
2. In the outer query, select from that CTE.
3. Filter using a correlated subquery that computes AVG(revenue) for *only the rows matching the current row's employee_id*.
4. Sort by employee and then by revenue descending.

Expected Output:
| employee_id | customer_id | revenue |
|-------------|-------------|---------|
| 4 | QUICK | 28734.90 |
| 4 | SAVEA | 21345.10 |
| 3 | ERNSH | 19872.55 |

Concepts Used:
- CTE
- Correlated Subquery
- GROUP BY
- Aggregate Functions (SUM, AVG)

Complexity:
Hard
*/

WITH employee_customer_revenue AS (
    SELECT
        o.employee_id,
        o.customer_id,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS revenue
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY o.employee_id, o.customer_id
)
SELECT
    ecr.employee_id,
    ecr.customer_id,
    ROUND(ecr.revenue::numeric, 2) AS revenue
FROM employee_customer_revenue ecr
WHERE ecr.revenue > (
    SELECT AVG(ecr2.revenue)
    FROM employee_customer_revenue ecr2
    WHERE ecr2.employee_id = ecr.employee_id   -- correlation
)
ORDER BY ecr.employee_id, ecr.revenue DESC;

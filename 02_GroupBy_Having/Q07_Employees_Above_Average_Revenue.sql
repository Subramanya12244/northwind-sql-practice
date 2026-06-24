/*
Question:
Return all employees whose total revenue exceeds the average total revenue computed across all employees.

Business Requirement:
The business wants to identify employees whose total revenue is greater than the average employee revenue, supporting performance review conversations.

Approach:
1. Build a CTE (employee_revenue) that calculates each employee's total discounted revenue.
2. Select from that CTE in the outer query.
3. Filter using a scalar subquery computing AVG(total_revenue) over the whole CTE.
4. Sort by total revenue descending.

Expected Output:
| employee_id | first_name | last_name | total_revenue |
|-------------|------------|-----------|---------------|
| 4 | Margaret | Peacock | 232890.85 |
| 3 | Janet | Leverling | 202812.84 |
| 1 | Nancy | Davolio | 192107.60 |

Concepts Used:
- INNER JOIN
- GROUP BY
- CTE
- Aggregate Functions (SUM, AVG)
- Subquery

Complexity:
Medium
*/

WITH employee_revenue AS (
    SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
    FROM employees e
    JOIN orders o ON o.employee_id = e.employee_id
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY e.employee_id, e.first_name, e.last_name
)
SELECT *
FROM employee_revenue
WHERE total_revenue > (SELECT AVG(total_revenue) FROM employee_revenue)
ORDER BY total_revenue DESC;

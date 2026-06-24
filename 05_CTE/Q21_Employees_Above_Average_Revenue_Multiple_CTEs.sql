/*
Question:
Calculate employee revenue in one CTE, average revenue in a second CTE, and join them using the comparison itself as the join condition.

Business Requirement:
The business wants employees whose revenue exceeds the average employee revenue, computed using two CTEs joined directly via an inequality condition.

Approach:
1. Build a CTE (employee_revenue) for per-employee discounted revenue.
2. Build a second CTE (avg_revenue) producing the single average revenue value across all employees.
3. Join the two CTEs using ON er.total_revenue > ar.avg_rev as the join condition itself.
4. Sort by total revenue descending.

Expected Output:
| employee_id | first_name | last_name | total_revenue |
|-------------|------------|-----------|---------------|
| 4 | Margaret | Peacock | 232890.85 |
| 3 | Janet | Leverling | 202812.84 |
| 1 | Nancy | Davolio | 192107.60 |

Concepts Used:
- CTE (multiple)
- INNER JOIN (non-equality condition)
- GROUP BY
- Aggregate Functions (SUM, AVG)

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
),
avg_revenue AS (
    SELECT AVG(total_revenue) AS avg_rev
    FROM employee_revenue
)
SELECT er.*
FROM employee_revenue er
JOIN avg_revenue ar ON er.total_revenue > ar.avg_rev
ORDER BY er.total_revenue DESC;

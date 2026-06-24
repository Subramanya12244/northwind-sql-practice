/*
Question:
Find the employee(s) with the single highest total revenue, using a layered three-CTE structure: aggregate, find the maximum, then filter to matches.

Business Requirement:
The business wants to identify the employee(s) with the highest total revenue, correctly handling the case where multiple employees are exactly tied.

Approach:
1. Build a CTE (employee_revenue) aggregating discounted revenue per employee.
2. Build a second CTE (max_revenue) computing the single highest revenue value across all employees.
3. Build a third CTE (ranked_employees) joining the first two on equality (total_revenue = max_rev), which naturally includes every tied employee.
4. Select and round the final result from ranked_employees.

Expected Output:
| employee_id | first_name | last_name | total_revenue |
|-------------|------------|-----------|---------------|
| 4 | Margaret | Peacock | 232890.85 |

Concepts Used:
- CTE (multiple/chained)
- GROUP BY
- Aggregate Functions (SUM, MAX)
- Tie Handling
- INNER JOIN

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
max_revenue AS (
    SELECT MAX(total_revenue) AS max_rev
    FROM employee_revenue
),
ranked_employees AS (
    SELECT er.*
    FROM employee_revenue er
    JOIN max_revenue mr ON er.total_revenue = mr.max_rev
)
SELECT
    employee_id,
    first_name,
    last_name,
    ROUND(total_revenue::numeric, 2) AS total_revenue
FROM ranked_employees;

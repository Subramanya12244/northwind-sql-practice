/*
Question:
Identify how many unique customers each employee has handled orders for, ranked from highest to lowest.

Business Requirement:
The business wants to find employees who have served the highest number of unique customers, as an indicator of relationship breadth and account coverage.

Approach:
1. Join employees to orders on employee_id.
2. Count distinct customer_id values per employee.
3. Aggregate by employee.
4. Sort by unique customer count descending.

Expected Output:
| employee_id | first_name | last_name | unique_customers |
|-------------|------------|-----------|------------------|
| 4 | Margaret | Peacock | 44 |
| 3 | Janet | Leverling | 40 |
| 1 | Nancy | Davolio | 38 |

Concepts Used:
- INNER JOIN
- GROUP BY
- Aggregate Functions (COUNT DISTINCT)
- ORDER BY

Complexity:
Easy
*/

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM employees e
JOIN orders o ON o.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY unique_customers DESC;

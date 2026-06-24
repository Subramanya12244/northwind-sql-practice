/*
Question:
Return employees whose total revenue exceeds the average revenue across all employees, using a HAVING clause referencing a subquery.

Business Requirement:
The business wants to find employees whose revenue is above the average employee revenue, solved here via HAVING + subquery.

Approach:
1. Join employees, orders, and order_details; aggregate discounted revenue per employee.
2. In HAVING, compare that total against a subquery that recomputes revenue per employee and averages it.
3. Sort by total revenue descending.

Expected Output:
| employee_id | first_name | last_name | total_revenue |
|-------------|------------|-----------|---------------|
| 4 | Margaret | Peacock | 232890.85 |
| 3 | Janet | Leverling | 202812.84 |
| 1 | Nancy | Davolio | 192107.60 |

Concepts Used:
- INNER JOIN (multi-table)
- GROUP BY
- HAVING
- Subquery (non-correlated)
- Aggregate Functions (SUM, AVG)

Complexity:
Medium
*/

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
FROM employees e
JOIN orders o ON o.employee_id = e.employee_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING SUM(od.unit_price * od.quantity * (1 - od.discount)) > (
    SELECT AVG(rev)
    FROM (
        SELECT SUM(od2.unit_price * od2.quantity * (1 - od2.discount)) AS rev
        FROM orders o2
        JOIN order_details od2 ON od2.order_id = o2.order_id
        GROUP BY o2.employee_id
    ) sub
)
ORDER BY total_revenue DESC;

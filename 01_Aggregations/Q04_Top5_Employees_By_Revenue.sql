/*
Question:
Identify the 5 employees who generated the highest total discounted revenue across all orders they processed.

Business Requirement:
The business wants to identify top-performing employees by revenue generated, to support performance evaluation and incentive decisions.

Approach:
1. Join employees to orders on employee_id, then to order_details on order_id.
2. Calculate discounted revenue per line item.
3. Aggregate revenue at the employee level.
4. Sort by total revenue descending.
5. Limit results to the top 5 employees.

Expected Output:
| employee_id | first_name | last_name | total_revenue |
|-------------|------------|-----------|---------------|
| 4 | Margaret | Peacock | 232890.85 |
| 3 | Janet | Leverling | 202812.84 |
| 1 | Nancy | Davolio | 192107.60 |

Concepts Used:
- INNER JOIN (multi-table)
- GROUP BY
- Aggregate Functions (SUM)
- ORDER BY
- LIMIT

Complexity:
Easy
*/

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue
FROM employees e
JOIN orders o ON o.employee_id = e.employee_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_revenue DESC
LIMIT 5;

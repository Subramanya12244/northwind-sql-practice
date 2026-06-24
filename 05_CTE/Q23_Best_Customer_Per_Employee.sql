/*
Question:
For every employee, return the customer (or customers, if tied) generating the highest revenue from orders that employee handled.

Business Requirement:
For every employee, the business wants to find the customer generating the highest revenue from orders that employee handled, correctly surfacing ties.

Approach:
1. Build a CTE (employee_customer_revenue) aggregating revenue per employee-customer pair.
2. Build a second CTE (ranked) applying RANK() OVER (PARTITION BY employee_id ORDER BY total_revenue DESC).
3. Filter to rnk = 1, returning every customer tied for the top spot per employee.
4. Join in employees and customers for display-friendly names.
5. Sort by employee.

Expected Output:
| employee_id | first_name | last_name | customer_id | company_name | total_revenue |
|-------------|------------|-----------|-------------|--------------|---------------|
| 1 | Nancy | Davolio | SAVEA | Save-a-lot Markets | 15234.40 |
| 2 | Andrew | Fuller | ERNSH | Ernst Handel | 12873.10 |
| 3 | Janet | Leverling | QUICK | QUICK-Stop | 19872.55 |

Concepts Used:
- CTE
- Window Functions (RANK)
- PARTITION BY
- GROUP BY
- Aggregate Functions (SUM)
- Tie Handling
- INNER JOIN

Complexity:
Hard
*/

WITH employee_customer_revenue AS (
    SELECT
        o.employee_id,
        o.customer_id,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY o.employee_id, o.customer_id
),
ranked AS (
    SELECT
        ecr.*,
        RANK() OVER (PARTITION BY employee_id ORDER BY total_revenue DESC) AS rnk
    FROM employee_customer_revenue ecr
)
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    r.customer_id,
    cu.company_name,
    ROUND(r.total_revenue::numeric, 2) AS total_revenue
FROM ranked r
JOIN employees e ON e.employee_id = r.employee_id
JOIN customers cu ON cu.customer_id = r.customer_id
WHERE r.rnk = 1
ORDER BY e.employee_id;

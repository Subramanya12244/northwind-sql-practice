/*
Question:
Return all employees along with the total number of orders they have
handled, including employees with no orders displayed as 0.
Use RIGHT JOIN only.

Business Requirement:
The HR team wants a complete employee order count report — every employee
must appear, and those with no order history should show 0 rather than
being excluded.

Approach:
1. Place orders on the LEFT and employees on the RIGHT.
2. RIGHT JOIN preserves every row from employees (the right table)
   regardless of whether matching orders exist.
3. COUNT(DISTINCT o.order_id) counts unique orders per employee.
   DISTINCT is used defensively — it returns the same result as
   COUNT(o.order_id) in this query, but protects against inflated
   counts if order_details is ever joined in later.
   COUNT returns 0 for empty groups — COALESCE is not required.
4. GROUP BY e.employee_id, e.first_name, e.last_name — employee_id
   is the unique key; name columns are included because they are
   standalone non-aggregated items in the SELECT list.
   Alternative: GROUP BY e.employee_id only, using CONCAT() in SELECT.

LEFT JOIN equivalent (same result):
   SELECT CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
          COUNT(DISTINCT o.order_id) AS total_orders
   FROM employees e
   LEFT JOIN orders o ON o.employee_id = e.employee_id
   GROUP BY e.employee_id, e.first_name, e.last_name;

Expected Output:
| employee_name    | total_orders |
|------------------|--------------|
| Margaret Peacock | 156          |
| Nancy Davolio    | 123          |
| Andrew Fuller    | 0            |

Concepts Used:
- RIGHT JOIN
- GROUP BY
- Aggregate Functions (COUNT DISTINCT)
- String Concatenation (CONCAT)
- NULL Handling

Complexity:
Medium
*/

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
RIGHT JOIN employees e
    ON e.employee_id = o.employee_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name;

/*
Question:
Return all orders along with the corresponding employee name, preserving
every order even if it has no matching employee record.

Business Requirement:
The HR team wants a complete order-to-employee mapping report. Orders
with no matching employee (e.g. assigned to a deleted employee record)
must still appear with NULL for the employee name rather than being
silently dropped.

Approach:
1. Place employees on the LEFT and orders on the RIGHT.
2. RIGHT JOIN preserves every row from orders (the right table)
   regardless of whether a matching employee exists.
3. For unmatched orders, all employee columns are filled with NULL —
   CONCAT(NULL, ' ', NULL) returns a space via CONCAT() in PostgreSQL;
   use NULLIF(CONCAT(...), ' ') if a clean NULL is preferred.
4. Equivalent LEFT JOIN version (same result):
   SELECT o.order_id,
          CONCAT(e.first_name, ' ', e.last_name) AS employee_name
   FROM orders o
   LEFT JOIN employees e ON o.employee_id = e.employee_id;

Expected Output:
| order_id | employee_name   |
|----------|-----------------|
| 10248    | Nancy Davolio   |
| 10249    | Andrew Fuller   |
| 10250    | NULL            |

Concepts Used:
- RIGHT JOIN
- NULL Handling
- String Concatenation (CONCAT)

Complexity:
Easy
*/

SELECT
    o.order_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name
FROM employees e
RIGHT JOIN orders o
    ON o.employee_id = e.employee_id;

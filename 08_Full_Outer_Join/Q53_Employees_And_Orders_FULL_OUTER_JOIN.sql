/*
Question:
Return the employee name and order ID for every employee and every
order — no employee and no order should be excluded.

Business Requirement:
Generate a complete employee-order reconciliation report covering:
1. Employees who have handled orders (both sides populated)
2. Employees who have never handled an order (order_id = NULL)
3. Orders not assigned to any employee (employee_name = NULL)

Why FULL OUTER JOIN:
- LEFT JOIN orders → employees: drops unhandled employees (type 2)
- RIGHT JOIN orders → employees: drops unassigned orders (type 3)
- FULL OUTER JOIN: preserves all rows from both tables simultaneously

Note on table order:
Unlike LEFT/RIGHT JOIN, table order in FULL OUTER JOIN does not
determine which side is preserved — both are always preserved.
FROM orders FULL OUTER JOIN employees produces the same result as
FROM employees FULL OUTER JOIN orders.

Note on CONCAT with NULL:
CONCAT(NULL, ' ', NULL) returns ' ' (a space) in PostgreSQL, not NULL.
Use NULLIF(CONCAT(e.first_name, ' ', e.last_name), ' ') if a clean
NULL value is required for unmatched employee rows.

Expected Output:
| employee_name   | order_id |
|-----------------|----------|
| Nancy Davolio   | 10248    |
| Andrew Fuller   | 10249    |
| Steven Buchanan | NULL     |
| NULL            | 11080    |

Concepts Used:
- FULL OUTER JOIN
- NULL Handling
- String Concatenation (CONCAT)

Complexity:
Medium
*/

select concat(e.first_name,' ',e.last_name) as employee_name,
o.order_id
from orders o
full outer join employees e on e.employee_id = o.employee_id;

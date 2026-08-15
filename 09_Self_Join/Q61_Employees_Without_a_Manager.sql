/*
Question:
Return the full name of every employee who has no manager assigned (i.e. their `reports_to` column is NULL).

Business Requirement:
Retrieve employees who do not report to any manager.

Approach:
See markdown file for full reasoning. Key points:
- *

Expected Output:
| employee_name |
|---------------|
| Andrew Fuller |

Concepts Used:
- SELF JOIN
- LEFT JOIN
- NULL Handling (anti-join pattern)

Score: 10/10
Takeaway: To find rows with no matching record after a LEFT JOIN: `WHERE joined_table.primary_key IS NULL`

Complexity:
Easy
*/

select concat(e.first_name,' ',e.last_name) as employee_name
from employees e
left join employees m
on e.reports_to = m.employee_id
where e.reports_to is NULL;

-- Better interview version (filter on joined table's PK — more general anti-join):
SELECT
    CONCAT(e.first_name,' ',e.last_name) AS employee_name
FROM employees e
LEFT JOIN employees m
    ON e.reports_to = m.employee_id
WHERE m.employee_id IS NULL;

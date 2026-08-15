/*
Question:
Return the full name of every employee who appears in at least one other employee's `reports_to` field.

Business Requirement:
Retrieve all employees who manage at least one other employee.

Approach:
See markdown file for full reasoning. Key points:



-- Attempt 1 — Correct but with imprecise COUNT:
-- Reason it fails: Correct result, but `COUNT(e.reports_to)` is imprecise. Prefer `COUNT(e.employee_id)` — you're counting employees, not the FK column.
--
-- 
select-- concat(m.first_name,' ',m.last_name) as employee_name-- from employees e-- left join employees m-- on e.reports_to = m.employee_id-- group by m.first_name, m.last_name-- having count(e.reports_to) > 0;

Expected Output:
| employee_name |
|---------------|
| Andrew Fuller |
| Nancy Davolio |

Concepts Used:
- SELF JOIN
- LEFT JOIN
- GROUP BY
- HAVING
- Aggregate Functions (COUNT)
- DISTINCT (alternative)

Score: 10/10
Takeaway: Three valid approaches: GROUP BY + HAVING, DISTINCT, EXISTS. GROUP BY + HAVING is preferred in interviews for demonstrating aggregation skills.

Complexity:
Medium
*/

SELECT
    CONCAT(m.first_name,' ',m.last_name) AS employee_name
FROM employees e
LEFT JOIN employees m
    ON e.reports_to = m.employee_id
GROUP BY
    m.first_name,
    m.last_name
HAVING COUNT(e.employee_id) > 0;

-- Alternative (concise, equally correct):
SELECT DISTINCT
    CONCAT(m.first_name,' ',m.last_name) AS employee_name
FROM employees e
JOIN employees m
    ON e.reports_to = m.employee_id;

/*
Question:
Return every unique, non-duplicate pair of employees who share the same `reports_to` value, along with their manager's name. Do not return an employee paired with themselves, and do not return duplicate pairs (A,B and B,A).

Business Requirement:
Retrieve pairs of employees who report to the same manager.

Approach:
See markdown file for full reasoning. Key points:



-- Attempt 1 — Manager shown as employee 1 (wrong column in SELECT):
-- Reason it fails: e1 is an employee, not the manager. A third alias `m` is needed joined on `m.employee_id = e1.reports_to`.
--
-- 
select concat(e1.first_name,' ',e1.last_name) as employee_name1,-- concat(e2.first_name,' ',e2.last_name) as employee_name2,-- concat(e1.first_name,' ',e1.last_name) as manager_name-- from employees e1-- join employees e2-- on e1.reports_to = e2.reports_to-- and e1.employee_id < e2.employee_id

-- Attempt 2 — Manager joined on wrong column:
-- Reason it fails: `m.employee_id = e1.employee_id` makes manager = employee 1. Correct: `m.employee_id = e1.reports_to`.
--
-- 
select concat(e1.first_name,' ',e1.last_name) as employee_name1,-- concat(e2.first_name,' ',e2.last_name) as employee_name2,-- concat(m.first_name,' ',m.last_name) as manager_name-- from employees e1-- join employees e2-- on e1.reports_to = e2.reports_to-- join employees m-- on m.employee_id = e1.employee_id-- and e1.employee_id < e2.employee_id

Expected Output:
| employee_name1 | employee_name2 | manager_name |
|----------------|----------------|--------------|
| Nancy Davolio | Janet Leverling | Andrew Fuller |
| Nancy Davolio | Margaret Peacock | Andrew Fuller |

Concepts Used:
- SELF JOIN (triple alias)
- INNER JOIN
- Duplicate pair elimination (id < id)

Score: 10/10
Takeaway: When 3 logical roles come from the same table, use 3 aliases. Always join the manager alias on `m.employee_id = e1.reports_to` — not `e1.employee_id`.

Complexity:
Medium
*/

select concat(e1.first_name,' ',e1.last_name) as employee_name1,
concat(e2.first_name,' ',e2.last_name) as employee_name2,
concat(m.first_name,' ',m.last_name) as manager_name
from employees e1
join employees e2
on e1.reports_to = e2.reports_to
join employees m
on m.employee_id = e1.reports_to
where e1.employee_id < e2.employee_id;

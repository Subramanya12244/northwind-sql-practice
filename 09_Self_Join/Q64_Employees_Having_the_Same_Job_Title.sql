/*
Question:
Return every unique pair of employees who share the same `title` value, along with that shared title. Exclude self-pairs and duplicate pairs.

Business Requirement:
Retrieve pairs of employees having the same job title.

Approach:
See markdown file for full reasoning. Key points:



-- Attempt 1 — Unnecessary third join on employees:
-- Reason it fails: The third join fetches `j.title`, but `e1.title` is already identical to `e2.title` via the join condition. Completely redundant.
--
-- 
select concat(e1.first_name,' ',e1.last_name) as employee_name1,-- concat(e2.first_name,' ',e2.last_name) as employee_name2,-- j.title-- from-- employees e1-- join employees e2-- on e1.employee_id < e2.employee_id-- and e1.title = e2.title-- join employees j-- on e1.employee_id = j.employee_id

Expected Output:
| employee_name1 | employee_name2 | title |
|----------------|----------------|-------|
| Nancy Davolio | Janet Leverling | Sales Representative |
| Nancy Davolio | Margaret Peacock | Sales Representative |

Concepts Used:
- SELF JOIN
- INNER JOIN
- Duplicate pair elimination (id < id)

Score: 9.5/10
Takeaway: Only join another table if you actually need data that isn't already available from existing aliases.

Complexity:
Easy
*/

SELECT
    CONCAT(e1.first_name,' ',e1.last_name) AS employee_name1,
    CONCAT(e2.first_name,' ',e2.last_name) AS employee_name2,
    e1.title
FROM employees e1
JOIN employees e2
    ON e1.employee_id < e2.employee_id
    AND e1.title = e2.title;

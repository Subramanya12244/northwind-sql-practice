/*
Question:
Return every unique pair of employees who share the same hire year, along with that year. Exclude self-pairs and duplicate pairs.

Business Requirement:
Retrieve employee pairs hired in the same year.

Approach:
See markdown file for full reasoning. Key points:


Expected Output:
| employee_name1 | employee_name2 | hire_year |
|----------------|----------------|-----------|
| Nancy Davolio | Janet Leverling | 1992 |
| Andrew Fuller | Margaret Peacock | 1992 |

Concepts Used:
- SELF JOIN
- INNER JOIN
- Date Functions (EXTRACT)
- Duplicate pair elimination (id < id)

Score: 10/10
Takeaway: When comparing dates at year granularity in PostgreSQL: `EXTRACT(YEAR FROM date_column)`.

Complexity:
Easy
*/

select concat(e1.first_name,' ',e1.last_name) as employee_name1,
concat(e2.first_name,' ',e2.last_name) as employee_name2,
EXTRACT(YEAR FROM e1.hire_date) AS hire_year
from employees e1
join employees e2
on e1.employee_id < e2.employee_id
and EXTRACT(YEAR FROM e1.hire_date) = EXTRACT(YEAR FROM e2.hire_date);

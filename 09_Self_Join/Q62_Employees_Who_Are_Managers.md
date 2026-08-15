# Q62. Employees Who Are Managers

**Category:** SELF JOIN
**Difficulty:** Medium

---

## Problem Statement

Retrieve all employees who manage at least one other employee.

## Objective

Return the full name of every employee who appears in at least one other employee's `reports_to` field.

## Tables Used

- `employees (aliased twice: e = employee being managed, m = the manager)`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| employee_name | Full name of the employee who is a manager |

**Sample output:**

| employee_name |
|---------------|
| Andrew Fuller |
| Nancy Davolio |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## Concepts Used

- SELF JOIN
- LEFT JOIN
- GROUP BY
- HAVING
- Aggregate Functions (COUNT)
- DISTINCT (alternative)

## Why This Approach

**Why SELF JOIN:** to find employees who are managers, we need to know which employee IDs appear in another employee's `reports_to` column. Joining `employees e` (the managed employees) to `employees m` (the managers) on `e.reports_to = m.employee_id` creates one row for every manager-employee relationship. Grouping on the manager and counting subordinates then identifies who has at least one report.

**Why `LEFT JOIN` with `HAVING COUNT > 0` instead of `INNER JOIN`:** with `INNER JOIN`, only managers who have matching subordinates appear — which is already the right set. The `LEFT JOIN` version with `HAVING COUNT(e.employee_id) > 0` produces the same result but makes the filtering explicit and testable. The `DISTINCT` alternative (`INNER JOIN + SELECT DISTINCT`) is more concise and equally correct.

**Why `COUNT(e.employee_id)` not `COUNT(e.reports_to)`:** `e.employee_id` is the unique identifier of the subordinate employee — counting it gives the correct number of direct reports per manager. `e.reports_to` contains the manager's ID (not a unique per-subordinate value), and while it produces the same count here, `COUNT(e.employee_id)` is semantically clearer — you're counting employees, not the reference column.

### ❌ Attempt 1 — Correct but with imprecise COUNT:

```sql
select
concat(m.first_name,' ',m.last_name) as employee_name
from employees e
left join employees m
on e.reports_to = m.employee_id
group by m.first_name, m.last_name
having count(e.reports_to) > 0;
```

**Why it fails:** Correct result, but `COUNT(e.reports_to)` is imprecise. Prefer `COUNT(e.employee_id)` — you're counting employees, not the FK column.


**Improved version:**

```sql
-- Alternative (concise, equally correct):
SELECT DISTINCT
    CONCAT(m.first_name,' ',m.last_name) AS employee_name
FROM employees e
JOIN employees m
    ON e.reports_to = m.employee_id;
```

## Common Mistakes

- `HAVING COUNT(e.reports_to) > 0` works but is semantically imprecise — count the employee being managed (`e.employee_id`), not the FK reference column (`e.reports_to`).
- Not grouping by `m.employee_id` alongside the name columns — risks merging two managers with identical names.
- Selecting from the wrong alias — selecting `e.*` (the subordinate) rather than `m.*` (the manager) when the goal is to show manager names.

## Difficulty

**Medium**

## Interview Follow-up Questions

**1. What are the three valid approaches to solve this, and which would you use in an interview?**

Approach 1 — GROUP BY + HAVING: `SELECT CONCAT(m.first_name,' ',m.last_name) FROM employees e LEFT JOIN employees m ON e.reports_to = m.employee_id GROUP BY m.employee_id, m.first_name, m.last_name HAVING COUNT(e.employee_id) > 0`. Approach 2 — DISTINCT with INNER JOIN: `SELECT DISTINCT CONCAT(m.first_name,' ',m.last_name) FROM employees e JOIN employees m ON e.reports_to = m.employee_id`. Approach 3 — EXISTS: `SELECT CONCAT(first_name,' ',last_name) FROM employees m WHERE EXISTS (SELECT 1 FROM employees e WHERE e.reports_to = m.employee_id)`. In an interview, GROUP BY + HAVING is preferred because it demonstrates aggregation skills and is extensible (easily add `COUNT(e.employee_id) AS direct_reports`).

**2. Why might `COUNT(e.employee_id)` be preferred over `COUNT(e.reports_to)`?**

`COUNT(e.employee_id)` counts the number of subordinate employee records — semantically 'how many employees report to this manager.' `COUNT(e.reports_to)` counts non-NULL values of the FK column, which happens to produce the same number here. But `e.employee_id` is the more precise column to count because it directly represents the entity being counted (the subordinate). In a code review, `COUNT(e.employee_id)` communicates intent more clearly.

**3. How would you extend this to show each manager alongside their count of direct reports?**

Add `COUNT(e.employee_id) AS direct_reports` to the SELECT list — the GROUP BY is already in place: `SELECT CONCAT(m.first_name,' ',m.last_name) AS manager_name, COUNT(e.employee_id) AS direct_reports FROM employees e JOIN employees m ON e.reports_to = m.employee_id GROUP BY m.employee_id, m.first_name, m.last_name ORDER BY direct_reports DESC`.

**4. How does the EXISTS approach differ from the DISTINCT approach in terms of performance?**

`EXISTS` uses a correlated subquery that stops scanning as soon as one matching row is found — it is short-circuit evaluating and can be very efficient when the index on `reports_to` is present. `DISTINCT` requires the database to process all join rows and then deduplicate. For a small table like `employees`, the difference is negligible, but `EXISTS` scales better for large tables where a manager has thousands of reports.

## Learning Outcomes

- Know three valid approaches to 'find entities with at least one related record' — GROUP BY + HAVING, DISTINCT, and EXISTS.
- Understand why `COUNT(e.employee_id)` is more semantically precise than `COUNT(e.reports_to)` when counting subordinates.
- Recognise that GROUP BY + HAVING is the interview-preferred approach because it's extensible and demonstrates aggregation fluency.

---

**Score from review session: 10/10**

**Interview Takeaway:** Three valid approaches: GROUP BY + HAVING, DISTINCT, EXISTS. GROUP BY + HAVING is preferred in interviews for demonstrating aggregation skills.

📄 **SQL File:** [`Q62_Employees_Who_Are_Managers.sql`](./Q62_Employees_Who_Are_Managers.sql)

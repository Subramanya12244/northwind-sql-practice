# Q197 · Employee Reporting Chain With A Recursive CTE

> **Revision Card**
> **Category:** Common Table Expressions (Recursive Hierarchy) | **Difficulty:** Hard
> **Concepts:** WITH RECURSIVE · Anchor + recursive member · UNION ALL · Depth · Path building
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** The anchor selects the top of the tree (reports_to IS NULL); the recursive part joins children to rows already found.

## 1. Problem

HR wants the full reporting chain for every employee, from the top manager down, to build an org chart.

**Objective:** Return every employee with their depth below the top manager (0 for the top) and the full path of names from the top, sorted so each manager is followed by their team.

**Tables:** `employees`

**Expected output:**

| Column | Description |
|--------|-------------|
| employee_id | Employee |
| first_name | First name |
| last_name | Last name |
| depth | Levels below the top manager |
| path | Names from the top manager down to this employee |

| employee_id | first_name | last_name | depth | path |
|-------------|------------|-----------|-------|------|
| 2 | Andrew | Fuller | 0 | Andrew Fuller |
| 3 | Janet | Leverling | 1 | Andrew Fuller > Janet Leverling |
| 8 | Laura | Callahan | 1 | Andrew Fuller > Laura Callahan |
| 4 | Margaret | Peacock | 1 | Andrew Fuller > Margaret Peacock |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Anchor: employees with no manager, depth 0, path = their name.
2. Recursive member: join employees to the previous level on reports_to, depth + 1, path || ' > ' || name.
3. Order by path so the tree reads top-down.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH RECURSIVE chain AS (
    SELECT employee_id, first_name, last_name, reports_to,
           0 AS depth,
           (first_name || ' ' || last_name)::text AS path
    FROM employees
    WHERE reports_to IS NULL
    UNION ALL
    SELECT e.employee_id, e.first_name, e.last_name, e.reports_to,
           ch.depth + 1,
           ch.path || ' > ' || e.first_name || ' ' || e.last_name
    FROM employees e
    JOIN chain ch ON e.reports_to = ch.employee_id
)
SELECT employee_id, first_name, last_name, depth, path
FROM chain
ORDER BY path;
```

## 6. Why This Works

A self-join only reaches one level. WITH RECURSIVE repeats the second SELECT, each time joining employees whose manager was found in the previous step, until no new rows appear. Carrying depth and path along each step records how each employee was reached. Sorting by the path string keeps every subtree under its manager.

## 7. Common Pitfalls (generic)

- Using UNION instead of UNION ALL, which adds duplicate checks and can hide cycle bugs.
- Forgetting to cast the anchor path to text, which can make the recursive column type not match.
- No anchor condition: starting from every employee multiplies the rows instead of building one tree.

## 8. Interview Follow-ups

**1. How would you protect against a cycle in reports_to?**

Track visited ids in an array (ARRAY[employee_id]) and stop when the next id is already in it; PostgreSQL 14+ also has the CYCLE clause.

**2. How would you list everyone under one manager?**

Use that manager as the anchor instead of reports_to IS NULL.

**3. How do you get each manager's total team size?**

Run the recursion from every employee as its own root, then COUNT(*) - 1 per root.

## 9. Key Takeaway

WITH RECURSIVE walks a hierarchy: anchor at the root, then repeatedly join children to the rows found so far.

---
📄 **SQL File:** [`Q197_Employee_Reporting_Chain_With_A_Recursive_CTE.sql`](./Q197_Employee_Reporting_Chain_With_A_Recursive_CTE.sql)

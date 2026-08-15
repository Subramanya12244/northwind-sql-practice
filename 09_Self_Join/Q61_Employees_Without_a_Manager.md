# Q61. Employees Without a Manager

**Category:** SELF JOIN
**Difficulty:** Easy

---

## Problem Statement

Retrieve employees who do not report to any manager.

## Objective

Return the full name of every employee who has no manager assigned (i.e. their `reports_to` column is NULL).

## Tables Used

- `employees (aliased twice: e = employee, m = manager)`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| employee_name | Full name of the employee with no manager |

**Sample output:**

| employee_name |
|---------------|
| Andrew Fuller |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## Concepts Used

- SELF JOIN
- LEFT JOIN
- NULL Handling (anti-join pattern)

## Why This Approach

**Why SELF JOIN:** the `employees` table stores both employees and their managers. The `reports_to` column references `employee_id` in the same table. To find employees with no manager, we join `employees` to itself — `e` is the employee, `m` is the manager record they report to — and then filter for rows where no manager match was found.

**Why `LEFT JOIN` and not `INNER JOIN`:** an `INNER JOIN` would only return employees who have a matching manager row — exactly the employees we want to exclude. `LEFT JOIN` preserves every employee row, placing NULL in all `m.*` columns when no manager match exists. Filtering for NULL then isolates the employees with no manager.

**Why `WHERE m.employee_id IS NULL` is preferred over `WHERE e.reports_to IS NULL`:**
Both produce the same result in this dataset — if `e.reports_to` is NULL, there will be no matching manager row, so `m.employee_id` will also be NULL. However, `WHERE m.employee_id IS NULL` (filtering on the joined table's primary key) is the more general and robust anti-join pattern. It catches not just the case where `reports_to` is NULL, but also the case where `reports_to` has a value that doesn't match any existing `employee_id` — an orphaned reference. `WHERE e.reports_to IS NULL` would miss that second scenario.

**Improved version:**

```sql
-- Better interview version (filter on joined table's PK — more general anti-join):
SELECT
    CONCAT(e.first_name,' ',e.last_name) AS employee_name
FROM employees e
LEFT JOIN employees m
    ON e.reports_to = m.employee_id
WHERE m.employee_id IS NULL;
```

## Common Mistakes

- Using `INNER JOIN` — only returns employees who have managers, which is the opposite of the requirement.
- Filtering on `WHERE e.reports_to IS NULL` instead of `WHERE m.employee_id IS NULL` — works for this dataset but misses orphaned `reports_to` references where the manager ID doesn't exist.
- Aliasing the table incorrectly — `e` must be the employee side, `m` must be the manager side.

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. Why is this called a SELF JOIN even though we only have one table?**

A SELF JOIN joins a table to itself by giving it two different aliases. Here `employees e` and `employees m` both refer to the same physical table, but are treated as two logically separate tables in the query — one representing the employee, one representing their manager. The database engine processes them as if they were two distinct tables connected by the join condition.

**2. What is the difference between filtering on `WHERE e.reports_to IS NULL` vs `WHERE m.employee_id IS NULL`?**

`WHERE e.reports_to IS NULL` checks whether the employee was assigned a manager reference at all. `WHERE m.employee_id IS NULL` checks whether the `LEFT JOIN` found a matching manager row. The second is more robust — it also catches cases where `reports_to` has a value but that value doesn't match any employee ID in the table (an orphaned reference). In a well-constrained database both are equivalent, but `WHERE m.employee_id IS NULL` is the correct general anti-join pattern.

**3. How would you find the employee at the very top of the hierarchy — the one with no manager — in a company with multiple management levels?**

The same query works regardless of hierarchy depth. The top-level employee simply has `reports_to = NULL` (or no matching manager row), so they appear in this result. If you wanted to also show their level in the hierarchy, a recursive CTE (`WITH RECURSIVE`) would be the appropriate tool.

**4. How would you adapt this to find products with no supplier, or orders with no customer, using the same pattern?**

The anti-join pattern is the same: `LEFT JOIN <lookup_table> ON <fk> = <pk> WHERE <lookup_table>.<pk> IS NULL`. For products: `FROM products p LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id WHERE s.supplier_id IS NULL`. The SELF JOIN aspect is specific to this question because both entities live in the same table — for other anti-join scenarios, the tables are different.

## Learning Outcomes

- Understand the SELF JOIN concept — one table given two aliases to represent two logical roles (employee and manager).
- Master the `LEFT JOIN + WHERE joined_table.primary_key IS NULL` anti-join pattern for finding unmatched rows.
- Know why filtering on the joined table's PK is more robust than filtering on the FK column in the original table.

---

**Score from review session: 10/10**

**Interview Takeaway:** To find rows with no matching record after a LEFT JOIN: `WHERE joined_table.primary_key IS NULL`

📄 **SQL File:** [`Q61_Employees_Without_a_Manager.sql`](./Q61_Employees_Without_a_Manager.sql)

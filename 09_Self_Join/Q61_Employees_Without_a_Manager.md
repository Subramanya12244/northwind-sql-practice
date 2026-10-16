# Q61 · Employees Without a Manager

> **Revision Card**
> **Category:** Self Join | **Difficulty:** Easy
> **Concepts:** SELF JOIN · LEFT JOIN · NULL handling (anti-join)
> **Outcome:** ✅ correct first attempt
> **Watch out for:** filtering `WHERE m.employee_id IS NULL` (joined table's PK) is the robust anti-join — it also catches orphaned `reports_to` references that `WHERE e.reports_to IS NULL` misses.

## 1. Problem

Retrieve employees who do not report to any manager.

**Objective:** Return the full name of every employee who has no manager assigned (i.e. their `reports_to` column is NULL).

**Tables:** `employees` (aliased twice: `e` = employee, `m` = manager)

**Expected output:**

| Column | Description |
|---|---|
| employee_name | Full name of the employee with no manager |

| employee_name |
|---------------|
| Andrew Fuller |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## 2. My Approach

1. Recognise that `employees` holds both employees and managers, with `reports_to` referencing `employee_id` in the same table.
2. `LEFT JOIN employees` to itself: `e` is the employee, `m` is the manager they report to.
3. Keep every employee row (LEFT JOIN) so non-matches surface as NULL on the `m.*` side.
4. Filter for the employees with no manager match.

## 3. My Solution (as submitted)

```sql
SELECT CONCAT(e.first_name,' ',e.last_name) AS employee_name
FROM employees e
LEFT JOIN employees m
    ON e.reports_to = m.employee_id
WHERE e.reports_to IS NULL;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt. (The submitted query returns the correct result on this dataset.)

## 5. Correct / Optimal Solution

The more robust anti-join filters on the joined table's primary key rather than the FK — it also catches orphaned `reports_to` references (a value that matches no existing `employee_id`):

```sql
SELECT CONCAT(e.first_name,' ',e.last_name) AS employee_name
FROM employees e
LEFT JOIN employees m
    ON e.reports_to = m.employee_id
WHERE m.employee_id IS NULL;
```

## 6. Why This Works

**Why SELF JOIN:** the `employees` table stores both employees and their managers. The `reports_to` column references `employee_id` in the same table. To find employees with no manager, we join `employees` to itself — `e` is the employee, `m` is the manager record they report to — and then filter for rows where no manager match was found.

**Why `LEFT JOIN` and not `INNER JOIN`:** an `INNER JOIN` would only return employees who have a matching manager row — exactly the employees we want to exclude. `LEFT JOIN` preserves every employee row, placing NULL in all `m.*` columns when no manager match exists. Filtering for NULL then isolates the employees with no manager.

**Why `WHERE m.employee_id IS NULL` is preferred over `WHERE e.reports_to IS NULL`:** both produce the same result in this dataset — if `e.reports_to` is NULL, there will be no matching manager row, so `m.employee_id` will also be NULL. However, `WHERE m.employee_id IS NULL` (filtering on the joined table's primary key) is the more general and robust anti-join pattern. It catches not just the case where `reports_to` is NULL, but also the case where `reports_to` has a value that doesn't match any existing `employee_id` — an orphaned reference. `WHERE e.reports_to IS NULL` would miss that second scenario.

## 7. Common Pitfalls (generic)

- Using `INNER JOIN` — only returns employees who have managers, which is the opposite of the requirement.
- Filtering on `WHERE e.reports_to IS NULL` instead of `WHERE m.employee_id IS NULL` — works for this dataset but misses orphaned `reports_to` references where the manager ID doesn't exist.
- Aliasing the table incorrectly — `e` must be the employee side, `m` must be the manager side.

## 8. Interview Follow-ups

**1. Why is this called a SELF JOIN even though we only have one table?**

A SELF JOIN joins a table to itself by giving it two different aliases. Here `employees e` and `employees m` both refer to the same physical table, but are treated as two logically separate tables in the query — one representing the employee, one representing their manager. The database engine processes them as if they were two distinct tables connected by the join condition.

**2. What is the difference between filtering on `WHERE e.reports_to IS NULL` vs `WHERE m.employee_id IS NULL`?**

`WHERE e.reports_to IS NULL` checks whether the employee was assigned a manager reference at all. `WHERE m.employee_id IS NULL` checks whether the `LEFT JOIN` found a matching manager row. The second is more robust — it also catches cases where `reports_to` has a value but that value doesn't match any employee ID in the table (an orphaned reference). In a well-constrained database both are equivalent, but `WHERE m.employee_id IS NULL` is the correct general anti-join pattern.

**3. How would you find the employee at the very top of the hierarchy — the one with no manager — in a company with multiple management levels?**

The same query works regardless of hierarchy depth. The top-level employee simply has `reports_to = NULL` (or no matching manager row), so they appear in this result. If you wanted to also show their level in the hierarchy, a recursive CTE (`WITH RECURSIVE`) would be the appropriate tool.

**4. How would you adapt this to find products with no supplier, or orders with no customer, using the same pattern?**

The anti-join pattern is the same: `LEFT JOIN <lookup_table> ON <fk> = <pk> WHERE <lookup_table>.<pk> IS NULL`. For products: `FROM products p LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id WHERE s.supplier_id IS NULL`. The SELF JOIN aspect is specific to this question because both entities live in the same table — for other anti-join scenarios, the tables are different.

## 9. Key Takeaway

To find rows with no matching record after a LEFT JOIN, filter on the joined table's primary key (`WHERE joined_table.pk IS NULL`) — it is the general, robust anti-join and catches orphaned references that filtering the FK column would miss.

---
📄 **SQL File:** [`Q61_Employees_Without_a_Manager.sql`](./Q61_Employees_Without_a_Manager.sql)

# Q53. Employees and Orders (FULL OUTER JOIN)

**Category:** FULL OUTER JOIN
**Difficulty:** Medium

---

## Problem Statement

Generate a report showing all employees and all orders. The report should include employees who have handled orders, employees who have never handled an order, and orders that are not assigned to any employee.

## Objective

Return the employee name and order ID for every employee and every order — no employee and no order should be excluded.

## Tables Used

- `orders`
- `employees`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| employee_name | Full name of the employee (NULL if the order has no matching employee) |
| order_id | Unique identifier of the order (NULL if the employee has never handled an order) |

**Sample output:**

| employee_name | order_id |
|---------------|----------|
| Nancy Davolio | 10248 |
| Andrew Fuller | 10249 |
| Steven Buchanan | NULL |
| NULL | 11080 |

*(In standard Northwind, all orders reference a valid employee — the NULL rows demonstrate FULL OUTER JOIN behaviour for data quality and HR scenarios.)*

## Concepts Used

- FULL OUTER JOIN
- NULL Handling
- String Concatenation (CONCAT)

## Why This Approach

**Why FULL OUTER JOIN:** the requirement specifies three distinct row types:
1. An employee who has handled at least one order — both sides populated
2. An employee who has never handled an order (`order_id = NULL`)
3. An order not assigned to any employee (`employee_name = NULL`)

Only `FULL OUTER JOIN` surfaces all three. `LEFT JOIN orders → employees` would miss type 2 (unhandled employees). `RIGHT JOIN orders → employees` would miss type 3 (unassigned orders).

**Why `orders` is listed first in `FROM`:** with `FULL OUTER JOIN`, the table order in `FROM` does not determine which side is preserved — both sides are always preserved. Unlike `LEFT JOIN` or `RIGHT JOIN`, there is no "driving" table in a `FULL OUTER JOIN`. Listing `orders` first here is a stylistic choice; swapping to `FROM employees e FULL OUTER JOIN orders o` produces identical results.

**Why `CONCAT(e.first_name, ' ', e.last_name)`:** produces a single `employee_name` display column. When `employees` has no match for an order (type 3 rows), all employee columns including `first_name` and `last_name` are NULL — `CONCAT(NULL, ' ', NULL)` in PostgreSQL returns a space character `' '` rather than NULL. In reporting tools, this typically displays as blank, which is visually equivalent to NULL. Use `NULLIF(CONCAT(...), ' ')` if a clean NULL value is required in the output.

## Common Mistakes

- Using `LEFT JOIN orders → employees` — drops employees who have never handled an order (type 2 rows disappear).
- Using `RIGHT JOIN orders → employees` — drops orders with no assigned employee (type 3 rows disappear).
- Assuming table order matters for `FULL OUTER JOIN` — it doesn't; both sides are always preserved regardless of which appears first.
- Forgetting the `CONCAT()` NULL behaviour — `CONCAT(NULL, ' ', NULL)` returns `' '`, not `NULL`, in PostgreSQL.

## Difficulty

**Medium**

## Interview Follow-up Questions

**1. Does table order matter in a FULL OUTER JOIN? How is this different from LEFT JOIN and RIGHT JOIN?**

No — in a `FULL OUTER JOIN`, both tables are fully preserved regardless of which appears first in `FROM`. The result is identical whether you write `FROM employees FULL OUTER JOIN orders` or `FROM orders FULL OUTER JOIN employees`. This contrasts directly with `LEFT JOIN` and `RIGHT JOIN`, where table order is critical: it determines which side is preserved and which may contribute NULLs. The symmetry of `FULL OUTER JOIN` is one of its defining characteristics.

**2. In your Northwind schema, `employees.reports_to` references `employees.employee_id` — a self-referencing key. How would you add a manager column to this query?**

Add a self-join on `employees` using a second alias:

```sql
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name,
    o.order_id
FROM orders o
FULL OUTER JOIN employees e ON e.employee_id = o.employee_id
LEFT JOIN employees m ON m.employee_id = e.reports_to;
```

The `LEFT JOIN employees m` is a self-join — `m` is a second reference to the same `employees` table, fetching the manager's name. Top-level employees (those with no manager, i.e. `reports_to IS NULL`) get `NULL` for `manager_name`. This is a preview of the SELF JOIN section of your roadmap.

**3. How would you filter this result to show only the anomalous rows — employees with no orders and orders with no employee?**

Filter for NULL on either side:

```sql
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    o.order_id
FROM orders o
FULL OUTER JOIN employees e ON e.employee_id = o.employee_id
WHERE e.employee_id IS NULL   -- orders with no assigned employee
   OR o.order_id IS NULL;     -- employees who have never handled an order
```

**4. How would you count orders per employee using FULL OUTER JOIN, including employees with zero orders and a row for unassigned orders?**

Use `COUNT(o.order_id)` with `GROUP BY e.employee_id` — this correctly returns 0 for employees with no orders, and produces a NULL-employee-id group for unassigned orders:

```sql
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(o.order_id) AS total_orders
FROM orders o
FULL OUTER JOIN employees e ON e.employee_id = o.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_orders DESC;
```

This is the FULL OUTER JOIN version of Q46 (Employees and Total Orders), with the added capability of capturing unassigned orders as a NULL-name row.

## Learning Outcomes

- Confirm that `FULL OUTER JOIN` table order is irrelevant — both sides are always preserved, unlike `LEFT JOIN` and `RIGHT JOIN` where order is critical.
- Understand the `CONCAT()` NULL behaviour (`CONCAT(NULL, ' ', NULL) = ' '`) and know when to apply `NULLIF()` to convert it back to a clean NULL.
- Preview how `FULL OUTER JOIN` and `SELF JOIN` can be combined to build rich employee hierarchy reports — a natural next step in the SQL roadmap.

---

📄 **SQL File:** [`Q53_Employees_And_Orders_FULL_OUTER_JOIN.sql`](./Q53_Employees_And_Orders_FULL_OUTER_JOIN.sql)

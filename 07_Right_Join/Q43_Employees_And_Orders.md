# Q43 · Employees and Orders

> **Revision Card**
> **Category:** RIGHT JOIN | **Difficulty:** Easy
> **Concepts:** RIGHT JOIN · NULL Handling · String Concatenation (CONCAT)
> **Outcome:** ✅ correct first attempt
> **Watch out for:** `CONCAT(NULL, ' ', NULL)` returns a space (not NULL) in PostgreSQL — whereas `||` would propagate NULL through the whole expression.

## 1. Problem

The HR team wants a report showing every order along with the employee who handled it. If an order has no matching employee record, it should still appear in the report.

**Objective:** Return all orders along with the corresponding employee name, preserving every order even if it has no matching employee.

**Tables:** `employees`, `orders`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| order_id | Unique identifier of the order |
| employee_name | Full name of the employee who handled the order (NULL if no matching employee exists) |

**Sample output:**

| order_id | employee_name |
|----------|---------------|
| 10248 | Nancy Davolio |
| 10249 | Andrew Fuller |
| 10250 | NULL |

*(Sample values are illustrative. In standard Northwind, all orders reference a valid employee — the NULL row demonstrates RIGHT JOIN behaviour for orphaned orders.)*

## 2. My Approach

1. Place `employees` on the LEFT and `orders` on the RIGHT.
2. `RIGHT JOIN` preserves every row from `orders` (the right table) regardless of whether a matching employee exists.
3. For unmatched orders, all employee columns are filled with NULL — `CONCAT(NULL, ' ', NULL)` returns a space via `CONCAT()` in PostgreSQL; use `NULLIF(CONCAT(...), ' ')` if a clean NULL is preferred.
4. Build the display name with `CONCAT(e.first_name, ' ', e.last_name)`.
5. Equivalent `LEFT JOIN` version (same result): `orders LEFT JOIN employees`.

## 3. My Solution (as submitted)

```sql
SELECT
    o.order_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name
FROM employees e
RIGHT JOIN orders o
    ON o.employee_id = e.employee_id;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why `employees` is on the LEFT and `orders` is on the RIGHT:** the requirement is to preserve every order. Placing `orders` as the right table in a `RIGHT JOIN` guarantees all orders appear, with employee columns set to `NULL` for any order whose `employee_id` doesn't match a record in `employees`.

**Why `CONCAT(e.first_name, ' ', e.last_name)`:** the expected output shows a single `employee_name` column rather than two separate name columns. `CONCAT()` builds this combined display value. Importantly, when `employees` has no match for an order (the NULL case), `CONCAT(NULL, ' ', NULL)` returns an empty string via `CONCAT()` — or optionally `NULL` depending on PostgreSQL's behaviour with all-NULL inputs to `CONCAT`. In practice, since the whole employee row is NULL for unmatched orders, the result is `NULL` for the entire `employee_name` column, which matches the expected output.

**LEFT JOIN equivalent:**
```sql
SELECT o.order_id,
       CONCAT(e.first_name, ' ', e.last_name) AS employee_name
FROM orders o
LEFT JOIN employees e ON o.employee_id = e.employee_id;
```

**Practical relevance:** in your ER diagram, `employees.reports_to` is a self-referencing foreign key — meaning employees can have managers who are also employees. An order assigned to an employee whose record has been deleted (e.g. a departed employee's record purged from HR) would produce a NULL employee_name row in this query, flagging it for reassignment.

## 7. Common Pitfalls (generic)

- Using `||` instead of `CONCAT()` for name concatenation — if either name part is NULL (which it is for unmatched orders), `||` propagates NULL through the entire expression, silently producing NULL instead of an empty string for partially available names.
- Placing `orders` on the left and `employees` on the right with `RIGHT JOIN` — this would preserve all employees (including those who have never handled an order), which is the opposite of the requirement.
- Forgetting that even with a `RIGHT JOIN`, columns from the right table (orders) are always available — NULLs only appear in columns from the left table (employees) when no match is found.

## 8. Interview Follow-ups

**1. What happens to `CONCAT(e.first_name, ' ', e.last_name)` when the employee row is entirely NULL (unmatched order)?**

When no employee row matches, all columns from `employees` are NULL — `e.first_name` is NULL and `e.last_name` is NULL. PostgreSQL's `CONCAT()` treats NULL arguments as empty strings, so `CONCAT(NULL, ' ', NULL)` returns `' '` (a single space). In practice, this is visually treated as NULL or empty in most reporting tools. If a clean NULL is required, use a `CASE` expression or `NULLIF(CONCAT(...), ' ')` to convert the single-space result back to NULL. The `||` operator would propagate NULL directly, returning NULL without this edge case.

**2. How would you modify this query to also count the total orders per employee in the same result?**

Since `orders` is already the right (preserved) table, adding `COUNT(o.order_id)` with `GROUP BY e.employee_id` is straightforward — but note that this changes the query from showing individual orders to showing one row per employee:

```sql
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(o.order_id) AS total_orders
FROM employees e
RIGHT JOIN orders o ON o.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name;
```

This is essentially Q46 (Employees and Total Orders) — the individual order detail and the aggregated count are two different reporting requirements served by the same join structure.

**3. Your ER diagram shows `employees.reports_to` references `employees.employee_id`. How would you extend this query to also show each order's employee and their manager's name?**

This requires a SELF JOIN on the `employees` table:

```sql
SELECT
    o.order_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name
FROM employees e
RIGHT JOIN orders o ON o.employee_id = e.employee_id
LEFT JOIN employees m ON m.employee_id = e.reports_to;
```

`e` is the handling employee; `m` is their manager (a second alias on the same `employees` table, joined on `reports_to`). This is a preview of the SELF JOIN section of your roadmap.

**4. How would you find orders with no matching employee using this RIGHT JOIN?**

Add a `WHERE` clause filtering on a NULL employee column:

```sql
SELECT o.order_id, e.first_name
FROM employees e
RIGHT JOIN orders o ON o.employee_id = e.employee_id
WHERE e.employee_id IS NULL;
```

This is the RIGHT JOIN anti-join pattern — returning only unmatched right-table rows, which represent orders assigned to employees that no longer exist in the system.

## 9. Key Takeaway

The RIGHT JOIN preserves the right table (orders) completely while the left table (employees) may contribute NULLs. Remember the PostgreSQL `CONCAT()` edge case: all-NULL inputs produce a space, not NULL — unlike `||`, which propagates NULL.

---
📄 **SQL File:** [`Q43_Employees_And_Orders.sql`](./Q43_Employees_And_Orders.sql)

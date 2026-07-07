# Q34. Employees and Customers Served

**Category:** LEFT JOIN
**Difficulty:** Medium

---

## Problem Statement

The management team wants a report showing every employee and the total number of distinct customers they have served. Employees who have not served any customers should also appear with a count of 0.

## Objective

Return all employees along with the number of distinct customers they have served, ensuring employees with no orders appear with a count of 0.

## Tables Used

- `employees`
- `orders`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| employee_name | Full name of the employee (first + last) |
| customers_served | Number of distinct customers served by this employee (0 if no orders handled) |

**Sample output:**

| employee_name | customers_served |
|---------------|------------------|
| Nancy Davolio | 45 |
| Janet Leverling | 40 |
| Margaret Peacock | 44 |
| Andrew Fuller | 0 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- LEFT JOIN
- GROUP BY
- Aggregate Functions (COUNT DISTINCT)
- String Concatenation
- NULL Handling

## Why This Approach

**Why `LEFT JOIN employees → orders`:** preserves every employee row regardless of whether they have handled any orders. An `INNER JOIN` would silently drop employees with no order history — directly violating the requirement to show them with a count of 0.

**Why `COUNT(DISTINCT o.customer_id)`:** an employee typically handles multiple orders for the same customer over time. Without `DISTINCT`, each of those orders would count as a separate customer, massively overstating the number of unique relationships. `DISTINCT` ensures each customer is counted only once per employee regardless of how many orders that employee processed for them.

**Why `COUNT` does not need `COALESCE`:** `COUNT(DISTINCT o.customer_id)` returns `0` (not `NULL`) for employees with no matching orders — `NULL` values are simply not counted. Unlike `SUM()`, `COUNT()` never returns `NULL` for an empty group. `COALESCE` would be redundant here, though harmless.

**Why concatenate `first_name` and `last_name`:** the expected output shows a single `employee_name` column rather than two separate name columns. `first_name || ' ' || last_name` (PostgreSQL string concatenation) builds that combined display name. Both parts should appear in `GROUP BY` alongside `employee_id` to avoid partial-name grouping issues if names were split differently.

**Why `GROUP BY` includes `employee_id`:** it is the true unique key. Grouping on the concatenated name alone risks merging two employees who happen to share both first and last names.

## Common Mistakes

- Using `INNER JOIN`, which silently drops employees with no order history from the result.
- Using `COUNT(o.order_id)` instead of `COUNT(DISTINCT o.customer_id)` — that counts orders handled, not unique customers served; a very different metric.
- Using plain `COUNT(o.customer_id)` without `DISTINCT` — counts one row per order, not one row per unique customer, inflating the figure whenever an employee handles multiple orders for the same customer.
- Grouping by the concatenated name alone instead of including `employee_id`, risking silent row merges for employees who share a name.

## Difficulty

**Medium**

## Interview Follow-up Questions

**1. Why is `COUNT(DISTINCT o.customer_id)` used instead of `COUNT(o.order_id)` or `COUNT(o.customer_id)`?**

`COUNT(o.order_id)` counts total orders handled — a different metric entirely (order volume vs customer breadth). `COUNT(o.customer_id)` without `DISTINCT` counts one row per order, so an employee who handled 10 orders for the same customer gets a count of 10 instead of 1. `COUNT(DISTINCT o.customer_id)` is the only version that correctly answers "how many unique customers did this employee serve" — each customer is counted exactly once per employee regardless of order frequency.

**2. Does `COUNT(DISTINCT o.customer_id)` need `COALESCE` for employees with no orders?**

No. `COUNT()` always returns `0` for an empty group, never `NULL` — unlike `SUM()`, `AVG()`, `MIN()`, and `MAX()`, which return `NULL`. For an employee with no matching orders, `o.customer_id` is `NULL` for their one LEFT JOIN output row, and `COUNT(DISTINCT o.customer_id)` simply finds nothing to count and returns `0`. `COALESCE` is genuinely required only for `SUM()`-style aggregates, not for `COUNT()`.

**3. How would you add a tie-breaker if two employees served exactly the same number of customers?**

Add a secondary sort column to `ORDER BY` — for example, sort by employee name alphabetically as a tie-breaker:

```sql
ORDER BY customers_served DESC, employee_name ASC;
```

This ensures deterministic, consistent ordering even when counts are identical.

**4. How would you extend this to show both unique customers served and total orders handled per employee?**

Add `COUNT(o.order_id)` alongside the existing `COUNT(DISTINCT o.customer_id)`:

```sql
SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    COUNT(DISTINCT o.customer_id) AS customers_served,
    COUNT(o.order_id) AS total_orders
FROM employees e
LEFT JOIN orders o ON o.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY customers_served DESC;
```

This gives both breadth (unique customers) and volume (total orders) in one pass — a useful combined view for performance analysis.

**5. How would you find employees who have handled orders for more than 30 distinct customers?**

Wrap the query in a CTE or subquery and filter on the computed count, or use `HAVING` directly:

```sql
SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    COUNT(DISTINCT o.customer_id) AS customers_served
FROM employees e
LEFT JOIN orders o ON o.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING COUNT(DISTINCT o.customer_id) > 30
ORDER BY customers_served DESC;
```

`HAVING` is required here (not `WHERE`) because the filter target is an aggregate value that doesn't exist until after `GROUP BY` has been applied.

## Learning Outcomes

- Understand the critical difference between `COUNT(order_id)` (order volume), `COUNT(customer_id)` (raw order rows with customer context), and `COUNT(DISTINCT customer_id)` (unique customer relationships) — three queries that look similar but answer fundamentally different business questions.
- Reinforce that `COUNT()` returns `0` for empty groups while `SUM()` returns `NULL` — knowing which aggregates behave which way eliminates an entire category of `COALESCE` errors.
- Practice building a display name from two source columns using concatenation, and understand why the underlying key (`employee_id`) must still drive the grouping even when only the concatenated name is displayed.

---

📄 **SQL File:** [`Q34_Employees_And_Customers_Served.sql`](./Q34_Employees_And_Customers_Served.sql)

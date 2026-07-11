# Q46. Employees and Total Orders

**Category:** RIGHT JOIN
**Difficulty:** Medium

---

## Problem Statement

The HR team wants a report showing every employee and the total number of orders they have handled. Employees who have not handled any orders should also appear with an order count of 0.

## Objective

Return all employees along with the total number of orders they have handled, ensuring employees with no orders appear with a count of 0.

## Tables Used

- `orders`
- `employees`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| employee_name | Full name of the employee (first + last) |
| total_orders | Total number of distinct orders handled by this employee (0 if none) |

**Sample output:**

| employee_name | total_orders |
|---------------|--------------|
| Margaret Peacock | 156 |
| Janet Leverling | 127 |
| Nancy Davolio | 123 |
| Andrew Fuller | 0 |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## Concepts Used

- RIGHT JOIN
- GROUP BY
- Aggregate Functions (COUNT DISTINCT)
- String Concatenation (CONCAT)
- NULL Handling

## Why This Approach

**Why `orders` is on the LEFT and `employees` is on the RIGHT:** the requirement is to preserve every employee. Placing `employees` as the right table in a `RIGHT JOIN` ensures all employees appear in the result, with `o.order_id` columns being NULL for any employee who has no matching orders.

**Why `COUNT(DISTINCT o.order_id)`:** in this query, each order appears exactly once (no `order_details` join multiplying rows), so `COUNT(o.order_id)` and `COUNT(DISTINCT o.order_id)` produce the same result here. `DISTINCT` is included as a defensive habit — if `order_details` were later joined in, plain `COUNT(o.order_id)` would inflate the count by counting one row per line item per order. Using `DISTINCT` future-proofs the query.

**Why `COUNT` does not need `COALESCE`:** `COUNT(DISTINCT o.order_id)` returns `0` (not `NULL`) for employees with no matching orders — NULL values are simply not counted. Unlike `SUM()`, `COUNT()` never returns NULL for an empty group. `COALESCE` would be redundant here.

**Why `GROUP BY e.employee_id, e.first_name, e.last_name`:** `employee_id` is the unique key; `first_name` and `last_name` must also appear in `GROUP BY` because they are referenced as standalone non-aggregated columns (not consumed inside an expression the way `CONCAT()` works when it's the entire `SELECT` item). Alternatively, grouping only by `e.employee_id` and using `CONCAT()` inside `SELECT` would allow omitting name columns from `GROUP BY` — as demonstrated in Q37.

**LEFT JOIN equivalent:**
```sql
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM employees e
LEFT JOIN orders o ON o.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name;
```

This is structurally identical to Q34 (Employees and Customers Served), which used `LEFT JOIN` — same preserved entity, same aggregation, opposite join direction.

## Common Mistakes

- Using `INNER JOIN`, which silently drops employees with no order history.
- Using `COUNT(*)` instead of `COUNT(DISTINCT o.order_id)` — for employees with no orders, the `RIGHT JOIN` produces one NULL-padded row, and `COUNT(*)` would count it as 1 instead of 0.
- Forgetting to include name columns in `GROUP BY` when they are referenced as standalone `SELECT` items (rather than wrapped inside `CONCAT()`).
- Adding `COALESCE` around `COUNT()` unnecessarily — `COUNT` already returns 0 for empty groups; only `SUM`, `AVG`, `MIN`, `MAX` need `COALESCE`.

## Difficulty

**Medium**

## Interview Follow-up Questions

**1. Why is `COUNT(DISTINCT o.order_id)` used instead of plain `COUNT(o.order_id)` or `COUNT(*)`?**

Three distinct behaviours in this context: `COUNT(*)` counts every row including the NULL-padded row produced for employees with no orders — incorrectly returning 1 instead of 0. `COUNT(o.order_id)` counts non-NULL order_id values only — returns 0 correctly for no-order employees in this query. `COUNT(DISTINCT o.order_id)` also returns 0 for no-order employees and additionally deduplicates order IDs — making it future-proof if `order_details` is ever joined in (which would otherwise multiply order rows). In this specific query, `COUNT(o.order_id)` and `COUNT(DISTINCT o.order_id)` give the same result, but `DISTINCT` is the safer habit.

**2. This is the RIGHT JOIN equivalent of Q34 (Employees and Customers Served with LEFT JOIN). What is the structural difference?**

Q34 placed `employees` as the left table and used `LEFT JOIN` to preserve all employees. This query places `employees` as the right table and uses `RIGHT JOIN` to preserve all employees. The preserved entity, the join condition, the aggregation, and the result are all identical. The only difference is which table appears first in `FROM` and the direction of the join keyword. This is another demonstration that `LEFT JOIN A to B` and `RIGHT JOIN B to A` are syntactically different but semantically equivalent.

**3. Why must `first_name` and `last_name` appear in `GROUP BY` here, when Q37 only needed `GROUP BY e.employee_id`?**

In Q37, name columns were consumed entirely inside `CONCAT(e.first_name, ' ', e.last_name)` — a single expression in the `SELECT` list. PostgreSQL allows the underlying columns used *inside a function expression* to be omitted from `GROUP BY` when the primary key (`employee_id`) is already in the clause. In this query, `first_name` and `last_name` are referenced separately in `GROUP BY` as their own standalone columns (they appear in the `GROUP BY` list directly). An alternative that avoids listing name columns in `GROUP BY` is to use `CONCAT()` in `SELECT` and group by `employee_id` only — as done in Q37 and Q46's LEFT JOIN equivalent above.

**4. How would you add a revenue column to this query alongside the order count?**

Join in `order_details` and aggregate revenue:

```sql
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2), 0) AS total_revenue
FROM order_details od
RIGHT JOIN orders o ON o.order_id = od.order_id
RIGHT JOIN employees e ON e.employee_id = o.employee_id
GROUP BY e.employee_id
ORDER BY total_revenue DESC;
```

Note the chain now uses two `RIGHT JOIN`s to preserve `employees` through the full path from `order_details`.

**5. How would you identify which employee handled the most orders in a single month?**

Use a CTE to aggregate orders per employee per month, then rank:

```sql
WITH monthly_orders AS (
    SELECT
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
        DATE_TRUNC('month', o.order_date) AS order_month,
        COUNT(DISTINCT o.order_id) AS orders_that_month
    FROM orders o
    RIGHT JOIN employees e ON e.employee_id = o.employee_id
    GROUP BY e.employee_id, e.first_name, e.last_name, order_month
)
SELECT *,
    RANK() OVER (PARTITION BY order_month ORDER BY orders_that_month DESC) AS rank_in_month
FROM monthly_orders
WHERE orders_that_month > 0
ORDER BY order_month, rank_in_month;
```

## Learning Outcomes

- Confirm that `RIGHT JOIN B to A` is exactly equivalent to `LEFT JOIN A to B` — the preserved entity and result are identical, only the syntax direction differs.
- Understand the three-way difference between `COUNT(*)`, `COUNT(column)`, and `COUNT(DISTINCT column)` in the context of outer join queries — a frequently tested interview topic.
- Know when `GROUP BY primary_key` alone is sufficient (when display columns are inside `CONCAT()`) versus when name columns must also be listed (when they are standalone `SELECT` items).
- Recognise that `COUNT` never needs `COALESCE` while `SUM` always does in empty-group scenarios — a rule that applies regardless of whether the outer join is `LEFT` or `RIGHT`.

---

📄 **SQL File:** [`Q46_Employees_And_Total_Orders.sql`](./Q46_Employees_And_Total_Orders.sql)

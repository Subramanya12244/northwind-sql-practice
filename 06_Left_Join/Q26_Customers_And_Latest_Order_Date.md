# Q26. Customers and Latest Order Date

**Category:** LEFT JOIN
**Difficulty:** Medium

---

## Problem Statement

Customer success wants to track recency of engagement — when each customer last placed an order — while still surfacing customers who have never ordered at all, so they aren't invisible in the report.

## Objective

Return every customer along with the date of their most recent order, showing `NULL` for customers who have never placed an order.

## Tables Used

- `customers`
- `orders`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| customer_id | Unique identifier of the customer |
| company_name | Name of the customer's company |
| latest_order_date | Date of the customer's most recent order, or NULL if they have never ordered |

**Sample output:**

| customer_id | company_name | latest_order_date |
|-------------|--------------|-------------------|
| QUICK | QUICK-Stop | 1998-04-30 |
| ERNSH | Ernst Handel | 1998-04-22 |
| FISSA | FISSA Fabrica Inter. Salchichas S.A. | NULL |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- LEFT JOIN
- GROUP BY
- Aggregate Functions (MAX)
- NULL Handling
- ORDER BY with NULLS

## Why This Approach

**Why `MAX(o.order_date)` works correctly without special-casing:** for a customer with no matching `orders` rows, every value of `o.order_date` in their group is `NULL`. `MAX()` (like all standard aggregate functions except `COUNT`) ignores `NULL` values when computing its result, and when *every* value in a group is `NULL`, `MAX()` itself returns `NULL` — which is exactly the desired output here, with zero extra logic required.

**Why `ORDER BY latest_order_date DESC NULLS LAST`:** in PostgreSQL, `NULL` values sort *first* by default when using `DESC` ordering, which would push customers with no order history to the top of a 'most recent first' report — the opposite of what's useful. `NULLS LAST` explicitly overrides that default, keeping never-ordered customers at the bottom where they belong in this context.

## Common Mistakes

- Using `INNER JOIN`, which would drop customers with no order history from the report entirely.
- Forgetting `NULLS LAST` and being surprised when never-ordered customers appear at the top of a 'most recent' sort.
- Assuming `MAX()` needs a `COALESCE` or `CASE` to handle the all-`NULL` group case — it doesn't; this is one of the few places `NULL` handling is automatic and correct by default.

## Difficulty

**Medium**

## Interview Follow-up Questions

1. Why does `MAX()` correctly return `NULL` for a customer with no orders, without any extra `CASE`/`COALESCE` logic?
2. What's PostgreSQL's default `NULL` sort position with `ASC` vs `DESC`, and why does that matter for this query?
3. How would you write this for a database where `NULLS LAST` isn't supported (e.g. MySQL or older SQL Server)?
4. How would you modify this to also flag customers who haven't ordered in over a year (but have ordered at least once)?

## Learning Outcomes

- Understand that most aggregate functions (except `COUNT`) naturally ignore and propagate `NULL` correctly without extra logic.
- Learn the `NULLS FIRST`/`NULLS LAST` PostgreSQL syntax and why default `NULL` sort order can silently produce misleading reports.

---

📄 **SQL File:** [`Q26_Customers_And_Latest_Order_Date.sql`](./Q26_Customers_And_Latest_Order_Date.sql)

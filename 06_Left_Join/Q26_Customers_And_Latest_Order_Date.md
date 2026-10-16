# Q26 · Customers and Latest Order Date

> **Revision Card**
> **Category:** LEFT JOIN | **Difficulty:** Medium
> **Concepts:** LEFT JOIN · GROUP BY · MAX · NULL Handling · ORDER BY with NULLS
> **Outcome:** ✅ correct first attempt
> **Watch out for:** in `DESC` sorts PostgreSQL puts `NULL` first — add `NULLS LAST` or never-ordered customers float to the top of a 'most recent' report.

## 1. Problem

Customer success wants to track recency of engagement — when each customer last placed an order — while still surfacing customers who have never ordered at all, so they aren't invisible in the report.

**Objective:** Return every customer along with the date of their most recent order, showing `NULL` for customers who have never placed an order.

**Tables:** `customers`, `orders`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| customer_id | Unique identifier of the customer |
| company_name | Name of the customer's company |
| latest_order_date | Date of the customer's most recent order, or NULL if they have never ordered |

| customer_id | company_name | latest_order_date |
|-------------|--------------|-------------------|
| QUICK | QUICK-Stop | 1998-04-30 |
| ERNSH | Ernst Handel | 1998-04-22 |
| FISSA | FISSA Fabrica Inter. Salchichas S.A. | NULL |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## 2. My Approach

1. Start from `customers` and LEFT JOIN to `orders` on `customer_id`.
2. Aggregate using `MAX(o.order_date)`, which naturally returns `NULL` for customers with no matching orders.
3. Group by customer.
4. Sort descending by latest order date, explicitly placing `NULL` values (never-ordered customers) last.

## 3. My Solution (as submitted)

```sql
SELECT
    cu.customer_id,
    cu.company_name,
    MAX(o.order_date) AS latest_order_date
FROM customers cu
LEFT JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.company_name
ORDER BY latest_order_date DESC NULLS LAST;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why `MAX(o.order_date)` works correctly without special-casing:** for a customer with no matching `orders` rows, every value of `o.order_date` in their group is `NULL`. `MAX()` (like all standard aggregate functions except `COUNT`) ignores `NULL` values when computing its result, and when *every* value in a group is `NULL`, `MAX()` itself returns `NULL` — which is exactly the desired output here, with zero extra logic required.

**Why `ORDER BY latest_order_date DESC NULLS LAST`:** in PostgreSQL, `NULL` values sort *first* by default when using `DESC` ordering, which would push customers with no order history to the top of a 'most recent first' report — the opposite of what's useful. `NULLS LAST` explicitly overrides that default, keeping never-ordered customers at the bottom where they belong in this context.

## 7. Common Pitfalls (generic)

- Using `INNER JOIN`, which would drop customers with no order history from the report entirely.
- Forgetting `NULLS LAST` and being surprised when never-ordered customers appear at the top of a 'most recent' sort.
- Assuming `MAX()` needs a `COALESCE` or `CASE` to handle the all-`NULL` group case — it doesn't; this is one of the few places `NULL` handling is automatic and correct by default.

## 8. Interview Follow-ups

1. Why does `MAX()` correctly return `NULL` for a customer with no orders, without any extra `CASE`/`COALESCE` logic?
2. What's PostgreSQL's default `NULL` sort position with `ASC` vs `DESC`, and why does that matter for this query?
3. How would you write this for a database where `NULLS LAST` isn't supported (e.g. MySQL or older SQL Server)?
4. How would you modify this to also flag customers who haven't ordered in over a year (but have ordered at least once)?

## 9. Key Takeaway

Most aggregates (except `COUNT`) ignore and propagate `NULL` correctly on their own — so `MAX` over an all-NULL group gives the right `NULL` answer — but you must manage `NULL` sort position explicitly with `NULLS FIRST`/`NULLS LAST`.

---
📄 **SQL File:** [`Q26_Customers_And_Latest_Order_Date.sql`](./Q26_Customers_And_Latest_Order_Date.sql)

# Q25 · Customers and Order Count

> **Revision Card**
> **Category:** LEFT JOIN | **Difficulty:** Medium
> **Concepts:** LEFT JOIN · GROUP BY · COUNT · NULL Handling
> **Outcome:** ✅ correct first attempt
> **Watch out for:** use `COUNT(o.order_id)`, not `COUNT(*)` — `COUNT(*)` counts the NULL-padded row and reports 1 instead of 0 for no-order customers.

## 1. Problem

The customer success team needs a complete roster of every customer along with their order count — including customers who have never placed a single order, since those are exactly the accounts most in need of outreach.

**Objective:** Return every customer and their total order count, ensuring customers with zero orders still appear in the result with a count of 0, rather than being excluded.

**Tables:** `customers`, `orders`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| customer_id | Unique identifier of the customer |
| company_name | Name of the customer's company |
| order_count | Total number of orders placed (0 if the customer has never ordered) |

| customer_id | company_name | order_count |
|-------------|--------------|-------------|
| SAVEA | Save-a-lot Markets | 31 |
| ERNSH | Ernst Handel | 30 |
| FISSA | FISSA Fabrica Inter. Salchichas S.A. | 0 |
| PARIS | Paris spécialités | 0 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## 2. My Approach

1. Start from `customers` and LEFT JOIN to `orders` on `customer_id`, preserving every customer regardless of order history.
2. Aggregate using `COUNT(o.order_id)` — counting the joined column, not `COUNT(*)`, so unmatched customers correctly show 0.
3. Group by customer.
4. Sort by order count descending.

## 3. My Solution (as submitted)

```sql
SELECT
    cu.customer_id,
    cu.company_name,
    COUNT(o.order_id) AS order_count
FROM customers cu
LEFT JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.company_name
ORDER BY order_count DESC;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why `LEFT JOIN` instead of `INNER JOIN`:** an `INNER JOIN` only returns rows where a match exists in *both* tables — any customer with zero matching rows in `orders` would be silently dropped entirely. `LEFT JOIN` preserves every row from `customers` (the 'left' table), filling in `NULL` for the `orders` columns when no match exists, which is exactly what 'include customers with no orders' requires.

**Why `COUNT(o.order_id)` and not `COUNT(*)`:** this is the single most important detail in this query. For a customer with no orders, the `LEFT JOIN` still produces exactly one output row (with all `orders` columns `NULL`) — `COUNT(*)` would count that one `NULL`-padded row as `1`, incorrectly suggesting one order exists. `COUNT(o.order_id)` specifically counts non-`NULL` values of that column, correctly yielding `0` for unmatched customers, since `NULL` values are never counted by `COUNT(column)`.

## 7. Common Pitfalls (generic)

- Using `INNER JOIN`, which silently excludes customers with zero orders entirely — the most common mistake for this exact business requirement.
- Using `COUNT(*)` instead of `COUNT(o.order_id)`, which incorrectly reports `1` instead of `0` for customers with no matching orders.
- Forgetting to `GROUP BY` company_name alongside customer_id when both are selected.

## 8. Interview Follow-ups

1. What's the difference between `COUNT(*)` and `COUNT(column_name)` in the context of a `LEFT JOIN`? Why does it matter here specifically?
2. What would happen to this result if `INNER JOIN` were used instead of `LEFT JOIN`?
3. How would you modify this query to show only customers with zero orders (rather than all customers with their counts)?
4. Would the choice between `LEFT JOIN` and `RIGHT JOIN` matter here if the table order in `FROM`/`JOIN` were swapped? Explain.

## 9. Key Takeaway

Before choosing `INNER` vs `LEFT JOIN`, ask "should rows with no match still appear?" — and when counting over a `LEFT JOIN`, always count the joined column (`COUNT(o.order_id)`), never `COUNT(*)`.

---
📄 **SQL File:** [`Q25_Customers_And_Order_Count.sql`](./Q25_Customers_And_Order_Count.sql)

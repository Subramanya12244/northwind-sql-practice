# Q25. Customers and Order Count

**Category:** LEFT JOIN
**Difficulty:** Medium

---

## Problem Statement

The customer success team needs a complete roster of every customer along with their order count — including customers who have never placed a single order, since those are exactly the accounts most in need of outreach.

## Objective

Return every customer and their total order count, ensuring customers with zero orders still appear in the result with a count of 0, rather than being excluded.

## Tables Used

- `customers`
- `orders`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| customer_id | Unique identifier of the customer |
| company_name | Name of the customer's company |
| order_count | Total number of orders placed (0 if the customer has never ordered) |

**Sample output:**

| customer_id | company_name | order_count |
|-------------|--------------|-------------|
| SAVEA | Save-a-lot Markets | 31 |
| ERNSH | Ernst Handel | 30 |
| FISSA | FISSA Fabrica Inter. Salchichas S.A. | 0 |
| PARIS | Paris spécialités | 0 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- LEFT JOIN
- GROUP BY
- Aggregate Functions (COUNT)
- NULL Handling

## Why This Approach

**Why `LEFT JOIN` instead of `INNER JOIN`:** an `INNER JOIN` only returns rows where a match exists in *both* tables — any customer with zero matching rows in `orders` would be silently dropped entirely. `LEFT JOIN` preserves every row from `customers` (the 'left' table), filling in `NULL` for the `orders` columns when no match exists, which is exactly what 'include customers with no orders' requires.

**Why `COUNT(o.order_id)` and not `COUNT(*)`:** this is the single most important detail in this query. For a customer with no orders, the `LEFT JOIN` still produces exactly one output row (with all `orders` columns `NULL`) — `COUNT(*)` would count that one `NULL`-padded row as `1`, incorrectly suggesting one order exists. `COUNT(o.order_id)` specifically counts non-`NULL` values of that column, correctly yielding `0` for unmatched customers, since `NULL` values are never counted by `COUNT(column)`.

## Common Mistakes

- Using `INNER JOIN`, which silently excludes customers with zero orders entirely — the most common mistake for this exact business requirement.
- Using `COUNT(*)` instead of `COUNT(o.order_id)`, which incorrectly reports `1` instead of `0` for customers with no matching orders.
- Forgetting to `GROUP BY` company_name alongside customer_id when both are selected.

## Difficulty

**Medium**

## Interview Follow-up Questions

1. What's the difference between `COUNT(*)` and `COUNT(column_name)` in the context of a `LEFT JOIN`? Why does it matter here specifically?
2. What would happen to this result if `INNER JOIN` were used instead of `LEFT JOIN`?
3. How would you modify this query to show only customers with zero orders (rather than all customers with their counts)?
4. Would the choice between `LEFT JOIN` and `RIGHT JOIN` matter here if the table order in `FROM`/`JOIN` were swapped? Explain.

## Learning Outcomes

- Internalize the single most common `LEFT JOIN` pitfall: `COUNT(*)` vs `COUNT(column)`.
- Build the habit of asking 'should rows with no match still appear?' before choosing between `INNER JOIN` and `LEFT JOIN`.

---

📄 **SQL File:** [`Q25_Customers_And_Order_Count.sql`](./Q25_Customers_And_Order_Count.sql)

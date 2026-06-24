# Q15. Customers Above Average Orders (Correlated Subquery)

**Category:** Correlated Subqueries
**Difficulty:** Medium

---

## Problem Statement

Same business need as Q8 — identify customers ordering more frequently than average — but solved using `HAVING` with a non-correlated scalar subquery, to compare against the CTE-based approach.

## Objective

Return customers whose order count exceeds the average order count across all customers, computed via a subquery referenced directly inside `HAVING`.

## Tables Used

- `customers`
- `orders`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| customer_id | Unique identifier of the customer |
| company_name | Name of the customer's company |
| order_count | Total number of orders placed by the customer |

**Sample output:**

| customer_id | company_name | order_count |
|-------------|--------------|-------------|
| SAVEA | Save-a-lot Markets | 31 |
| ERNSH | Ernst Handel | 30 |
| QUICK | QUICK-Stop | 28 |
| HUNGO | Hungry Owl All-Night Grocers | 19 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- INNER JOIN
- GROUP BY
- HAVING
- Subquery (non-correlated)
- Aggregate Functions (COUNT, AVG)

## Why This Approach

**Why this subquery is *not* technically correlated, despite living in this section:** the inner query (`SELECT AVG(order_count) FROM (SELECT COUNT(order_id) ...GROUP BY customer_id) sub`) computes a single global number that doesn't reference anything from the outer query's current row — it would return the exact same value regardless of which customer the outer query is currently evaluating. A genuinely correlated subquery (see Q18) re-executes per outer row because it references an outer-row column inside its `WHERE` clause.

**Why the inner query needs its own nested subquery:** `AVG(COUNT(order_id))` is not valid SQL — you cannot nest aggregate functions directly. The fix is to first compute `COUNT(order_id)` per customer in an inner derived table, then `AVG()` *that* result set in the layer above it.

**Why `HAVING` rather than `WHERE`:** the comparison is against an aggregated value (`COUNT(order_id)`), and `WHERE` clauses execute before aggregation — `HAVING` is required to filter on the result of a `GROUP BY` aggregate.

## Common Mistakes

- Writing `AVG(COUNT(order_id))` directly, which PostgreSQL will reject — aggregates cannot be nested without an intermediate derived table.
- Confusing this non-correlated subquery pattern with a true correlated subquery (Q18) — the key test is whether the inner query references any column from the outer query's current row.
- Using `WHERE` instead of `HAVING` when filtering on an aggregated value.

## Difficulty

**Medium**

## Interview Follow-up Questions

1. Is the subquery in this query correlated or non-correlated? How can you tell?
2. Why can't you write `HAVING COUNT(order_id) > AVG(COUNT(order_id))` directly?
3. How does this approach compare in readability and performance to the CTE-based version in Q8?
4. If this subquery were evaluated once or many times during query execution, which would it be, and why does that matter for performance?

## Learning Outcomes

- Clearly distinguish correlated from non-correlated subqueries — a frequent point of confusion and a common interview trap.
- Understand why aggregate functions cannot be nested directly and how derived tables solve that.
- Compare CTE-based and subquery-based approaches to the same 'above average' problem for stylistic and performance trade-offs.

---

📄 **SQL File:** [`Q15_Customers_Above_Average_Orders_Correlated.sql`](./Q15_Customers_Above_Average_Orders_Correlated.sql)

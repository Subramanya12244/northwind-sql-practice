# Q15 · Customers Above Average Orders (Correlated Subquery)

> **Revision Card**
> **Category:** Correlated Subqueries | **Difficulty:** Medium
> **Concepts:** INNER JOIN · GROUP BY · HAVING · Subquery (non-correlated) · Aggregates (COUNT, AVG)
> **Outcome:** ✅ correct first attempt
> **Watch out for:** `AVG(COUNT(...))` is illegal — you must average a derived table of per-customer counts, not nest aggregates directly.

## 1. Problem

Same business need as Q8 — identify customers ordering more frequently than average — but solved using `HAVING` with a non-correlated scalar subquery, to compare against the CTE-based approach.

**Objective:** Return customers whose order count exceeds the average order count across all customers, computed via a subquery referenced directly inside `HAVING`.

**Tables:** `customers`, `orders`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| customer_id | Unique identifier of the customer |
| company_name | Name of the customer's company |
| order_count | Total number of orders placed by the customer |

| customer_id | company_name | order_count |
|-------------|--------------|-------------|
| SAVEA | Save-a-lot Markets | 31 |
| ERNSH | Ernst Handel | 30 |
| QUICK | QUICK-Stop | 28 |
| HUNGO | Hungry Owl All-Night Grocers | 19 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## 2. My Approach

1. Join `customers` to `orders` and count orders per customer.
2. In `HAVING`, compare that count against a subquery computing `AVG(order_count)`.
3. Since aggregates can't nest directly, that subquery itself wraps a derived table that first computes `COUNT(order_id) GROUP BY customer_id`.
4. Sort by order count descending.

## 3. My Solution (as submitted)

```sql
SELECT
    cu.customer_id,
    cu.company_name,
    COUNT(o.order_id) AS order_count
FROM customers cu
JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.company_name
HAVING COUNT(o.order_id) > (
    SELECT AVG(order_count)
    FROM (
        SELECT COUNT(order_id) AS order_count
        FROM orders
        GROUP BY customer_id
    ) sub
)
ORDER BY order_count DESC;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why this subquery is *not* technically correlated, despite living in this section:** the inner query (`SELECT AVG(order_count) FROM (SELECT COUNT(order_id) ...GROUP BY customer_id) sub`) computes a single global number that doesn't reference anything from the outer query's current row — it would return the exact same value regardless of which customer the outer query is currently evaluating. A genuinely correlated subquery (see Q18) re-executes per outer row because it references an outer-row column inside its `WHERE` clause.

**Why the inner query needs its own nested subquery:** `AVG(COUNT(order_id))` is not valid SQL — you cannot nest aggregate functions directly. The fix is to first compute `COUNT(order_id)` per customer in an inner derived table, then `AVG()` *that* result set in the layer above it.

**Why `HAVING` rather than `WHERE`:** the comparison is against an aggregated value (`COUNT(order_id)`), and `WHERE` clauses execute before aggregation — `HAVING` is required to filter on the result of a `GROUP BY` aggregate.

## 7. Common Pitfalls (generic)

- Writing `AVG(COUNT(order_id))` directly, which PostgreSQL will reject — aggregates cannot be nested without an intermediate derived table.
- Confusing this non-correlated subquery pattern with a true correlated subquery (Q18) — the key test is whether the inner query references any column from the outer query's current row.
- Using `WHERE` instead of `HAVING` when filtering on an aggregated value.

## 8. Interview Follow-ups

**1. Is the subquery in this query correlated or non-correlated? How can you tell?**

It is non-correlated. The test is whether the inner query references any column from the outer query's current row — here the subquery `SELECT AVG(order_count) FROM (SELECT COUNT(order_id) ... GROUP BY customer_id) sub` has no reference to `cu` or any outer column. It computes a single global average order count that is identical no matter which customer the outer `HAVING` is currently evaluating. Because of this, PostgreSQL can evaluate it once and reuse the scalar for every group.

**2. Why can't you write `HAVING COUNT(order_id) > AVG(COUNT(order_id))` directly?**

SQL does not allow aggregate functions to be nested directly — `AVG(COUNT(order_id))` is a syntax error because `COUNT` is already an aggregate and you cannot wrap one aggregate inside another in the same query level. To average per-customer counts you must first materialize those counts in a derived table (`SELECT COUNT(order_id) ... GROUP BY customer_id`), then apply `AVG()` to that result set in an outer layer. The two aggregations happen at different grouping grains, which is exactly why they need separate query levels.

**3. How does this approach compare in readability and performance to the CTE-based version in Q8?**

Functionally they are equivalent and typically produce near-identical execution plans, since PostgreSQL inlines simple CTEs and the per-customer counts get computed either way. The CTE version in Q8 is generally more readable because the per-customer count is named once and referenced, rather than buried in a nested derived table inside `HAVING`. Performance differences are usually negligible for a dataset this size; the choice is primarily about clarity and maintainability.

**4. If this subquery were evaluated once or many times during query execution, which would it be, and why does that matter for performance?**

Because it is non-correlated, it is evaluated once — PostgreSQL computes the single global average as an initplan and caches the scalar, reusing it for every group tested in `HAVING`. This matters because a genuinely correlated subquery (like Q18) must re-execute for each outer row, which can be dramatically more expensive on large tables. Recognizing that this one is a constant lets you reason confidently that it adds only a one-time cost.

## 9. Key Takeaway

Distinguish correlated from non-correlated subqueries by whether the inner query references an outer-row column; and remember aggregates can't be nested — average a derived table of per-group counts instead.

---
📄 **SQL File:** [`Q15_Customers_Above_Average_Orders_Correlated.sql`](./Q15_Customers_Above_Average_Orders_Correlated.sql)

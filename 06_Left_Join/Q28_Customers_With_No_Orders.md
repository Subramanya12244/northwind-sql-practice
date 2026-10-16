# Q28 · Customers with No Orders

> **Revision Card**
> **Category:** LEFT JOIN | **Difficulty:** Easy
> **Concepts:** LEFT JOIN · NULL Handling · WHERE · NOT EXISTS (alternative)
> **Outcome:** ✅ correct first attempt
> **Watch out for:** avoid `NOT IN (SELECT customer_id FROM orders)` — a single `NULL` in the subquery makes it return an empty result set entirely.

## 1. Problem

Marketing wants a clean, targeted list of customers who have never placed a single order, to drive a dedicated re-engagement or first-purchase incentive campaign.

**Objective:** Return only the customers who have zero orders on record — no aggregation or counts needed, just the filtered list itself.

**Tables:** `customers`, `orders`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| customer_id | Unique identifier of the customer |
| company_name | Name of the customer's company |

| customer_id | company_name |
|-------------|--------------|
| FISSA | FISSA Fabrica Inter. Salchichas S.A. |
| PARIS | Paris spécialités |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## 2. My Approach

1. LEFT JOIN `customers` to `orders` on `customer_id`, preserving every customer regardless of order history.
2. Filter to rows where `o.order_id IS NULL`, which identifies customers with no matching order at all.
3. (Alternative shown: `NOT EXISTS`, often more efficient and equally NULL-safe.)

## 3. My Solution (as submitted)

```sql
SELECT
    cu.customer_id,
    cu.company_name
FROM customers cu
LEFT JOIN orders o ON o.customer_id = cu.customer_id
WHERE o.order_id IS NULL;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why `LEFT JOIN` followed by `WHERE o.order_id IS NULL`:** the `LEFT JOIN` preserves every customer, filling unmatched rows' `orders` columns with `NULL`. Filtering specifically for `o.order_id IS NULL` afterward isolates exactly the customers for whom *no match was found at all* — which is the definition of 'never placed an order'.

**Why `NOT EXISTS` is shown as an equally valid, often better-performing alternative:** `NOT EXISTS` lets the database stop searching for a given customer as soon as it finds *any* matching order, rather than building out every matching row before filtering — this can be meaningfully faster on large `orders` tables, especially with an index on `orders.customer_id`.

**Why `NOT IN (SELECT customer_id FROM orders)` is explicitly avoided:** if `orders.customer_id` can contain even a single `NULL` value, `NOT IN` returns an *empty result set entirely* — not just an incorrect one, a completely empty one — because comparing anything to `NULL` with `<>` evaluates to `NULL` (neither true nor false), and `NOT IN` requires every comparison in the list to evaluate to true. This is one of the best-known SQL correctness traps and worth being able to explain precisely in an interview.

## 7. Common Pitfalls (generic)

- Using `NOT IN (SELECT customer_id FROM orders)` without checking whether `orders.customer_id` can be `NULL` — if it can, this silently returns zero rows instead of the correct customer list.
- Filtering on a non-key column (e.g. `o.order_date IS NULL`) instead of `o.order_id IS NULL` — usually equivalent in practice, but less precise and less clearly tied to 'no matching order exists at all'.
- Using `INNER JOIN` and a negation, which doesn't work the way people expect with joins — `INNER JOIN` simply excludes unmatched rows rather than letting you test for their absence afterward.

## 8. Interview Follow-ups

**1. Why is `NOT IN` risky here if `orders.customer_id` could contain NULLs? Walk through exactly what happens.**

`NOT IN (SELECT customer_id FROM orders)` is internally a chain of `<>` comparisons joined by `AND`. If the subquery list contains even one `NULL`, then for every candidate customer the comparison `candidate <> NULL` evaluates to `NULL` (unknown), not `TRUE`. Since `NOT IN` requires *all* comparisons to be `TRUE`, the presence of that one `NULL` makes the whole predicate `NULL` for every row, so the query returns an empty result set — not a wrong subset, but zero rows entirely. The anti-join (`LEFT JOIN ... IS NULL`) and `NOT EXISTS` don't have this flaw.

**2. What's the performance difference, conceptually, between `LEFT JOIN ... WHERE IS NULL` and `NOT EXISTS`?**

`LEFT JOIN ... WHERE o.order_id IS NULL` logically builds all matching join rows first, then discards the matched ones, keeping only the NULL-padded leftovers. `NOT EXISTS` is a semi/anti-join that can short-circuit — it stops scanning a customer's orders the moment it finds one match. In practice, modern PostgreSQL often plans both as the same hash/anti-join and performance is comparable, but `NOT EXISTS` expresses intent more directly and can be faster on large `orders` tables with an index on `customer_id`.

**3. Why specifically filter on `o.order_id IS NULL` rather than any other column from `orders`?**

When no match is found, the `LEFT JOIN` NULL-pads *every* `orders` column, so in principle any of them could be tested. `order_id` is chosen because it is the primary key and therefore guaranteed non-NULL in any real matched row — so `o.order_id IS NULL` reliably means "no order matched" and can never give a false positive. A nullable column (e.g. `shipped_date`, which can be NULL even on a real order) would incorrectly flag genuine customers as having no orders.

**4. How would you write this same logic using a `RIGHT JOIN` instead, if the table order in `FROM` were reversed?**

Put `orders` first and `customers` second, then RIGHT JOIN so `customers` is still the preserved side:
```sql
SELECT cu.customer_id, cu.company_name
FROM orders o
RIGHT JOIN customers cu ON o.customer_id = cu.customer_id
WHERE o.order_id IS NULL;
```
This is logically identical to the `LEFT JOIN` version — the preserved table (`customers`) is just named on the right. `LEFT JOIN` with `customers` first is generally preferred for readability.

## 9. Key Takeaway

Master the anti-join pattern (`LEFT JOIN ... WHERE key IS NULL`, or its `NOT EXISTS` equivalent) for "find rows with no match" — and remember `NOT IN` is unsafe whenever the subquery column can contain `NULL`.

---
📄 **SQL File:** [`Q28_Customers_With_No_Orders.sql`](./Q28_Customers_With_No_Orders.sql)

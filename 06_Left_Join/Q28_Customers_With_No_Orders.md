# Q28. Customers with No Orders

**Category:** LEFT JOIN
**Difficulty:** Easy

---

## Problem Statement

Marketing wants a clean, targeted list of customers who have never placed a single order, to drive a dedicated re-engagement or first-purchase incentive campaign.

## Objective

Return only the customers who have zero orders on record — no aggregation or counts needed, just the filtered list itself.

## Tables Used

- `customers`
- `orders`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| customer_id | Unique identifier of the customer |
| company_name | Name of the customer's company |

**Sample output:**

| customer_id | company_name |
|-------------|--------------|
| FISSA | FISSA Fabrica Inter. Salchichas S.A. |
| PARIS | Paris spécialités |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- LEFT JOIN
- NULL Handling
- WHERE
- NOT EXISTS (alternative)

## Why This Approach

**Why `LEFT JOIN` followed by `WHERE o.order_id IS NULL`:** the `LEFT JOIN` preserves every customer, filling unmatched rows' `orders` columns with `NULL`. Filtering specifically for `o.order_id IS NULL` afterward isolates exactly the customers for whom *no match was found at all* — which is the definition of 'never placed an order'.

**Why `NOT EXISTS` is shown as an equally valid, often better-performing alternative:** `NOT EXISTS` lets the database stop searching for a given customer as soon as it finds *any* matching order, rather than building out every matching row before filtering — this can be meaningfully faster on large `orders` tables, especially with an index on `orders.customer_id`.

**Why `NOT IN (SELECT customer_id FROM orders)` is explicitly avoided:** if `orders.customer_id` can contain even a single `NULL` value, `NOT IN` returns an *empty result set entirely* — not just an incorrect one, a completely empty one — because comparing anything to `NULL` with `<>` evaluates to `NULL` (neither true nor false), and `NOT IN` requires every comparison in the list to evaluate to true. This is one of the best-known SQL correctness traps and worth being able to explain precisely in an interview.

## Common Mistakes

- Using `NOT IN (SELECT customer_id FROM orders)` without checking whether `orders.customer_id` can be `NULL` — if it can, this silently returns zero rows instead of the correct customer list.
- Filtering on a non-key column (e.g. `o.order_date IS NULL`) instead of `o.order_id IS NULL` — usually equivalent in practice, but less precise and less clearly tied to 'no matching order exists at all'.
- Using `INNER JOIN` and a negation, which doesn't work the way people expect with joins — `INNER JOIN` simply excludes unmatched rows rather than letting you test for their absence afterward.

## Difficulty

**Easy**

## Interview Follow-up Questions

1. Why is `NOT IN` risky here if `orders.customer_id` could contain NULLs? Walk through exactly what happens.
2. What's the performance difference, conceptually, between `LEFT JOIN ... WHERE IS NULL` and `NOT EXISTS`?
3. Why specifically filter on `o.order_id IS NULL` rather than any other column from `orders`?
4. How would you write this same logic using a `RIGHT JOIN` instead, if the table order in `FROM` were reversed?

## Learning Outcomes

- Master the 'anti-join' pattern (`LEFT JOIN ... WHERE x IS NULL` and its `NOT EXISTS` equivalent) for finding rows with no match — one of the most frequently tested SQL patterns in interviews.
- Understand precisely why `NOT IN` is unsafe in the presence of `NULL`s, a classic and important SQL gotcha.

---

📄 **SQL File:** [`Q28_Customers_With_No_Orders.sql`](./Q28_Customers_With_No_Orders.sql)

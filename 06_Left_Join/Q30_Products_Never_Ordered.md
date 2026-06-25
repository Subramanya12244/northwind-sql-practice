# Q30. Products Never Ordered

**Category:** LEFT JOIN
**Difficulty:** Easy

---

## Problem Statement

Inventory and purchasing teams want to identify products that have never sold a single unit, to evaluate discontinuation, repricing, or removing them from active catalog promotion entirely.

## Objective

Return only the products that have never appeared in any order, with no aggregation needed — just the filtered list of products themselves.

## Tables Used

- `products`
- `order_details`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| product_id | Unique identifier of the product |
| product_name | Name of the product that has never been ordered |

**Sample output:**

| product_id | product_name |
|------------|--------------|
| 9 | Mishi Kobe Niku |
| 17 | Alice Mutton |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- LEFT JOIN
- NULL Handling
- WHERE
- NOT EXISTS (alternative)

## Why This Approach

**Structurally identical to Q28's anti-join pattern, applied to products instead of customers:** `LEFT JOIN` preserves every product even if it has no matching `order_details` rows, and filtering on `od.product_id IS NULL` (any column from the right-hand table that is guaranteed non-null *in a real match* works equally well — `product_id` is a natural, obvious choice here since it's the exact join key) isolates exactly the products with zero matches.

**Why `od.product_id` works just as well as `od.order_id`:** when no matching row exists in `order_details`, every column from that table comes back `NULL` for that output row — not just the column used in the join condition. Filtering on `od.product_id IS NULL` or `od.order_id IS NULL` are equally valid choices; this version uses the join key itself, which some find slightly more intuitive to read since it visually mirrors the `ON` condition immediately above it.

**Why this matters operationally beyond the SQL mechanics:** a product appearing in this list might be brand new (never yet sold), discontinued by the supplier but not yet removed from the catalog, or mispriced/unappealing — the query surfaces the *symptom*, and distinguishing between these causes is a judgment call for the business, not something the SQL itself can determine.

## Common Mistakes

- Using `NOT IN (SELECT product_id FROM order_details)` without verifying `order_details.product_id` can never be `NULL` — same risk as Q28's `NOT IN` trap.
- Confusing 'never ordered' with 'currently out of stock' — these are different concepts; this query only reflects historical order activity, not current inventory levels (which would live in a separate stock/inventory table if Northwind had one).
- Filtering on `p.product_id IS NULL` instead of `od.product_id IS NULL` — this would never be true, since every row from `products` exists by definition and can never be `NULL`.

## Difficulty

**Easy**

## Interview Follow-up Questions

1. How is this query structurally identical to Q28? What's the only thing that changes?
2. Does it matter whether you filter on `od.product_id IS NULL` or `od.order_id IS NULL`? Why or why not?
3. What real-world business scenarios could explain a product showing up in this result — and how would you investigate further?
4. If `products` had millions of rows and `order_details` had hundreds of millions, how would you tune this query for performance?
5. How would you combine this with a revenue/quantity query to show both 'never ordered' products and their listing price, to prioritize a discontinuation review?

## Learning Outcomes

- Reinforce the anti-join pattern from Q28 by applying it to a second, structurally identical business question — solidifying that the *pattern* (not the specific tables) is the transferable skill.
- Understand that any column from the right-hand (joined) table works equally well in the `IS NULL` filter, since an unmatched row has every one of its columns set to `NULL` — not just the one named in the join condition.
- Practice distinguishing what SQL can directly answer (historical order activity) from what requires further business context (why a product never sold) — an important practical-judgment skill beyond pure query-writing.

---

📄 **SQL File:** [`Q30_Products_Never_Ordered.sql`](./Q30_Products_Never_Ordered.sql)
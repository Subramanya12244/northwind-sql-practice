# Q30 · Products Never Ordered

> **Revision Card**
> **Category:** LEFT JOIN | **Difficulty:** Easy
> **Concepts:** LEFT JOIN · NULL Handling · WHERE · NOT EXISTS (alternative)
> **Outcome:** ✅ correct first attempt
> **Watch out for:** filter on a *right-hand* table column (`od.product_id IS NULL`) — `p.product_id IS NULL` can never be true for an existing product row.

## 1. Problem

Inventory and purchasing teams want to identify products that have never sold a single unit, to evaluate discontinuation, repricing, or removing them from active catalog promotion entirely.

**Objective:** Return only the products that have never appeared in any order, with no aggregation needed — just the filtered list of products themselves.

**Tables:** `products`, `order_details`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| product_id | Unique identifier of the product |
| product_name | Name of the product that has never been ordered |

| product_id | product_name |
|------------|--------------|
| 9 | Mishi Kobe Niku |
| 17 | Alice Mutton |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## 2. My Approach

1. LEFT JOIN `products` to `order_details` on `product_id`, preserving every product regardless of whether it has been ordered.
2. Filter to rows where `od.product_id IS NULL`, which identifies products with no matching row in `order_details` at all — using the join key itself, which mirrors the `ON` condition directly above.

## 3. My Solution (as submitted)

```sql
select p.product_id, p.product_name
from products p
left join order_details od on p.product_id = od.product_id
where od.product_id is NULL;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Structurally identical to Q28's anti-join pattern, applied to products instead of customers:** `LEFT JOIN` preserves every product even if it has no matching `order_details` rows, and filtering on `od.product_id IS NULL` (any column from the right-hand table that is guaranteed non-null *in a real match* works equally well — `product_id` is a natural, obvious choice here since it's the exact join key) isolates exactly the products with zero matches.

**Why `od.product_id` works just as well as `od.order_id`:** when no matching row exists in `order_details`, every column from that table comes back `NULL` for that output row — not just the column used in the join condition. Filtering on `od.product_id IS NULL` or `od.order_id IS NULL` are equally valid choices; this version uses the join key itself, which some find slightly more intuitive to read since it visually mirrors the `ON` condition immediately above it.

**Why this matters operationally beyond the SQL mechanics:** a product appearing in this list might be brand new (never yet sold), discontinued by the supplier but not yet removed from the catalog, or mispriced/unappealing — the query surfaces the *symptom*, and distinguishing between these causes is a judgment call for the business, not something the SQL itself can determine.

## 7. Common Pitfalls (generic)

- Using `NOT IN (SELECT product_id FROM order_details)` without verifying `order_details.product_id` can never be `NULL` — same risk as Q28's `NOT IN` trap.
- Confusing 'never ordered' with 'currently out of stock' — these are different concepts; this query only reflects historical order activity, not current inventory levels (which would live in a separate stock/inventory table if Northwind had one).
- Filtering on `p.product_id IS NULL` instead of `od.product_id IS NULL` — this would never be true, since every row from `products` exists by definition and can never be `NULL`.

## 8. Interview Follow-ups

**1. How is this query structurally identical to Q28? What's the only thing that changes?**

Both queries follow the exact same skeleton: `LEFT JOIN <parent> to <child>`, then `WHERE <child>.<column> IS NULL`. Q28 applies this to `customers`/`orders`; this query applies it to `products`/`order_details`. The join type, the filter logic, and the overall shape of the query are identical — only the table and column names change. Once the anti-join pattern is internalized, it transfers directly to any "find entities with no matching child row" question.

**2. Does it matter whether you filter on `od.product_id IS NULL` or `od.order_id IS NULL`? Why or why not?**

No, they're equivalent here. When a `LEFT JOIN` finds no matching row in `order_details`, it produces one fully NULL-padded row for *every* column that would have come from that table — not just the join key. So testing `product_id`, `order_id`, or any other `order_details` column for `NULL` catches exactly the same set of unmatched products. The one case where it would matter is if a column could legitimately be `NULL` even in a real, matched row — but `product_id` (the join key) and `order_id` are both guaranteed non-null in any real row, so either is a safe choice.

**3. What real-world business scenarios could explain a product showing up in this result — and how would you investigate further?**

Several distinct possibilities, each implying a different next step: the product could be genuinely new and just hasn't sold yet (monitor); discontinued by the supplier but never removed from the catalog (archive/flag inactive); priced or positioned poorly (review pricing, not necessarily delist); a seasonal item being checked outside its selling season (re-check later); or a data entry issue, such as a duplicate `product_id` where real sales are recorded against a different row (investigate before concluding zero sales is accurate). The SQL only confirms *that* a product has zero matching order lines — distinguishing between these causes requires business context the query itself can't provide.

**4. If `products` had millions of rows and `order_details` had hundreds of millions, how would you tune this query for performance?**

Key levers: ensure `order_details.product_id` is indexed, since it's both the join and filter column; prefer `NOT EXISTS` over `LEFT JOIN ... IS NULL` at this scale, since it lets the planner stop searching as soon as it finds one match rather than materializing a join row for every product first; avoid `SELECT *` to minimize I/O; and check `EXPLAIN ANALYZE` to confirm the planner is choosing an efficient anti-join strategy (e.g. a hash anti join) rather than a slow nested loop.

**5. How would you combine this with a revenue/quantity query to show both 'never ordered' products and their listing price, to prioritize a discontinuation review?**

Since these products have no `order_details` rows by definition, there's no historical revenue to compute — instead, join in `products.unit_price` (the current catalog price) directly:

```sql
SELECT
    p.product_id,
    p.product_name,
    p.unit_price AS list_price
FROM products p
LEFT JOIN order_details od ON od.product_id = p.product_id
WHERE od.product_id IS NULL
ORDER BY p.unit_price DESC;
```

Sorting by `list_price DESC` surfaces the highest-priced never-sold products first — typically the most urgent discontinuation or repricing candidates, since they tie up the most potential revenue per unit with zero turnover.

## 9. Key Takeaway

Any column from the right-hand table works in the `IS NULL` filter because an unmatched `LEFT JOIN` row has *every* right-side column set to `NULL` — just never filter on a left-side column, which can never be `NULL` for a real row.

---
📄 **SQL File:** [`Q30_Products_Never_Ordered.sql`](./Q30_Products_Never_Ordered.sql)

# Q29 · Products Never Ordered

> **Revision Card**
> **Category:** LEFT JOIN | **Difficulty:** Easy
> **Concepts:** LEFT JOIN · NULL Handling · WHERE · NOT EXISTS (alternative)
> **Outcome:** ✅ correct first attempt
> **Watch out for:** same `NOT IN` NULL trap as Q28 — use the anti-join (`LEFT JOIN ... WHERE od.order_id IS NULL`) or `NOT EXISTS`.

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

1. LEFT JOIN `products` to `order_details` on `product_id`, preserving every product regardless of sales history.
2. Filter to rows where `od.order_id IS NULL`, which identifies products with no matching order line item at all.
3. (Alternative shown: `NOT EXISTS`, an equally valid and often more efficient approach.)

## 3. My Solution (as submitted)

```sql
SELECT
    p.product_id,
    p.product_name
FROM products p
LEFT JOIN order_details od ON od.product_id = p.product_id
WHERE od.order_id IS NULL;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Structurally identical to Q28's anti-join pattern, applied to products instead of customers:** `LEFT JOIN` preserves every product even if it has no matching `order_details` rows, and filtering on `od.order_id IS NULL` (any column from the right-hand table that is guaranteed non-null *in a real match* works equally well — `order_id` is a natural, obvious choice) isolates exactly the products with zero matches.

**Why this matters operationally beyond the SQL mechanics:** a product appearing in this list might be brand new (never yet sold), discontinued by the supplier but not yet removed from the catalog, or mispriced/unappealing — the query surfaces the *symptom*, and distinguishing between these causes is a judgment call for the business, not something the SQL itself can determine.

## 7. Common Pitfalls (generic)

- Using `NOT IN (SELECT product_id FROM order_details)` without verifying `order_details.product_id` can never be `NULL` — same risk as Q28's `NOT IN` trap.
- Confusing 'never ordered' with 'currently out of stock' — these are different concepts; this query only reflects historical order activity, not current inventory levels (which would live in a separate stock/inventory table if Northwind had one).

## 8. Interview Follow-ups

**1. How is this query structurally identical to Q28? What's the only thing that changes?**

Both follow the same anti-join skeleton: `LEFT JOIN <parent> to <child>`, then `WHERE <child>.<key> IS NULL` to keep only parents with no matching child. Q28 applies it to `customers`/`orders`; this applies it to `products`/`order_details`. The join type, the `IS NULL` filter, and the overall shape are identical — only the table and column names change. Once the anti-join pattern is internalised, it transfers directly to any "entity with no matching child row" question.

**2. What real-world business scenarios could explain a product showing up in this result — and how would you investigate further?**

A product with zero order lines could be genuinely new (not yet sold — monitor it), discontinued by the supplier but still in the catalog (archive/flag inactive), mispriced or poorly positioned (review pricing before delisting), seasonal and checked off-season (re-check later), or a data issue such as a duplicate `product_id` where real sales were recorded against a different row. The SQL only confirms *that* there are no matching order lines; distinguishing the cause requires checking the product's creation date, supplier status, and price against business context.

**3. If `products` had millions of rows and `order_details` had hundreds of millions, how would you tune this query for performance?**

Ensure `order_details.product_id` is indexed, since it is both the join and filter column. At that scale prefer `NOT EXISTS` over `LEFT JOIN ... IS NULL`, because it lets the planner stop scanning a product's order lines as soon as one match is found rather than materialising join rows for every product first. Select only the needed columns (avoid `SELECT *`), and run `EXPLAIN ANALYZE` to confirm the planner picks an efficient hash anti-join rather than a slow nested loop.

**4. How would you combine this with Q27 to show both 'never ordered' products and their listing price, to prioritize a discontinuation review?**

Since these products have no `order_details` rows, there is no historical revenue to compute — instead surface the current catalog price and sort by it:
```sql
SELECT p.product_id, p.product_name, p.unit_price AS list_price
FROM products p
LEFT JOIN order_details od ON od.product_id = p.product_id
WHERE od.order_id IS NULL
ORDER BY p.unit_price DESC;
```
Sorting by `list_price DESC` puts the highest-priced never-sold items first — typically the most urgent discontinuation or repricing candidates, since they tie up the most potential value per unit with zero turnover.

## 9. Key Takeaway

The anti-join pattern is about the *pattern*, not the tables — once internalized on customers (Q28), it transfers directly to products, or any "entity with no matching child row" question.

---
📄 **SQL File:** [`Q29_Products_Never_Ordered.sql`](./Q29_Products_Never_Ordered.sql)

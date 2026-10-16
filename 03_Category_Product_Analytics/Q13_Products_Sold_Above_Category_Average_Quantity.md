# Q13 · Products Sold Above Category Average Quantity

> **Revision Card**
> **Category:** Category & Product Analytics | **Difficulty:** Hard
> **Concepts:** CTE · GROUP BY · SUM/AVG · Window Functions (alt) · Compare-to-peer-group
> **Outcome:** ✅ correct first attempt
> **Watch out for:** compare each product to its *own category's* average, not the company-wide average — join `category_avg` back on `category_id`.

## 1. Problem

Inventory planning wants to identify which products are outperforming their own category's typical sales volume, to inform restocking priorities within each category rather than comparing unrelated categories directly.

**Objective:** Find products whose total quantity sold exceeds the average quantity sold by products *within the same category* (not the company-wide average).

**Tables:** `products`, `order_details`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| product_id | Unique identifier of the product |
| product_name | Name of the product |
| category_id | Category the product belongs to |
| total_qty | Total quantity sold of this product |
| avg_qty_in_category | Average quantity sold across all products in the same category |

**Sample output:**

| product_id | product_name | category_id | total_qty | avg_qty_in_category |
|------------|--------------|-------------|-----------|---------------------|
| 24 | Guaraná Fantástica | 1 | 858 | 626.4 |
| 75 | Rhönbräu Klosterbier | 1 | 541 | 626.4 |
| 59 | Raclette Courdavault | 4 | 1496 | 672.7 |
| 31 | Gorgonzola Telino | 4 | 999 | 672.7 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## 2. My Approach

1. Build a CTE (`product_qty`) that sums total quantity sold per product, retaining `category_id`.
2. Build a second CTE (`category_avg`) that averages `total_qty` per category, using the first CTE as its source.
3. Join `product_qty` to `category_avg` on `category_id`.
4. Filter to products where `total_qty > avg_qty_in_category`.
5. Sort by category and then by quantity descending.
6. (Alternative: a window function version using `AVG(SUM(quantity)) OVER (PARTITION BY category_id)` achieves the same result in one pass.)

## 3. My Solution (as submitted)

```sql
WITH product_qty AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        SUM(od.quantity) AS total_qty
    FROM products p
    JOIN order_details od ON od.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category_id
),
category_avg AS (
    SELECT
        category_id,
        AVG(total_qty) AS avg_qty_in_category
    FROM product_qty
    GROUP BY category_id
)
SELECT
    pq.product_id,
    pq.product_name,
    pq.category_id,
    pq.total_qty,
    ca.avg_qty_in_category
FROM product_qty pq
JOIN category_avg ca ON ca.category_id = pq.category_id
WHERE pq.total_qty > ca.avg_qty_in_category
ORDER BY pq.category_id, pq.total_qty DESC;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

(Equivalent single-pass window-function version, preferred in production:)

```sql
SELECT *
FROM (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        SUM(od.quantity) AS total_qty,
        AVG(SUM(od.quantity)) OVER (PARTITION BY p.category_id) AS avg_qty_in_category
    FROM products p
    JOIN order_details od ON od.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category_id
) sub
WHERE total_qty > avg_qty_in_category
ORDER BY category_id, total_qty DESC;
```

## 6. Why This Works

**Why this needs *two* levels of aggregation, not one:** the comparison target ('average quantity in *this product's* category') is itself an aggregate over an aggregate — first sum quantity per product, then average those per-product sums within each category. A single `GROUP BY` pass cannot produce both the product-level total and the category-level average simultaneously.

**Why two CTEs (`product_qty` and `category_avg`):** the first CTE computes the finer grain (per product); the second re-aggregates that result to the coarser grain (per category). Joining them back together lines up each product with its *own* category's average for comparison.

**Window function alternative:** `AVG(SUM(quantity)) OVER (PARTITION BY category_id)` achieves the same result in a single query by computing the category average as a window over the already-grouped product totals, avoiding the second CTE and an extra join — generally the more efficient and idiomatic approach in PostgreSQL once you're comfortable with window functions.

## 7. Common Pitfalls (generic)

- Comparing each product to the *company-wide* average quantity instead of its own category's average — this answers a different, less useful question.
- Forgetting to join `category_avg` back on `category_id`, which would compare every product to every category's average rather than just its own.
- Assuming `GROUP BY category_id` alone (without first aggregating per product) can answer this — it can't, because you'd lose the per-product detail needed for the final comparison.

## 8. Interview Follow-ups

**1. Why can't this be solved with a single `GROUP BY category_id` pass?**

The comparison requires two different grains at once: each product's own total quantity, and the average of those per-product totals within its category. A single `GROUP BY category_id` collapses all products in a category into one row, destroying the per-product detail needed on the left side of the comparison. You must first aggregate to the product grain, then re-aggregate to the category grain — an aggregate over an aggregate — which a single grouping level cannot express.

**2. Walk through the difference between the two-CTE approach and the window function approach. Which would you prefer in production, and why?**

The two-CTE approach computes per-product totals in `product_qty`, re-aggregates them to a per-category average in `category_avg`, then joins the two back on `category_id` to compare. The window version computes the per-product total once and layers `AVG(SUM(...)) OVER (PARTITION BY category_id)` on top, so the category average rides alongside each product row with no second scan or join. In production I prefer the window function: it reads the aggregated data once, avoids the extra join, and is more idiomatic PostgreSQL — generally cheaper and clearer.

**3. What does `PARTITION BY` do differently from `GROUP BY` in the window function version?**

`GROUP BY` reduces many rows to one row per group, collapsing detail. `PARTITION BY` divides rows into groups for the window calculation but preserves every input row, attaching the per-partition aggregate to each one. That is exactly why the window version works in a single pass: each product row keeps its own `total_qty` while also seeing its category's average in the same row — something `GROUP BY` alone cannot do.

**4. How would you adapt this to compare products against the median quantity in their category instead of the mean?**

Replace the mean with an ordered-set aggregate. In the two-CTE form, compute the category median with `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_qty)` grouped by `category_id`, then join and filter `total_qty > median`. There is no window form of `PERCENTILE_CONT` as a plain `OVER()` aggregate in standard PostgreSQL, so the CTE-plus-join structure (or a correlated subquery) is the natural way to carry the per-category median back for comparison.

## 9. Key Takeaway

Multi-level aggregation — averaging an already-aggregated per-product total up to the category grain — powers the common 'compare to peer-group average' pattern; a window function can collapse the self-join-style CTE into one clean pass.

---
📄 **SQL File:** [`Q13_Products_Sold_Above_Category_Average_Quantity.sql`](./Q13_Products_Sold_Above_Category_Average_Quantity.sql)

# Q148 · Rank Vs Dense Rank Product Prices

> **Revision Card**
> **Category:** Window Functions (Ranking) | **Difficulty:** Easy
> **Concepts:** RANK · DENSE_RANK · PARTITION BY · Tie Handling
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** RANK leaves gaps after ties (1,1,3); DENSE_RANK does not (1,1,2). Know which the question wants.

## 1. Problem

The pricing team wants to see, within each category, how every product's list price ranks from most to least expensive. They want both ranking styles side by side so they can see how tied prices are treated.

**Objective:** For each product, show its price rank within its category using both `RANK()` and `DENSE_RANK()` (highest price = 1).

**Tables:** `products`, `categories`

**Expected output:**

| Column | Description |
|--------|-------------|
| category_name | Category name |
| product_id | Product identifier |
| product_name | Product name |
| unit_price | List price |
| price_rank | RANK() within category by price, descending |
| price_dense_rank | DENSE_RANK() within category by price, descending |

| category_name | product_id | product_name | unit_price | price_rank | price_dense_rank |
|---------------|------------|--------------|------------|------------|------------------|
| Beverages | 38 | Côte de Blaye | 263.50 | 1 | 1 |
| Beverages | 43 | Ipoh Coffee | 46.00 | 2 | 2 |
| Beverages | 2 | Chang | 19.00 | 3 | 3 |
| Beverages | 1 | Chai | 18.00 | 4 | 4 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Join `products` to `categories`.
2. Compute `RANK()` and `DENSE_RANK()` over the same window: `PARTITION BY category_id ORDER BY unit_price DESC`.
3. Sort by category, rank, then `product_id` as the tie-breaker.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    c.category_name,
    p.product_id,
    p.product_name,
    p.unit_price,
    RANK()       OVER (PARTITION BY c.category_id ORDER BY p.unit_price DESC) AS price_rank,
    DENSE_RANK() OVER (PARTITION BY c.category_id ORDER BY p.unit_price DESC) AS price_dense_rank
FROM products p
JOIN categories c ON c.category_id = p.category_id
ORDER BY category_name, price_rank, product_id;
```

## 6. Why This Works

Both functions number rows within each category by descending price. They differ only on ties. `RANK()` gives tied rows the same number and then skips (1, 1, 3), so the rank equals 1 + the number of strictly higher-priced rows. `DENSE_RANK()` gives tied rows the same number and continues with the next integer (1, 1, 2), so it counts distinct price levels.

Putting both in one query with identical windows makes the difference visible wherever prices tie. Where no ties exist, the two columns match.

## 7. Common Pitfalls (generic)

- Assuming `RANK()` and `DENSE_RANK()` always match — they diverge right after any tie.
- Using `ROW_NUMBER()` when ties should share a rank.
- Ordering ascending by accident, making the cheapest product rank 1.
- Ordering the final result by rank alone, without a unique tie-breaker.

## 8. Interview Follow-ups

**1. Which would you use for 'the 2nd most expensive price level' in each category?**

`DENSE_RANK() = 2`, because it counts distinct price levels. With `RANK()`, a tie at the top means there may be no row with rank 2 at all.

**2. What does ROW_NUMBER() do with ties here?**

It gives tied rows different numbers in an arbitrary order unless you add a tie-breaker to the window's `ORDER BY`. That is useful when you need exactly N rows, but it hides the fact that prices are equal.

**3. Can you reuse the window definition?**

Yes. Declare `WINDOW w AS (PARTITION BY c.category_id ORDER BY p.unit_price DESC)` and write `RANK() OVER w`, `DENSE_RANK() OVER w`. This avoids repetition and guarantees both columns use the same window.

## 9. Key Takeaway

RANK skips numbers after ties, DENSE_RANK does not, ROW_NUMBER never ties. Pick based on how the question treats equal values.

---
📄 **SQL File:** [`Q148_Rank_Vs_Dense_Rank_Product_Prices.sql`](./Q148_Rank_Vs_Dense_Rank_Product_Prices.sql)

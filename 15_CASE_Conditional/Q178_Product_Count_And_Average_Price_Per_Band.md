# Q178 · Product Count And Average Price Per Band

> **Revision Card**
> **Category:** CASE Expressions (Grouping) | **Difficulty:** Easy
> **Concepts:** CASE in GROUP BY · COUNT · AVG · MIN · MAX
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Group by the same CASE expression (or its alias / ordinal), not by `unit_price`.

## 1. Problem

Following the price-band labels, pricing wants a summary: how many products fall into each band and their price range.

**Objective:** For each price band (Budget < 20, Mid-range < 50, Premium), return the product count, min, max and average price.

**Tables:** `products`

**Expected output:**

| Column | Description |
|--------|-------------|
| price_band | Budget / Mid-range / Premium |
| product_count | Number of products |
| min_price | Lowest price in band |
| max_price | Highest price in band |
| avg_price | Average price, 2 dp |

| price_band | product_count | min_price | max_price | avg_price |
|------------|---------------|-----------|-----------|-----------|
| Budget | 39 | 2.50 | 19.50 | 13.02 |
| Mid-range | 31 | 20.00 | 49.30 | 31.59 |
| Premium | 7 | 53.00 | 263.50 | 105.11 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Compute the band with `CASE`.
2. `GROUP BY` the band alias.
3. Aggregate `COUNT`, `MIN`, `MAX`, `AVG`.
4. Order by `min_price` so bands appear cheapest first.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    CASE
        WHEN unit_price < 20 THEN 'Budget'
        WHEN unit_price < 50 THEN 'Mid-range'
        ELSE 'Premium'
    END AS price_band,
    COUNT(*)                  AS product_count,
    MIN(unit_price)           AS min_price,
    MAX(unit_price)           AS max_price,
    ROUND(AVG(unit_price), 2) AS avg_price
FROM products
GROUP BY price_band
ORDER BY min_price;
```

## 6. Why This Works

PostgreSQL allows `GROUP BY` an output-column alias, so the `CASE` is written once. Each row is bucketed first, then the aggregates run per bucket. The bands do not overlap, so `min_price` is unique per band and gives a natural low-to-high order.

## 7. Common Pitfalls (generic)

- Grouping by `unit_price` — you get one row per price, not per band.
- Ordering by `price_band` alphabetically: Budget, Mid-range, Premium happens to work here, but generally it will not.
- Using an alias in `WHERE`/`HAVING` — not allowed; repeat the expression or wrap in a subquery.

## 8. Interview Follow-ups

**1. Is `GROUP BY alias` standard SQL?**

No — it is a PostgreSQL/MySQL extension. Portable code repeats the `CASE` or groups in a derived table.

**2. How would you include bands with zero products?**

Generate the bands from a `VALUES` list and `LEFT JOIN` the products onto it.

**3. How would you get the share of products per band?**

`ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)`.

## 9. Key Takeaway

Bucket with `CASE`, group by the bucket, then aggregate — the CASE becomes the grouping key.

---
📄 **SQL File:** [`Q178_Product_Count_And_Average_Price_Per_Band.sql`](./Q178_Product_Count_And_Average_Price_Per_Band.sql)

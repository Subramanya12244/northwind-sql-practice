# Q128 · Product Price Bands

> **Revision Card**
> **Category:** CASE Expressions (Bucketing) | **Difficulty:** Easy
> **Concepts:** Searched CASE · WHEN Order · ELSE · Bucketing
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** `CASE` returns the first matching `WHEN`, so order the bounds from low to high (or high to low) consistently.

## 1. Problem

Pricing wants every product labelled Budget (under 20), Mid-range (20 to under 50) or Premium (50 and above).

**Objective:** Return each product with its price and price band.

**Tables:** `products`

**Expected output:**

| Column | Description |
|--------|-------------|
| product_id | Product identifier |
| product_name | Product name |
| unit_price | List price |
| price_band | Budget / Mid-range / Premium |

| product_id | product_name | unit_price | price_band |
|------------|--------------|------------|------------|
| 1 | Chai | 18.00 | Budget |
| 2 | Chang | 19.00 | Budget |
| 3 | Aniseed Syrup | 10.00 | Budget |
| 4 | Chef Anton's Cajun Seasoning | 22.00 | Mid-range |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Write a searched `CASE` with `WHEN unit_price < 20`, then `< 50`, then `ELSE`.
2. Order by `product_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    product_id,
    product_name,
    unit_price,
    CASE
        WHEN unit_price < 20 THEN 'Budget'
        WHEN unit_price < 50 THEN 'Mid-range'
        ELSE 'Premium'
    END AS price_band
FROM products
ORDER BY product_id;
```

## 6. Why This Works

`CASE` evaluates `WHEN` branches top to bottom and returns the first true one. Because a price below 20 has already matched the first branch, the second branch only needs `< 50` — no `BETWEEN` is needed, and there are no gaps or overlaps. `ELSE` catches everything else, including any unexpected high values.

## 7. Common Pitfalls (generic)

- Ordering branches wrongly (e.g. `< 50` first), so every budget product becomes Mid-range.
- Using `BETWEEN 20 AND 50` and `>= 50` — the value 50 then matches two ranges and only the first wins.
- Omitting `ELSE`: unmatched rows get NULL (here a NULL price would also fall to `ELSE`).

## 8. Interview Follow-ups

**1. Simple vs searched CASE?**

Simple: `CASE category_id WHEN 1 THEN ... END` compares one expression for equality. Searched: `CASE WHEN condition THEN ...` allows any predicate.

**2. How would you handle NULL prices?**

Add `WHEN unit_price IS NULL THEN 'Unpriced'` as the first branch.

**3. Where else can CASE appear?**

Anywhere an expression is allowed: `SELECT`, `WHERE`, `ORDER BY`, `GROUP BY`, inside aggregates and in `UPDATE ... SET`.

## 9. Key Takeaway

Order `CASE` branches so each bound only needs one comparison; first match wins.

---
📄 **SQL File:** [`Q128_Product_Price_Bands.sql`](./Q128_Product_Price_Bands.sql)

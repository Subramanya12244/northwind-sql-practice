# Q196 · Revenue By Discount Tier

> **Revision Card**
> **Category:** CASE & Conditional Logic (Bucketing a Float Column) | **Difficulty:** Medium
> **Concepts:** CASE · Half-open ranges · REAL precision · GROUP BY ordinal · SUM · AVG
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** discount is a REAL: 0.05 is stored as 0.0500000007, so `discount <= 0.05` is false. Use half-open ranges.

## 1. Problem

Finance wants to know whether larger discounts actually drive bigger orders, by comparing order lines in each discount tier.

**Objective:** Bucket order lines into No discount, Under 10%, 10% to under 15%, and 15% or more; show lines, units, net revenue (2 dp) and average quantity (1 dp) per tier, in tier order.

**Tables:** `order_details`

**Expected output:**

| Column | Description |
|--------|-------------|
| discount_tier | Tier label, numbered so it sorts correctly |
| order_lines | Number of order lines |
| units | Total quantity |
| net_revenue | SUM(unit_price × quantity × (1 − discount)), 2 dp |
| avg_quantity | Average quantity per line, 1 dp |

| discount_tier | order_lines | units | net_revenue | avg_quantity |
|---------------|-------------|-------|-------------|--------------|
| 1. No discount | 100 | 1920 | 48442.75 | 19.2 |
| 2. Under 10% | 50 | 1000 | 33669.89 | 20.0 |
| 3. 10% to under 15% | 50 | 1080 | 33360.69 | 21.6 |
| 4. 15% or more | 50 | 1080 | 22846.47 | 21.6 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. CASE with half-open ranges: = 0, < 0.1, < 0.15, else.
2. GROUP BY 1 groups by the CASE expression.
3. Number the labels so ORDER BY discount_tier sorts them in tier order.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT CASE
         WHEN discount = 0    THEN '1. No discount'
         WHEN discount < 0.1  THEN '2. Under 10%'
         WHEN discount < 0.15 THEN '3. 10% to under 15%'
         ELSE                      '4. 15% or more'
       END                                                          AS discount_tier,
       COUNT(*)                                                     AS order_lines,
       SUM(quantity)                                                AS units,
       ROUND(SUM(unit_price * quantity * (1 - discount))::numeric, 2) AS net_revenue,
       ROUND(AVG(quantity), 1)                                      AS avg_quantity
FROM order_details
GROUP BY 1
ORDER BY discount_tier;
```

## 6. Why This Works

CASE checks its branches top to bottom and stops at the first match, so each branch only needs an upper bound. The discount column is REAL (floating point): 0.05 is stored slightly above 0.05, so a boundary like `<= 0.05` silently moves lines into the next tier. Half-open ranges (`< 0.1`) put every stored value in exactly one tier.

## 7. Common Pitfalls (generic)

- Using <= on float boundaries, which misplaces values stored just above the boundary.
- Forgetting ELSE, which turns unexpected values into NULL tiers.
- Ordering by the label text without a prefix, which sorts '15% or more' before 'No discount'.

## 8. Interview Follow-ups

**1. How would you avoid float issues entirely?**

Store discounts as NUMERIC(4,3), or compare ROUND(discount::numeric, 3).

**2. How would you show tiers with no lines?**

Generate the tier list in a VALUES list and LEFT JOIN the grouped result to it.

**3. How would you show each tier's share of revenue?**

Add ROUND(100 * SUM(...) / SUM(SUM(...)) OVER (), 1) as a window over the grouped rows.

## 9. Key Takeaway

Bucket with half-open ranges, especially on floating-point columns; boundaries with = are fragile.

---
📄 **SQL File:** [`Q196_Revenue_By_Discount_Tier.sql`](./Q196_Revenue_By_Discount_Tier.sql)

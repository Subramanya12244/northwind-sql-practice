# Q131 · Pivot Category Revenue By Year

> **Revision Card**
> **Category:** Conditional Aggregation (Pivot) | **Difficulty:** Medium
> **Concepts:** Pivot · SUM FILTER · EXTRACT · COALESCE · JOIN
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** A FILTER with no matching rows returns NULL, not 0 — wrap in `COALESCE` for a clean pivot.

## 1. Problem

Finance wants a cross-tab with one row per category and one revenue column per year (1996, 1997, 1998) for the board pack.

**Objective:** Return net revenue per category for 1996, 1997 and 1998 as separate columns, plus a total column, each rounded to 2 dp.

**Tables:** `categories`, `products`, `order_details`, `orders`

**Expected output:**

| Column | Description |
|--------|-------------|
| category_name | Category name |
| rev_1996 | Net revenue in 1996 |
| rev_1997 | Net revenue in 1997 |
| rev_1998 | Net revenue in 1998 |
| rev_total | Net revenue, all years |

| category_name | rev_1996 | rev_1997 | rev_1998 | rev_total |
|---------------|----------|----------|----------|-----------|
| Beverages | 11705.40 | 4772.42 | 12857.70 | 29335.52 |
| Condiments | 6030.69 | 5794.68 | 3351.39 | 15176.76 |
| Confections | 7799.85 | 5119.97 | 7592.03 | 20511.84 |
| Dairy Products | 7423.72 | 6741.73 | 4164.32 | 18329.78 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Join categories → products → order_details → orders.
2. For each year, `SUM(net) FILTER (WHERE EXTRACT(YEAR FROM order_date) = yyyy)`.
3. `COALESCE(..., 0)` and round each column.
4. Group by category and order by `category_name`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    c.category_name,
    ROUND(COALESCE(SUM(od.unit_price * od.quantity * (1 - od.discount))
          FILTER (WHERE EXTRACT(YEAR FROM o.order_date) = 1996), 0)::numeric, 2) AS rev_1996,
    ROUND(COALESCE(SUM(od.unit_price * od.quantity * (1 - od.discount))
          FILTER (WHERE EXTRACT(YEAR FROM o.order_date) = 1997), 0)::numeric, 2) AS rev_1997,
    ROUND(COALESCE(SUM(od.unit_price * od.quantity * (1 - od.discount))
          FILTER (WHERE EXTRACT(YEAR FROM o.order_date) = 1998), 0)::numeric, 2) AS rev_1998,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2)    AS rev_total
FROM categories c
JOIN products p       ON p.category_id = c.category_id
JOIN order_details od ON od.product_id = p.product_id
JOIN orders o         ON o.order_id    = od.order_id
GROUP BY c.category_id, c.category_name
ORDER BY c.category_name;
```

## 6. Why This Works

A pivot turns row values (years) into columns. With conditional aggregation each output column is one aggregate restricted to one year, all computed in a single scan of the joined rows. `COALESCE` turns the NULL of an empty year into 0, and the unfiltered `SUM` gives the row total.

## 7. Common Pitfalls (generic)

- Grouping by year as well — that un-pivots the result back into rows.
- Forgetting that a year with no sales gives NULL, which breaks later arithmetic.
- Hard-coding years means a new year needs a query change; dynamic pivots need `crosstab()` or application code.

## 8. Interview Follow-ups

**1. What is `crosstab()`?**

A function in the `tablefunc` extension that pivots a (row, column, value) query; it still needs the output columns declared.

**2. How would you add year-over-year growth?**

Compute `rev_1997 - rev_1996` in an outer query, or `NULLIF(rev_1996, 0)` in a division for percentage growth.

**3. How would you un-pivot back?**

`CROSS JOIN LATERAL (VALUES (1996, rev_1996), (1997, rev_1997), (1998, rev_1998)) v(yr, rev)`.

## 9. Key Takeaway

Pivot = `GROUP BY` the row key + one `SUM(...) FILTER (WHERE col = value)` per output column.

---
📄 **SQL File:** [`Q131_Pivot_Category_Revenue_By_Year.sql`](./Q131_Pivot_Category_Revenue_By_Year.sql)

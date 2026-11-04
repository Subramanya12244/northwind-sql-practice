# Q152 · Month Over Month Revenue Change

> **Revision Card**
> **Category:** Window Functions (Offset) | **Difficulty:** Medium
> **Concepts:** LAG · NULLIF · Percent Change · DATE_TRUNC · CTE
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** The first month has no previous month, so LAG returns NULL; guard the division with NULLIF.

## 1. Problem

The finance team wants a month-over-month report: each month's revenue, the previous month's revenue, the absolute change, and the percentage change.

**Objective:** For each order month, return revenue, previous month revenue (via `LAG`), absolute change, and percent change rounded to 2 dp.

**Tables:** `orders`, `order_details`

**Expected output:**

| Column | Description |
|--------|-------------|
| order_month | First day of the order month |
| monthly_revenue | Net revenue this month, 2 dp |
| prev_month_revenue | Net revenue of the previous month in the series (NULL for the first) |
| revenue_change | monthly_revenue − prev_month_revenue, 2 dp |
| pct_change | Percent change vs previous month, 2 dp |

| order_month | monthly_revenue | prev_month_revenue | revenue_change | pct_change |
|-------------|-----------------|--------------------|----------------|------------|
| 1996-01-01 | 5217.41 | NULL | NULL | NULL |
| 1996-04-01 | 18574.06 | 5217.41 | 13356.64 | 256.00 |
| 1996-07-01 | 19336.35 | 18574.06 | 762.29 | 4.10 |
| 1996-10-01 | 9197.44 | 19336.35 | -10138.91 | -52.43 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. CTE `monthly`: revenue per month.
2. CTE `with_prev`: add `LAG(revenue) OVER (ORDER BY order_month)`.
3. Compute change and `100.0 * change / NULLIF(prev, 0)`; round and order by month.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::date AS order_month,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS revenue
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY DATE_TRUNC('month', o.order_date)
),
with_prev AS (
    SELECT
        order_month,
        revenue,
        LAG(revenue) OVER (ORDER BY order_month) AS prev_revenue
    FROM monthly
)
SELECT
    order_month,
    ROUND(revenue::numeric, 2)                  AS monthly_revenue,
    ROUND(prev_revenue::numeric, 2)             AS prev_month_revenue,
    ROUND((revenue - prev_revenue)::numeric, 2) AS revenue_change,
    ROUND((100.0 * (revenue - prev_revenue) / NULLIF(prev_revenue, 0))::numeric, 2) AS pct_change
FROM with_prev
ORDER BY order_month;
```

## 6. Why This Works

`LAG(x)` reads the value of `x` from the previous row in the window order, so each month can see the prior month without a self-join. Computing `LAG` in its own CTE keeps the arithmetic readable.

The first row has no predecessor, so `LAG` returns NULL and the change columns are NULL too — correct, since there is nothing to compare. `NULLIF(prev_revenue, 0)` stops a divide-by-zero if a prior month had zero revenue. `100.0` forces decimal arithmetic.

## 7. Common Pitfalls (generic)

- Dividing by the previous value without `NULLIF`, which risks a division-by-zero error.
- Using integer arithmetic, which truncates percentages.
- Calling the previous row 'last month' when months are missing from the series.
- Getting the sign backwards: (current − previous) / previous, not the reverse.

## 8. Interview Follow-ups

**1. How would you compare to the same month last year?**

Use `LAG(revenue, 12) OVER (ORDER BY order_month)` if every month is present. A safer option is a self-join on `order_month - INTERVAL '1 year'`, which does not depend on the series being complete.

**2. How do you replace the first NULL with 0?**

`LAG(revenue, 1, 0)` takes a default as the third argument. Be careful: then the percent change divides by 0, which `NULLIF` turns back into NULL.

**3. How would you do this per category?**

Group by category and month in the CTE, then use `LAG(revenue) OVER (PARTITION BY category_id ORDER BY order_month)`. Each category's series is compared only with itself.

## 9. Key Takeaway

`LAG()` compares a row with its predecessor without a self-join; guard percentage math with `NULLIF`.

---
📄 **SQL File:** [`Q152_Month_Over_Month_Revenue_Change.sql`](./Q152_Month_Over_Month_Revenue_Change.sql)

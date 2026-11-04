# Q101 · Running Total Of Monthly Revenue

> **Revision Card**
> **Category:** Window Functions (Aggregate Windows) | **Difficulty:** Easy
> **Concepts:** SUM OVER · ROWS BETWEEN UNBOUNDED PRECEDING · DATE_TRUNC · CTE
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Aggregate to one row per month first; then SUM() OVER (ORDER BY month) gives the cumulative total.

## 1. Problem

Finance wants a cumulative revenue chart: each month's net revenue alongside the revenue accumulated from the first month up to and including that month.

**Objective:** Return one row per order month with its revenue and the running total of revenue to date.

**Tables:** `orders`, `order_details`

**Expected output:**

| Column | Description |
|--------|-------------|
| order_month | First day of the order month |
| monthly_revenue | Net revenue in that month, 2 dp |
| running_revenue | Cumulative net revenue up to and including that month, 2 dp |

| order_month | monthly_revenue | running_revenue |
|-------------|-----------------|-----------------|
| 1996-01-01 | 5217.41 | 5217.41 |
| 1996-04-01 | 18574.06 | 23791.47 |
| 1996-07-01 | 19336.35 | 43127.82 |
| 1996-10-01 | 9197.44 | 52325.26 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. CTE `monthly`: `DATE_TRUNC('month', order_date)` and sum net revenue per month.
2. Outer query: `SUM(revenue) OVER (ORDER BY order_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`.
3. Round both values and order by month.

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
)
SELECT
    order_month,
    ROUND(revenue::numeric, 2) AS monthly_revenue,
    ROUND(SUM(revenue) OVER (ORDER BY order_month
                             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)::numeric, 2) AS running_revenue
FROM monthly
ORDER BY order_month;
```

## 6. Why This Works

Adding `ORDER BY` inside `OVER()` turns an aggregate into a cumulative one: each row sees the frame from the first row up to itself. Writing `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` explicitly avoids the default `RANGE` frame, which treats peers (equal sort values) as one group. Months are unique here, so both give the same answer, but `ROWS` states the intent.

Grouping by month first matters. A running sum over raw order lines would produce one row per line, not one per month.

## 7. Common Pitfalls (generic)

- Running the window over order lines instead of monthly totals.
- Leaving out `ORDER BY` in `OVER()`, which gives the grand total on every row.
- Relying on the default `RANGE` frame when the sort key has duplicates, which jumps whole groups at once.
- Rounding each month before summing, which accumulates rounding error.

## 8. Interview Follow-ups

**1. How would you reset the running total each year?**

Add `PARTITION BY EXTRACT(YEAR FROM order_month)` to the window. The cumulative sum then restarts in January of each year — a year-to-date figure.

**2. What's the difference between ROWS and RANGE frames?**

`ROWS` counts physical rows. `RANGE` groups rows with equal `ORDER BY` values as peers and includes all of them together. With duplicate sort values, `RANGE` gives the same running total to all peers.

**3. Months with no orders are missing — how would you include them?**

Generate a calendar with `generate_series(min_month, max_month, interval '1 month')` and `LEFT JOIN` the monthly totals onto it, using `COALESCE(revenue, 0)`. The running total then has a row, flat, for empty months.

## 9. Key Takeaway

Running total = `SUM(x) OVER (ORDER BY t ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)` over pre-aggregated rows.

---
📄 **SQL File:** [`Q101_Running_Total_Of_Monthly_Revenue.sql`](./Q101_Running_Total_Of_Monthly_Revenue.sql)

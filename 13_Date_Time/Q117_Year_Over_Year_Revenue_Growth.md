# Q117 · Year Over Year Revenue Growth

> **Revision Card**
> **Category:** Date & Time (Window Functions over Periods) | **Difficulty:** Hard
> **Concepts:** CTE · LAG · Window Functions · NULLIF · Percentage Calculation · ROUND
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** compute growth from unrounded totals and guard the divisor with NULLIF; the first year has no prior year, so its growth is NULL.

## 1. Problem

The CFO wants a yearly revenue trend: total net revenue per calendar year, the previous year's revenue, and the year-over-year growth percentage.

**Objective:** Return yearly net revenue, previous year's revenue and YoY growth % (all rounded to 2 decimals).

**Tables:** `orders`, `order_details`

**Expected output:**

| Column | Description |
|--------|-------------|
| order_year | Calendar year (integer) |
| revenue | Net revenue for the year |
| prev_year_revenue | Revenue of the preceding year (NULL for the first year) |
| yoy_growth_pct | (revenue − prev) × 100 / prev, rounded to 2 decimals |

| order_year | revenue | prev_year_revenue | yoy_growth_pct |
|---|---|---|---|
| 1996 | 52325.26 | NULL | NULL |
| 1997 | 40058.78 | 52325.26 | -23.44 |
| 1998 | 45935.76 | 40058.78 | 14.67 |

*(Sample rows are illustrative — taken from the practice dataset to show shape/format; your instance may differ.)*

## 2. My Approach

1. CTE `yearly`: sum net revenue per `EXTRACT(YEAR ...)::int`.
2. Use `LAG(revenue) OVER (ORDER BY order_year)` for the prior year.
3. Growth % = `(revenue - prev) * 100.0 / NULLIF(prev, 0)`.
4. Round each output column and order by year.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH yearly AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date)::int AS order_year,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS revenue
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY EXTRACT(YEAR FROM o.order_date)
)
SELECT
    order_year,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY order_year)::numeric, 2) AS prev_year_revenue,
    ROUND(((revenue - LAG(revenue) OVER (ORDER BY order_year)) * 100.0
           / NULLIF(LAG(revenue) OVER (ORDER BY order_year), 0))::numeric, 2) AS yoy_growth_pct
FROM yearly
ORDER BY order_year;
```

## 6. Why This Works

Aggregating first, then windowing, means `LAG` looks at one row per year. `LAG` reads the previous row in the window order without a self-join. Rounding only at output time avoids compounding rounding error in the percentage, and `NULLIF(prev, 0)` prevents division by zero.

## 7. Common Pitfalls (generic)

- Applying LAG before aggregating, so the previous row is just another order line.
- Integer division when both sides are integers — multiply by `100.0`.
- Rounding the yearly totals before computing growth, introducing small errors.
- Assuming consecutive rows are consecutive years; a missing year makes LAG compare non-adjacent years.

## 8. Interview Follow-ups

**1. How would you write this with a self-join instead of LAG?**

Join the yearly CTE to itself on `cur.order_year = prev.order_year + 1` with a LEFT JOIN. This also handles missing years correctly, because a gap produces NULL instead of silently comparing with an older year.

**2. Is comparing full years fair if the last year is incomplete?**

No — partial periods distort growth. Compare year-to-date windows instead, e.g. orders up to the same day-of-year in each year, or annualise the partial year and say so.

**3. How would you compute month-over-month growth by year and month?**

Group by `DATE_TRUNC('month', order_date)` and use `LAG(revenue) OVER (ORDER BY month)`. For same-month-last-year, use `LAG(revenue, 12)` only if every month exists, or a self-join on `month - INTERVAL '1 year'`.

## 9. Key Takeaway

Aggregate to one row per period, then `LAG` over the period order; compute growth on unrounded values with `NULLIF` on the divisor.

---
📄 **SQL File:** [`Q117_Year_Over_Year_Revenue_Growth.sql`](./Q117_Year_Over_Year_Revenue_Growth.sql)

# Q102 · Three Month Moving Average Revenue

> **Revision Card**
> **Category:** Window Functions (Sliding Frames) | **Difficulty:** Medium
> **Concepts:** AVG OVER · ROWS BETWEEN 2 PRECEDING · Named WINDOW · DATE_TRUNC · CTE
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** The first two rows have partial windows; show months_in_window so the reader knows the average is not over 3 months.

## 1. Problem

Leadership wants revenue trends smoothed out. For each month, report the revenue and the average of that month plus the two months before it (a trailing 3-month moving average).

**Objective:** Return each order month's revenue, the number of months in its trailing window, and the 3-month trailing moving average.

**Tables:** `orders`, `order_details`

**Expected output:**

| Column | Description |
|--------|-------------|
| order_month | First day of the order month |
| monthly_revenue | Net revenue in that month, 2 dp |
| months_in_window | Number of months averaged (1–3) |
| moving_avg_3m | Average revenue of this month and up to 2 prior months, 2 dp |

| order_month | monthly_revenue | months_in_window | moving_avg_3m |
|-------------|-----------------|------------------|---------------|
| 1996-01-01 | 5217.41 | 1 | 5217.41 |
| 1996-04-01 | 18574.06 | 2 | 11895.73 |
| 1996-07-01 | 19336.35 | 3 | 14375.94 |
| 1996-10-01 | 9197.44 | 3 | 15702.61 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. CTE `monthly`: revenue per `DATE_TRUNC('month', order_date)`.
2. Define `WINDOW w AS (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)`.
3. Compute `AVG(revenue) OVER w` and `COUNT(*) OVER w`; round and order by month.

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
    COUNT(*) OVER w AS months_in_window,
    ROUND(AVG(revenue) OVER w::numeric, 2) AS moving_avg_3m
FROM monthly
WINDOW w AS (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
ORDER BY order_month;
```

## 6. Why This Works

A sliding frame limits each row's window to a fixed number of neighbours. `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` covers the current row and the two rows before it, so `AVG` over that frame is a trailing 3-row average. The named `WINDOW` clause lets `AVG` and `COUNT` share exactly the same frame.

At the start of the series there are fewer than two prior rows, so the frame shrinks. `months_in_window` makes that visible so the first values are not mistaken for full 3-month averages.

Note that `ROWS` counts rows, not calendar months. If a month has no orders, the window reaches further back in time.

## 7. Common Pitfalls (generic)

- Using `RANGE` instead of `ROWS` and getting a different frame than intended.
- Assuming the frame is 3 calendar months when months are missing from the data.
- Not flagging partial windows at the start of the series.
- Computing the moving average over raw order lines instead of monthly totals.

## 8. Interview Follow-ups

**1. How would you make the window exactly 3 calendar months, even with gaps?**

Use `RANGE BETWEEN INTERVAL '2 months' PRECEDING AND CURRENT ROW` on the date column, which PostgreSQL 11+ supports. Or fill missing months with a `generate_series` calendar first, so `ROWS` lines up with months.

**2. How would you return NULL until a full 3 months are available?**

Wrap it: `CASE WHEN COUNT(*) OVER w = 3 THEN AVG(revenue) OVER w END`. This avoids showing averages based on only one or two months.

**3. What about a centred moving average?**

Use `ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING`. Each month is then averaged with its neighbours on both sides, which smooths without lag but needs future data.

## 9. Key Takeaway

Moving averages use a bounded frame: `AVG(x) OVER (ORDER BY t ROWS BETWEEN n-1 PRECEDING AND CURRENT ROW)`.

---
📄 **SQL File:** [`Q102_Three_Month_Moving_Average_Revenue.sql`](./Q102_Three_Month_Moving_Average_Revenue.sql)

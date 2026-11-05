# Q198 · Selling Periods From Order Dates (Gaps And Islands)

> **Revision Card**
> **Category:** Date & Time (Gaps and Islands) | **Difficulty:** Hard
> **Concepts:** Gaps and islands · LAG · Running SUM as a group id · Date arithmetic · CTE pipeline
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Flag the first row of each island (gap > 7 days), then a running SUM of the flags numbers the islands.

## 1. Problem

Orders arrive in bursts. Sales planning wants each selling period: when it started and ended, how many orders it had and the revenue, where a period ends once more than a week passes without an order.

**Objective:** Group order dates into periods in which consecutive order dates are at most 7 days apart. For each period show its number, start date, end date, orders and revenue (2 dp), in date order.

**Tables:** `orders`, `order_details`

**Expected output:**

| Column | Description |
|--------|-------------|
| period_no | Selling period number |
| period_start | First order date in the period |
| period_end | Last order date in the period |
| orders | Orders in the period |
| revenue | Net revenue, 2 dp |

| period_no | period_start | period_end | orders | revenue |
|-----------|--------------|------------|--------|---------|
| 1 | 1996-01-01 | 1996-01-25 | 9 | 5217.41 |
| 2 | 1996-04-04 | 1996-04-28 | 9 | 18574.06 |
| 3 | 1996-07-03 | 1996-07-27 | 8 | 19336.35 |
| 4 | 1996-10-02 | 1996-10-26 | 8 | 9197.44 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Aggregate to one row per order date (orders, revenue).
2. Flag a new period when the gap to the previous date (LAG) is over 7 days or there is no previous date.
3. Running SUM of the flags gives each row its period number; group by it.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH days AS (
    SELECT o.order_date,
           COUNT(DISTINCT o.order_id)                                   AS orders,
           SUM(d.unit_price * d.quantity * (1 - d.discount))::numeric   AS revenue
    FROM orders o
    JOIN order_details d ON d.order_id = o.order_id
    GROUP BY o.order_date
),
flagged AS (
    SELECT *,
           CASE WHEN order_date - LAG(order_date) OVER (ORDER BY order_date) <= 7 THEN 0 ELSE 1 END AS new_period
    FROM days
),
numbered AS (
    SELECT *, SUM(new_period) OVER (ORDER BY order_date) AS period_no
    FROM flagged
)
SELECT period_no,
       MIN(order_date)          AS period_start,
       MAX(order_date)          AS period_end,
       SUM(orders)              AS orders,
       ROUND(SUM(revenue), 2)   AS revenue
FROM numbered
GROUP BY period_no
ORDER BY period_no;
```

## 6. Why This Works

This is the classic gaps-and-islands pattern. LAG compares each date with the previous one; a large gap marks the start of a new island. A running SUM over those 0/1 flags increases by one at each start, so every date inside an island shares the same number, and grouping by it yields one row per period.

## 7. Common Pitfalls (generic)

- Comparing each date with the first date of the period instead of the previous date.
- Forgetting that LAG returns NULL on the first row: NULL <= 7 is not true, so the CASE correctly starts period 1 — keep it that way.
- Grouping order lines instead of order dates first, which counts lines rather than orders.

## 8. Interview Follow-ups

**1. How would you find the longest quiet gap between periods?**

Take LAG(period_end) OVER (ORDER BY period_no) and subtract it from period_start.

**2. How does the ROW_NUMBER trick differ?**

date − ROW_NUMBER() days is constant for consecutive days, which finds strictly consecutive runs; the LAG + SUM version allows a tolerance like 7 days.

**3. How would you do this per customer?**

Add PARTITION BY customer_id to both window functions and group by customer and period.

## 9. Key Takeaway

Gaps and islands: flag where a new island starts, running-SUM the flags into an island id, then aggregate by it.

---
📄 **SQL File:** [`Q198_Selling_Periods_From_Order_Dates_Gaps_And_Islands.sql`](./Q198_Selling_Periods_From_Order_Dates_Gaps_And_Islands.sql)

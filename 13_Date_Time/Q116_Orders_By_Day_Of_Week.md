# Q116 · Orders By Day Of Week

> **Revision Card**
> **Category:** Date & Time (Weekday Patterns) | **Difficulty:** Medium
> **Concepts:** EXTRACT(ISODOW) · TO_CHAR · TRIM · JOIN · COUNT DISTINCT · SUM
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** TO_CHAR(..., 'Day') pads names to 9 characters and sorts alphabetically — sort by a numeric day number instead.

## 1. Problem

Marketing wants to know which weekdays generate the most orders and revenue to plan promotions. Summarise all orders by day of the week, Monday first.

**Objective:** Return order count and net revenue for each day of the week, ordered Monday through Sunday.

**Tables:** `orders`, `order_details`

**Expected output:**

| Column | Description |
|--------|-------------|
| day_number | ISO day of week, 1 = Monday … 7 = Sunday |
| day_name | Trimmed weekday name |
| order_count | Distinct orders placed on that weekday |
| revenue | Net revenue, rounded to 2 decimals |

| day_number | day_name | order_count | revenue |
|---|---|---|---|
| 1 | Monday | 14 | 12496.18 |
| 2 | Tuesday | 15 | 21052.53 |
| 3 | Wednesday | 13 | 19259.98 |
| 4 | Thursday | 14 | 24571.98 |

*(Sample rows are illustrative — taken from the practice dataset to show shape/format; your instance may differ.)*

## 2. My Approach

1. Join `orders` to `order_details`.
2. Derive `EXTRACT(ISODOW ...)::int` and `TRIM(TO_CHAR(order_date, 'Day'))`.
3. Group by both; count distinct orders and sum net revenue.
4. Order by `day_number`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    EXTRACT(ISODOW FROM o.order_date)::int AS day_number,
    TRIM(TO_CHAR(o.order_date, 'Day'))     AS day_name,
    COUNT(DISTINCT o.order_id)             AS order_count,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS revenue
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
GROUP BY EXTRACT(ISODOW FROM o.order_date), TRIM(TO_CHAR(o.order_date, 'Day'))
ORDER BY day_number;
```

## 6. Why This Works

`ISODOW` numbers Monday as 1 and Sunday as 7, so sorting by it gives a business-friendly week. `DOW` would put Sunday at 0. `TO_CHAR(..., 'Day')` produces a blank-padded name, so `TRIM` cleans it. `day_number` is unique per row, so it is a complete ORDER BY.

## 7. Common Pitfalls (generic)

- Sorting by the day name, giving Friday, Monday, Saturday … alphabetically.
- Forgetting `TRIM`, leaving names like `'Monday   '` that fail equality checks.
- Using `DOW` and being surprised that Sunday = 0 sorts first.
- Weekday names from `TO_CHAR` depend on `lc_time` locale if you use the `TMDay` pattern.

## 8. Interview Follow-ups

**1. What is the difference between DOW and ISODOW?**

`DOW` returns 0 (Sunday) to 6 (Saturday), the US convention. `ISODOW` returns 1 (Monday) to 7 (Sunday), the ISO 8601 convention; only Sunday differs.

**2. How would you compare weekday versus weekend revenue?**

Group by `CASE WHEN EXTRACT(ISODOW FROM order_date) >= 6 THEN 'Weekend' ELSE 'Weekday' END`. Because there are 5 weekdays and 2 weekend days, compare averages per day, not just totals.

**3. How would you show the average orders per Monday rather than total?**

Count distinct Mondays in the range, e.g. via `generate_series`, and divide total Monday orders by that count with numeric division. Counting only Mondays that had orders would overstate the average.

## 9. Key Takeaway

Group weekdays by a numeric `ISODOW` key for correct ordering, and display a trimmed `TO_CHAR` name alongside it.

---
📄 **SQL File:** [`Q116_Orders_By_Day_Of_Week.sql`](./Q116_Orders_By_Day_Of_Week.sql)

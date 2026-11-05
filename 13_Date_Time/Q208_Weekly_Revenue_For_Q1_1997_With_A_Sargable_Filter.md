# Q208 · Weekly Revenue For Q1 1997 With A Sargable Filter

> **Revision Card**
> **Category:** Date & Time (Sargable Ranges and Calendar Fill) | **Difficulty:** Hard
> **Concepts:** Sargable range predicate · DATE_TRUNC('week') · GENERATE_SERIES · LEFT JOIN · COALESCE · Query optimization
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Filter with order_date >= '1997-01-01' AND < '1997-04-01', not EXTRACT(...) on the column, so an index can be used.

## 1. Problem

Finance needs weekly revenue for the first quarter of 1997, including weeks with no sales, and the query must stay fast as the orders table grows.

**Objective:** Show net revenue (2 dp, 0 for weeks without orders) for every Monday-starting week overlapping Q1 1997, from the week of 1996-12-30 to the week of 1997-03-24.

**Tables:** `orders`, `order_details`

**Expected output:**

| Column | Description |
|--------|-------------|
| week_start | Monday of the week |
| revenue | Net revenue in Q1 1997 for that week, 2 dp; 0 when none |

| week_start | revenue |
|------------|---------|
| 1996-12-30 | 0 |
| 1997-01-06 | 0 |
| 1997-01-13 | 0 |
| 1997-01-20 | 0 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. GENERATE_SERIES produces every Monday from 1996-12-30 to 1997-03-24.
2. A CTE sums revenue per DATE_TRUNC('week', order_date) for orders in [1997-01-01, 1997-04-01).
3. LEFT JOIN the weeks to the totals and COALESCE missing weeks to 0.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH weeks AS (
    SELECT w::date AS week_start
    FROM GENERATE_SERIES(DATE '1996-12-30', DATE '1997-03-24', INTERVAL '7 days') AS w
),
q1 AS (
    SELECT DATE_TRUNC('week', o.order_date)::date AS week_start,
           SUM(d.unit_price * d.quantity * (1 - d.discount))::numeric AS revenue
    FROM orders o
    JOIN order_details d ON d.order_id = o.order_id
    WHERE o.order_date >= DATE '1997-01-01'
      AND o.order_date <  DATE '1997-04-01'
    GROUP BY 1
)
SELECT w.week_start, COALESCE(ROUND(q1.revenue, 2), 0) AS revenue
FROM weeks w
LEFT JOIN q1 ON q1.week_start = w.week_start
ORDER BY w.week_start;
```

## 6. Why This Works

A predicate is sargable when it compares the bare column with constants; wrapping the column in EXTRACT or DATE_TRUNC hides it from indexes and forces every row to be evaluated. The half-open range [1997-01-01, 1997-04-01) also avoids end-of-day and timestamp issues. Weeks come from GENERATE_SERIES, because grouping the orders alone would skip weeks with no sales.

## 7. Common Pitfalls (generic)

- WHERE EXTRACT(QUARTER FROM order_date) = 1 AND EXTRACT(YEAR …) = 1997, which can't use an index on order_date.
- BETWEEN '1997-01-01' AND '1997-03-31' on a timestamp column, which misses most of 31 March.
- Grouping orders only, which leaves out empty weeks.

## 8. Interview Follow-ups

**1. How do you prove the filter uses an index?**

Create an index on orders(order_date) and compare EXPLAIN for the range filter and the EXTRACT filter.

**2. Why does the first week start in December 1996?**

1 January 1997 was a Wednesday; DATE_TRUNC('week') moves it to Monday 30 December.

**3. How would you report ISO weeks instead?**

Use TO_CHAR(order_date, 'IYYY-IW') or EXTRACT(WEEK …) for labels, while keeping the range filter.

## 9. Key Takeaway

Filter dates with a half-open range on the bare column (sargable), and fill calendar gaps with GENERATE_SERIES.

---
📄 **SQL File:** [`Q208_Weekly_Revenue_For_Q1_1997_With_A_Sargable_Filter.sql`](./Q208_Weekly_Revenue_For_Q1_1997_With_A_Sargable_Filter.sql)

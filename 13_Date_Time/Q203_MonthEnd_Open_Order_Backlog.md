# Q203 · Month-End Open Order Backlog

> **Revision Card**
> **Category:** Date & Time (Calendar Series and Point-in-Time State) | **Difficulty:** Hard
> **Concepts:** GENERATE_SERIES · Month-end dates · Point-in-time join conditions · LEFT JOIN · COALESCE
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** An order is open at a month end if it was placed by then and not yet shipped by then (or never shipped).

## 1. Problem

Operations reports the backlog at every month end of 1997: how many orders were placed but not yet shipped, and how old they were on average.

**Objective:** For each month end in 1997, count orders that were open at that date and their average age in days (1 dp, 0 when none), in date order.

**Tables:** `orders`

**Expected output:**

| Column | Description |
|--------|-------------|
| month_end | Last day of the month |
| open_orders | Orders placed on or before month_end and not shipped by then |
| avg_age_days | Average days since those orders were placed, 1 dp; 0 when none |

| month_end | open_orders | avg_age_days |
|-----------|-------------|--------------|
| 1997-01-31 | 5 | 278.2 |
| 1997-02-28 | 7 | 222.1 |
| 1997-03-31 | 6 | 287.2 |
| 1997-04-30 | 6 | 317.2 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. GENERATE_SERIES over the 12 months, converted to month-end dates.
2. LEFT JOIN orders where order_date <= month_end AND (shipped_date IS NULL OR shipped_date > month_end).
3. Count orders and average month_end − order_date per month end.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH month_ends AS (
    SELECT (DATE_TRUNC('month', d) + INTERVAL '1 month - 1 day')::date AS month_end
    FROM GENERATE_SERIES(DATE '1997-01-01', DATE '1997-12-01', INTERVAL '1 month') AS d
)
SELECT me.month_end,
       COUNT(o.order_id) AS open_orders,
       COALESCE(ROUND(AVG(me.month_end - o.order_date), 1), 0) AS avg_age_days
FROM month_ends me
LEFT JOIN orders o
       ON o.order_date <= me.month_end
      AND (o.shipped_date IS NULL OR o.shipped_date > me.month_end)
GROUP BY me.month_end
ORDER BY me.month_end;
```

## 6. Why This Works

Backlog is state at a point in time, so each month end is joined to the orders that were open on that date, not to orders placed in that month. GENERATE_SERIES supplies every month end even when nothing was open, and the LEFT JOIN keeps those months with a count of 0. Orders that were never shipped count as open at every later month end.

## 7. Common Pitfalls (generic)

- Grouping orders by order month, which counts new orders instead of open ones.
- Treating NULL shipped_date as shipped: the condition must test IS NULL.
- An inner join, which drops month ends with no open orders.

## 8. Interview Follow-ups

**1. How would you compute the backlog for every day?**

Use GENERATE_SERIES with a 1-day step; the join condition stays the same.

**2. How would you split the backlog by employee?**

Add employee_id to the grouping and the select list.

**3. How do you make this fast on large tables?**

Index on (order_date) and on (shipped_date), or maintain a daily snapshot table.

## 9. Key Takeaway

Point-in-time questions join a calendar to rows that were 'active' on each date.

---
📄 **SQL File:** [`Q203_MonthEnd_Open_Order_Backlog.sql`](./Q203_MonthEnd_Open_Order_Backlog.sql)

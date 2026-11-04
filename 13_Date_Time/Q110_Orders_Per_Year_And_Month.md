# Q110 · Orders Per Year And Month

> **Revision Card**
> **Category:** Date & Time (Grouping by Period) | **Difficulty:** Easy
> **Concepts:** EXTRACT · GROUP BY · COUNT · Integer Casting
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** group by both year AND month — grouping by month alone merges January 1996 with January 1997.

## 1. Problem

The operations team wants a simple monthly activity report showing how many orders were placed in each calendar month of each year, so they can spot busy and quiet periods.

**Objective:** Return the number of orders placed per calendar year and month, with year and month as integers.

**Tables:** `orders`

**Expected output:**

| Column | Description |
|--------|-------------|
| order_year | Calendar year of order_date (integer) |
| order_month | Calendar month 1–12 of order_date (integer) |
| order_count | Number of orders placed in that year-month |

| order_year | order_month | order_count |
|---|---|---|
| 1996 | 1 | 9 |
| 1996 | 4 | 9 |
| 1996 | 7 | 8 |
| 1996 | 10 | 8 |

*(Sample rows are illustrative — taken from the practice dataset to show shape/format; your instance may differ.)*

## 2. My Approach

1. Extract the year and month from `order_date` with `EXTRACT(...)::int`.
2. Group by both parts and `COUNT(*)` the orders.
3. Order by year, then month.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    EXTRACT(YEAR FROM order_date)::int  AS order_year,
    EXTRACT(MONTH FROM order_date)::int AS order_month,
    COUNT(*)                            AS order_count
FROM orders
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY order_year, order_month;
```

## 6. Why This Works

`EXTRACT(YEAR ...)` and `EXTRACT(MONTH ...)` turn a DATE into numeric parts that can be grouped. Grouping on the pair (year, month) keeps each calendar month of each year separate. `EXTRACT` returns `numeric` in PostgreSQL 14+, so the `::int` cast gives clean integer output. Only months that actually contain orders appear — there is no gap-filling.

## 7. Common Pitfalls (generic)

- Grouping by month only, which merges the same month across different years.
- Leaving `EXTRACT` uncast, returning `numeric` values like `1996` with decimal type instead of integers.
- Using `TO_CHAR(order_date, 'Month')` for ordering — text month names sort alphabetically, not chronologically.
- Expecting months with zero orders to appear; they need a `generate_series` calendar and a LEFT JOIN.

## 8. Interview Follow-ups

**1. How would you include months with zero orders?**

Generate a calendar with `generate_series(DATE '1996-01-01', DATE '1998-12-01', INTERVAL '1 month')` and LEFT JOIN the orders onto it. Use `COUNT(o.order_id)` rather than `COUNT(*)` so empty months show 0 instead of 1.

**2. What is the difference between EXTRACT and DATE_TRUNC here?**

`EXTRACT` returns a single numeric part (e.g. the month number), so you need two columns to identify a year-month. `DATE_TRUNC('month', order_date)` returns one DATE/TIMESTAMP at the first of the month, which is a single sortable key and convenient for joins to a calendar.

**3. Why can't you use the alias order_year in GROUP BY in every database?**

PostgreSQL allows output aliases in GROUP BY, but the SQL standard and some engines (e.g. SQL Server) do not. Repeating the expression is the portable choice, which is why the solution groups on the full `EXTRACT` expressions.

## 9. Key Takeaway

Period reports group on every part of the period key — year AND month — and cast `EXTRACT` to int for clean output.

---
📄 **SQL File:** [`Q110_Orders_Per_Year_And_Month.sql`](./Q110_Orders_Per_Year_And_Month.sql)

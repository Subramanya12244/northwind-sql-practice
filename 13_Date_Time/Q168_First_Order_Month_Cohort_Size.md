# Q168 · First Order Month Cohort Size

> **Revision Card**
> **Category:** Date & Time (Cohort Analysis) | **Difficulty:** Hard
> **Concepts:** DATE_TRUNC · MIN · CTE · GROUP BY · Running SUM Window
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** a customer's cohort is the month of their FIRST order — take MIN per customer before counting, or repeat customers are counted in several cohorts.

## 1. Problem

Growth analytics is starting cohort analysis. Assign each customer to the month of their first-ever order (their acquisition cohort). For each cohort year-month, report how many new customers were acquired and the running total of customers acquired so far.

**Objective:** Return, per first-order year and month, the number of newly acquired customers and the cumulative total.

**Tables:** `orders`

**Expected output:**

| Column | Description |
|--------|-------------|
| cohort_year | Year of the customer's first order (integer) |
| cohort_month_num | Month 1–12 of the first order (integer) |
| new_customers | Customers whose first order fell in that month |
| cumulative_customers | Running total of acquired customers up to that month |

| cohort_year | cohort_month_num | new_customers | cumulative_customers |
|---|---|---|---|
| 1996 | 1 | 9 | 9 |
| 1996 | 4 | 9 | 18 |
| 1996 | 7 | 8 | 26 |
| 1996 | 10 | 8 | 34 |

*(Sample rows are illustrative — taken from the practice dataset to show shape/format; your instance may differ.)*

## 2. My Approach

1. CTE `first_orders`: per customer, `DATE_TRUNC('month', MIN(order_date))::date`.
2. Group by cohort month and `COUNT(*)` customers.
3. Running total with `SUM(COUNT(*)) OVER (ORDER BY cohort_month)`.
4. Split into integer year and month; order by both.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH first_orders AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date))::date AS cohort_month
    FROM orders
    GROUP BY customer_id
)
SELECT
    EXTRACT(YEAR FROM cohort_month)::int  AS cohort_year,
    EXTRACT(MONTH FROM cohort_month)::int AS cohort_month_num,
    COUNT(*)                              AS new_customers,
    SUM(COUNT(*)) OVER (ORDER BY cohort_month)::int AS cumulative_customers
FROM first_orders
GROUP BY cohort_month
ORDER BY cohort_year, cohort_month_num;
```

## 6. Why This Works

Cohort membership is a per-customer fact, so it is computed once with `MIN(order_date)` and truncated to the month. Counting those rows gives each cohort's size with every customer in exactly one cohort. A window over an aggregate (`SUM(COUNT(*)) OVER ...`) runs after grouping, producing the running total in the same query.

## 7. Common Pitfalls (generic)

- Grouping orders by month and counting distinct customers — that measures active customers, not new ones.
- Forgetting `DATE_TRUNC` and creating one cohort per day.
- `DATE_TRUNC` on a DATE returns a TIMESTAMP; cast back to date for clean output.
- Running totals without an ORDER BY in the window, which just gives the grand total on every row.

## 8. Interview Follow-ups

**1. How would you extend this into a retention matrix?**

Join each customer's orders back to their cohort and compute months since cohort: `(EXTRACT(YEAR FROM AGE(order_month, cohort_month)) * 12 + EXTRACT(MONTH FROM AGE(order_month, cohort_month)))`. Count distinct customers per (cohort, month offset) and divide by the cohort size for retention %.

**2. Why use MIN in a CTE rather than a window function?**

Either works: `MIN(order_date) OVER (PARTITION BY customer_id)` keeps every order row, which is useful for the retention matrix. For cohort size alone, collapsing to one row per customer is simpler and cheaper.

**3. How would you show months with zero new customers?**

Build a month calendar with `generate_series` over the data range and LEFT JOIN the cohort counts. Use `COALESCE(new_customers, 0)` and compute the running total after the join so it carries forward across empty months.

## 9. Key Takeaway

Cohorts start with one row per customer — `DATE_TRUNC('month', MIN(order_date))` — then count and window over those rows.

---
📄 **SQL File:** [`Q168_First_Order_Month_Cohort_Size.sql`](./Q168_First_Order_Month_Cohort_Size.sql)

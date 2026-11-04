# Q109 · Average Gap Between Employee Orders

> **Revision Card**
> **Category:** Window Functions (Offset + Aggregation) | **Difficulty:** Hard
> **Concepts:** LAG · PARTITION BY · Date Arithmetic · AVG · AVG() OVER () · Multi-step CTE
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Compute LAG before aggregating — window functions cannot be nested inside AVG().

## 1. Problem

Operations wants to see how steadily each employee takes orders: the average and longest gap in days between consecutive orders they handled, and how each employee's average compares with the team average.

**Objective:** For each employee, compute the number of orders, the average and maximum days between consecutive orders, and the difference between their average gap and the average of all employees' averages.

**Tables:** `orders`, `employees`

**Expected output:**

| Column | Description |
|--------|-------------|
| employee_id | Employee identifier |
| first_name | First name |
| last_name | Last name |
| total_orders | Number of orders handled |
| avg_gap_days | Average days between consecutive orders, 2 dp |
| max_gap_days | Longest gap in days |
| diff_vs_team_avg | avg_gap_days minus the mean of all employees' avg_gap_days, 2 dp |

| employee_id | first_name | last_name | total_orders | avg_gap_days | max_gap_days | diff_vs_team_avg |
|-------------|------------|-----------|--------------|--------------|--------------|------------------|
| 8 | Laura | Callahan | 11 | 28.20 | 75 | -1.42 |
| 7 | Robert | King | 11 | 28.30 | 75 | -1.32 |
| 9 | Anne | Dodsworth | 11 | 28.40 | 75 | -1.22 |
| 4 | Margaret | Peacock | 11 | 29.50 | 83 | -0.12 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. CTE `order_gaps`: `order_date - LAG(order_date) OVER (PARTITION BY employee_id ORDER BY order_date, order_id)`.
2. CTE `employee_gaps`: per employee `COUNT(*)`, `AVG(gap_days)`, `MAX(gap_days)`.
3. Outer query: `avg_gap_days - AVG(avg_gap_days) OVER ()`; join employees; order by `avg_gap_days`, `employee_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH order_gaps AS (
    SELECT
        o.employee_id,
        o.order_id,
        o.order_date,
        o.order_date - LAG(o.order_date) OVER (PARTITION BY o.employee_id
                                               ORDER BY o.order_date, o.order_id) AS gap_days
    FROM orders o
),
employee_gaps AS (
    SELECT
        employee_id,
        COUNT(*)                         AS total_orders,
        ROUND(AVG(gap_days)::numeric, 2) AS avg_gap_days,
        MAX(gap_days)                    AS max_gap_days
    FROM order_gaps
    GROUP BY employee_id
)
SELECT
    eg.employee_id,
    e.first_name,
    e.last_name,
    eg.total_orders,
    eg.avg_gap_days,
    eg.max_gap_days,
    ROUND(eg.avg_gap_days - AVG(eg.avg_gap_days) OVER (), 2) AS diff_vs_team_avg
FROM employee_gaps eg
JOIN employees e ON e.employee_id = eg.employee_id
ORDER BY avg_gap_days, employee_id;
```

## 6. Why This Works

The gap needs the previous order for the same employee, which is exactly `LAG` with `PARTITION BY employee_id`. Window functions cannot be nested inside aggregates, so the gaps are computed in one CTE and aggregated in the next.

Each employee's first order has no predecessor, so its gap is NULL. `AVG` and `MAX` ignore NULLs, while `COUNT(*)` still counts every order. In the final step, `AVG(...) OVER ()` puts the team-wide mean on every row, so the comparison needs no subquery. Note this is a mean of per-employee averages, not a mean over all gaps.

## 7. Common Pitfalls (generic)

- Writing `AVG(order_date - LAG(order_date) OVER (...))` — nested window in aggregate is an error.
- Forgetting `PARTITION BY employee_id`, which measures gaps between different employees' orders.
- Using `COUNT(gap_days)` and undercounting orders by one per employee.
- Treating the mean of averages as the same as the overall average gap (it is not when order counts differ).

## 8. Interview Follow-ups

**1. How would you compute the overall average gap across all employees' orders instead?**

Take `AVG(gap_days)` directly over the `order_gaps` CTE, without grouping first. This weights each gap equally, so employees with more orders have more influence than in the mean-of-averages.

**2. How would you find each employee's longest gap and its dates?**

In `order_gaps`, also keep `LAG(order_date)` as `prev_date`. Then rank gaps with `ROW_NUMBER() OVER (PARTITION BY employee_id ORDER BY gap_days DESC NULLS LAST, order_id)` and keep `rn = 1`.

**3. Why might the median gap be better than the mean?**

Gaps are often skewed by a few long breaks such as holidays. `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY gap_days)` per employee is less sensitive to these outliers.

## 9. Key Takeaway

Compute row-level window values (LAG) in one CTE, aggregate in the next — window functions cannot be nested in aggregates.

---
📄 **SQL File:** [`Q109_Average_Gap_Between_Employee_Orders.sql`](./Q109_Average_Gap_Between_Employee_Orders.sql)

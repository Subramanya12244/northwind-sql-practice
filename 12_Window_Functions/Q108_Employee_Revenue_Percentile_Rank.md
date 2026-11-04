# Q108 · Employee Revenue Percentile Rank

> **Revision Card**
> **Category:** Window Functions (Distribution) | **Difficulty:** Hard
> **Concepts:** PERCENT_RANK · CUME_DIST · GROUP BY · CTE
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** PERCENT_RANK = (rank − 1)/(n − 1) starts at 0; CUME_DIST = rows ≤ current / n never reaches 0.

## 1. Problem

HR is preparing performance reviews and wants each sales employee's relative standing by total net revenue, expressed both as a percentile rank and as a cumulative distribution.

**Objective:** For each employee with orders, return total revenue, `PERCENT_RANK()` and `CUME_DIST()` (both ordered by revenue ascending, 4 dp).

**Tables:** `orders`, `order_details`, `employees`

**Expected output:**

| Column | Description |
|--------|-------------|
| employee_id | Employee identifier |
| first_name | First name |
| last_name | Last name |
| total_revenue | Net revenue from the employee's orders, 2 dp |
| percent_rank | (rank − 1) / (rows − 1), 4 dp |
| cume_dist | Fraction of employees with revenue ≤ this one, 4 dp |

| employee_id | first_name | last_name | total_revenue | percent_rank | cume_dist |
|-------------|------------|-----------|---------------|--------------|-----------|
| 6 | Michael | Suyama | 32276.55 | 1.0000 | 1.0000 |
| 4 | Margaret | Peacock | 22617.81 | 0.8571 | 0.8750 |
| 2 | Andrew | Fuller | 16311.83 | 0.7143 | 0.7500 |
| 9 | Anne | Dodsworth | 14310.56 | 0.5714 | 0.6250 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. CTE `employee_revenue`: net revenue per employee.
2. Compute `PERCENT_RANK()` and `CUME_DIST()` over `ORDER BY revenue` (ascending, so higher = better).
3. Join employees, round, order by revenue descending then `employee_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH employee_revenue AS (
    SELECT
        o.employee_id,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS revenue
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY o.employee_id
)
SELECT
    er.employee_id,
    e.first_name,
    e.last_name,
    ROUND(er.revenue::numeric, 2) AS total_revenue,
    ROUND(PERCENT_RANK() OVER (ORDER BY er.revenue)::numeric, 4) AS percent_rank,
    ROUND(CUME_DIST()    OVER (ORDER BY er.revenue)::numeric, 4) AS cume_dist
FROM employee_revenue er
JOIN employees e ON e.employee_id = er.employee_id
ORDER BY total_revenue DESC, employee_id;
```

## 6. Why This Works

Both are distribution functions over an ordered window. `PERCENT_RANK()` is `(RANK() − 1) / (N − 1)`: the lowest row is 0 and the highest is 1. `CUME_DIST()` is `(rows with value ≤ current) / N`: it is always above 0 and the top row is 1.

With 8 employees, the bottom earner has percent_rank 0 and cume_dist 0.125. Ordering ascending means a larger value means stronger performance. Ties get the same value in both functions.

## 7. Common Pitfalls (generic)

- Mixing up the two: `PERCENT_RANK` starts at 0, `CUME_DIST` starts at 1/N.
- Ordering descending and then reading high values as good.
- Forgetting that a single-row partition gives `PERCENT_RANK` = 0.
- Applying a percentile function to non-aggregated order lines.

## 8. Interview Follow-ups

**1. How would you list the top 25% of employees?**

Wrap the query and filter `cume_dist > 0.75`, or `percent_rank >= 0.75`. The two can give slightly different sets on small samples, so state which definition you use.

**2. How do these relate to PERCENTILE_CONT?**

`PERCENT_RANK`/`CUME_DIST` map a row to a percentile. `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue)` goes the other way: it returns the value at a given percentile, such as the median.

**3. How would you rank employees within each country?**

Add `PARTITION BY e.country` to both windows. Each employee is then ranked only against colleagues in the same country.

## 9. Key Takeaway

`PERCENT_RANK` = relative rank from 0 to 1; `CUME_DIST` = share of rows at or below — know both formulas.

---
📄 **SQL File:** [`Q108_Employee_Revenue_Percentile_Rank.sql`](./Q108_Employee_Revenue_Percentile_Rank.sql)

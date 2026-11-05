# Q205 · Median And 90th Percentile Order Value Per Employee

> **Revision Card**
> **Category:** Aggregations (Ordered-Set Aggregates) | **Difficulty:** Hard
> **Concepts:** PERCENTILE_CONT · WITHIN GROUP · Mean vs median · CTE · ROUND with numeric
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** PERCENTILE_CONT needs WITHIN GROUP (ORDER BY …) and returns double precision; cast to numeric before ROUND(…, 2).

## 1. Problem

Sales managers think averages hide what a typical order looks like, so they want the median and the 90th-percentile order value per employee.

**Objective:** For each employee, compute their order count, mean, median and 90th-percentile net order value (all 2 dp), highest median first.

**Tables:** `orders`, `order_details`, `employees`

**Expected output:**

| Column | Description |
|--------|-------------|
| employee_id | Employee |
| first_name | First name |
| last_name | Last name |
| orders | Orders handled |
| mean_value | Mean order value, 2 dp |
| median_value | Median order value, 2 dp |
| p90_value | 90th percentile order value, 2 dp |

| employee_id | first_name | last_name | orders | mean_value | median_value | p90_value |
|-------------|------------|-----------|--------|------------|--------------|-----------|
| 4 | Margaret | Peacock | 11 | 2056.16 | 1486.90 | 3745.64 |
| 2 | Andrew | Fuller | 11 | 1482.89 | 1090.98 | 2414.99 |
| 6 | Michael | Suyama | 22 | 1467.12 | 1005.19 | 2711.74 |
| 7 | Robert | King | 11 | 1150.82 | 1003.20 | 1945.71 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. CTE: net value per order (order_id, employee_id).
2. Group by employee: AVG, PERCENTILE_CONT(0.5) and PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY order_value).
3. Join employees for names; order by median.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH order_values AS (
    SELECT o.order_id, o.employee_id,
           SUM(d.unit_price * d.quantity * (1 - d.discount))::numeric AS order_value
    FROM orders o
    JOIN order_details d ON d.order_id = o.order_id
    GROUP BY o.order_id, o.employee_id
)
SELECT e.employee_id, e.first_name, e.last_name,
       COUNT(*)                                                                  AS orders,
       ROUND(AVG(order_value), 2)                                                AS mean_value,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY order_value)::numeric, 2) AS median_value,
       ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY order_value)::numeric, 2) AS p90_value
FROM order_values ov
JOIN employees e ON e.employee_id = ov.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY median_value DESC, e.employee_id;
```

## 6. Why This Works

Percentiles are ordered-set aggregates: they sort each group's values (WITHIN GROUP) and pick the value at a position, interpolating between neighbours with PERCENTILE_CONT. Computing order totals first matters, because percentiles over order lines would describe lines, not orders. A mean well above the median signals a few very large orders.

## 7. Common Pitfalls (generic)

- Taking percentiles over order_details rows instead of order totals.
- ROUND(double precision, 2) does not exist in PostgreSQL; cast to numeric first.
- Confusing PERCENTILE_DISC (an actual value) with PERCENTILE_CONT (interpolated).

## 8. Interview Follow-ups

**1. When would you use PERCENTILE_DISC?**

When the answer must be an actual observed value, such as a real order amount.

**2. How would you get several percentiles at once?**

PERCENTILE_CONT(ARRAY[0.25, 0.5, 0.75]) WITHIN GROUP (ORDER BY order_value) returns an array.

**3. How would you flag unusually large orders?**

Compare each order with its employee's p90 in a join or window, and flag orders above it.

## 9. Key Takeaway

Use PERCENTILE_CONT … WITHIN GROUP for medians and percentiles, over the right grain (orders, not lines).

---
📄 **SQL File:** [`Q205_Median_And_90th_Percentile_Order_Value_Per_Employee.sql`](./Q205_Median_And_90th_Percentile_Order_Value_Per_Employee.sql)

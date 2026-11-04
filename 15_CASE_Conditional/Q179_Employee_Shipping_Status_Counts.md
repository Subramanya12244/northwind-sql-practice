# Q179 · Employee Shipping Status Counts

> **Revision Card**
> **Category:** Conditional Aggregation | **Difficulty:** Medium
> **Concepts:** COUNT FILTER · SUM(CASE) · Conditional Aggregation · NULL Handling
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** `shipped_date > required_date` is NULL for unshipped orders, so check `IS NULL` first.

## 1. Problem

The operations manager wants a one-row-per-employee scorecard showing how many of their orders shipped on time, late, or not at all.

**Objective:** For each employee, count total orders, on-time shipments, late shipments (shipped after the required date) and unshipped orders.

**Tables:** `employees`, `orders`

**Expected output:**

| Column | Description |
|--------|-------------|
| employee_id | Employee identifier |
| employee_name | First and last name |
| total_orders | All orders |
| on_time | Shipped on or before the required date |
| late | Shipped after the required date |
| unshipped | No shipped date |

| employee_id | employee_name | total_orders | on_time | late | unshipped |
|-------------|---------------|--------------|---------|------|-----------|
| 1 | Nancy Davolio | 11 | 8 | 1 | 2 |
| 2 | Andrew Fuller | 11 | 8 | 1 | 2 |
| 3 | Janet Leverling | 11 | 9 | 1 | 1 |
| 4 | Margaret Peacock | 11 | 8 | 1 | 2 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Join employees to orders.
2. Use `COUNT(*) FILTER (WHERE ...)` for on-time and late.
3. Use `SUM(CASE WHEN shipped_date IS NULL THEN 1 ELSE 0 END)` for unshipped (to show both styles).
4. Group by employee and order by `employee_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name                                     AS employee_name,
    COUNT(*)                                                               AS total_orders,
    COUNT(*) FILTER (WHERE o.shipped_date <= o.required_date)              AS on_time,
    COUNT(*) FILTER (WHERE o.shipped_date >  o.required_date)              AS late,
    SUM(CASE WHEN o.shipped_date IS NULL THEN 1 ELSE 0 END)                AS unshipped
FROM employees e
JOIN orders o ON o.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY e.employee_id;
```

## 6. Why This Works

Conditional aggregation computes several metrics in one pass instead of one query per metric. `FILTER (WHERE ...)` restricts the rows a single aggregate sees; `SUM(CASE ... THEN 1 ELSE 0 END)` is the portable equivalent. Comparisons with a NULL `shipped_date` are NULL, so such rows fall out of both on-time and late, and are counted only by the explicit `IS NULL` branch — the three counts add up to the total.

## 7. Common Pitfalls (generic)

- `COUNT(CASE WHEN cond THEN 1 ELSE 0 END)` — counts every row because 0 is not NULL; use `SUM`, or drop the `ELSE`.
- Treating unshipped orders as on time by using `NOT (shipped_date > required_date)`.
- Grouping by name only; two employees could share a name.

## 8. Interview Follow-ups

**1. `FILTER` vs `CASE` inside an aggregate?**

Same result; `FILTER` is SQL:2003 and clearer, `CASE` works on every database (MySQL, SQL Server).

**2. How would you add the on-time percentage?**

`ROUND(100.0 * COUNT(*) FILTER (WHERE ...) / NULLIF(COUNT(shipped_date), 0), 1)`.

**3. How do you include employees with no orders?**

`LEFT JOIN orders` and use `COUNT(o.order_id)` for the total so the unmatched row counts as 0.

## 9. Key Takeaway

Conditional aggregation = one GROUP BY, many `COUNT(*) FILTER (WHERE ...)` / `SUM(CASE ...)` columns.

---
📄 **SQL File:** [`Q179_Employee_Shipping_Status_Counts.sql`](./Q179_Employee_Shipping_Status_Counts.sql)

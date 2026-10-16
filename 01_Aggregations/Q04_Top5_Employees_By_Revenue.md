# Q04 · Top 5 Employees by Revenue

> **Revision Card**
> **Category:** Aggregations & Revenue Analysis | **Difficulty:** Easy
> **Concepts:** INNER JOIN (multi-table) · GROUP BY · SUM · ORDER BY · LIMIT
> **Outcome:** ❓ not recorded
> **Watch out for:** group by `employee_id` (the key), not just name — two employees could share a name and merge silently.

## 1. Problem

Sales leadership wants to recognize and analyze the top-performing sales employees by the total revenue they personally closed, to inform performance reviews and incentive planning.

**Objective:** Identify the 5 employees who generated the highest total discounted revenue across all orders they processed.

**Tables:** `employees`, `orders`, `order_details`

**Expected output:**

| Column | Description |
|---|---|
| employee_id | Unique identifier of the employee |
| first_name | Employee's first name |
| last_name | Employee's last name |
| total_revenue | Sum of discounted revenue across orders handled |

| employee_id | first_name | last_name | total_revenue |
|---|---|---|---|
| 4 | Margaret | Peacock | 232890.85 |
| 3 | Janet | Leverling | 202812.84 |
| 1 | Nancy | Davolio | 192107.60 |

*(Sample values illustrative of the standard Northwind dataset.)*

## 2. My Approach

1. Join `employees → orders → order_details`.
2. Compute per-line discounted revenue.
3. `SUM()` grouped by employee.
4. Sort by revenue descending.
5. `LIMIT 5`.

## 3. My Solution (as submitted)

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue
FROM employees e
JOIN orders o ON o.employee_id = e.employee_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_revenue DESC
LIMIT 5;
```

## 4. Mistakes I Made

- _Not recorded — add from memory, or change Outcome to ✅ "clean on first attempt"._

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why join through `orders`:** an employee's contribution to revenue is indirect — they link to `orders`, and revenue lives in `order_details`, so the chain `employees → orders → order_details` is required.

**Why `first_name` and `last_name` in `GROUP BY`:** both are selected non-aggregated columns, so PostgreSQL requires them in the grouping clause even though `employee_id` alone is the unique key.

## 7. Common Pitfalls (generic)

- Grouping only by name instead of `employee_id` → two same-named employees silently merge.
- Forgetting an employee with zero orders won't appear under `INNER JOIN` (fine here, but note it in interviews).

## 8. Interview Follow-ups

1. Why include `employee_id` in `GROUP BY` even if names seem unique?
2. How would you show revenue by employee *and* by year?
3. Would a zero-order employee appear? How to include all employees?
4. How does this differ structurally from Q03 (Top 10 Customers)?

## 9. Key Takeaway

Group by the stable key (`employee_id`), not display attributes — and remember `INNER JOIN` quietly drops zero-activity rows.

---
📄 **SQL File:** [`Q04_Top5_Employees_By_Revenue.sql`](./Q04_Top5_Employees_By_Revenue.sql)

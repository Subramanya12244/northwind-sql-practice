# Q23 · Best Customer per Employee

> **Revision Card**
> **Category:** Common Table Expressions (CTEs) | **Difficulty:** Hard
> **Concepts:** CTE · Window Functions (RANK) · PARTITION BY · GROUP BY · SUM · Tie Handling · INNER JOIN
> **Outcome:** ✅ correct first attempt
> **Watch out for:** use `RANK()` not `ROW_NUMBER()` (keeps ties), and never omit `PARTITION BY employee_id` or you rank customers globally instead of per employee.

## 1. Problem

For every employee, sales management wants to know which customer they have generated the most revenue from — their single 'best account' — with ties handled so that no genuinely tied customer is dropped from the result.

**Objective:** For every employee, return the customer (or customers, if tied) generating the highest revenue from orders that employee handled.

**Tables:** `orders`, `order_details`, `employees`, `customers`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| employee_id | Unique identifier of the employee |
| first_name | Employee's first name |
| last_name | Employee's last name |
| customer_id | Unique identifier of the employee's top customer |
| company_name | Name of the top customer's company |
| total_revenue | Revenue this customer generated specifically from orders handled by this employee |

| employee_id | first_name | last_name | customer_id | company_name | total_revenue |
|-------------|------------|-----------|-------------|--------------|---------------|
| 1 | Nancy | Davolio | SAVEA | Save-a-lot Markets | 15234.40 |
| 2 | Andrew | Fuller | ERNSH | Ernst Handel | 12873.10 |
| 3 | Janet | Leverling | QUICK | QUICK-Stop | 19872.55 |
| 4 | Margaret | Peacock | QUICK | QUICK-Stop | 28734.90 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## 2. My Approach

1. Build a CTE (`employee_customer_revenue`) aggregating revenue per employee-customer pair.
2. Build a second CTE (`ranked`) applying `RANK() OVER (PARTITION BY employee_id ORDER BY total_revenue DESC)`.
3. Filter to `rnk = 1`, returning every customer tied for the top spot per employee.
4. Join in `employees` and `customers` for display-friendly names.
5. Sort by employee.

## 3. My Solution (as submitted)

```sql
WITH employee_customer_revenue AS (
    SELECT
        o.employee_id,
        o.customer_id,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY o.employee_id, o.customer_id
),
ranked AS (
    SELECT
        ecr.*,
        RANK() OVER (PARTITION BY employee_id ORDER BY total_revenue DESC) AS rnk
    FROM employee_customer_revenue ecr
)
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    r.customer_id,
    cu.company_name,
    ROUND(r.total_revenue::numeric, 2) AS total_revenue
FROM ranked r
JOIN employees e ON e.employee_id = r.employee_id
JOIN customers cu ON cu.customer_id = r.customer_id
WHERE r.rnk = 1
ORDER BY e.employee_id;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why `RANK() OVER (PARTITION BY employee_id ORDER BY total_revenue DESC)` is the right tool:** this is a classic 'top 1 per group' problem, and `PARTITION BY employee_id` ensures the ranking restarts independently for each employee, so 'rank 1' always means 'this employee's own best customer', not a global ranking across all employee-customer pairs.

**Why `RANK()` over `ROW_NUMBER()`:** the requirement explicitly says 'handle ties correctly' — if an employee has two customers exactly tied for their top spot, `RANK()` assigns both `rnk = 1`, surfacing both; `ROW_NUMBER()` would arbitrarily pick one and hide the other, silently failing the requirement.

**Why the final joins to `employees` and `customers` happen *after* ranking, not before:** ranking only needs `employee_id`, `customer_id`, and the aggregated revenue — pulling in `first_name`/`company_name` earlier would just add unnecessary columns to the windowing step. Joining them in at the end keeps the CTE lean and the final `SELECT` focused on presentation.

## 7. Common Pitfalls (generic)

- Using `ROW_NUMBER()` instead of `RANK()`, silently dropping legitimate ties.
- Forgetting `PARTITION BY employee_id`, which would rank customers globally instead of within each employee's own portfolio — answering a different question entirely.
- Joining `employees`/`customers` before aggregating, which can implicitly affect grouping granularity if not handled carefully.

## 8. Interview Follow-ups

1. Why is `PARTITION BY employee_id` essential here, and what would happen if it were omitted?
2. How would the result change if `ROW_NUMBER()` were used instead of `RANK()`, in a scenario where two customers are tied for an employee's top spot?
3. Why are the `employees` and `customers` joins placed after the ranking CTE rather than before?
4. How would you extend this to return each employee's top 3 customers instead of just their top 1?

## 9. Key Takeaway

The 'best X per Y' pattern is a partitioned window ranking: `RANK() OVER (PARTITION BY Y ORDER BY metric DESC)` then filter `rnk = 1` — `RANK()` preserves ties, and presentation joins belong after the windowing step.

---
📄 **SQL File:** [`Q23_Best_Customer_Per_Employee.sql`](./Q23_Best_Customer_Per_Employee.sql)

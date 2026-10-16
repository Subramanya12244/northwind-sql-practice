# Q12 · Employees by Unique Customers Served

> **Revision Card**
> **Category:** Category & Product Analytics | **Difficulty:** Easy
> **Concepts:** INNER JOIN · GROUP BY · COUNT(DISTINCT) · ORDER BY
> **Outcome:** ✅ correct first attempt
> **Watch out for:** count `DISTINCT customer_id`, not `order_id` — the same customer can place many orders, and counting orders measures volume, not reach.

## 1. Problem

HR and sales leadership want to evaluate employee reach by counting how many distinct customers each employee has served, as a measure of relationship breadth separate from revenue volume.

**Objective:** Identify how many unique customers each employee has handled orders for, ranked from highest to lowest.

**Tables:** `employees`, `orders`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| employee_id | Unique identifier of the employee |
| first_name | Employee's first name |
| last_name | Employee's last name |
| unique_customers | Count of distinct customers this employee has served |

**Sample output:**

| employee_id | first_name | last_name | unique_customers |
|-------------|------------|-----------|------------------|
| 4 | Margaret | Peacock | 44 |
| 3 | Janet | Leverling | 40 |
| 1 | Nancy | Davolio | 38 |
| 2 | Andrew | Fuller | 32 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## 2. My Approach

1. Join `employees` to `orders` on `employee_id`.
2. Count distinct `customer_id` values per employee.
3. Aggregate by employee.
4. Sort by unique customer count descending.

## 3. My Solution (as submitted)

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM employees e
JOIN orders o ON o.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY unique_customers DESC;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why `COUNT(DISTINCT o.customer_id)`:** an employee typically processes multiple orders for the *same* customer over time. Without `DISTINCT`, this would count orders, not unique customer relationships — a different metric (see Q4, which intentionally counts revenue/orders, not unique customers).

## 7. Common Pitfalls (generic)

- Using `COUNT(o.order_id)` instead of `COUNT(DISTINCT o.customer_id)` — that measures order volume, not customer breadth, and conflates two different employee performance signals.
- Forgetting that this query says nothing about revenue — an employee with many unique-but-small customers could rank highly here while ranking low in Q4.

## 8. Interview Follow-ups

1. Why does this metric (unique customers served) tell a different story than Q4 (total revenue)? Can you think of an employee profile that would rank high on one but low on the other?
2. How would you find which customers are served by *more than one* employee?
3. How would you add a tie-breaker if two employees served the exact same number of unique customers?

## 9. Key Takeaway

Relationship-breadth metrics (unique customer count) answer a different question than volume/value metrics (orders, revenue) — reach for `COUNT(DISTINCT ...)` whenever the question is about distinct relationships.

---
📄 **SQL File:** [`Q12_Employees_By_Unique_Customers_Served.sql`](./Q12_Employees_By_Unique_Customers_Served.sql)

# Q12. Employees by Unique Customers Served

**Category:** Category & Product Analytics
**Difficulty:** Easy

---

## Problem Statement

HR and sales leadership want to evaluate employee reach by counting how many distinct customers each employee has served, as a measure of relationship breadth separate from revenue volume.

## Objective

Identify how many unique customers each employee has handled orders for, ranked from highest to lowest.

## Tables Used

- `employees`
- `orders`

## Expected Output

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

## Concepts Used

- INNER JOIN
- GROUP BY
- Aggregate Functions (COUNT DISTINCT)
- ORDER BY

## Why This Approach

**Why `COUNT(DISTINCT o.customer_id)`:** an employee typically processes multiple orders for the *same* customer over time. Without `DISTINCT`, this would count orders, not unique customer relationships — a different metric (see Q4, which intentionally counts revenue/orders, not unique customers).

## Common Mistakes

- Using `COUNT(o.order_id)` instead of `COUNT(DISTINCT o.customer_id)` — that measures order volume, not customer breadth, and conflates two different employee performance signals.
- Forgetting that this query says nothing about revenue — an employee with many unique-but-small customers could rank highly here while ranking low in Q4.

## Difficulty

**Easy**

## Interview Follow-up Questions

1. Why does this metric (unique customers served) tell a different story than Q4 (total revenue)? Can you think of an employee profile that would rank high on one but low on the other?
2. How would you find which customers are served by *more than one* employee?
3. How would you add a tie-breaker if two employees served the exact same number of unique customers?

## Learning Outcomes

- Distinguish between relationship breadth metrics (unique customer count) and volume/value metrics (orders, revenue).
- Reinforce correct usage of `COUNT(DISTINCT ...)` for relationship-based questions.

---

📄 **SQL File:** [`Q12_Employees_By_Unique_Customers_Served.sql`](./Q12_Employees_By_Unique_Customers_Served.sql)

# Q23. Best Customer per Employee

**Category:** Common Table Expressions (CTEs)
**Difficulty:** Hard

---

## Problem Statement

For every employee, sales management wants to know which customer they have generated the most revenue from — their single 'best account' — with ties handled so that no genuinely tied customer is dropped from the result.

## Objective

For every employee, return the customer (or customers, if tied) generating the highest revenue from orders that employee handled.

## Tables Used

- `orders`
- `order_details`
- `employees`
- `customers`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| employee_id | Unique identifier of the employee |
| first_name | Employee's first name |
| last_name | Employee's last name |
| customer_id | Unique identifier of the employee's top customer |
| company_name | Name of the top customer's company |
| total_revenue | Revenue this customer generated specifically from orders handled by this employee |

**Sample output:**

| employee_id | first_name | last_name | customer_id | company_name | total_revenue |
|-------------|------------|-----------|-------------|--------------|---------------|
| 1 | Nancy | Davolio | SAVEA | Save-a-lot Markets | 15234.40 |
| 2 | Andrew | Fuller | ERNSH | Ernst Handel | 12873.10 |
| 3 | Janet | Leverling | QUICK | QUICK-Stop | 19872.55 |
| 4 | Margaret | Peacock | QUICK | QUICK-Stop | 28734.90 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- CTE
- Window Functions (RANK)
- PARTITION BY
- GROUP BY
- Aggregate Functions (SUM)
- Tie Handling
- INNER JOIN

## Why This Approach

**Why `RANK() OVER (PARTITION BY employee_id ORDER BY total_revenue DESC)` is the right tool:** this is a classic 'top 1 per group' problem, and `PARTITION BY employee_id` ensures the ranking restarts independently for each employee, so 'rank 1' always means 'this employee's own best customer', not a global ranking across all employee-customer pairs.

**Why `RANK()` over `ROW_NUMBER()`:** the requirement explicitly says 'handle ties correctly' — if an employee has two customers exactly tied for their top spot, `RANK()` assigns both `rnk = 1`, surfacing both; `ROW_NUMBER()` would arbitrarily pick one and hide the other, silently failing the requirement.

**Why the final joins to `employees` and `customers` happen *after* ranking, not before:** ranking only needs `employee_id`, `customer_id`, and the aggregated revenue — pulling in `first_name`/`company_name` earlier would just add unnecessary columns to the windowing step. Joining them in at the end keeps the CTE lean and the final `SELECT` focused on presentation.

## Common Mistakes

- Using `ROW_NUMBER()` instead of `RANK()`, silently dropping legitimate ties.
- Forgetting `PARTITION BY employee_id`, which would rank customers globally instead of within each employee's own portfolio — answering a different question entirely.
- Joining `employees`/`customers` before aggregating, which can implicitly affect grouping granularity if not handled carefully.

## Difficulty

**Hard**

## Interview Follow-up Questions

1. Why is `PARTITION BY employee_id` essential here, and what would happen if it were omitted?
2. How would the result change if `ROW_NUMBER()` were used instead of `RANK()`, in a scenario where two customers are tied for an employee's top spot?
3. Why are the `employees` and `customers` joins placed after the ranking CTE rather than before?
4. How would you extend this to return each employee's top 3 customers instead of just their top 1?

## Learning Outcomes

- Master the 'best X per Y' analytical pattern using window functions — directly transferable to dozens of real business questions (best product per store, top transaction per account, etc).
- Reinforce correct tie-handling discipline using `RANK()`.
- Practice ordering join steps to keep CTEs minimal and readable.

---

📄 **SQL File:** [`Q23_Best_Customer_Per_Employee.sql`](./Q23_Best_Customer_Per_Employee.sql)

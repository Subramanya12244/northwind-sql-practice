# Q04. Top 5 Employees by Revenue

**Category:** Aggregations & Revenue Analysis
**Difficulty:** Easy

---

## Problem Statement

Sales leadership wants to recognize and analyze the top-performing sales employees based on the total revenue they have personally closed, to inform performance reviews and incentive planning.

## Objective

Identify the 5 employees who generated the highest total discounted revenue across all orders they processed.

## Tables Used

- `employees`
- `orders`
- `order_details`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| employee_id | Unique identifier of the employee |
| first_name | Employee's first name |
| last_name | Employee's last name |
| total_revenue | Sum of discounted revenue generated across all orders handled by this employee |

**Sample output:**

| employee_id | first_name | last_name | total_revenue |
|-------------|------------|-----------|---------------|
| 4 | Margaret | Peacock | 232890.85 |
| 3 | Janet | Leverling | 202812.84 |
| 1 | Nancy | Davolio | 192107.60 |
| 2 | Andrew | Fuller | 166537.76 |
| 8 | Laura | Callahan | 126862.28 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- INNER JOIN (multi-table)
- GROUP BY
- Aggregate Functions (SUM)
- ORDER BY
- LIMIT

## Why This Approach

**Why join through `orders`:** an employee's contribution to revenue is indirect — they are linked to `orders`, and revenue itself lives in `order_details`. The join chain `employees → orders → order_details` is required.

**Why include both `first_name` and `last_name` in `GROUP BY`:** since both are selected as non-aggregated columns, PostgreSQL requires them in the grouping clause even though `employee_id` alone is already a unique key.

## Common Mistakes

- Grouping only by name (`first_name`, `last_name`) instead of `employee_id` — two employees could theoretically share a name, silently merging their revenue.
- Forgetting that an employee with zero orders won't appear at all with `INNER JOIN` (acceptable here since the question implies active salespeople, but worth flagging in an interview).

## Difficulty

**Easy**

## Interview Follow-up Questions

1. Why might you still include `employee_id` in `GROUP BY` even if you're confident no two employees share the same name?
2. How would you modify this to show revenue by employee and by year separately?
3. If an employee had zero orders, would this query include them in the output? How would you change it if the requirement was to include all employees regardless?
4. How does this query differ structurally from Q3 (Top 10 Customers)?

## Learning Outcomes

- Reinforce the join-through-bridge-table pattern, this time anchored on employees instead of customers.
- Practice recognizing when `INNER JOIN` excludes legitimately relevant zero-activity rows versus when that's the desired behavior.

---

📄 **SQL File:** [`Q04_Top5_Employees_By_Revenue.sql`](./Q04_Top5_Employees_By_Revenue.sql)

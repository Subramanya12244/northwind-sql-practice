# Q08. Customers Above Average Order Count

**Category:** GROUP BY & HAVING
**Difficulty:** Medium

---

## Problem Statement

Operations wants to identify customers who order more frequently than the typical customer, to understand engagement patterns separate from revenue value.

## Objective

Return all customers whose order count exceeds the average order count computed across all customers.

## Tables Used

- `customers`
- `orders`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| customer_id | Unique identifier of the customer |
| company_name | Name of the customer's company |
| order_count | Total number of orders placed by the customer |

**Sample output:**

| customer_id | company_name | order_count |
|-------------|--------------|-------------|
| SAVEA | Save-a-lot Markets | 31 |
| ERNSH | Ernst Handel | 30 |
| QUICK | QUICK-Stop | 28 |
| HUNGO | Hungry Owl All-Night Grocers | 19 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- INNER JOIN
- GROUP BY
- CTE
- Aggregate Functions (COUNT, AVG)
- Subquery

## Why This Approach

**Why this mirrors Q6/Q7 but with `COUNT` instead of `SUM`:** the same 'aggregate per entity, then compare to a separately computed average' pattern applies regardless of which aggregate function defines the metric.

## Common Mistakes

- Using average order count across *orders* (i.e. just `1`, trivially) instead of average order count *per customer* — a subtle misreading of the requirement.
- Forgetting that customers with zero orders are excluded entirely by the `INNER JOIN`, which slightly skews the average upward (every customer in the CTE has at least 1 order).

## Difficulty

**Medium**

## Interview Follow-up Questions

1. Would the computed average change if customers with zero orders were included via a LEFT JOIN? Why?
2. How does this differ conceptually from Q5 (Top 5 Customers by Order Count)?
3. How would you find customers whose order count is *below* average instead?

## Learning Outcomes

- Apply the above-average comparison pattern to a count-based metric rather than a revenue-based one.
- Understand how `INNER JOIN` vs `LEFT JOIN` choices subtly shift computed averages.

---

📄 **SQL File:** [`Q08_Customers_Above_Average_Order_Count.sql`](./Q08_Customers_Above_Average_Order_Count.sql)

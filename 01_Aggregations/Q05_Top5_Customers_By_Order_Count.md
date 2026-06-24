# Q05. Top 5 Customers by Number of Orders

**Category:** Aggregations & Revenue Analysis
**Difficulty:** Easy

---

## Problem Statement

Operations wants to understand which customers order most *frequently* — a different signal than total revenue, useful for identifying high-frequency, potentially lower-basket-size accounts versus high-value/low-frequency ones.

## Objective

Identify the 5 customers who placed the highest number of distinct orders.

## Tables Used

- `customers`
- `orders`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| customer_id | Unique identifier of the customer |
| company_name | Name of the customer's company |
| order_count | Total number of distinct orders placed by the customer |

**Sample output:**

| customer_id | company_name | order_count |
|-------------|--------------|-------------|
| SAVEA | Save-a-lot Markets | 31 |
| ERNSH | Ernst Handel | 30 |
| QUICK | QUICK-Stop | 28 |
| FOLKO | Folk och fä HB | 19 |
| HUNGO | Hungry Owl All-Night Grocers | 19 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- INNER JOIN
- GROUP BY
- Aggregate Functions (COUNT)
- ORDER BY
- LIMIT

## Why This Approach

**Why `COUNT(DISTINCT o.order_id)` rather than plain `COUNT(o.order_id)`:** with only `customers` joined to `orders` (no `order_details` involved), each order already appears exactly once per customer, so the two are equivalent here. `DISTINCT` is added defensively — it's a safe habit that prevents inflated counts if this query is later extended to join in `order_details` (which would duplicate rows per line item, one row per product in the order).

## Common Mistakes

- Joining in `order_details` unnecessarily, then using plain `COUNT(order_id)` — this would count each order once *per line item*, wildly overstating order counts.
- Confusing 'most orders' (frequency) with 'most revenue' (value, see Q3) — these are different business questions with potentially different customer lists.

## Difficulty

**Easy**

## Interview Follow-up Questions

1. Why is `COUNT(DISTINCT order_id)` a safer default than plain `COUNT(order_id)`, even when it's not strictly necessary in this specific query?
2. What business difference is there between a customer who appears in this list versus the Q3 top-revenue list, but not both?
3. How would you extend this to find the average order count per customer segment or region?
4. If you joined `order_details` into this query, what would break, and how would you fix it?

## Learning Outcomes

- Distinguish between frequency-based metrics (order count) and value-based metrics (revenue) in business reporting.
- Build the habit of using `COUNT(DISTINCT ...)` defensively in joins that may later be extended.

---

📄 **SQL File:** [`Q05_Top5_Customers_By_Order_Count.sql`](./Q05_Top5_Customers_By_Order_Count.sql)

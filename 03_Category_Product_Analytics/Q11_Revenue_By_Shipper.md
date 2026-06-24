# Q11. Revenue by Shipper

**Category:** Category & Product Analytics
**Difficulty:** Easy

---

## Problem Statement

Logistics and procurement want to understand how much order revenue flows through each shipping partner, to support shipper contract negotiations and performance comparisons.

## Objective

Calculate the total discounted revenue of orders handled by each shipping company.

## Tables Used

- `shippers`
- `orders`
- `order_details`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| shipper_id | Unique identifier of the shipping company |
| company_name | Name of the shipping company |
| total_revenue | Sum of discounted revenue from all orders shipped via this company |

**Sample output:**

| shipper_id | company_name | total_revenue |
|------------|--------------|---------------|
| 3 | Federal Shipping | 402817.59 |
| 1 | Speedy Express | 385482.42 |
| 2 | United Package | 374733.39 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- INNER JOIN (multi-table)
- GROUP BY
- Aggregate Functions (SUM)
- ORDER BY

## Why This Approach

**Why join on `o.ship_via = s.shipper_id`:** `orders.ship_via` stores the foreign key pointing to the shipper used for that order — it's the only link between an order and the company that shipped it.

**Why this is revenue 'handled' rather than 'shipping cost':** the question asks for order revenue attributed to each shipper, not the `freight` cost charged for shipping — a distinction worth clarifying with stakeholders, since Northwind's `orders.freight` column could easily be confused for this.

## Common Mistakes

- Summing `orders.freight` (the shipping cost) instead of `order_details` revenue, which answers a completely different question.
- Forgetting that `ship_via` can technically be unpopulated for some orders, which would silently exclude those orders from any shipper's total under an `INNER JOIN`.

## Difficulty

**Easy**

## Interview Follow-up Questions

1. What's the difference between 'revenue handled by a shipper' and 'shipping cost (freight) paid to a shipper'? Which does this query compute?
2. How would you find the average order value per shipper instead of total revenue?
3. If some orders have a `NULL` `ship_via`, how would that affect this query's totals, and how would you account for those orders?

## Learning Outcomes

- Practice joining through a foreign key that isn't named identically to the parent table's primary key (`ship_via` vs `shipper_id`).
- Distinguish between order revenue and shipping cost as two different metrics that are easy to conflate.

---

📄 **SQL File:** [`Q11_Revenue_By_Shipper.sql`](./Q11_Revenue_By_Shipper.sql)

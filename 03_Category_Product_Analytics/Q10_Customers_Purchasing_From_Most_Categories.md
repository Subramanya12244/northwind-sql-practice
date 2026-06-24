# Q10. Customers Purchasing from Most Categories

**Category:** Category & Product Analytics
**Difficulty:** Medium

---

## Problem Statement

The merchandising team wants to identify customers with the broadest purchasing range across product categories — a useful signal for cross-sell health versus customers concentrated in a single category.

## Objective

Identify the 10 customers who have purchased from the highest number of distinct product categories.

## Tables Used

- `customers`
- `orders`
- `order_details`
- `products`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| customer_id | Unique identifier of the customer |
| company_name | Name of the customer's company |
| category_count | Number of distinct product categories this customer has purchased from |

**Sample output:**

| customer_id | company_name | category_count |
|-------------|--------------|----------------|
| SAVEA | Save-a-lot Markets | 8 |
| ERNSH | Ernst Handel | 8 |
| QUICK | QUICK-Stop | 8 |
| HUNGO | Hungry Owl All-Night Grocers | 7 |
| RATTC | Rattlesnake Canyon Grocery | 7 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- INNER JOIN (multi-table)
- GROUP BY
- Aggregate Functions (COUNT DISTINCT)
- ORDER BY
- LIMIT

## Why This Approach

**Why `COUNT(DISTINCT p.category_id)`:** a customer typically buys multiple products, and several of those products can belong to the same category. Without `DISTINCT`, this would count *line items*, not *unique categories* — a fundamentally different (and wrong) metric for 'category breadth'.

**Why four tables are needed:** the chain `customers → orders → order_details → products` is the only path from customer identity to category information.

## Common Mistakes

- Counting `product_id` instead of `category_id` — that measures product variety, not category breadth.
- Omitting `DISTINCT`, which would count every line item rather than unique categories.

## Difficulty

**Medium**

## Interview Follow-up Questions

1. What's the business difference between 'category breadth' (this query) and 'category revenue concentration'?
2. How would you find customers who buy from *only one* category (the opposite extreme)?
3. How would you adapt this to also show which specific categories each top customer buys from?

## Learning Outcomes

- Practice distinguishing 'breadth' metrics (distinct count of a dimension) from 'volume' metrics (raw counts or sums).
- Reinforce the multi-hop join pattern from customer to category.

---

📄 **SQL File:** [`Q10_Customers_Purchasing_From_Most_Categories.sql`](./Q10_Customers_Purchasing_From_Most_Categories.sql)

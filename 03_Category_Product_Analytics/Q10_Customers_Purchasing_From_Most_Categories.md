# Q10 · Customers Purchasing from Most Categories

> **Revision Card**
> **Category:** Category & Product Analytics | **Difficulty:** Medium
> **Concepts:** INNER JOIN (multi-table) · GROUP BY · COUNT(DISTINCT) · ORDER BY · LIMIT
> **Outcome:** ✅ correct first attempt
> **Watch out for:** count `DISTINCT category_id`, not `product_id` — the latter measures product variety, not category breadth.

## 1. Problem

The merchandising team wants to identify customers with the broadest purchasing range across product categories — a useful signal for cross-sell health versus customers concentrated in a single category.

**Objective:** Identify the 10 customers who have purchased from the highest number of distinct product categories.

**Tables:** `customers`, `orders`, `order_details`, `products`

**Expected output:**

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

## 2. My Approach

1. Join `customers` to `orders`, `orders` to `order_details`, and `order_details` to `products`.
2. Count distinct `category_id` values per customer using `COUNT(DISTINCT p.category_id)`.
3. Aggregate by customer.
4. Sort by category count descending and limit to the top 10.

## 3. My Solution (as submitted)

```sql
SELECT
    cu.customer_id,
    cu.company_name,
    COUNT(DISTINCT p.category_id) AS category_count
FROM customers cu
JOIN orders o ON o.customer_id = cu.customer_id
JOIN order_details od ON od.order_id = o.order_id
JOIN products p ON p.product_id = od.product_id
GROUP BY cu.customer_id, cu.company_name
ORDER BY category_count DESC
LIMIT 10;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why `COUNT(DISTINCT p.category_id)`:** a customer typically buys multiple products, and several of those products can belong to the same category. Without `DISTINCT`, this would count *line items*, not *unique categories* — a fundamentally different (and wrong) metric for 'category breadth'.

**Why four tables are needed:** the chain `customers → orders → order_details → products` is the only path from customer identity to category information.

## 7. Common Pitfalls (generic)

- Counting `product_id` instead of `category_id` — that measures product variety, not category breadth.
- Omitting `DISTINCT`, which would count every line item rather than unique categories.

## 8. Interview Follow-ups

**1. What's the business difference between 'category breadth' (this query) and 'category revenue concentration'?**

Category breadth — `COUNT(DISTINCT p.category_id)` — measures how many different categories a customer buys across, a diversity/cross-sell signal. Category revenue concentration measures how a customer's spend is distributed across those categories, e.g. whether 90% of revenue comes from one category. A customer can score high on breadth (buys a little from all 8 categories) yet be highly concentrated in revenue, or buy from few categories but spread spend evenly. Breadth answers "how wide", concentration answers "how balanced".

**2. How would you find customers who buy from *only one* category (the opposite extreme)?**

Keep the same join and grouping but filter the aggregate with `HAVING COUNT(DISTINCT p.category_id) = 1`. For example: `... GROUP BY cu.customer_id, cu.company_name HAVING COUNT(DISTINCT p.category_id) = 1`. `HAVING` is required because the condition tests a group-level aggregate, which `WHERE` cannot reference.

**3. How would you adapt this to also show which specific categories each top customer buys from?**

Use `STRING_AGG(DISTINCT c.category_name, ', ' ORDER BY c.category_name)` (joining in `categories`) alongside the count to list category names per customer in one row. Alternatively, return one row per customer-category pair by grouping on both customer and category, or use `ARRAY_AGG(DISTINCT c.category_name)` to get them as an array. To restrict to the top customers first, wrap the top-10 result in a CTE and join back to the detail.

## 9. Key Takeaway

Distinguish 'breadth' metrics (distinct count of a dimension) from 'volume' metrics (raw counts or sums), and trace the full multi-hop join from customer to category.

---
📄 **SQL File:** [`Q10_Customers_Purchasing_From_Most_Categories.sql`](./Q10_Customers_Purchasing_From_Most_Categories.sql)

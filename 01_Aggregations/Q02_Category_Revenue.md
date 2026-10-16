# Q02 · Category Revenue

> **Revision Card**
> **Category:** Aggregations & Revenue Analysis | **Difficulty:** Easy
> **Concepts:** INNER JOIN (multi-table) · GROUP BY · SUM
> **Outcome:** ❓ not recorded
> **Watch out for:** `products` is the bridge — you can't join `order_details` to `categories` directly (no shared key).

## 1. Problem

Category managers need a consolidated view of how much revenue each product category generates after discounts, to compare category performance and guide merchandising strategy.

**Objective:** Calculate total discounted revenue per category by rolling up product-level sales through the category hierarchy.

**Tables:** `categories`, `products`, `order_details`

**Expected output:**

| Column | Description |
|---|---|
| category_id | Unique identifier of the category |
| category_name | Name of the category |
| total_revenue | Sum of discounted revenue of all products in the category |

| category_id | category_name | total_revenue |
|---|---|---|
| 1 | Beverages | 267868.18 |
| 4 | Dairy Products | 234507.29 |
| 8 | Seafood | 141623.09 |

*(Sample values illustrative of the standard Northwind dataset.)*

## 2. My Approach

1. Start from `categories`, join to `products` on `category_id`.
2. Join `products` to `order_details` on `product_id` for transaction revenue.
3. Compute per-line discounted revenue.
4. `SUM()` grouped by category.
5. Sort by `total_revenue DESC`.

## 3. My Solution (as submitted)

```sql
SELECT
    c.category_id,
    c.category_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue
FROM categories c
JOIN products p ON p.category_id = c.category_id
JOIN order_details od ON od.product_id = p.product_id
GROUP BY c.category_id, c.category_name
ORDER BY total_revenue DESC;
```

## 4. Mistakes I Made

- _Not recorded — add from memory, or change Outcome to ✅ "clean on first attempt"._

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why three tables are joined:** revenue lives in `order_details`, but category info lives in `categories` — `products` is the bridge connecting a `product_id` to a `category_id`. There is no way from `order_details` to `categories` without it.

**Why `INNER JOIN` not `LEFT JOIN`:** the question asks for revenue *generated*, so only categories with actual sales activity are relevant; chaining through `order_details` (which only exists for completed line items) makes `INNER JOIN` the natural read.

## 7. Common Pitfalls (generic)

- Trying to join `order_details` to `categories` directly — no shared key exists.
- Failing to roll up at the right grain (one category contains many products).
- Re-using `products.unit_price` instead of `order_details.unit_price` (same trap as Q01).

## 8. Interview Follow-ups

1. Why is `products` necessary — couldn't we join `order_details` to `categories` directly?
2. How would you show each category's revenue as a percentage of total company revenue?
3. Aggregating at category level directly vs product-level-then-sum — would results differ?
4. How would you handle a category that exists but has no products?

## 9. Key Takeaway

When two tables share no direct foreign key, route through the intermediate *bridge* table — and keep applying the transaction-level revenue formula at whatever grain you aggregate.

---
📄 **SQL File:** [`Q02_Category_Revenue.sql`](./Q02_Category_Revenue.sql)

# Q09 · Top Categories by Number of Orders

> **Revision Card**
> **Category:** Category & Product Analytics | **Difficulty:** Medium
> **Concepts:** INNER JOIN (multi-table) · GROUP BY · COUNT(DISTINCT) · ORDER BY · LIMIT
> **Outcome:** ✅ correct first attempt
> **Watch out for:** without `COUNT(DISTINCT order_id)`, an order with 2+ products from the same category is counted multiple times, inflating category reach.

## 1. Problem

Merchandising wants to know which product categories appear in the most customer orders, as a measure of category reach/popularity distinct from raw revenue.

**Objective:** Identify the 5 categories that appear in the highest number of distinct orders.

**Tables:** `categories`, `products`, `order_details`, `orders`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| category_id | Unique identifier of the category |
| category_name | Name of the category |
| order_count | Number of distinct orders that included at least one product from this category |

**Sample output:**

| category_id | category_name | order_count |
|-------------|---------------|-------------|
| 1 | Beverages | 186 |
| 4 | Dairy Products | 164 |
| 3 | Confections | 169 |
| 8 | Seafood | 163 |
| 6 | Meat/Poultry | 108 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## 2. My Approach

1. Join `categories` to `products`, then to `order_details`, then to `orders`.
2. Count distinct `order_id` values per category using `COUNT(DISTINCT o.order_id)`.
3. Aggregate by category.
4. Sort by order count descending and limit to the top 5.

## 3. My Solution (as submitted)

```sql
SELECT
    c.category_id,
    c.category_name,
    COUNT(DISTINCT o.order_id) AS order_count
FROM categories c
JOIN products p ON p.category_id = c.category_id
JOIN order_details od ON od.product_id = p.product_id
JOIN orders o ON o.order_id = od.order_id
GROUP BY c.category_id, c.category_name
ORDER BY order_count DESC
LIMIT 5;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why `COUNT(DISTINCT o.order_id)` is essential, not optional, here:** unlike Q5, this join chain passes through `order_details`, which has multiple rows per order (one per product line). A single order can contain several products from the same category, which would duplicate that order's contribution to the count without `DISTINCT` — directly inflating the category's apparent order reach.

**Why `orders` is joined at all:** `order_details` already has `order_id`, so technically `COUNT(DISTINCT od.order_id)` would suffice without joining `orders` — the explicit join to `orders` here is for clarity/extensibility (e.g. if filtering by order date were later required) rather than strict necessity.

## 7. Common Pitfalls (generic)

- Omitting `DISTINCT`, which inflates the order count whenever an order contains 2+ products from the same category.
- Confusing 'number of orders touching a category' with 'number of products in a category' — these answer different questions.
- Unnecessarily joining `orders` and not using any of its other columns, adding overhead with no benefit (acceptable for clarity, but worth noting in a performance discussion).

## 8. Interview Follow-ups

1. Why is `DISTINCT` critical in this query but only a defensive habit in Q5?
2. Is the join to `orders` strictly necessary here? When would it become necessary?
3. How would you modify this to count orders per category *per year*?
4. What would happen to this result if a category had products, but none of those products were ever ordered?

## 9. Key Takeaway

Know exactly when `COUNT(DISTINCT ...)` is required versus merely a safety habit — it depends on which tables are joined and at what grain, since fan-out through `order_details` can multiply an order's contribution.

---
📄 **SQL File:** [`Q09_Top_Categories_By_Order_Count.sql`](./Q09_Top_Categories_By_Order_Count.sql)

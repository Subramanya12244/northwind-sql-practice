# Q27 · Products and Total Quantity Sold

> **Revision Card**
> **Category:** LEFT JOIN | **Difficulty:** Medium
> **Concepts:** LEFT JOIN · GROUP BY · SUM · NULL Handling · COALESCE
> **Outcome:** ✅ correct first attempt
> **Watch out for:** `SUM()` over an all-NULL group returns `NULL`, not `0` — wrap in `COALESCE(..., 0)` when the business asks to "display 0".

## 1. Problem

Inventory management wants a full product catalog report showing total units sold per product, explicitly showing 0 — not a blank — for products that have never been ordered, so slow-moving inventory is clearly visible.

**Objective:** Return every product and the total quantity sold across all orders, displaying 0 for products that have never appeared in any order.

**Tables:** `products`, `order_details`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| product_id | Unique identifier of the product |
| product_name | Name of the product |
| total_quantity_sold | Total units sold across all orders (0 if never ordered) |

| product_id | product_name | total_quantity_sold |
|------------|--------------|---------------------|
| 59 | Raclette Courdavault | 1496 |
| 38 | Côte de Blaye | 623 |
| 9 | Mishi Kobe Niku | 0 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## 2. My Approach

1. Start from `products` and LEFT JOIN to `order_details` on `product_id`.
2. Aggregate using `SUM(od.quantity)`, wrapped in `COALESCE(..., 0)` to convert the `NULL` result (from products with no matching `order_details` rows) into a literal 0.
3. Group by product.
4. Sort by total quantity sold descending.

## 3. My Solution (as submitted)

```sql
SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(od.quantity), 0) AS total_quantity_sold
FROM products p
LEFT JOIN order_details od ON od.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why `COALESCE(SUM(od.quantity), 0)` is necessary here, unlike `MAX()` in Q26:** for a product with no matching `order_details` rows, every `od.quantity` value in that group is `NULL`, and `SUM()` over an all-`NULL` group returns `NULL` — not `0`. This is a key contrast to be clear on: `SUM()`/`MAX()`/`MIN()` etc. all return `NULL` (not zero) when there's nothing to aggregate. Since the requirement explicitly says 'display 0', `COALESCE` is required to convert that `NULL` into the literal `0` the business asked for.

**Why this differs from Q26's `MAX(order_date)`, which needed no `COALESCE`:** in Q26, `NULL` was the *correct* business answer (a customer genuinely has no 'latest order date'); here, the business explicitly wants `0` displayed instead of `NULL` — a deliberate, stated formatting requirement, not just default aggregate behavior left as-is.

## 7. Common Pitfalls (generic)

- Leaving the result as `NULL` instead of wrapping in `COALESCE`, technically correct in raw SQL semantics but failing the explicit business requirement to 'display 0'.
- Using `INNER JOIN`, which would drop never-ordered products from the report entirely rather than showing them with 0.

## 8. Interview Follow-ups

1. Why does `SUM()` return `NULL` instead of `0` for a group with no rows, and why does that matter for this report?
2. Contrast this query's need for `COALESCE` with Q26's `MAX(order_date)`, which didn't need it. What's the underlying principle?
3. Where else, besides `COALESCE`, could you handle this NULL-to-zero conversion (e.g. in the application layer, in a view)? What are the trade-offs?
4. How would you find products that sold below a certain threshold quantity, including those that sold zero?

## 9. Key Takeaway

Know the difference between "NULL is the correct answer" (Q26) and "NULL must be converted to a business default" (here) — `COALESCE` is the standard tool for supplying a zero default over a `LEFT JOIN` + `SUM` aggregate.

---
📄 **SQL File:** [`Q27_Products_And_Total_Quantity_Sold.sql`](./Q27_Products_And_Total_Quantity_Sold.sql)

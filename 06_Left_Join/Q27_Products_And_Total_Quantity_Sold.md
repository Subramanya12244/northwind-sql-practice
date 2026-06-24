# Q27. Products and Total Quantity Sold

**Category:** LEFT JOIN
**Difficulty:** Medium

---

## Problem Statement

Inventory management wants a full product catalog report showing total units sold per product, explicitly showing 0 — not a blank — for products that have never been ordered, so slow-moving inventory is clearly visible.

## Objective

Return every product and the total quantity sold across all orders, displaying 0 for products that have never appeared in any order.

## Tables Used

- `products`
- `order_details`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| product_id | Unique identifier of the product |
| product_name | Name of the product |
| total_quantity_sold | Total units sold across all orders (0 if never ordered) |

**Sample output:**

| product_id | product_name | total_quantity_sold |
|------------|--------------|---------------------|
| 59 | Raclette Courdavault | 1496 |
| 38 | Côte de Blaye | 623 |
| 9 | Mishi Kobe Niku | 0 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- LEFT JOIN
- GROUP BY
- Aggregate Functions (SUM)
- NULL Handling
- COALESCE

## Why This Approach

**Why `COALESCE(SUM(od.quantity), 0)` is necessary here, unlike `MAX()` in Q26:** for a product with no matching `order_details` rows, every `od.quantity` value in that group is `NULL`, and `SUM()` over an all-`NULL` group returns `NULL` — not `0`. This is a key contrast to be clear on: `SUM()`/`MAX()`/`MIN()` etc. all return `NULL` (not zero) when there's nothing to aggregate. Since the requirement explicitly says 'display 0', `COALESCE` is required to convert that `NULL` into the literal `0` the business asked for.

**Why this differs from Q26's `MAX(order_date)`, which needed no `COALESCE`:** in Q26, `NULL` was the *correct* business answer (a customer genuinely has no 'latest order date'); here, the business explicitly wants `0` displayed instead of `NULL` — a deliberate, stated formatting requirement, not just default aggregate behavior left as-is.

## Common Mistakes

- Leaving the result as `NULL` instead of wrapping in `COALESCE`, technically correct in raw SQL semantics but failing the explicit business requirement to 'display 0'.
- Using `INNER JOIN`, which would drop never-ordered products from the report entirely rather than showing them with 0.

## Difficulty

**Medium**

## Interview Follow-up Questions

1. Why does `SUM()` return `NULL` instead of `0` for a group with no rows, and why does that matter for this report?
2. Contrast this query's need for `COALESCE` with Q26's `MAX(order_date)`, which didn't need it. What's the underlying principle?
3. Where else, besides `COALESCE`, could you handle this NULL-to-zero conversion (e.g. in the application layer, in a view)? What are the trade-offs?
4. How would you find products that sold below a certain threshold quantity, including those that sold zero?

## Learning Outcomes

- Solidify the distinction between 'NULL is the correct answer' (Q26) and 'NULL needs to be converted to a business-meaningful default' (this question) — a subtle but critical SQL design decision.
- Practice `COALESCE` as the standard tool for supplying defaults over `LEFT JOIN` aggregates.

---

📄 **SQL File:** [`Q27_Products_And_Total_Quantity_Sold.sql`](./Q27_Products_And_Total_Quantity_Sold.sql)

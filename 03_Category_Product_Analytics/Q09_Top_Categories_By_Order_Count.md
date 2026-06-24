# Q09. Top Categories by Number of Orders

**Category:** Category & Product Analytics
**Difficulty:** Medium

---

## Problem Statement

Merchandising wants to know which product categories appear in the most customer orders, as a measure of category reach/popularity distinct from raw revenue.

## Objective

Identify the 5 categories that appear in the highest number of distinct orders.

## Tables Used

- `categories`
- `products`
- `order_details`
- `orders`

## Expected Output

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

## Concepts Used

- INNER JOIN (multi-table)
- GROUP BY
- Aggregate Functions (COUNT DISTINCT)
- ORDER BY
- LIMIT

## Why This Approach

**Why `COUNT(DISTINCT o.order_id)` is essential, not optional, here:** unlike Q5, this join chain passes through `order_details`, which has multiple rows per order (one per product line). A single order can contain several products from the same category, which would duplicate that order's contribution to the count without `DISTINCT` — directly inflating the category's apparent order reach.

**Why `orders` is joined at all:** `order_details` already has `order_id`, so technically `COUNT(DISTINCT od.order_id)` would suffice without joining `orders` — the explicit join to `orders` here is for clarity/extensibility (e.g. if filtering by order date were later required) rather than strict necessity.

## Common Mistakes

- Omitting `DISTINCT`, which inflates the order count whenever an order contains 2+ products from the same category.
- Confusing 'number of orders touching a category' with 'number of products in a category' — these answer different questions.
- Unnecessarily joining `orders` and not using any of its other columns, adding overhead with no benefit (acceptable for clarity, but worth noting in a performance discussion).

## Difficulty

**Medium**

## Interview Follow-up Questions

1. Why is `DISTINCT` critical in this query but only a defensive habit in Q5?
2. Is the join to `orders` strictly necessary here? When would it become necessary?
3. How would you modify this to count orders per category *per year*?
4. What would happen to this result if a category had products, but none of those products were ever ordered?

## Learning Outcomes

- Understand exactly when `DISTINCT` is required versus merely a safety habit, based on which tables are joined and at what grain.
- Reinforce category-to-order roll-up logic through the products bridge table.

---

📄 **SQL File:** [`Q09_Top_Categories_By_Order_Count.sql`](./Q09_Top_Categories_By_Order_Count.sql)

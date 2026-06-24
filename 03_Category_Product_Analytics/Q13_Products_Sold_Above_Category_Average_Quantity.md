# Q13. Products Sold Above Category Average Quantity

**Category:** Category & Product Analytics
**Difficulty:** Hard

---

## Problem Statement

Inventory planning wants to identify which products are outperforming their own category's typical sales volume, to inform restocking priorities within each category rather than comparing unrelated categories directly.

## Objective

Find products whose total quantity sold exceeds the average quantity sold by products *within the same category* (not the company-wide average).

## Tables Used

- `products`
- `order_details`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| product_id | Unique identifier of the product |
| product_name | Name of the product |
| category_id | Category the product belongs to |
| total_qty | Total quantity sold of this product |
| avg_qty_in_category | Average quantity sold across all products in the same category |

**Sample output:**

| product_id | product_name | category_id | total_qty | avg_qty_in_category |
|------------|--------------|-------------|-----------|---------------------|
| 24 | Guaraná Fantástica | 1 | 858 | 626.4 |
| 75 | Rhönbräu Klosterbier | 1 | 541 | 626.4 |
| 59 | Raclette Courdavault | 4 | 1496 | 672.7 |
| 31 | Gorgonzola Telino | 4 | 999 | 672.7 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- CTE
- GROUP BY
- Aggregate Functions (SUM, AVG)
- Window Functions (alternative)
- Self-comparison within group

## Why This Approach

**Why this needs *two* levels of aggregation, not one:** the comparison target ('average quantity in *this product's* category') is itself an aggregate over an aggregate — first sum quantity per product, then average those per-product sums within each category. A single `GROUP BY` pass cannot produce both the product-level total and the category-level average simultaneously.

**Why two CTEs (`product_qty` and `category_avg`):** the first CTE computes the finer grain (per product); the second re-aggregates that result to the coarser grain (per category). Joining them back together lines up each product with its *own* category's average for comparison.

**Window function alternative:** `AVG(SUM(quantity)) OVER (PARTITION BY category_id)` achieves the same result in a single query by computing the category average as a window over the already-grouped product totals, avoiding the second CTE and an extra join — generally the more efficient and idiomatic approach in PostgreSQL once you're comfortable with window functions.

## Common Mistakes

- Comparing each product to the *company-wide* average quantity instead of its own category's average — this answers a different, less useful question.
- Forgetting to join `category_avg` back on `category_id`, which would compare every product to every category's average rather than just its own.
- Assuming `GROUP BY category_id` alone (without first aggregating per product) can answer this — it can't, because you'd lose the per-product detail needed for the final comparison.

## Difficulty

**Hard**

## Interview Follow-up Questions

1. Why can't this be solved with a single `GROUP BY category_id` pass?
2. Walk through the difference between the two-CTE approach and the window function approach. Which would you prefer in production, and why?
3. What does `PARTITION BY` do differently from `GROUP BY` in the window function version?
4. How would you adapt this to compare products against the median quantity in their category instead of the mean?

## Learning Outcomes

- Understand multi-level aggregation: aggregating an already-aggregated result to a coarser grain.
- Learn to recognize when window functions can replace a self-join-style CTE pattern for cleaner, single-pass queries.
- Practice 'compare to peer group average' logic, a very common real-world analytics pattern (e.g. comparing a salesperson to their team average, a store to its region average, etc).

---

📄 **SQL File:** [`Q13_Products_Sold_Above_Category_Average_Quantity.sql`](./Q13_Products_Sold_Above_Category_Average_Quantity.sql)

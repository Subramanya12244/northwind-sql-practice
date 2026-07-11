# Q44. Products and Total Quantity Sold

**Category:** RIGHT JOIN
**Difficulty:** Medium

---

## Problem Statement

The sales team wants a report showing every product and the total quantity sold. Products that have never been ordered should also appear with a total quantity sold of 0.

## Objective

Return all products along with the total quantity sold, ensuring products with no orders appear with a quantity of 0.

## Tables Used

- `order_details`
- `products`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| product_name | Name of the product |
| total_quantity_sold | Total units sold across all orders (0 if the product has never been ordered) |

**Sample output:**

| product_name | total_quantity_sold |
|--------------|---------------------|
| Chai | 828 |
| Chang | 1057 |
| Product X | 0 |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## Concepts Used

- RIGHT JOIN
- GROUP BY
- Aggregate Functions (SUM)
- NULL Handling (COALESCE)

## Why This Approach

**Why `order_details` is on the LEFT and `products` is on the RIGHT:** the requirement is to preserve every product. Placing `products` as the right table in a `RIGHT JOIN` guarantees every product appears in the result regardless of whether it has any matching rows in `order_details`.

**Why `COALESCE(ROUND(SUM(od.quantity), 2), 0)`:** for a product with no matching `order_details` rows, `SUM(od.quantity)` receives only NULL values and returns NULL — not 0. `COALESCE` converts that NULL to 0 for display. Note that `ROUND(..., 2)` is applied here even though quantity is an integer — this is harmless but technically unnecessary for whole-number quantities; `COALESCE(SUM(od.quantity), 0)` without `ROUND` would produce the same integer result more cleanly.

**Why `GROUP BY p.product_name, p.product_id`:** `product_id` is the unique key ensuring one row per product. `product_name` is included because it is a non-aggregated selected column. Including `product_id` in `GROUP BY` (even though it's not in `SELECT`) is the correct habit — it prevents silent row merges for products with identical names.

**LEFT JOIN equivalent:**
```sql
SELECT p.product_name,
       COALESCE(SUM(od.quantity), 0) AS total_quantity_sold
FROM products p
LEFT JOIN order_details od ON od.product_id = p.product_id
GROUP BY p.product_name, p.product_id;
```

This is structurally identical to Q27 (Products and Total Quantity Sold), which used `LEFT JOIN`. The only difference here is the join direction — `products` moves from left to right, and `LEFT JOIN` becomes `RIGHT JOIN`.

## Common Mistakes

- Using `COUNT(od.quantity)` instead of `SUM(od.quantity)` — `COUNT` counts the number of order line items (rows), not the total units sold within each line item. A single order for 100 units of Chai would contribute `COUNT = 1` but `SUM = 100`.
- Forgetting `COALESCE` — `SUM()` returns NULL for empty groups, not 0.
- Grouping by `product_name` alone, risking silent merges for products with identical names.
- Using `ROUND` on an integer column unnecessarily — while harmless, it signals a misunderstanding of the data type being aggregated.

## Difficulty

**Medium**

## Interview Follow-up Questions

**1. This produces the same result as Q27, which used LEFT JOIN. What is the structural difference between the two queries?**

In Q27, `products` was the left table and `order_details` was the right table — `LEFT JOIN` preserved all products. Here, `order_details` is the left table and `products` is the right table — `RIGHT JOIN` preserves all products. The preserved table is `products` in both cases; only the syntactic direction of the join changes. The result set is identical. This demonstrates a fundamental SQL truth: `LEFT JOIN A to B` = `RIGHT JOIN B to A`.

**2. Why is `ROUND(SUM(od.quantity), 2)` technically unnecessary here?**

`od.quantity` is an integer column — it has no decimal places. `SUM()` of integers produces an integer. Applying `ROUND(..., 2)` to an integer just adds `.00` to the display, which is redundant and potentially misleading (suggesting fractional quantities are possible). A cleaner version would be `COALESCE(SUM(od.quantity), 0)` without `ROUND`. This is a minor style point, but worth noting in a code review.

**3. How would you add a column showing each product's revenue alongside quantity sold?**

Add the revenue expression alongside the quantity sum — both aggregate over the same `order_details` rows:

```sql
SELECT
    p.product_name,
    COALESCE(SUM(od.quantity), 0) AS total_quantity_sold,
    COALESCE(ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2), 0) AS total_revenue
FROM order_details od
RIGHT JOIN products p ON p.product_id = od.product_id
GROUP BY p.product_name, p.product_id
ORDER BY total_revenue DESC;
```

**4. How would you find products in the top 10 by quantity sold, while still keeping zero-sales products in a separate "never ordered" report?**

Use two separate queries or a `CASE` expression to segment:

```sql
WITH product_qty AS (
    SELECT
        p.product_name,
        COALESCE(SUM(od.quantity), 0) AS total_quantity_sold
    FROM order_details od
    RIGHT JOIN products p ON p.product_id = od.product_id
    GROUP BY p.product_name, p.product_id
)
SELECT *,
    CASE WHEN total_quantity_sold = 0 THEN 'Never Ordered'
         ELSE 'Active' END AS status
FROM product_qty
ORDER BY total_quantity_sold DESC;
```

## Learning Outcomes

- Confirm that `RIGHT JOIN` and `LEFT JOIN` produce identical results when the preserved table and lookup table are swapped — building confidence to read and write both interchangeably.
- Recognise that `SUM()` (unlike `COUNT()`) requires `COALESCE` for empty-group NULL handling, regardless of whether the outer join is `LEFT` or `RIGHT`.
- Practice identifying unnecessary `ROUND()` calls on integer columns — a code quality habit relevant for production SQL.

---

📄 **SQL File:** [`Q44_Products_And_Total_Quantity_Sold.sql`](./Q44_Products_And_Total_Quantity_Sold.sql)

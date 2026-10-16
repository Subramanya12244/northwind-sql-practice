# Q01 · Product Revenue

> **Revision Card**
> **Category:** Aggregations & Revenue Analysis | **Difficulty:** Easy
> **Concepts:** INNER JOIN · GROUP BY · SUM · ROUND/CAST
> **Outcome:** ✅ correct first attempt
> **Watch out for:** use `order_details.unit_price` (price at sale), not `products.unit_price` (current catalog price).

## 1. Problem

The sales analytics team wants a breakdown of revenue contributed by every product in the catalog, after accounting for any discounts applied at the line-item level. This report feeds into product performance reviews and discontinuation decisions.

**Objective:** Calculate total revenue per product, where revenue = `unit_price * quantity * (1 - discount)`, summed at the product level.

**Tables:** `products`, `order_details`

**Expected output:**

| Column | Description |
|---|---|
| product_id | Unique identifier of the product |
| product_name | Name of the product |
| total_revenue | Sum of discounted revenue across all orders |

| product_id | product_name | total_revenue |
|---|---|---|
| 38 | Côte de Blaye | 149984.20 |
| 29 | Thüringer Rostbratwurst | 87736.40 |
| 59 | Raclette Courdavault | 76683.75 |

*(Sample values illustrative of the standard Northwind dataset.)*

## 2. My Approach

1. Join `products` to `order_details` on `product_id` to bring in line-item sales.
2. Compute per-line revenue: `unit_price * quantity * (1 - discount)`.
3. Aggregate (`SUM`) at product level with `GROUP BY`.
4. `ROUND` to 2 decimals for currency display.
5. Sort by `total_revenue DESC`.

## 3. My Solution (as submitted)

```sql
SELECT
    p.product_id,
    p.product_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue
FROM products p
JOIN order_details od ON od.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why `JOIN` instead of a subquery:** `order_details` holds one row per product per order — joining it to `products` lets every line item contribute to its product's running total in a single pass.

**Why `order_details.unit_price`, not `products.unit_price`:** the price in `products` reflects the *current* catalog price, which can change after the sale. `order_details.unit_price` is the price actually charged at that transaction — using the wrong one silently produces inaccurate historical revenue.

**Why `GROUP BY` both `product_id` and `product_name`:** PostgreSQL requires every selected non-aggregated column in `GROUP BY`; `product_name` must be listed even though `product_id` alone is the key.

## 7. Common Pitfalls (generic)

- Using `products.unit_price` instead of `order_details.unit_price` → wrong historical totals if prices changed.
- Forgetting `(1 - discount)` → overstates revenue (`discount` is a fraction like `0.15`, not a flat amount).
- Using `COUNT()` instead of `SUM()` when the intent is revenue, not volume.
- Omitting `ROUND()`/`numeric` cast → noisy floating-point output.

## 8. Interview Follow-ups

1. Why `order_details.unit_price` instead of `products.unit_price` for revenue?
2. How would the query change for revenue *before* discounts?
3. Would a never-ordered product appear in this output? Why/why not?
4. How would you add quantity sold alongside revenue?
5. If `discount` could be `NULL`, how would that affect the calc and how do you defend against it?

## 9. Key Takeaway

Transactional (point-in-time) price fields differ from current catalog price fields — always aggregate historical revenue from the transaction-level price, and every non-aggregated column must appear in `GROUP BY`.

---
📄 **SQL File:** [`Q01_Product_Revenue.sql`](./Q01_Product_Revenue.sql)

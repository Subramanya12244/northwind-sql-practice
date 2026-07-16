# Q56. Products and Total Revenue (FULL OUTER JOIN)

**Category:** FULL OUTER JOIN
**Difficulty:** Hard

---

## Problem Statement

Generate a report showing all products and the total revenue generated from each product. The report should include products that have been sold, products that have never been sold, and order detail records that reference a product that does not exist in the products table.

## Objective

Return the product name and total revenue for every product and every order detail record — no product and no order detail line should be excluded from the report.

## Tables Used

- `products`
- `order_details`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| product_name | Name of the product (NULL if the order detail references a non-existent product) |
| total_revenue | Total discounted revenue for this product (0.00 if the product has never been sold, >0.00 for orphaned order lines) |

**Sample output:**

| product_name | total_revenue |
|--------------|---------------|
| Chai | 18452.30 |
| Chang | 15324.75 |
| Product X | 0.00 |
| NULL | 420.00 |

- **`Product X | 0.00`** — a product that exists in the catalog but has never appeared in any order
- **`NULL | 420.00`** — order detail line(s) whose `product_id` references a product that no longer exists (or never existed) in the `products` table

*(Sample values are illustrative. In standard Northwind, all order details reference valid products and all products exist — the NULL row demonstrates FULL OUTER JOIN behaviour for data integrity scenarios.)*

## Concepts Used

- FULL OUTER JOIN
- GROUP BY
- Aggregate Functions (SUM)
- NULL Handling (COALESCE)
- ROUND / CAST
- NULL grouping behaviour in GROUP BY

## Why This Approach

**Why FULL OUTER JOIN and not LEFT or RIGHT JOIN:**

| Join Type | Preserves | Drops |
|-----------|-----------|-------|
| `LEFT JOIN products → order_details` | All products | Orphaned order lines |
| `RIGHT JOIN products → order_details` | All order lines | Never-sold products |
| `FULL OUTER JOIN` | All products AND all order lines | Nothing |

Three row types are required:
1. **Products that have been sold** — `products` matches `order_details`, both sides populated, `SUM > 0`
2. **Products never sold** — `products` has no matching `order_details` row, `product_name` populated, `total_revenue = 0.00`
3. **Orphaned order lines** — `order_details.product_id` references a product not in `products`, `product_name = NULL`, `total_revenue > 0`

Only `FULL OUTER JOIN` surfaces all three simultaneously.

**Why `COALESCE(ROUND(SUM(...)::numeric, 2), 0)`:** for products that have never been sold (type 2 rows), all `order_details` columns are NULL. `SUM()` over an all-NULL group returns NULL — not 0. `COALESCE` converts that NULL to `0.00` as the business requirement asks. Note that for type 3 rows (orphaned order lines), `SUM()` correctly produces a non-zero revenue value since the line items do have quantity, unit_price, and discount values — only `product_name` is NULL.

**Why `::numeric` is placed inside `SUM()` before `ROUND()`:** your SQL casts the entire revenue expression to `::numeric` before summing it. This is valid — it converts each `double precision` line-item calculation to `numeric` before accumulation. An alternative equally correct form is `ROUND(SUM(od.unit_price * od.quantity * (1-od.discount))::numeric, 2)` — casting the `SUM()` result rather than each row — which is slightly more efficient since the cast happens once rather than per row.

**Why `GROUP BY p.product_name, p.product_id`:** `product_id` is the unique key ensuring one row per product. `product_name` is included because it is a non-aggregated selected column. For type 3 rows (orphaned order lines), both `p.product_id` and `p.product_name` are NULL — PostgreSQL groups all NULL `product_id` values together into one NULL group, producing exactly one `NULL | total_revenue` row regardless of how many orphaned order lines exist.

**How the NULL row's revenue is computed:** orphaned order lines have NULL `p.product_id` but non-NULL values for `od.unit_price`, `od.quantity`, and `od.discount` — the revenue data comes from `order_details`, which is fully populated for those rows. `SUM()` correctly accumulates those line-item revenues even though `product_name` is NULL.

## Common Mistakes

- Using `LEFT JOIN products → order_details` — preserves all products but silently drops orphaned order lines (type 3 rows never appear). The `NULL | 420.00` row would be invisible.
- Using `RIGHT JOIN products → order_details` — preserves all order lines but drops never-sold products (type 2 rows never appear). The `Product X | 0.00` row would be invisible.
- Using `COUNT(*)` instead of `SUM()` — counts line items, not revenue. An entirely different metric.
- Forgetting `COALESCE` — `SUM()` returns NULL for never-sold products, not `0.00`. Without `COALESCE`, type 2 rows display NULL instead of 0.00.
- Casting `::numeric` outside `ROUND()` instead of inside — `ROUND(SUM(...)::numeric, 2)` is the standard pattern; placing it elsewhere (e.g. `ROUND(SUM(...)::numeric, 2)::numeric` — redundant, but harmless) is worth understanding.
- Expecting multiple NULL rows — `GROUP BY p.product_id` groups all NULL product IDs together, so there is always exactly one NULL row regardless of how many orphaned order lines exist.

## Difficulty

**Hard**

## Interview Follow-up Questions

**1. What do the three different row types in the output represent in real-world terms, and what business action does each suggest?**

Type 1 (`product_name | revenue > 0`) — a product that has been ordered and is generating revenue. No action needed; this is the normal state. Type 2 (`product_name | 0.00`) — a product that exists in the catalog but has never been ordered. Business action: investigate — is it newly listed, mispriced, or a candidate for discontinuation? This is the same as Q29/Q30 but now with its revenue value (0.00) explicitly confirmed. Type 3 (`NULL | revenue > 0`) — an order detail line whose `product_id` references a product that no longer exists in the `products` table. Business action: urgent data quality fix — revenue is being recorded against a product the system can't identify, which will cause reconciliation failures in financial reporting.

**2. Why does `GROUP BY p.product_id` produce exactly one NULL row even when there are multiple orphaned order lines?**

PostgreSQL's `GROUP BY` treats NULL values as equal to each other for grouping purposes — all rows where `p.product_id IS NULL` (i.e. all orphaned order lines) are placed in the same group. This is a deliberate SQL design: NULL means "unknown", and for grouping, all unknowns are treated as belonging to the same group. The `SUM()` then accumulates revenue across all rows in that NULL group, producing a single `NULL | combined_revenue` row. This is the same `GROUP BY` NULL behaviour documented in Q55.

**3. Why is `::numeric` placed inside the SUM() expression per row in your SQL, and is there a more efficient placement?**

Your SQL computes `(od.unit_price * od.quantity * (1-od.discount))::numeric` — casting each row's revenue calculation to `numeric` before it is passed to `SUM()`. This works correctly but performs the cast once per order detail row. A more efficient placement is to cast the aggregated result: `SUM(od.unit_price * od.quantity * (1-od.discount))::numeric` — the cast happens once on the final summed value rather than on every row. Both approaches produce identical results. The difference only becomes measurable at very high row volumes:

```sql
-- Your version (cast per row — correct, slightly less efficient):
COALESCE(ROUND(SUM((od.unit_price * od.quantity * (1-od.discount))::numeric), 2), 0)

-- Alternative (cast on SUM result — same result, one cast instead of N):
COALESCE(ROUND(SUM(od.unit_price * od.quantity * (1-od.discount))::numeric, 2), 0)
```

**4. How would you separate the NULL product row from regular rows and label it clearly for a stakeholder report?**

Use `COALESCE` on `product_name` to replace NULL with a descriptive label:

```sql
SELECT
    COALESCE(p.product_name, 'Orphaned Order Lines') AS product_name,
    COALESCE(
        ROUND(SUM((od.unit_price * od.quantity * (1 - od.discount))::numeric), 2),
        0
    ) AS total_revenue
FROM products p
FULL OUTER JOIN order_details od ON od.product_id = p.product_id
GROUP BY p.product_name, p.product_id
ORDER BY total_revenue DESC NULLS LAST;
```

`NULLS LAST` in `ORDER BY` keeps the orphaned row at the bottom when sorting by revenue, since `ORDER BY revenue DESC` would otherwise float NULL-named rows to unpredictable positions in some SQL engines.

**5. How does this query differ from Q27 (Products and Total Quantity Sold with LEFT JOIN) and Q44 (RIGHT JOIN version)?**

Q27 used `LEFT JOIN products → order_details`, preserving all products but silently dropping any order lines whose `product_id` doesn't exist in `products`. Q44 used `RIGHT JOIN order_details → products`, preserving all order lines but dropping never-sold products. Both were acceptable for their stated requirements. This query uses `FULL OUTER JOIN`, adding the critical third row type — orphaned order lines — that neither Q27 nor Q44 could surface. The FULL OUTER JOIN version is the complete data quality version: it answers not just "which products sold" and "which products never sold" but also "are there revenue records attached to products that no longer exist in our system?" — a question that matters enormously for financial reconciliation.

## Learning Outcomes

- Understand the three FULL OUTER JOIN row types in a product-revenue context and know the real-world business implication of each — particularly the orphaned order line row, which represents a data integrity risk for financial reporting.
- Confirm that `GROUP BY` groups all NULL values together — producing exactly one NULL row regardless of how many orphaned records exist — and understand why this is the correct behaviour for aggregation.
- Know the difference between casting `::numeric` per row inside `SUM()` versus casting the `SUM()` result — both correct, but the latter is slightly more efficient.
- Recognise this as the most complete version of the product revenue report — superseding both Q27 (LEFT JOIN) and Q44 (RIGHT JOIN) by capturing all three row types in a single query.

---

📄 **SQL File:** [`Q56_Products_And_Total_Revenue_FULL_OUTER_JOIN.sql`](./Q56_Products_And_Total_Revenue_FULL_OUTER_JOIN.sql)

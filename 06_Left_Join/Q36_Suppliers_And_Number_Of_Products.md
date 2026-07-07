# Q36. Suppliers and Number of Products

**Category:** LEFT JOIN
**Difficulty:** Easy

---

## Problem Statement

The procurement team wants a report showing every supplier and the total number of products they supply. Suppliers who do not supply any products should also appear with a product count of 0.

## Objective

Return all suppliers along with the number of products they supply, ensuring suppliers with no products appear with a count of 0.

## Tables Used

- `suppliers`
- `products`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| supplier_name | Name of the supplier company |
| total_products | Total number of products supplied (0 if none) |

**Sample output:**

| supplier_name | total_products |
|---------------|----------------|
| Exotic Liquids | 8 |
| Plutzer Lebensmittelgroßmärkte AG | 5 |
| New Orleans Cajun Delights | 0 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- LEFT JOIN
- GROUP BY
- Aggregate Functions (COUNT)
- NULL Handling

## Why This Approach

**Why `LEFT JOIN suppliers → products`:** preserves every supplier row regardless of whether any products are linked to them. An `INNER JOIN` would silently drop suppliers with no products — directly violating the stated requirement. `LEFT JOIN` keeps every row from `suppliers` and fills `NULL` for all `products` columns where no match exists.

**Why `COUNT(p.product_id)` and not `COUNT(*)`:** for a supplier with no products, the `LEFT JOIN` produces exactly one output row with `p.product_id = NULL`. `COUNT(p.product_id)` counts only non-NULL values, correctly returning `0`. `COUNT(*)` would count that NULL-padded row as `1`, incorrectly suggesting one product exists. Always count a column from the right-hand (joined) table, never `COUNT(*)`, when outer join NULL rows are in play.

**Why no `COALESCE` is needed:** `COUNT()` is the one standard aggregate that returns `0` (not `NULL`) for an empty group. `COALESCE` is genuinely required only for `SUM()`, `AVG()`, `MIN()`, and `MAX()`, which return `NULL` for empty groups. Omitting `COALESCE` here is correct, not an oversight.

**Why `GROUP BY s.company_name, s.supplier_id`:** `supplier_id` is the unique key ensuring one row per supplier; `company_name` must also appear in `GROUP BY` because it is a non-aggregated selected column. Grouping by `company_name` alone risks silently merging two suppliers with identical names.

## Common Mistakes

- Using `INNER JOIN`, which drops suppliers with no products from the result entirely.
- Using `COUNT(*)` instead of `COUNT(p.product_id)`, returning `1` instead of `0` for empty suppliers.
- Grouping on `company_name` alone rather than including the unique key `supplier_id`.
- Adding `COALESCE` unnecessarily — while harmless, it signals a misunderstanding of which aggregates need it.

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. This query is structurally identical to Q35 (Categories and Number of Products). What is the only thing that changes?**

The tables and join key change — `categories`/`category_id` becomes `suppliers`/`supplier_id`, and `products` is joined on `supplier_id` instead of `category_id`. The join type, the `COUNT(p.product_id)` pattern, the `GROUP BY` discipline, and the reasoning about why `COUNT(*)` would be wrong are all identical. This is precisely the point: once the LEFT JOIN + COUNT pattern is internalized, it transfers directly to any "show all X with their associated Y count" report regardless of which tables are involved.

**2. What would happen if a product had a NULL `supplier_id` — would it be counted for any supplier?**

No. A product with `supplier_id = NULL` would not match any supplier row in the `LEFT JOIN` (since `NULL = anything` is never true in SQL join conditions). That product would effectively be orphaned — excluded from every supplier's count. This is a data quality scenario worth noting: if products can have NULL supplier references, a separate data integrity check should flag them, since they would be invisible in this report.

**3. How would you extend this to also show each supplier's average product unit price?**

Add `ROUND(AVG(p.unit_price)::numeric, 2) AS avg_unit_price` to the `SELECT`. For suppliers with no products, `AVG()` returns `NULL` — use `COALESCE(..., 0)` if a zero default is required for display:

```sql
SELECT
    s.company_name AS supplier_name,
    COUNT(p.product_id) AS total_products,
    COALESCE(ROUND(AVG(p.unit_price)::numeric, 2), 0) AS avg_unit_price
FROM suppliers s
LEFT JOIN products p ON p.supplier_id = s.supplier_id
GROUP BY s.company_name, s.supplier_id
ORDER BY total_products DESC;
```

**4. How would you find suppliers who supply more than 3 products?**

Use `HAVING` to filter on the aggregated count after grouping:

```sql
SELECT
    s.company_name AS supplier_name,
    COUNT(p.product_id) AS total_products
FROM suppliers s
LEFT JOIN products p ON p.supplier_id = s.supplier_id
GROUP BY s.company_name, s.supplier_id
HAVING COUNT(p.product_id) > 3
ORDER BY total_products DESC;
```

`HAVING` is required here (not `WHERE`) because the filter applies to an aggregate result that does not exist until after `GROUP BY` completes.

**5. How would you rank suppliers by product count and show their rank position?**

Use `RANK()` as a window function over the grouped result via a CTE or subquery:

```sql
WITH supplier_counts AS (
    SELECT
        s.company_name AS supplier_name,
        COUNT(p.product_id) AS total_products
    FROM suppliers s
    LEFT JOIN products p ON p.supplier_id = s.supplier_id
    GROUP BY s.company_name, s.supplier_id
)
SELECT
    supplier_name,
    total_products,
    RANK() OVER (ORDER BY total_products DESC) AS rank_position
FROM supplier_counts;
```

`RANK()` correctly handles ties by assigning the same rank to suppliers with identical product counts.

## Learning Outcomes

- Reinforce the `LEFT JOIN` + `COUNT(joined_column)` pattern as a transferable template applicable to any "show all entities with their associated count" report.
- Confirm that `COUNT` returns `0` for empty groups without needing `COALESCE`, in contrast to all other standard aggregate functions.
- Practice recognising structurally identical queries across different table pairs — a key skill for writing SQL efficiently without re-deriving logic from scratch each time.

---

📄 **SQL File:** [`Q36_Suppliers_And_Number_Of_Products.sql`](./Q36_Suppliers_And_Number_Of_Products.sql)

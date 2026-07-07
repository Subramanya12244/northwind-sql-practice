# Q35. Categories and Number of Products

**Category:** LEFT JOIN
**Difficulty:** Easy

---

## Problem Statement

The inventory team wants a report showing every product category and the total number of products in each category. Categories with no products should also appear with a product count of 0.

## Objective

Return all categories along with the number of products in each category, ensuring categories with no products still appear with a count of 0 rather than being excluded.

## Tables Used

- `categories`
- `products`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| category_name | Name of the product category |
| total_products | Total number of products in this category (0 if no products assigned) |

**Sample output:**

| category_name | total_products |
|---------------|----------------|
| Beverages | 12 |
| Condiments | 12 |
| Confections | 13 |
| Seafood | 0 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- LEFT JOIN
- GROUP BY
- Aggregate Functions (COUNT)
- NULL Handling

## Why This Approach

**Why `LEFT JOIN categories → products`:** preserves every category row regardless of whether any products are assigned to it. An `INNER JOIN` would silently drop categories with no products — the opposite of what the requirement asks. `LEFT JOIN` keeps every row from `categories` (the left table) and fills `NULL` for all `products` columns when no matching product exists.

**Why `COUNT(p.product_id)` and not `COUNT(*)`:** this is the most important detail in this query. For a category with no products, the `LEFT JOIN` still produces exactly one output row — with `p.product_id` set to `NULL`. `COUNT(p.product_id)` counts only non-NULL values, correctly returning `0` for empty categories. `COUNT(*)` would count that NULL-padded row as `1`, incorrectly suggesting one product exists when none do.

**Why `COUNT` does not need `COALESCE`:** `COUNT(p.product_id)` already returns `0` for empty groups — not `NULL`. `COALESCE` is only necessary for `SUM()`, `AVG()`, `MIN()`, and `MAX()`, which return `NULL` for empty groups. Adding `COALESCE` here is harmless but redundant — understanding this distinction demonstrates deeper SQL fluency.

**Why `GROUP BY c.category_name, c.category_id`:** `category_id` is the unique key that guarantees one row per category; `category_name` must also appear in `GROUP BY` because it is a non-aggregated column in the `SELECT` list. Grouping on `category_name` alone risks silently merging two categories that happen to share the same name.

## Common Mistakes

- Using `INNER JOIN`, which silently drops categories with no products — directly violating the stated requirement.
- Using `COUNT(*)` instead of `COUNT(p.product_id)`, which returns `1` instead of `0` for empty categories because the NULL-padded LEFT JOIN row is still counted as a row by `COUNT(*)`.
- Grouping by `category_name` alone instead of also including `category_id`, which risks merging categories with identical names.
- Wrapping in `COALESCE` and assuming it is required — `COUNT` already handles empty groups gracefully, unlike `SUM`.

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. What is the difference between `COUNT(p.product_id)` and `COUNT(*)` in this query, and why does it matter?**

For a category with no products, the `LEFT JOIN` produces one output row with `p.product_id = NULL`. `COUNT(p.product_id)` counts only non-NULL values, so it returns `0` — correct. `COUNT(*)` counts every row including NULL-padded ones, so it returns `1` — incorrect. This is the single most important distinction when using `LEFT JOIN` with `COUNT`. The fix is always to count a column from the *joined* (right-hand) table, not `COUNT(*)`, whenever NULLs from an outer join are present.

**2. Does this query need `COALESCE` to display `0` for empty categories?**

No. `COUNT(p.product_id)` already returns `0` (not `NULL`) for an empty group, so `COALESCE` would be redundant here. This contrasts with `SUM()`, which returns `NULL` for an empty group and does need `COALESCE` to display `0`. Knowing which aggregates auto-return `0` versus `NULL` for empty groups is a useful interview signal — `COUNT` is the only standard aggregate that returns `0` rather than `NULL` when there is nothing to aggregate.

**3. In the real Northwind dataset, do any categories actually have zero products? What does the query reveal?**

In the standard Northwind dataset, all 8 categories have at least one product, so no category genuinely returns `0`. However, the `LEFT JOIN` pattern is still the correct design — it future-proofs the query for a real-world scenario where a new category is created before any products are assigned to it (common in product catalog management workflows). Writing `INNER JOIN` because "the data currently has no empty categories" is a fragile assumption that can silently break when data changes.

**4. How would you extend this to also show the number of discontinued products per category?**

Add a conditional count using `FILTER` (PostgreSQL syntax) or a `SUM(CASE WHEN ...)` expression:

```sql
SELECT
    c.category_name,
    COUNT(p.product_id) AS total_products,
    COUNT(p.product_id) FILTER (WHERE p.discontinued = 1) AS discontinued_products
FROM categories c
LEFT JOIN products p ON p.category_id = c.category_id
GROUP BY c.category_name, c.category_id
ORDER BY total_products DESC;
```

**5. How would you find categories where the average product unit price exceeds a given threshold?**

Add `AVG(p.unit_price)` to the `SELECT` and filter with `HAVING`:

```sql
SELECT
    c.category_name,
    COUNT(p.product_id) AS total_products,
    ROUND(AVG(p.unit_price)::numeric, 2) AS avg_unit_price
FROM categories c
LEFT JOIN products p ON p.category_id = c.category_id
GROUP BY c.category_name, c.category_id
HAVING AVG(p.unit_price) > 30
ORDER BY avg_unit_price DESC;
```

`HAVING` is required here because the filter applies to an aggregated value that doesn't exist until after `GROUP BY` completes. `WHERE` operates before aggregation and cannot reference aggregate results.

## Learning Outcomes

- Solidify the single most important `LEFT JOIN` + `COUNT` rule: always count a column from the right-hand (joined) table, never `COUNT(*)`, when empty-group rows are a possibility.
- Reinforce that `COUNT` is the only standard SQL aggregate that returns `0` for an empty group — all others (`SUM`, `AVG`, `MIN`, `MAX`) return `NULL` and require `COALESCE` when a zero default is needed.
- Build the habit of using `LEFT JOIN` by default for "show all X with their Y count" reports, even when the current data has no empty categories, to future-proof the query against schema or data changes.
- Practice the `GROUP BY` discipline of always including the primary key alongside display columns to prevent silent row merges.

---

📄 **SQL File:** [`Q35_Categories_And_Number_Of_Products.sql`](./Q35_Categories_And_Number_Of_Products.sql)

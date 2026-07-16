# Q52. Products and Categories (FULL OUTER JOIN)

**Category:** FULL OUTER JOIN
**Difficulty:** Medium

---

## Problem Statement

Generate a report showing all products and all categories. The report should include products that belong to a category, products without a category, and categories that currently have no products.

## Objective

Return the product name and category name — no product and no category should be excluded from the result.

## Tables Used

- `products`
- `categories`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| product_name | Name of the product (NULL if the category has no products) |
| category_name | Name of the category (NULL if the product has no matching category) |

**Sample output:**

| product_name | category_name |
|--------------|---------------|
| Chai | Beverages |
| Chang | Beverages |
| Product X | NULL |
| NULL | Empty Category |

*(In standard Northwind, all products belong to a category and all categories have products — the NULL rows demonstrate FULL OUTER JOIN behaviour for data quality scenarios.)*

## Concepts Used

- FULL OUTER JOIN
- NULL Handling

## Why This Approach

**Why FULL OUTER JOIN:** the requirement has three row types:
1. A product that belongs to a category — both sides populated
2. A product with no matching category (`category_name = NULL`)
3. A category with no products (`product_name = NULL`)

`LEFT JOIN products → categories` would miss type 3 (empty categories). `RIGHT JOIN` would miss type 2 (uncategorised products). Only `FULL OUTER JOIN` surfaces all three simultaneously.

**Practical use case — catalog reconciliation:** in a real product management system, this report would be run when merging two product databases, after a category restructure, or following a data import where some products arrived without category assignments. It gives a complete picture of the state of both tables at once — which is exactly what `FULL OUTER JOIN` is designed for.

**Why the join condition links `category_id`:** `products.category_id` is the foreign key referencing `categories.category_id`. When a product's `category_id` matches a category's `category_id`, both sides are populated. When no match exists on either side, the corresponding columns are NULL.

## Common Mistakes

- Using `LEFT JOIN products → categories` — this shows all products with their categories (NULLs for uncategorised products) but completely drops categories that have no products. Type 3 rows disappear.
- Using `RIGHT JOIN products → categories` — this shows all categories with their products but drops uncategorised products. Type 2 rows disappear.
- Expecting `FULL OUTER JOIN` to aggregate or deduplicate — it doesn't. A category with 12 products still produces 12 separate rows in the result, one per product.
- Confusing "no products in a category" with "category doesn't exist" — a `NULL` `product_name` row from `FULL OUTER JOIN` means the category exists in `categories` but has no matching row in `products` via the join key.

## Difficulty

**Medium**

## Interview Follow-up Questions

**1. How would you use this result to find both uncategorised products AND empty categories at once?**

Filter for NULL on either side after the `FULL OUTER JOIN`:

```sql
SELECT p.product_name, c.category_name
FROM products p
FULL OUTER JOIN categories c ON c.category_id = p.category_id
WHERE p.category_id IS NULL   -- products with no matching category
   OR p.product_id IS NULL;   -- categories with no products
```

This is the FULL OUTER JOIN anti-join — both types of unmatched rows in one pass. Neither `LEFT JOIN` nor `RIGHT JOIN` can produce both types simultaneously.

**2. In your Northwind schema, is it possible for `category_name` to be NULL in this result? Under what conditions?**

Yes — if a product's `category_id` references a `category_id` that doesn't exist in the `categories` table (an orphaned product). This happens when: (a) a category is deleted without reassigning its products, (b) a product is imported with a `category_id` that was never created, or (c) foreign key constraints are not enforced at the database level. In a well-constrained database with active FK enforcement, this shouldn't occur — but this query is the tool for auditing whether it has.

**3. How would you rewrite this without FULL OUTER JOIN, for a database that doesn't support it (e.g. older MySQL)?**

Use a `UNION` of `LEFT JOIN` and `RIGHT JOIN`:

```sql
SELECT p.product_name, c.category_name
FROM products p LEFT JOIN categories c ON c.category_id = p.category_id
UNION
SELECT p.product_name, c.category_name
FROM products p RIGHT JOIN categories c ON c.category_id = p.category_id;
```

`UNION` (not `UNION ALL`) removes the duplicates produced by matched rows appearing in both halves. The result is identical to `FULL OUTER JOIN`. PostgreSQL supports `FULL OUTER JOIN` natively, so the `UNION` workaround is unnecessary here but worth knowing for cross-database compatibility.

**4. How would you extend this to count the number of products per category, including empty categories?**

Add `COUNT(p.product_id)` and `GROUP BY c.category_id, c.category_name`. `COUNT(p.product_id)` correctly returns 0 for empty categories (NULL product_id not counted), and the FULL OUTER JOIN ensures empty categories still appear:

```sql
SELECT
    c.category_name,
    COUNT(p.product_id) AS product_count
FROM products p
FULL OUTER JOIN categories c ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY product_count DESC;
```

## Learning Outcomes

- Understand the three row types produced by `FULL OUTER JOIN` — matched, left-only, and right-only — and know which real-world scenarios generate each type.
- Recognise `FULL OUTER JOIN` as the standard tool for catalog reconciliation, data quality auditing, and any "show everything from both sides" reporting requirement.
- Know the `LEFT JOIN UNION RIGHT JOIN` workaround for databases without native `FULL OUTER JOIN` support.

---

📄 **SQL File:** [`Q52_Products_And_Categories_FULL_OUTER_JOIN.sql`](./Q52_Products_And_Categories_FULL_OUTER_JOIN.sql)

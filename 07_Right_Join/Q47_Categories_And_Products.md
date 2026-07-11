# Q47. Categories and Products

**Category:** RIGHT JOIN
**Difficulty:** Easy

---

## Problem Statement

The inventory team wants a report showing every product along with the category it belongs to. Products without a matching category should also appear in the report.

## Objective

Return all products along with their category names, preserving every product even if it has no matching category.

## Tables Used

- `categories`
- `products`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| product_name | Name of the product |
| category_name | Name of the category the product belongs to (NULL if no matching category) |

**Sample output:**

| product_name | category_name |
|--------------|---------------|
| Chai | Beverages |
| Chang | Beverages |
| Product X | NULL |

*(Sample values are illustrative. In standard Northwind, all products have a valid category — the NULL row demonstrates RIGHT JOIN behaviour for uncategorised products.)*

## Concepts Used

- RIGHT JOIN
- NULL Handling

## Why This Approach

**Why `categories` is on the LEFT and `products` is on the RIGHT:** the requirement is to preserve every product. Placing `products` as the right table in a `RIGHT JOIN` ensures all products appear in the result regardless of whether a matching category exists. For any product whose `category_id` does not match a row in `categories`, the `category_name` column is filled with NULL.

**Structural similarity to Q42:** this query is identical in structure to Q42 (Products and Suppliers). Both preserve `products` as the right table and look up a display name from a parent/lookup table on the left. The only difference is the lookup table — `suppliers` in Q42, `categories` here. Once the RIGHT JOIN pattern is internalised, it applies directly to any "preserve child table, look up parent name" scenario.

**LEFT JOIN equivalent:**
```sql
SELECT p.product_name, c.category_name
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id;
```

**When would `category_name` be NULL in practice?** If a category is deleted from `categories` without first reassigning products to another category, those products become uncategorised — their `category_id` references a row that no longer exists. In a database with FK constraints enforced, this deletion would be blocked. In a data warehouse or loosely-constrained system, this query would surface those orphaned products.

## Common Mistakes

- Placing `products` on the left and `categories` on the right with `RIGHT JOIN` — this would preserve all categories (including empty ones with no products), not all products.
- Using `INNER JOIN`, which would drop uncategorised products entirely from the result.
- Confusing this with Q35 (Categories and Number of Products with LEFT JOIN) — that query counted products per category; this query lists products with their category name, a fundamentally different output grain.

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. How is this query structurally identical to Q42, and what is the transferable pattern?**

Both queries preserve `products` as the right table and look up a descriptive name from a parent/reference table on the left. The pattern is: `RIGHT JOIN <lookup_table> ON <child_fk> = <parent_pk>`. The preserved table (`products`) always appears on the right; the lookup table (`suppliers` in Q42, `categories` here) always appears on the left. The result is a product list enriched with a nullable parent-table attribute. This pattern recurs any time you want "all child records with their parent's display name, even if the parent is missing."

**2. How would you rewrite this as a LEFT JOIN?**

Swap the table order so `products` becomes the left (driving) table:

```sql
SELECT p.product_name, c.category_name
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id;
```

Result is identical. Most developers prefer this form because the driving entity (`products`) is listed first in `FROM`, making the intent immediately clear.

**3. How would you use this query to audit for uncategorised products specifically?**

Filter for rows where the category column is NULL after the RIGHT JOIN:

```sql
SELECT p.product_name, c.category_name
FROM categories c
RIGHT JOIN products p ON p.category_id = c.category_id
WHERE c.category_id IS NULL;
```

This is the RIGHT JOIN anti-join pattern — returning only the unmatched rows from the right (preserved) table.

**4. How would you extend this to also show each product's unit price and whether it is discontinued, grouped by category?**

Add columns from `products` (always available since it's the preserved right table) and sort by category:

```sql
SELECT
    c.category_name,
    p.product_name,
    p.unit_price,
    CASE WHEN p.discontinued = 1 THEN 'Yes' ELSE 'No' END AS is_discontinued
FROM categories c
RIGHT JOIN products p ON p.category_id = c.category_id
ORDER BY c.category_name NULLS LAST, p.product_name;
```

`NULLS LAST` places uncategorised products at the bottom rather than the top when sorting by `category_name DESC`.

## Learning Outcomes

- Reinforce the RIGHT JOIN "preserve right table, look up from left" pattern as a direct template for any "child record with nullable parent attribute" report.
- Recognise this as structurally identical to Q42 — building the habit of recognising SQL patterns across different table pairs rather than treating every query as a unique problem.
- Practice the RIGHT JOIN anti-join extension for data quality auditing.

---

📄 **SQL File:** [`Q47_Categories_And_Products.sql`](./Q47_Categories_And_Products.sql)

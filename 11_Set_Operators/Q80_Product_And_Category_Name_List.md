# Q80. Product and Category Name List

**Category:** Set Operators (UNION)
**Difficulty:** Easy

---

## Problem Statement

Create a single list combining all product names and all category names into one unified column.

## Objective

Return a single column containing every product name and every category name, with duplicates removed.

## Tables Used

- `products`
- `categories`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| product_name | Name from either the products or categories table |

**Sample output:**

| product_name |
|--------------|
| Beverages |
| Chai |
| Chang |
| Condiments |
| Confections |

*(Output column is labelled `product_name` because that is the alias from the first SELECT statement — UNION always takes column names from the first query.)*

## Concepts Used

- UNION
- Set Operators

## Why This Approach

**Why UNION works here despite mixing products and categories:** UNION doesn't care whether the rows are conceptually similar — it only requires the same number of columns with compatible types. Both `product_name` (varchar) and `category_name` (varchar) satisfy this requirement. The combined output is a single-column list of text values.

**Why the output column is labelled `product_name`:** UNION always takes the column names for its output from the **first** SELECT statement. The second SELECT's column alias (`category_name`) is completely ignored. If you want a neutral label, alias the first SELECT's column:
```sql
SELECT product_name AS name FROM products
UNION
SELECT category_name FROM categories;
```

**What this list would be used for:** mixing product names and category names in one list is unusual in most business reports — more commonly you'd include a `type` column to distinguish them (similar to Q82). But as a pure set operation exercise, it demonstrates that UNION is purely structural — it doesn't validate whether the combined rows are semantically meaningful.

**Why UNION deduplicates:** if any product happened to have the same name as a category (e.g. a product named "Beverages"), it would appear only once in the output. `UNION ALL` would show it twice.

## Common Mistakes

- Expecting the output column to be labelled `category_name` — UNION always uses the first SELECT's column name.
- Selecting additional columns from one query but not the other — e.g. `SELECT product_name, unit_price FROM products UNION SELECT category_name FROM categories` causes a column count mismatch error.
- Using `JOIN` — `products` and `categories` do have a `category_id` foreign key relationship, but a JOIN here would produce one row per product with its category name alongside it (wider rows). UNION produces one row per name from either table (taller list). These answer completely different questions.

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. UNION takes column names from the first SELECT. How would you give the combined column a neutral, meaningful label?**

Alias the first SELECT's column: `SELECT product_name AS item_name FROM products UNION SELECT category_name FROM categories`. The alias in the first query becomes the output column name. The second query's column name is irrelevant to the output label, though it should still be a compatible type.

**2. In this dataset, products and categories ARE related by a foreign key. Could you solve this with a JOIN, and what would be different?**

Yes — `SELECT p.product_name, c.category_name FROM products p JOIN categories c ON p.category_id = c.category_id` produces product-category pairs, one row per product. That answers "which category does each product belong to?" UNION answers "give me all product names and all category names in one flat list." They answer fundamentally different questions — one combines attributes of related rows, the other stacks rows from independent result sets.

**3. How many rows would UNION vs UNION ALL produce from these two tables in Northwind?**

Northwind has 77 products and 8 categories = 85 total rows before deduplication. If any product name exactly matches a category name, `UNION` would produce fewer than 85 rows (deduplicating those matches). `UNION ALL` always produces exactly 77 + 8 = 85 rows. In standard Northwind, no product name matches a category name, so both produce 85 rows — but `UNION` is slightly slower due to the deduplication step.

**4. How would you add a type column to distinguish products from categories in the output?**

```sql
SELECT product_name AS name, 'Product' AS type FROM products
UNION
SELECT category_name, 'Category' AS type FROM categories
ORDER BY type, name;
```
This makes the combined list actionable — a reader can see which column each name came from.

**5. Can you UNION more than two SELECT statements?**

Yes — you can chain as many SELECT statements as needed: `SELECT ... UNION SELECT ... UNION SELECT ...`. Each additional SELECT adds another result set to the combined output. Q81 demonstrates this with three tables. UNION removes duplicates across the entire combined result, not just between adjacent pairs.

## Learning Outcomes

- Understand that UNION column labels come from the first SELECT statement — a frequently tested detail.
- Reinforce that UNION requires structural compatibility (same column count, compatible types) but does not require semantic similarity between the combined rows.
- Know the row count formula: UNION produces ≤ (rows_A + rows_B) rows; UNION ALL produces exactly (rows_A + rows_B) rows.

---

📄 **SQL File:** [`Q80_Product_And_Category_Name_List.sql`](./Q80_Product_And_Category_Name_List.sql)

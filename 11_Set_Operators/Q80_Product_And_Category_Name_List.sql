/*
Question:
Return a single column containing all product names and all category
names combined into one unified list, with duplicates removed.

Business Requirement:
Create a flat list of all names from both the products and categories
tables in a single column.

Approach:
1. SELECT product_name FROM products — all 77 product names.
2. UNION SELECT category_name FROM categories — all 8 category names.
3. UNION removes any duplicate values across both sets.
4. Output column is labelled product_name (from the first SELECT).
   To use a neutral label: SELECT product_name AS name FROM products ...

Note on column labelling:
   UNION always takes output column names from the FIRST SELECT statement.
   The second SELECT's column name (category_name) is ignored in the output.
   To override: alias the first SELECT column.

Note on UNION vs JOIN:
   products and categories ARE related by category_id in Northwind.
   JOIN would produce product-category PAIRS (wider rows).
   UNION produces a flat list of ALL names from both tables (taller list).
   These answer completely different business questions.

Expected Output:
| product_name |
|--------------|
| Beverages    |
| Chai         |
| Chang        |
| Condiments   |

Concepts Used:
- UNION
- Set Operators

Complexity:
Easy
*/

select p.product_name from products p
union
select c.category_name from categories c;

/*
Question:
Return all products along with their category names, preserving every
product even if it has no matching category record.

Business Requirement:
The inventory team wants a complete product-category mapping report.
Products with no matching category (uncategorised or orphaned records)
must still appear with NULL for the category name rather than being
silently dropped.

Approach:
1. Place categories on the LEFT and products on the RIGHT.
2. RIGHT JOIN preserves every row from products (the right table)
   regardless of whether a matching category exists.
3. For unmatched products, category_name is filled with NULL.
4. Equivalent LEFT JOIN version (same result):
   SELECT p.product_name, c.category_name
   FROM products p
   LEFT JOIN categories c ON p.category_id = c.category_id;

Note:
In standard Northwind, all products belong to a valid category.
The NULL scenario demonstrates RIGHT JOIN behaviour for data quality
use cases — e.g. detecting products orphaned by a deleted category.

Expected Output:
| product_name | category_name |
|--------------|---------------|
| Chai         | Beverages     |
| Chang        | Beverages     |
| Product X    | NULL          |

Concepts Used:
- RIGHT JOIN
- NULL Handling

Complexity:
Easy
*/

SELECT
    p.product_name,
    c.category_name
FROM categories c
RIGHT JOIN products p
    ON p.category_id = c.category_id;

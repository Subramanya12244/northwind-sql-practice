/*
Question:
Return the product name and category name for every product and every
category — no product and no category should be excluded.

Business Requirement:
Generate a complete product-category reconciliation report covering:
1. Products that belong to a category (both sides populated)
2. Products with no matching category (category_name = NULL)
3. Categories with no products (product_name = NULL)

Why FULL OUTER JOIN:
- LEFT JOIN products → categories: misses empty categories (type 3)
- RIGHT JOIN products → categories: misses uncategorised products (type 2)
- FULL OUTER JOIN: preserves all rows from both tables simultaneously

UNION workaround (for databases without FULL OUTER JOIN support):
   SELECT p.product_name, c.category_name
   FROM products p LEFT JOIN categories c ON c.category_id = p.category_id
   UNION
   SELECT p.product_name, c.category_name
   FROM products p RIGHT JOIN categories c ON c.category_id = p.category_id;

Expected Output:
| product_name | category_name  |
|--------------|----------------|
| Chai         | Beverages      |
| Chang        | Beverages      |
| Product X    | NULL           |
| NULL         | Empty Category |

Concepts Used:
- FULL OUTER JOIN
- NULL Handling

Complexity:
Medium
*/

select p.product_name, c.category_name
from products p
full outer join categories c on c.category_id = p.category_id;

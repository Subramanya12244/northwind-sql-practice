/*
Question:
Return all categories along with the number of products in each category,
including categories with no products displayed as 0.

Business Requirement:
The inventory team wants a complete category-product count report —
every category must appear, and those with no products should show a
count of 0 rather than being excluded from the report.

Approach:
1. Start from categories and LEFT JOIN to products on category_id,
   preserving every category regardless of whether products are assigned.
2. Use COUNT(p.product_id) — not COUNT(*) — to count products per
   category. For a category with no products, the LEFT JOIN produces
   one NULL-padded row; COUNT(p.product_id) sees NULL and returns 0,
   while COUNT(*) would incorrectly return 1.
3. COUNT returns 0 (not NULL) for empty groups, so COALESCE is not
   required — unlike SUM(), which returns NULL for empty groups.
4. GROUP BY both category_name and category_id — category_id is the
   unique key ensuring one row per category; category_name is included
   because it is a non-aggregated selected column.

Expected Output:
| category_name | total_products |
|---------------|----------------|
| Beverages     | 12             |
| Confections   | 13             |
| Seafood       | 0              |

Concepts Used:
- LEFT JOIN
- GROUP BY
- Aggregate Functions (COUNT)
- NULL Handling

Complexity:
Easy
*/

select c.category_name,
count(p.product_id) as total_products
from categories c
left join products p on p.category_id = c.category_id
group by c.category_name, c.category_id;

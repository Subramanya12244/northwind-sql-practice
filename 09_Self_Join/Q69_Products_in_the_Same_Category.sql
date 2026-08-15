/*
Question:
Return every unique pair of products that share the same `category_id`, along with the category name. Exclude self-pairs and duplicate pairs.

Business Requirement:
Retrieve pairs of products belonging to the same category.

Approach:
See markdown file for full reasoning. Key points:



-- Attempt 1 — Missing same-category condition:
-- Reason it fails: Missing `AND p1.category_id = p2.category_id` — pairs every product with every other product.
--
-- 
select p1.product_name as Product_1_Name,-- p2.product_name as Product_2_Name,-- c.category_name-- from products p1-- join products p2-- on p1.product_id < p2.product_id-- left join categories c on c.category_id = p1.category_id

Expected Output:
| product_1_name | product_2_name | category_name |
|----------------|----------------|---------------|
| Chai | Chang | Beverages |
| Chai | Guaraná Fantástica | Beverages |

Concepts Used:
- SELF JOIN
- INNER JOIN
- LEFT JOIN (to lookup category name)
- Duplicate pair elimination (id < id)

Score: 10/10
Takeaway: Pattern: `id < id AND category = category`. Join a lookup table only when the display value (name) isn't already on the self-joined table.

Complexity:
Easy
*/

select p1.product_name as Product_1_Name,
p2.product_name as Product_2_Name,
c.category_name
from products p1
join products p2
on p1.product_id < p2.product_id
and p1.category_id = p2.category_id
left join categories c on c.category_id = p1.category_id;

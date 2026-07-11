/*
Question:
Return all products and their corresponding supplier names, preserving
every product even if it has no matching supplier record.

Business Requirement:
The inventory team wants a complete product-supplier report. Products
with no matching supplier (orphaned records) must still appear with
NULL for the supplier name rather than being silently dropped.

Approach:
1. Place suppliers on the LEFT and products on the RIGHT.
2. RIGHT JOIN preserves every row from products (the right table)
   regardless of whether a matching supplier exists.
3. For unmatched products, all supplier columns (including company_name)
   are filled with NULL.
4. Equivalent LEFT JOIN version (same result, different table order):
   SELECT p.product_name, s.company_name AS supplier_name
   FROM products p
   LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id;

Note:
In standard Northwind, all products have valid supplier references,
so no NULL rows appear in practice. The NULL scenario demonstrates
RIGHT JOIN behaviour for orphan-row detection use cases.

Expected Output:
| product_name | supplier_name   |
|--------------|-----------------|
| Chai         | Exotic Liquids  |
| Chang        | Exotic Liquids  |
| Product X    | NULL            |

Concepts Used:
- RIGHT JOIN
- NULL Handling

Complexity:
Easy
*/

select
    p.product_name,
    s.company_name as supplier_name
from suppliers s
right join products p on
    p.supplier_id = s.supplier_id;

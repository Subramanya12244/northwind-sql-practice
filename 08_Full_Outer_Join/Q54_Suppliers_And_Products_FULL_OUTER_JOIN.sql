/*
Question:
Return the supplier name and product name for every supplier and every
product — no supplier and no product should be excluded.

Business Requirement:
Generate a complete supplier-product reconciliation report covering:
1. Suppliers who supply products (both sides populated)
2. Suppliers with no products (product_name = NULL)
3. Products with no matching supplier (company_name = NULL)

Why FULL OUTER JOIN:
- LEFT JOIN suppliers → products: misses supplier-less products (type 3)
- RIGHT JOIN suppliers → products: misses product-less suppliers (type 2)
- FULL OUTER JOIN: preserves all rows from both tables simultaneously

Structural pattern (same across Q51-Q54):
   SELECT <display_col_A>, <display_col_B>
   FROM <table_A>
   FULL OUTER JOIN <table_B> ON <shared_key>;
   -- Both sides preserved; NULLs appear only for unmatched rows.

Expected Output:
| company_name               | product_name                     |
|----------------------------|----------------------------------|
| Exotic Liquids             | Chai                             |
| Grandma Kelly's Homestead  | Northwoods Cranberry Sauce       |
| Supplier X                 | NULL                             |
| NULL                       | Product Y                        |

Concepts Used:
- FULL OUTER JOIN
- NULL Handling

Complexity:
Medium
*/

select s.company_name, p.product_name
from suppliers s
full outer join products p on p.supplier_id = s.supplier_id;

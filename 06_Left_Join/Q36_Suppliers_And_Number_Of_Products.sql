/*
Question:
Return all suppliers along with the number of products they supply,
including suppliers with no products displayed as 0.

Business Requirement:
The procurement team wants a complete supplier-product count report —
every supplier must appear, and those with no products should show a
count of 0 rather than being excluded.

Approach:
1. Start from suppliers and LEFT JOIN to products on supplier_id,
   preserving every supplier regardless of whether products are assigned.
2. Use COUNT(p.product_id) — not COUNT(*) — to count products per
   supplier. For a supplier with no products, the LEFT JOIN produces
   one NULL-padded row; COUNT(p.product_id) sees NULL and returns 0,
   while COUNT(*) would incorrectly return 1.
3. COUNT returns 0 (not NULL) for empty groups, so COALESCE is not
   required — unlike SUM(), which returns NULL for empty groups.
4. GROUP BY both company_name and supplier_id — supplier_id is the
   unique key; company_name is included as a non-aggregated selected column.

Expected Output:
| supplier_name                     | total_products |
|-----------------------------------|----------------|
| Exotic Liquids                    | 8              |
| New Orleans Cajun Delights        | 0              |

Concepts Used:
- LEFT JOIN
- GROUP BY
- Aggregate Functions (COUNT)
- NULL Handling

Complexity:
Easy
*/

select s.company_name,
count(p.product_id) as total_products
from suppliers s
left join products p on p.supplier_id = s.supplier_id
group by s.company_name, s.supplier_id;

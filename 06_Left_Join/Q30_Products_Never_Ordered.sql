/*
Question:
Return all products that do not appear in any order.

Business Requirement:
The inventory team wants to identify products that have never been purchased
by any customer, to support catalog review and discontinuation decisions.

Approach:
1. LEFT JOIN products to order_details on product_id, preserving every
   product regardless of whether it has been ordered.
2. Filter to rows where od.product_id IS NULL, which identifies products
   with no matching row in order_details at all.

Expected Output:
| product_id | product_name |
|------------|--------------|
| 9 | Mishi Kobe Niku |
| 17 | Alice Mutton |

Concepts Used:
- LEFT JOIN
- NULL Handling
- WHERE

Complexity:
Easy
*/

select p.product_id, p.product_name
from products p
left join order_details od on p.product_id = od.product_id
where od.product_id is NULL

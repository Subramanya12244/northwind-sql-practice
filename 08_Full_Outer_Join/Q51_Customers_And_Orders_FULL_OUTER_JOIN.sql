/*
Question:
Return the customer name and order ID for every customer and every
order — no row from either table should be excluded.

Business Requirement:
Generate a complete reconciliation report covering:
1. Customers who have placed orders (both sides populated)
2. Customers who have never placed an order (order_id = NULL)
3. Orders that have no matching customer record (contact_name = NULL)

Why FULL OUTER JOIN:
- LEFT JOIN would drop orphaned orders (type 3 rows)
- RIGHT JOIN would drop customers with no orders (type 2 rows)
- Only FULL OUTER JOIN preserves all rows from both tables simultaneously

Approach:
1. FULL OUTER JOIN customers to orders on customer_id.
2. Matched rows: customer has at least one order — both sides populated.
3. Left-only rows: customer has no orders — order_id is NULL.
4. Right-only rows: order has no matching customer — contact_name is NULL.

FULL OUTER JOIN = LEFT JOIN UNION RIGHT JOIN (equivalent, less efficient):
   SELECT c.contact_name, o.order_id
   FROM customers c LEFT JOIN orders o ON o.customer_id = c.customer_id
   UNION
   SELECT c.contact_name, o.order_id
   FROM customers c RIGHT JOIN orders o ON o.customer_id = c.customer_id;

Expected Output:
| contact_name                         | order_id |
|--------------------------------------|----------|
| Maria Anders                         | 10248    |
| Ana Trujillo                         | 10249    |
| FISSA Fabrica Inter. Salchichas S.A. | NULL     |
| NULL                                 | 11080    |

Concepts Used:
- FULL OUTER JOIN
- NULL Handling

Complexity:
Medium
*/

select c.contact_name, o.order_id
from customers c
full outer join orders o on o.customer_id = c.customer_id;

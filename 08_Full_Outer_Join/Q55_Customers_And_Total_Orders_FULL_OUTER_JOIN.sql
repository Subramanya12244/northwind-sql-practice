/*
Question:
Return all customers and the total number of orders they have placed,
including customers with no orders (0) and a row for orphaned orders
where no matching customer exists (NULL contact_name).

Business Requirement:
Generate a complete customer order count report covering:
1. Customers with orders: both sides populated, COUNT > 0
2. Customers with no orders: order_id = NULL, COUNT = 0
3. Orphaned orders (no matching customer): contact_name = NULL, COUNT > 0

Why FULL OUTER JOIN (vs Q25 which used LEFT JOIN):
- LEFT JOIN (Q25): shows types 1 and 2 only — orphaned orders invisible
- FULL OUTER JOIN: shows all three types including data quality anomalies

Key behaviour — COUNT(o.order_id) vs COUNT(*):
   For customers with no orders (type 2), the FULL OUTER JOIN produces
   a row with o.order_id = NULL.
   COUNT(o.order_id) → 0 (NULL values not counted) ✅
   COUNT(*) → 1 (counts the NULL-padded row itself) ❌

Key behaviour — NULL grouping in GROUP BY:
   All orphaned orders (type 3) have c.customer_id = NULL.
   GROUP BY c.customer_id treats all NULLs as one group.
   Result: exactly ONE NULL row in output, regardless of how many
   orphaned orders exist. COUNT gives the total for all orphaned orders.
   PostgreSQL treats NULL = NULL as TRUE for GROUP BY (but FALSE for WHERE).

Approach:
1. FULL OUTER JOIN customers to orders on customer_id.
2. COUNT(o.order_id) per customer — correctly returns 0 for no-order
   customers and the orphaned-order count for the NULL group.
3. GROUP BY c.customer_id, c.contact_name — both required.

Compare to Q25 (LEFT JOIN version — no orphaned order row):
   SELECT c.contact_name, COUNT(o.order_id) AS order_count
   FROM customers c
   LEFT JOIN orders o ON o.customer_id = c.customer_id
   GROUP BY c.customer_id, c.contact_name;

Expected Output:
| contact_name                         | total_orders |
|--------------------------------------|--------------|
| Maria Anders                         | 12           |
| Ana Trujillo                         | 8            |
| FISSA Fabrica Inter. Salchichas S.A. | 0            |
| NULL                                 | 1            |

Concepts Used:
- FULL OUTER JOIN
- GROUP BY
- Aggregate Functions (COUNT)
- NULL Handling
- NULL grouping behaviour in GROUP BY

Complexity:
Hard
*/

select c.contact_name,
count(o.order_id) as total_orders
from customers c
full outer join orders o on o.customer_id = c.customer_id
group by c.customer_id, c.contact_name;

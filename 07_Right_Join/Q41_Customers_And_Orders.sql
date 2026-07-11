/*
Question:
Return all orders and their corresponding customer names, preserving
every order even if it has no matching customer record.

Business Requirement:
The sales team wants a complete order report showing the customer behind
each order. Orders with no matching customer (data quality anomalies)
must still appear with NULL for the customer name rather than being
silently dropped.

Approach:
1. Place customers on the LEFT and orders on the RIGHT.
2. RIGHT JOIN preserves every row from orders (the right table)
   regardless of whether a matching customer exists.
3. For unmatched orders, all customer columns (including contact_name)
   are filled with NULL.
4. Equivalent LEFT JOIN version (same result, different table order):
   SELECT o.order_id, c.contact_name
   FROM orders o
   LEFT JOIN customers c ON o.customer_id = c.customer_id;

Note:
In the standard Northwind dataset, all orders have valid customer
references, so no NULL rows will appear in practice. The NULL scenario
demonstrates the RIGHT JOIN behaviour for data quality / orphan-row
detection use cases common in production systems.

Expected Output:
| order_id | contact_name |
|----------|--------------|
| 10248    | Maria Anders |
| 10249    | Ana Trujillo |
| 10250    | NULL         |

Concepts Used:
- RIGHT JOIN
- NULL Handling

Complexity:
Easy
*/

select o.order_id, c.contact_name
from customers c
right join orders o on o.customer_id = c.customer_id;

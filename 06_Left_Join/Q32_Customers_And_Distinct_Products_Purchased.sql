/*
Question:
Return all customers along with the count of distinct products they have
purchased, including customers with no orders displayed as 0.

Business Requirement:
The product analytics team wants a complete customer-product breadth
report — every customer must appear, and those with no orders should
show a distinct product count of 0 rather than being excluded.

Approach:
1. Start from customers and LEFT JOIN to orders on customer_id.
2. LEFT JOIN to order_details on order_id to reach line-item level.
3. LEFT JOIN to products on product_id to bring in product context.
4. All joins must remain LEFT JOIN — converting any to INNER JOIN would
   drop no-order customers from the result at that step.
5. Use COUNT(DISTINCT p.product_id) to count unique products per customer.
   DISTINCT is essential — without it, repeat purchases of the same
   product across multiple orders inflate the count incorrectly.
6. COUNT returns 0 (not NULL) for empty groups, so COALESCE is not
   required here — unlike SUM(), which returns NULL for empty groups.
7. GROUP BY both contact_name and customer_id — customer_id ensures
   correct one-row-per-customer grouping; contact_name is included
   because it is a non-aggregated selected column.

Expected Output:
| contact_name | distinct_products |
|--------------|-------------------|
| Maria Anders | 24 |
| Thomas Hardy | 31 |
| Ana Trujillo | 0 |

Concepts Used:
- LEFT JOIN (chained, four levels)
- GROUP BY
- Aggregate Functions (COUNT DISTINCT)
- NULL Handling

Complexity:
Medium
*/

select c.contact_name,
count(distinct p.product_id)
from customers c
left join orders o on o.customer_id = c.customer_id
left join order_details od on o.order_id = od.order_id
left join products p on p.product_id = od.product_id
group by c.contact_name, c.customer_id;

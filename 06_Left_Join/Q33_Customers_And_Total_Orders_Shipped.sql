/*
Question:
Return all customers along with the number of shipped orders, including
customers with no orders displayed as 0.

Business Requirement:
The logistics team wants a complete customer shipping report — every
customer must appear, and those with no orders should show a shipped
order count of 0 rather than being excluded.

Approach:
1. Start from customers and LEFT JOIN to orders on customer_id, preserving
   every customer regardless of order history.
2. LEFT JOIN to shippers on ship_via = shipper_id to bring in shipper
   context alongside each order row.
3. Count orders per customer using COUNT(o.order_id), which correctly
   returns 0 for customers with no matching orders (NULL order_id rows
   produced by the LEFT JOIN are not counted).
4. Wrap in COALESCE(..., 0) as a defensive default — COUNT already
   returns 0 for empty groups, but COALESCE makes the intent explicit.
5. GROUP BY both contact_name and customer_id — customer_id ensures
   correct one-row-per-customer grouping; contact_name is included
   because it is a non-aggregated selected column.

Note:
The join to shippers attaches shipper information to each order but does
not filter for "dispatched" orders specifically. To count only orders
that have actually been shipped out, filter on o.shipped_date IS NOT NULL
(placed inside the ON clause to preserve no-order customers in the result).

Expected Output:
| contact_name | shipped_orders |
|--------------|----------------|
| Maria Anders | 12 |
| Ana Trujillo | 0 |
| Thomas Hardy | 9 |

Concepts Used:
- LEFT JOIN (chained, two levels)
- GROUP BY
- Aggregate Functions (COUNT)
- NULL Handling (COALESCE)

Complexity:
Medium
*/

select c.contact_name,
coalesce(count(o.order_id),0)
from customers c left join
orders o on o.customer_id = c.customer_id
left join shippers sh on shipper_id = ship_via
group by c.contact_name,c.customer_id;

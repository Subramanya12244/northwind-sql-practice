/*
Question:
Return all customers along with their total revenue, including customers
with no orders displayed as 0.00.

Business Requirement:
The sales team wants a complete customer revenue report — every customer
must appear, and those with no orders should show revenue as 0 rather
than being excluded or showing NULL.

Approach:
1. Start from customers and LEFT JOIN to orders on customer_id, preserving
   every customer regardless of order history.
2. LEFT JOIN again to order_details on order_id — must remain LEFT JOIN
   so the NULL-padded rows from step 1 are not dropped at this stage.
3. Calculate discounted revenue per line item:
   unit_price * quantity * (1 - discount).
4. Aggregate with SUM() at the customer level.
5. Wrap SUM() in COALESCE(..., 0) to convert NULL (produced for customers
   with no orders) into the required 0.00 display value.
6. Cast to numeric and ROUND to 2 decimal places for clean currency display.
7. GROUP BY both contact_name and customer_id — customer_id ensures
   correct grouping; contact_name is included because it is selected.

Expected Output:
| contact_name | revenue |
|--------------|---------|
| Maria Anders | 15234.50 |
| Ana Trujillo | 0.00 |
| Thomas Hardy | 11624.90 |

Concepts Used:
- LEFT JOIN (chained, two levels)
- GROUP BY
- Aggregate Functions (SUM)
- NULL Handling (COALESCE)
- ROUND / CAST

Complexity:
Medium
*/

select c.contact_name,
coalesce (round(sum(od.unit_price*od.quantity*(1-od.discount))::numeric,2),0) as revenue
from customers as c
left join orders as o on
c.customer_id=o.customer_id
left join order_details od on
o.order_id=od.order_id
group by c.contact_name,c.customer_id;

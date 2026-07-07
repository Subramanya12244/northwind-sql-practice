/*
Question:
Return all shipping companies along with the total number of orders they
have handled, including shippers with no orders displayed as 0.

Business Requirement:
The logistics department wants a complete shipper order count report —
every shipping company must appear, and those with no orders should show
a count of 0 rather than being excluded.

Approach:
1. Start from shippers and LEFT JOIN to orders on ship_via = shipper_id,
   preserving every shipper regardless of order history.
   Note: ship_via (orders) references shipper_id (shippers) — the columns
   have different names in Northwind, so the join condition must map them
   explicitly. Qualifying with table aliases (o.ship_via = s.shipper_id)
   is safer and more readable.
2. Use COUNT(o.order_id) — not COUNT(*) — to count orders per shipper.
   For a shipper with no orders, COUNT(o.order_id) returns 0 correctly,
   while COUNT(*) would return 1 for the NULL-padded LEFT JOIN row.
3. COUNT returns 0 for empty groups so COALESCE is not required.
4. GROUP BY both company_name and shipper_id.

Expected Output:
| company_name     | total_orders |
|------------------|--------------|
| Speedy Express   | 249          |
| United Package   | 326          |
| New Shipper Co   | 0            |

Concepts Used:
- LEFT JOIN
- GROUP BY
- Aggregate Functions (COUNT)
- NULL Handling

Complexity:
Easy
*/

select s.company_name,
count(o.order_id) as total_orders
from shippers s
left join orders o on ship_via = shipper_id
group by s.company_name, s.shipper_id;

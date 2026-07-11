/*
Question:
Return all customers along with their total revenue, including customers
with no orders displayed as 0.00. Use RIGHT JOIN only.

Business Requirement:
The finance team wants a complete customer revenue report — every customer
must appear, and those with no orders should show 0.00 rather than being
excluded or showing NULL.

Approach:
1. Place order_details on the LEFT, orders in the middle, customers on the RIGHT.
2. First RIGHT JOIN: order_details RIGHT JOIN orders — preserves all orders
   even if they have no line items in order_details (edge case).
3. Second RIGHT JOIN: [order_details + orders] RIGHT JOIN customers —
   preserves all customers even if they have no matching orders.
   The net effect: customers is fully preserved (the rightmost table).
4. Calculate discounted revenue: quantity * unit_price * (1 - discount).
5. Aggregate with SUM(); wrap in COALESCE(..., 0) — SUM returns NULL
   (not 0) for empty groups.
6. Cast to numeric and ROUND to 2 decimal places.
7. GROUP BY c.customer_id to ensure one row per customer.

LEFT JOIN equivalent (same result, clearer reading order):
   SELECT c.contact_name,
       COALESCE(ROUND(SUM(od.quantity * od.unit_price * (1-od.discount))::numeric, 2), 0)
   FROM customers c
   LEFT JOIN orders o ON o.customer_id = c.customer_id
   LEFT JOIN order_details od ON od.order_id = o.order_id
   GROUP BY c.contact_name, c.customer_id;

Expected Output:
| contact_name | total_revenue |
|--------------|---------------|
| Maria Anders | 12543.65      |
| Ana Trujillo | 0.00          |

Concepts Used:
- RIGHT JOIN (chained, two levels)
- GROUP BY
- Aggregate Functions (SUM)
- NULL Handling (COALESCE)
- ROUND / CAST

Complexity:
Medium
*/

SELECT
    c.contact_name,
    COALESCE(
        ROUND(
            SUM(od.quantity * od.unit_price * (1 - od.discount))::numeric,
            2
        ),
        0
    ) AS total_revenue
FROM order_details od
RIGHT JOIN orders o
    ON o.order_id = od.order_id
RIGHT JOIN customers c
    ON c.customer_id = o.customer_id
GROUP BY c.contact_name, c.customer_id;

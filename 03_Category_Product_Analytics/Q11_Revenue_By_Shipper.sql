/*
Question:
Calculate the total discounted revenue of orders handled by each shipping company.

Business Requirement:
The business wants to calculate total revenue handled by each shipping company, to support logistics partner evaluation and contract negotiations.

Approach:
1. Join shippers to orders on ship_via = shipper_id.
2. Join orders to order_details to access transaction-level revenue.
3. Calculate discounted revenue per line item.
4. Aggregate revenue by shipper.
5. Sort by total revenue descending.

Expected Output:
| shipper_id | company_name | total_revenue |
|------------|--------------|---------------|
| 3 | Federal Shipping | 402817.59 |
| 1 | Speedy Express | 385482.42 |
| 2 | United Package | 374733.39 |

Concepts Used:
- INNER JOIN (multi-table)
- GROUP BY
- Aggregate Functions (SUM)
- ORDER BY

Complexity:
Easy
*/

SELECT
    s.shipper_id,
    s.company_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue
FROM shippers s
JOIN orders o ON o.ship_via = s.shipper_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY s.shipper_id, s.company_name
ORDER BY total_revenue DESC;

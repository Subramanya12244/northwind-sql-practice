/*
Question:
Identify the 10 customers who have generated the highest total discounted revenue across all their orders.

Business Requirement:
The business wants to identify the most valuable customers based on total revenue generated after discounts, to focus retention and account management efforts.

Approach:
1. Join customers, orders, and order_details to connect customer identity to transaction-level data.
2. Calculate revenue using unit_price * quantity * (1 - discount).
3. Aggregate revenue at the customer level using GROUP BY.
4. Sort in descending order of revenue.
5. Return only the top 10 customers using LIMIT.

Expected Output:
| customer_id | company_name | total_revenue |
|-------------|--------------|---------------|
| QUICK | QUICK-Stop | 117483.39 |
| ERNSH | Ernst Handel | 104874.98 |
| SAVEA | Save-a-lot Markets | 104361.95 |

Concepts Used:
- INNER JOIN (multi-table)
- GROUP BY
- Aggregate Functions (SUM)
- ORDER BY
- LIMIT

Complexity:
Easy
*/

SELECT
    cu.customer_id,
    cu.company_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue
FROM customers cu
JOIN orders o ON o.customer_id = cu.customer_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY cu.customer_id, cu.company_name
ORDER BY total_revenue DESC
LIMIT 10;

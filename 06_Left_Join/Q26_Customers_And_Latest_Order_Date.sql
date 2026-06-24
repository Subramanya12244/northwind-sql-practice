/*
Question:
Return every customer along with the date of their most recent order, showing NULL for customers who have never placed an order.

Business Requirement:
The business wants every customer's most recent order date, explicitly including customers who have never ordered, sorted with the most recently active customers first.

Approach:
1. Start from customers and LEFT JOIN to orders on customer_id.
2. Aggregate using MAX(o.order_date), which naturally returns NULL for customers with no matching orders.
3. Group by customer.
4. Sort descending by latest order date, explicitly placing NULL values (never-ordered customers) last.

Expected Output:
| customer_id | company_name | latest_order_date |
|-------------|--------------|-------------------|
| QUICK | QUICK-Stop | 1998-04-30 |
| ERNSH | Ernst Handel | 1998-04-22 |
| FISSA | FISSA Fabrica Inter. Salchichas S.A. | NULL |

Concepts Used:
- LEFT JOIN
- GROUP BY
- Aggregate Functions (MAX)
- NULL Handling
- ORDER BY with NULLS

Complexity:
Medium
*/

SELECT
    cu.customer_id,
    cu.company_name,
    MAX(o.order_date) AS latest_order_date
FROM customers cu
LEFT JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.company_name
ORDER BY latest_order_date DESC NULLS LAST;

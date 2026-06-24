/*
Question:
Return every customer and their total order count, ensuring customers with zero orders still appear in the result with a count of 0, rather than being excluded.

Business Requirement:
The business wants a full list of all customers and their order counts, explicitly including customers who have never placed an order, displayed as 0.

Approach:
1. Start from customers and LEFT JOIN to orders on customer_id, preserving every customer regardless of order history.
2. Aggregate using COUNT(o.order_id) — counting the joined column, not COUNT(*), so unmatched customers correctly show 0.
3. Group by customer.
4. Sort by order count descending.

Expected Output:
| customer_id | company_name | order_count |
|-------------|--------------|-------------|
| SAVEA | Save-a-lot Markets | 31 |
| ERNSH | Ernst Handel | 30 |
| FISSA | FISSA Fabrica Inter. Salchichas S.A. | 0 |

Concepts Used:
- LEFT JOIN
- GROUP BY
- Aggregate Functions (COUNT)
- NULL Handling

Complexity:
Medium
*/

SELECT
    cu.customer_id,
    cu.company_name,
    COUNT(o.order_id) AS order_count
FROM customers cu
LEFT JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.company_name
ORDER BY order_count DESC;

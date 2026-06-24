/*
Question:
Return only the customers who have zero orders on record — no aggregation or counts needed, just the filtered list itself.

Business Requirement:
The business wants a list of customers who have never placed an order, to target with a re-engagement or first-order incentive campaign.

Approach:
1. LEFT JOIN customers to orders on customer_id, preserving every customer regardless of order history.
2. Filter to rows where o.order_id IS NULL, which identifies customers with no matching order at all.
3. (Alternative shown: NOT EXISTS, often more efficient and equally NULL-safe.)

Expected Output:
| customer_id | company_name |
|-------------|--------------|
| FISSA | FISSA Fabrica Inter. Salchichas S.A. |
| PARIS | Paris spécialités |

Concepts Used:
- LEFT JOIN
- NULL Handling
- WHERE
- NOT EXISTS (alternative)

Complexity:
Easy
*/

SELECT
    cu.customer_id,
    cu.company_name
FROM customers cu
LEFT JOIN orders o ON o.customer_id = cu.customer_id
WHERE o.order_id IS NULL;

-- Equivalent, often better-performing alternative using NOT EXISTS:
-- SELECT
--     cu.customer_id,
--     cu.company_name
-- FROM customers cu
-- WHERE NOT EXISTS (
--     SELECT 1 FROM orders o WHERE o.customer_id = cu.customer_id
-- );

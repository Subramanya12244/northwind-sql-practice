/*
Question:
For every category, return the product(s) generating the highest revenue within that category, including all products tied for first place.

Business Requirement:
The business wants to identify the top revenue-generating product within each category, correctly surfacing all products in the event of a tie, to support 'category anchor product' marketing decisions.

Approach:
1. Build a CTE (product_revenue) that aggregates total discounted revenue per product, retaining category_id.
2. Build a second CTE (ranked) that applies RANK() OVER (PARTITION BY category_id ORDER BY total_revenue DESC) to rank products within each category.
3. Filter to rows where rnk = 1, which returns every product tied for the top spot in its category.
4. Sort the final output by category_id.

Expected Output:
| category_id | product_id | product_name | total_revenue |
|-------------|------------|--------------|---------------|
| 1 | 38 | Côte de Blaye | 149984.20 |
| 2 | 63 | Vegie-spread | 21477.80 |
| 4 | 59 | Raclette Courdavault | 76683.75 |

Concepts Used:
- CTE
- Window Functions (RANK)
- PARTITION BY
- GROUP BY
- Aggregate Functions (SUM)
- Tie Handling

Complexity:
Hard
*/

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
    FROM products p
    JOIN order_details od ON od.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category_id
),
ranked AS (
    SELECT
        pr.*,
        RANK() OVER (PARTITION BY category_id ORDER BY total_revenue DESC) AS rnk
    FROM product_revenue pr
)
SELECT
    category_id,
    product_id,
    product_name,
    ROUND(total_revenue::numeric, 2) AS total_revenue
FROM ranked
WHERE rnk = 1
ORDER BY category_id;

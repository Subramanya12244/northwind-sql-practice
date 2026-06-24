/*
Question:
For every category, return the product(s) generating the highest revenue within that category, including all ties.

Business Requirement:
The business wants the top revenue-generating product within each category, displayed with the category's name for direct use in a stakeholder-facing report.

Approach:
1. Build a CTE (product_revenue) aggregating discounted revenue per product, retaining category_id.
2. Build a second CTE (ranked) applying RANK() OVER (PARTITION BY category_id ORDER BY total_revenue DESC).
3. Join the ranked result to categories to bring in category_name.
4. Filter to rnk = 1 to keep every product tied for the top spot in its category.
5. Sort by category_id.

Expected Output:
| category_id | category_name | product_id | product_name | total_revenue |
|-------------|---------------|------------|--------------|---------------|
| 1 | Beverages | 38 | Côte de Blaye | 149984.20 |
| 2 | Condiments | 63 | Vegie-spread | 21477.80 |
| 4 | Dairy Products | 59 | Raclette Courdavault | 76683.75 |

Concepts Used:
- CTE (multiple)
- Window Functions (RANK)
- PARTITION BY
- GROUP BY
- Aggregate Functions (SUM)
- Tie Handling
- INNER JOIN

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
    c.category_id,
    c.category_name,
    r.product_id,
    r.product_name,
    ROUND(r.total_revenue::numeric, 2) AS total_revenue
FROM ranked r
JOIN categories c ON c.category_id = r.category_id
WHERE r.rnk = 1
ORDER BY c.category_id;

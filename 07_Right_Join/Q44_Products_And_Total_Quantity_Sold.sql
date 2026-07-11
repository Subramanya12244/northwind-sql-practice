/*
Question:
Return all products along with the total quantity sold, including
products with no orders displayed as 0.

Business Requirement:
The sales team wants a complete product quantity report — every product
must appear, and those with no order history should show 0 rather than
being excluded.

Approach:
1. Place order_details on the LEFT and products on the RIGHT.
2. RIGHT JOIN preserves every row from products (the right table)
   regardless of whether matching order_details rows exist.
3. SUM(od.quantity) aggregates total units sold per product.
   For products with no orders, SUM returns NULL — COALESCE converts
   this to 0 for display.
4. ROUND(..., 2) is applied here but is technically unnecessary since
   quantity is an integer column with no decimal component.
5. GROUP BY p.product_name, p.product_id — product_id is the unique
   key; product_name is included as a non-aggregated selected column.

Note:
This produces the same result as Q27 (LEFT JOIN version):
   SELECT p.product_name, COALESCE(SUM(od.quantity), 0)
   FROM products p
   LEFT JOIN order_details od ON od.product_id = p.product_id
   GROUP BY p.product_name, p.product_id;
The only difference is join direction — LEFT JOIN A to B = RIGHT JOIN B to A.

Expected Output:
| product_name | total_quantity_sold |
|--------------|---------------------|
| Chai         | 828                 |
| Chang        | 1057                |
| Product X    | 0                   |

Concepts Used:
- RIGHT JOIN
- GROUP BY
- Aggregate Functions (SUM)
- NULL Handling (COALESCE)

Complexity:
Medium
*/

SELECT
    p.product_name,
    COALESCE(
        ROUND(SUM(od.quantity), 2),
        0
    ) AS total_quantity_sold
FROM order_details od
RIGHT JOIN products p
    ON p.product_id = od.product_id
GROUP BY p.product_name, p.product_id;

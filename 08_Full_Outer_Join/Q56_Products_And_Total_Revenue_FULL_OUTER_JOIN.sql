/*
Question:
Return the product name and total revenue for every product and every
order detail record — no product and no order line should be excluded.

Business Requirement:
Generate a complete product revenue report covering all three data states:
1. Products that have been sold (product_name populated, revenue > 0)
2. Products that have never been sold (product_name populated, revenue = 0.00)
3. Orphaned order lines whose product_id references a non-existent product
   (product_name = NULL, revenue > 0 — a data integrity anomaly)

Why FULL OUTER JOIN:
- LEFT JOIN products → order_details:  misses type 3 (orphaned order lines)
- RIGHT JOIN products → order_details: misses type 2 (never-sold products)
- FULL OUTER JOIN: preserves all rows from both tables simultaneously

This is the most complete product revenue report — superseding:
- Q27 (LEFT JOIN version — no orphaned order line row)
- Q44 (RIGHT JOIN version — no never-sold product row)

NULL grouping behaviour:
   All orphaned order lines have p.product_id = NULL after the FULL OUTER JOIN.
   GROUP BY p.product_id groups all NULLs together → exactly ONE NULL row,
   regardless of how many orphaned order lines exist.
   SUM() accumulates revenue across all rows in that NULL group correctly
   since od.unit_price, od.quantity, and od.discount are still populated.

Note on ::numeric cast placement:
   Your SQL: SUM((od.unit_price * od.quantity * (1-od.discount))::numeric)
   → casts each row to numeric before summing (N casts total)

   Alternative: SUM(od.unit_price * od.quantity * (1-od.discount))::numeric
   → casts the SUM result once (1 cast total — slightly more efficient)
   Both produce identical results.

COALESCE:
   Required because SUM() returns NULL (not 0) for never-sold products.
   Without COALESCE, type 2 rows show NULL instead of 0.00.

Expected Output:
| product_name | total_revenue |
|--------------|---------------|
| Chai         | 18452.30      |
| Chang        | 15324.75      |
| Product X    | 0.00          |
| NULL         | 420.00        |

Concepts Used:
- FULL OUTER JOIN
- GROUP BY
- Aggregate Functions (SUM)
- NULL Handling (COALESCE)
- ROUND / CAST
- NULL grouping behaviour in GROUP BY

Complexity:
Hard
*/

select p.product_name,
coalesce(round(sum((od.unit_price * od.quantity * (1-od.discount))::numeric), 2), 0) as total_revenue
from products p
full outer join order_details od on od.product_id = p.product_id
group by p.product_name, p.product_id;

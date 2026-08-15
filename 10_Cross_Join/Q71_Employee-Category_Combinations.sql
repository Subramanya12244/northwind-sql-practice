/*
Question:
Return the employee name and category name for every possible employee–category pairing.

Business Requirement:
Generate every possible combination of employees and product categories.

CROSS JOIN Rules:
- No ON clause — ever.
- Produces N × M rows: 9 employees × 8 categories = **72 rows**
- Table order does not affect the result.
- Trigger phrases: "every X with every Y", "all possible combinations"


-- Attempt 1 — Used CROSS JOIN with ON clause (invalid syntax + wrong logic):
-- Note: Two mistakes in one:
--
-- select concat(e.first_name,' ',e.last_name) as employee_name,
-- c.category_name
-- from categories c
-- cross join products p on p.category_id = c.category_id
-- cross join order_details od on od.product_id = p.product_id
-- cross join orders o on o.order_id = od.order_id
-- cross join employees e on e.employee_id = o.employee_id

Expected Output (first 5 rows):
| employee_name | category_name |
|---------------|---------------|
| Nancy Davolio | Beverages |
| Nancy Davolio | Condiments |
| Nancy Davolio | Confections |
| Janet Leverling | Beverages |
| Janet Leverling | Condiments |

Concepts Used:
- CROSS JOIN
- No ON clause

Score: 5/10
Takeaway: CROSS JOIN never has an ON clause. If you write ON, you're thinking in INNER JOIN terms. For 'every X with every Y', only those two tables are needed — no joins through related tables.

Complexity:
Easy
*/

SELECT
    CONCAT(e.first_name,' ',e.last_name) AS employee_name,
    c.category_name
FROM employees e
CROSS JOIN categories c;

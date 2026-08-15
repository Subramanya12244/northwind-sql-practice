/*
Question:
Return the product name and employee name for every possible product–employee pairing.

Business Requirement:
Generate every possible combination of products and employees.

CROSS JOIN Rules:
- No ON clause — ever.
- Produces N × M rows: 77 products × 9 employees = **693 rows**
- Table order does not affect the result.
- Trigger phrases: "every X with every Y", "all possible combinations"

Expected Output (first 5 rows):
| product_name | employee_name |
|--------------|---------------|
| Chai | Nancy Davolio |
| Chai | Andrew Fuller |
| Chai | Janet Leverling |
| Chang | Nancy Davolio |
| Chang | Andrew Fuller |

Concepts Used:
- CROSS JOIN
- No ON clause
- String Concatenation (CONCAT)

Score: 10/10
Takeaway: CROSS JOIN is symmetric — table order does not affect which rows are returned, only their display order.

Complexity:
Easy
*/

select p.product_name,
concat(e.first_name,' ',e.last_name) as employee_name
from employees e
cross join products p;

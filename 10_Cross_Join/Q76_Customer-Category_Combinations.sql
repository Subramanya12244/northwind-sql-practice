/*
Question:
Return the customer name and category name for every possible customer–category pairing.

Business Requirement:
Generate every possible combination of customers and product categories.

CROSS JOIN Rules:
- No ON clause — ever.
- Produces N × M rows: 91 customers × 8 categories = **728 rows**
- Table order does not affect the result.
- Trigger phrases: "every X with every Y", "all possible combinations"

Expected Output (first 5 rows):
| contact_name | category_name |
|--------------|---------------|
| Maria Anders | Beverages |
| Maria Anders | Condiments |
| Maria Anders | Confections |
| Ana Trujillo | Beverages |
| Ana Trujillo | Condiments |

Concepts Used:
- CROSS JOIN
- No ON clause

Score: 10/10
Takeaway: By Q76, CROSS JOIN patterns are recognised instantly. Two tables, no ON, N × M rows.

Complexity:
Easy
*/

select cu.contact_name, c.category_name
from customers cu
cross join categories c;

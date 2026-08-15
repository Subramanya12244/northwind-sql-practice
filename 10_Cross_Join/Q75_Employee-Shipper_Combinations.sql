/*
Question:
Return the employee name and shipper name for every possible employee–shipper pairing.

Business Requirement:
Generate every possible combination of employees and shippers.

CROSS JOIN Rules:
- No ON clause — ever.
- Produces N × M rows: 9 employees × 3 shippers = **27 rows**
- Table order does not affect the result.
- Trigger phrases: "every X with every Y", "all possible combinations"

Expected Output (first 5 rows):
| employee_name | company_name |
|---------------|--------------|
| Nancy Davolio | Speedy Express |
| Nancy Davolio | United Package |
| Nancy Davolio | Federal Shipping |
| Andrew Fuller | Speedy Express |
| Andrew Fuller | United Package |

Concepts Used:
- CROSS JOIN
- No ON clause

Score: 10/10
Takeaway: Table order in CROSS JOIN does not matter. `FROM employees CROSS JOIN shippers` = `FROM shippers CROSS JOIN employees`.

Complexity:
Easy
*/

select concat(e.first_name,' ',e.last_name) as employee_name,
s.company_name
from employees e
cross join shippers s;

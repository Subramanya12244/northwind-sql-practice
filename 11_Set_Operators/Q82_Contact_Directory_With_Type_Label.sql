/*
Question:
Return a unified contact directory combining customers and employees,
with name, city, and a type label identifying the source of each row.

Business Requirement:
The HR team wants a single contact list showing all customers and
employees together, with a Type column indicating whether each
contact is a 'Customer' or 'Employee'.

Approach:
1. First SELECT: customers — contact_name, city, literal 'Customer' as type.
2. Second SELECT: employees — CONCAT(first_name,' ',last_name) as name,
   city, literal 'Employee' as type.
   CONCAT is required because employees split names across two columns
   while customers have a single contact_name column.
3. UNION combines both result sets with 3 columns each (compatible types).
4. UNION deduplicates — unlikely to matter here but safe by default.

Column mapping (by position, not by name):
   Position 1: contact_name  ↔  CONCAT(first_name,' ',last_name)
   Position 2: city          ↔  city
   Position 3: 'Customer'    ↔  'Employee'
   Output column names come from the first SELECT: name, city, type.

Minor note on submitted SQL:
   'employee' (lowercase) was used instead of 'Employee' (capitalised).
   Both are valid SQL but 'Employee' is consistent with 'Customer' and
   matches the expected output. In production, always match the exact
   string the business requirement specifies — case-sensitive comparisons
   on the type column will fail silently with inconsistent capitalisation.

To sort alphabetically by type then name:
   ... ORDER BY type, name;   (add at the very end of the UNION)

Expected Output:
| name            | city      | type     |
|-----------------|-----------|----------|
| Maria Anders    | Berlin    | Customer |
| Nancy Davolio   | Seattle   | Employee |
| Janet Leverling | Kirkland  | Employee |
| Ana Trujillo    | Mexico    | Customer |

Concepts Used:
- UNION
- Set Operators
- Literal String Columns
- String Concatenation (CONCAT)

Complexity:
Medium
*/

-- Your submitted solution (minor: 'employee' should be 'Employee'):
select c.contact_name, c.city, 'Customer' as type
from customers c
union
select concat(e.first_name,' ',e.last_name) as employee_name, e.city, 'Employee' as type
from employees e;

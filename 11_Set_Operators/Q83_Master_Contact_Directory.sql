/*
Question:
Return a unified Master Contact Directory combining customers, suppliers,
and employees into a single three-column result with name, city, and
entity type label.

Business Requirement:
The Sales department wants one searchable directory covering all business
contacts regardless of whether they are customers, suppliers, or employees.

Approach:
1. SELECT 1 — customers: contact_name, city, literal 'Customer'
2. SELECT 2 — employees: CONCAT(first_name,' ',last_name), city, literal 'Employee'
   CONCAT is required because employees split names across two columns;
   customers and suppliers have a single contact_name column.
3. SELECT 3 — suppliers: contact_name, city, literal 'Supplier'
4. Three-way UNION combines all three result sets and deduplicates.
5. All three SELECTs return exactly 3 columns with compatible types.
6. Output column names (Name, City, Entity_Type) come from the first SELECT.

Column mapping by position:
   col 1: contact_name / CONCAT(first_name,last_name) / contact_name  → Name
   col 2: city                                                          → City
   col 3: 'Customer' / 'Employee' / 'Supplier'                         → Entity_Type

Result size:
   91 customers + 9 employees + 29 suppliers = 129 rows
   (UNION deduplicates — unlikely to matter here but safe by default)

⚠️  Submitted SQL issue — capitalisation inconsistency:
   'employee' (lowercase) was used instead of 'Employee' (title case).
   'Customer' and 'Supplier' use title case consistently.
   Impact: downstream WHERE Entity_Type = 'Employee' returns ZERO rows
   because PostgreSQL string comparison is case-sensitive.
   Fix: change 'employee' to 'Employee'.

ORDER BY (optional — add at the very end of the full UNION):
   ORDER BY Entity_Type, Name;

Custom sort order (employees first, then customers, then suppliers):
   ORDER BY
       CASE Entity_Type WHEN 'Employee' THEN 1 WHEN 'Customer' THEN 2 ELSE 3 END,
       Name;

Expected Output:
| Name          | City    | Entity_Type |
|---------------|---------|-------------|
| Maria Anders  | Berlin  | Customer    |
| Nancy Davolio | Seattle | Employee    |
| Yoshi Nagase  | Osaka   | Supplier    |

Concepts Used:
- UNION (three-way)
- Set Operators
- Literal String Columns
- String Concatenation (CONCAT)

Complexity:
Medium
*/

-- Submitted solution (minor: 'employee' should be 'Employee'):
select c.contact_name as Name,
c.city,
'Customer' as Entity_Type
from customers c
union
select concat(e.first_name,' ',e.last_name) as Name,
e.city,
'employee' as Entity_Type
from employees e
Union
select s.contact_name as Name,
s.city,
'Supplier' as Entity_Type
from suppliers s;

-- Corrected version (consistent capitalisation + ORDER BY):
-- SELECT c.contact_name AS Name, c.city, 'Customer' AS Entity_Type
-- FROM customers c
-- UNION
-- SELECT CONCAT(e.first_name,' ',e.last_name), e.city, 'Employee'
-- FROM employees e
-- UNION
-- SELECT s.contact_name, s.city, 'Supplier'
-- FROM suppliers s
-- ORDER BY Entity_Type, Name;

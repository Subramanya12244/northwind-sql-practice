/*
Question:
Return the supplier name and shipper name for every possible supplier–shipper pairing.

Business Requirement:
Generate every possible combination of suppliers and shippers.

CROSS JOIN Rules:
- No ON clause — ever.
- Produces N × M rows: 29 suppliers × 3 shippers = **87 rows**
- Table order does not affect the result.
- Trigger phrases: "every X with every Y", "all possible combinations"


-- Minor — submitted `s.contact_name` instead of `s.company_name`:
-- Note: CROSS JOIN logic is correct. `contact_name` is the supplier's contact person; `company_name` is the supplier entity itself. 'Supplier Name' refers to the company. Use `s.company_name AS supplier_name` for clarity.
--
-- select s.contact_name, sh.company_name from shippers sh cross join suppliers s

Expected Output (first 5 rows):
| supplier_name | shipper_name |
|---------------|--------------|
| Exotic Liquids | Speedy Express |
| Exotic Liquids | United Package |
| Exotic Liquids | Federal Shipping |
| New Orleans Cajun Delights | Speedy Express |
| New Orleans Cajun Delights | United Package |

Concepts Used:
- CROSS JOIN
- No ON clause

Score: 10/10
Takeaway: 'Supplier Name' = company_name. 'Supplier Contact' = contact_name. Always confirm which attribute the question requires.

Complexity:
Easy
*/

SELECT
    s.company_name AS supplier_name,
    sh.company_name AS shipper_name
FROM suppliers s
CROSS JOIN shippers sh;

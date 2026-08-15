/*
Question:
Return the supplier name and category name for every possible supplier–category pairing.

Business Requirement:
Generate every possible combination of suppliers and product categories.

CROSS JOIN Rules:
- No ON clause — ever.
- Produces N × M rows: 29 suppliers × 8 categories = **232 rows**
- Table order does not affect the result.
- Trigger phrases: "every X with every Y", "all possible combinations"


-- Minor — selected `s.contact_name` instead of `s.company_name`:
-- Note: The CROSS JOIN logic and table selection are correct. `contact_name` is the supplier's contact person, not the company name. When 'Supplier Name' is requested, use `s.company_name`. Score: 9.8/10.
--
-- SELECT s.contact_name, c.category_name FROM categories c CROSS JOIN suppliers s;

Expected Output (first 5 rows):
| supplier_name | category_name |
|---------------|---------------|
| Exotic Liquids | Beverages |
| Exotic Liquids | Condiments |
| Exotic Liquids | Confections |
| New Orleans Cajun Delights | Beverages |
| New Orleans Cajun Delights | Condiments |

Concepts Used:
- CROSS JOIN
- No ON clause

Score: 9.8/10
Takeaway: In Northwind, 'Supplier Name' = `company_name`. 'Supplier Contact' = `contact_name`. When in doubt, the company name is the correct choice for entity identification.

Complexity:
Easy
*/

SELECT
    s.company_name AS supplier_name,
    c.category_name
FROM suppliers s
CROSS JOIN categories c;

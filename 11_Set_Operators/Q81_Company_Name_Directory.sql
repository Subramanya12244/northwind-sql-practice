/*
Question:
Return a single unified list of company names from customers,
suppliers, and shippers combined, with duplicates removed.

Business Requirement:
Create a master company directory merging all business entities
(buyers, sellers, logistics partners) into one deduplicated list.

Approach:
1. SELECT company_name FROM customers — 91 customer company names.
2. UNION SELECT company_name FROM suppliers — 29 supplier names.
3. UNION SELECT company_name FROM shippers — 3 shipper names.
4. UNION deduplicates across the ENTIRE combined result (not pair by pair).
5. All three tables share a column named company_name — no aliasing needed.

Result size:
   Northwind: 91 + 29 + 3 = 123 potential rows.
   UNION removes any duplicates across all three tables.
   In standard Northwind, no names overlap, so 123 rows are returned.
   UNION ALL would also return 123 rows here, but UNION is safer for
   real-world data where company names might repeat across roles.

ORDER BY rule:
   ORDER BY can only appear once, at the very END of the full UNION chain.
   ORDER BY inside an individual SELECT is invalid in a UNION expression.
   Example: ... UNION SELECT company_name FROM shippers ORDER BY company_name;

Extension — show entity type:
   SELECT company_name, 'Customer' AS entity_type FROM customers
   UNION
   SELECT company_name, 'Supplier' FROM suppliers
   UNION
   SELECT company_name, 'Shipper' FROM shippers
   ORDER BY entity_type, company_name;

Expected Output:
| company_name                            |
|-----------------------------------------|
| Alfreds Futterkiste                     |
| Ana Trujillo Emparedados y helados      |
| Exotic Liquids                          |
| Federal Shipping                        |

Concepts Used:
- UNION (three-way)
- Set Operators

Complexity:
Easy
*/

SELECT company_name
FROM customers
UNION
SELECT company_name
FROM suppliers
UNION
SELECT company_name
FROM shippers;

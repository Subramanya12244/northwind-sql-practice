/*
Question:
Return a unified Master Company Directory combining company names,
countries, and entity type labels from customers, suppliers, and shippers.

Business Requirement:
The management team wants one searchable company directory covering
all business entities — buyers, sellers, and logistics partners.

Schema check (critical — verify before writing):
   customers: company_name ✅  country ✅
   suppliers: company_name ✅  country ✅
   shippers:  company_name ✅  country ❌ (column does not exist)

Approach:
1. SELECT 1 — customers: company_name, country, 'Customer'
2. SELECT 2 — suppliers: company_name, country, 'Supplier'
3. SELECT 3 — shippers: company_name, 'N/A' as country placeholder, 'Shipper'
   Shippers have no country column — substitute 'N/A' to maintain
   structural compatibility (same column count and compatible types).
4. Three-way UNION combines all three and deduplicates.

'N/A' vs NULL for missing country:
   NULL is semantically precise (unknown) but may be excluded by
   downstream WHERE country IS NOT NULL filters.
   'N/A' is explicit — clearly signals unavailable data in reports.
   Choose based on business convention.

Result size:
   91 customers + 29 suppliers + 3 shippers = 123 rows

Expected Output:
| Company_Name                       | Country | Entity_Type |
|------------------------------------|---------|-------------|
| Alfreds Futterkiste                | Germany | Customer    |
| Exotic Liquids                     | UK      | Supplier    |
| Speedy Express                     | N/A     | Shipper     |

Concepts Used:
- UNION (three-way)
- Set Operators
- Literal String Columns
- Schema Awareness (placeholder for missing column)

Complexity:
Medium
*/

select c.company_name as Name,
c.country,
'Customer' as Entity_Type
from customers c
Union
select s.company_name as Name,
s.country,
'Supplier' as Entity_Type
from suppliers s
union
select sh.company_name as Name,
'N/A' as country,
'Shipper' as Entity_Type
from shippers sh;

/*
Question:
Return the customer name and supplier name for every possible customer–supplier pairing.

Business Requirement:
Generate every possible combination of customers and suppliers.

CROSS JOIN Rules:
- No ON clause — ever.
- Produces N × M rows: 91 customers × 29 suppliers = **2,639 rows**
- Table order does not affect the result.
- Trigger phrases: "every X with every Y", "all possible combinations"

Expected Output (first 5 rows):
| customer_name | supplier_name |
|---------------|---------------|
| Maria Anders | Exotic Liquids |
| Maria Anders | New Orleans Cajun Delights |
| Ana Trujillo | Exotic Liquids |
| Ana Trujillo | New Orleans Cajun Delights |

Concepts Used:
- CROSS JOIN
- No ON clause

Score: 10/10
Takeaway: CROSS JOIN works between any two tables regardless of whether they share a foreign key relationship.

Complexity:
Easy
*/

SELECT
    cu.contact_name AS customer_name,
    s.company_name AS supplier_name
FROM customers cu
CROSS JOIN suppliers s;

/*
Question:
Return the product name and shipper name for every possible product–shipper pairing.

Business Requirement:
Generate every possible combination of products and shippers.

CROSS JOIN Rules:
- No ON clause — ever.
- Produces N × M rows: 77 products × 3 shippers = **231 rows**
- Table order does not affect the result.
- Trigger phrases: "every X with every Y", "all possible combinations"

Expected Output (first 5 rows):
| product_name | company_name |
|--------------|--------------|
| Chai | Speedy Express |
| Chai | United Package |
| Chai | Federal Shipping |
| Chang | Speedy Express |
| Chang | United Package |

Concepts Used:
- CROSS JOIN
- No ON clause

Score: 10/10
Takeaway: CROSS JOIN: no ON clause, only the two required tables. Table order does not affect the result.

Complexity:
Easy
*/

SELECT
    p.product_name,
    sh.company_name
FROM products p
CROSS JOIN shippers sh;

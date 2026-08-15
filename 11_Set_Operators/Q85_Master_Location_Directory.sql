/*
Question:
Return every unique city-country combination across customers, suppliers,
and employees — each location appearing only once.

Business Requirement:
The Data Analytics team wants a master location reference showing every
city where the company has any business contact, deduplicated so each
location appears exactly once regardless of how many entities are there.

Approach:
1. SELECT city, country FROM customers
2. UNION SELECT city, country FROM suppliers
3. UNION SELECT city, country FROM employees
4. UNION (not UNION ALL) deduplicates the entire combined result.
   Deduplication is row-level — both city AND country must match
   for a row to be considered a duplicate.

Why UNION (not UNION ALL):
   Requirement: "only unique city-country combinations"
   UNION ALL: keeps every row — London could appear 20 times if
   15 customers, 3 suppliers, 2 employees are all based there.
   UNION: deduplicates — London appears exactly once. ✅

Why both city AND country (not just city):
   City names are not globally unique.
   ('London', 'UK') and ('London', 'Canada') are different locations.
   Selecting city alone would incorrectly merge them.

Why no Entity_Type column:
   Adding Entity_Type would break deduplication —
   ('London', 'UK', 'Customer') and ('London', 'UK', 'Supplier')
   would be kept as two separate rows even though they are the same
   location. Omitting Entity_Type preserves correct location-level dedup.

Schema check:
   customers: city ✅  country ✅
   suppliers: city ✅  country ✅
   employees: city ✅  country ✅
   No placeholder substitution needed — clean symmetric UNION.

Extension — count entities per location (use UNION ALL for counting):
   WITH all_locations AS (
       SELECT city, country FROM customers
       UNION ALL SELECT city, country FROM suppliers
       UNION ALL SELECT city, country FROM employees
   )
   SELECT city, country, COUNT(*) AS entity_count
   FROM all_locations
   GROUP BY city, country
   ORDER BY entity_count DESC;

Expected Output:
| city    | country |
|---------|---------|
| Berlin  | Germany |
| London  | UK      |
| Seattle | USA     |
| Osaka   | Japan   |

Concepts Used:
- UNION (three-way)
- Set Operators
- Deduplication across multiple sources

Complexity:
Medium
*/

SELECT c.city,
       c.country
FROM customers c
UNION
SELECT s.city,
       s.country
FROM suppliers s
UNION
SELECT e.city,
       e.country
FROM employees e;

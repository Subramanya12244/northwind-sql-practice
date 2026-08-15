# Q85. Master Location Directory

**Category:** Set Operators (UNION — deduplication across multiple sources)
**Difficulty:** Medium

---

## Problem Statement

The Data Analytics team wants to know every unique location where the company has customers, suppliers, or employees, so they can build a master location reference.

## Objective

Return every unique `city` and `country` combination across customers, suppliers, and employees — with duplicates removed so each location appears only once regardless of how many entities are in that city.

## Tables Used

- `customers`
- `suppliers`
- `employees`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| city | Name of the city |
| country | Name of the country |

**Sample output:**

| city | country |
|------|---------|
| Berlin | Germany |
| London | UK |
| Seattle | USA |
| Osaka | Japan |
| Paris | France |

*(Only unique city-country combinations — if 5 customers are in London, UK, London appears only once.)*

## Concepts Used

- UNION (three-way)
- Set Operators
- Deduplication across multiple sources

## Why This Approach

**Why UNION (not UNION ALL) is critical here:** this query's requirement explicitly states "only unique city-country combinations." `UNION ALL` would include every city-country pair from every row of every table — London might appear 20 times if 15 customers, 3 suppliers, and 2 employees are all based there. `UNION` deduplicates across the entire combined result, ensuring each city-country pair appears exactly once regardless of how many entities are located there.

**Why two columns instead of one:** previous UNION questions (Q79–Q81) combined single-column values. This query combines two-column pairs — `(city, country)`. UNION's deduplication works on the **entire row** — a row is considered a duplicate only if all columns match. So `('London', 'UK')` and `('London', 'Canada')` are treated as two distinct location rows, not duplicates.

**Why no `Entity_Type` column is needed:** the requirement asks for unique locations, not a typed directory. Adding `Entity_Type` would break the deduplication — `('London', 'UK', 'Customer')` and `('London', 'UK', 'Supplier')` would be considered different rows even though they represent the same location. The type label is omitted precisely because it would interfere with the "unique locations" requirement.

**Why all three tables have `city` and `country`:** unlike Q84 where `shippers` was missing `country`, here `customers`, `suppliers`, and `employees` all have both `city` and `country` columns. No placeholder substitution is needed — a clean, symmetric UNION is possible.

## Common Mistakes

- Using `UNION ALL` instead of `UNION` — returns duplicate city-country pairs whenever multiple entities share the same location, directly violating the "unique combinations" requirement.
- Adding an `Entity_Type` column — breaks deduplication, as the same city appears once per entity type rather than once overall.
- Selecting only `city` without `country` — cities with the same name in different countries (e.g. London UK vs London Canada) would be incorrectly merged into one row.
- Forgetting that `employees` also has `city` and `country` — a schema check confirms all three tables share these columns, so no special handling is needed.

## Difficulty

**Medium**

## Interview Follow-up Questions

**1. Why is UNION (not UNION ALL) the correct choice for this specific requirement?**

The requirement says "only unique city-country combinations." `UNION ALL` stacks every row from all three tables including duplicates — if London appears in 10 customer rows, 3 supplier rows, and 2 employee rows, it would appear 15 times in a `UNION ALL` result. `UNION` deduplicates across the entire combined result, so London appears exactly once. The deduplication is applied to the full row — both `city` and `country` must match for a row to be considered a duplicate.

**2. Why must both `city` and `country` be selected — why not just `city` alone?**

City names are not globally unique. "London" exists in the UK, Canada, and the USA. Selecting only `city` would merge all London locations into one row, incorrectly implying they are the same place. Including `country` makes the location specific — `('London', 'UK')` and `('London', 'Canada')` are correctly preserved as two distinct locations.

**3. How would you extend this to also count how many entities (customers + suppliers + employees) are in each location?**

Use `UNION ALL` (to preserve all rows for counting), wrap it as a CTE, then aggregate:
```sql
WITH all_locations AS (
    SELECT city, country FROM customers
    UNION ALL
    SELECT city, country FROM suppliers
    UNION ALL
    SELECT city, country FROM employees
)
SELECT city, country, COUNT(*) AS entity_count
FROM all_locations
GROUP BY city, country
ORDER BY entity_count DESC;
```
Note: this uses `UNION ALL` (not `UNION`) because we want to count every entity — deduplicating before counting would undercount cities with multiple entities.

**4. How does UNION's deduplication work on multi-column rows?**

UNION considers a row a duplicate if and only if all columns in the row are identical. For two-column rows: `('London', 'UK')` and `('London', 'UK')` are duplicates — one is kept. `('London', 'UK')` and `('London', 'Canada')` are not duplicates — both are kept. `('London', 'UK')` and `('Berlin', 'UK')` are not duplicates — both are kept. The deduplication is column-count aware and applies to the complete row tuple.

**5. What is the difference between using UNION for deduplication here versus using SELECT DISTINCT on a joined result?**

Both achieve the same result. The UNION approach:
```sql
SELECT city, country FROM customers
UNION SELECT city, country FROM suppliers
UNION SELECT city, country FROM employees;
```
The DISTINCT approach:
```sql
SELECT DISTINCT city, country FROM (
    SELECT city, country FROM customers
    UNION ALL SELECT city, country FROM suppliers
    UNION ALL SELECT city, country FROM employees
) sub;
```
Both deduplicate the combined city-country pairs. The UNION approach is more concise and is the idiomatic SQL choice. The DISTINCT-on-subquery approach makes the deduplication explicit as a separate step, which can be clearer for readers unfamiliar with UNION's implicit deduplication.

## Learning Outcomes

- Understand that UNION's deduplication applies to the **complete row** — all selected columns must match for a row to be treated as a duplicate.
- Know when NOT to add a type column — adding `Entity_Type` to a "unique locations" query would break the deduplication by creating intentionally different rows.
- Confirm that `UNION` (deduplicate) vs `UNION ALL` (keep all rows) is a business requirement decision, not a stylistic one — the wrong choice produces factually incorrect results.

---

📄 **SQL File:** [`Q85_Master_Location_Directory.sql`](./Q85_Master_Location_Directory.sql)

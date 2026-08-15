# Q81. Company Name Directory

**Category:** Set Operators (UNION — three-way)
**Difficulty:** Easy

---

## Problem Statement

Create a single list containing the company names of all customers, all suppliers, and all shippers in one unified column.

## Objective

Return a single column containing every company name from all three tables, with duplicates removed.

## Tables Used

- `customers`
- `suppliers`
- `shippers`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| company_name | Company name from customers, suppliers, or shippers |

**Sample output:**

| company_name |
|--------------|
| Alfreds Futterkiste |
| Ana Trujillo Emparedados y helados |
| Exotic Liquids |
| Federal Shipping |
| Speedy Express |

*(In Northwind, company names across these three tables are distinct — UNION and UNION ALL would produce the same row count. The deduplication step of UNION is a safety net for real-world data.)*

## Concepts Used

- UNION (three-way)
- Set Operators

## Why This Approach

**Why three SELECT statements chained with UNION:** UNION is not limited to two queries. Any number of SELECT statements can be chained: `SELECT ... UNION SELECT ... UNION SELECT ...`. The deduplication applies across the entire combined result — not just between adjacent pairs. A name appearing in all three tables would still appear only once.

**Why the column name `company_name` is used across all three tables:** all three tables (`customers`, `suppliers`, `shippers`) happen to share a column named `company_name`. This makes the query clean — no aliasing is needed. The output column is labelled `company_name` (from the first SELECT).

**Why this is cleaner than a multi-table JOIN:** these three tables have no meaningful shared key that would make a JOIN useful for this requirement. A JOIN would either require an artificial key or produce a Cartesian product — neither makes sense here. UNION is the only correct tool.

**Real-world use case:** this type of query is commonly used to build a master entity list — e.g. a single table of all business entities in a system, regardless of their role (buyer, seller, logistics partner). The result can then be used as a lookup reference or joined to a unified communication log.

## Common Mistakes

- Adding `ORDER BY` inside one of the individual SELECT statements — invalid in a UNION chain. `ORDER BY` can only appear once, at the very end of the entire UNION expression.
- Assuming UNION deduplicates across only adjacent pairs — it deduplicates across the entire combined result. If "Speedy Express" appeared in both `suppliers` and `shippers`, it would appear only once.
- Using `UNION ALL` when the requirement is a deduplicated directory — produces duplicate entries for any company name that spans multiple tables.

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. How does UNION handle deduplication across three tables — does it work pair by pair or across all three at once?**

UNION deduplicates across the entire combined result set — not pair by pair. The SQL engine combines all three result sets and then removes any rows that are identical. A name appearing in all three tables appears exactly once in the final output. Conceptually it's equivalent to `(A UNION B) UNION C`, but the deduplication is applied globally across the final combined result.

**2. What is the result size in Northwind, and would UNION ALL give a different answer?**

Northwind has 91 customers + 29 suppliers + 3 shippers = 123 potential rows. `UNION ALL` always produces exactly 123 rows. `UNION` deduplicates — in standard Northwind, no company name appears across multiple tables, so `UNION` also produces 123 rows. In real-world data where company names could repeat across roles, `UNION` would produce fewer rows.

**3. How would you modify this to also show which table each company came from?**

Add a literal type column to each SELECT:
```sql
SELECT company_name, 'Customer' AS entity_type FROM customers
UNION
SELECT company_name, 'Supplier' AS entity_type FROM suppliers
UNION
SELECT company_name, 'Shipper' AS entity_type FROM shippers
ORDER BY entity_type, company_name;
```
Note: if a company name appears in two tables (both customer and supplier), UNION keeps only one row — the one from whichever SELECT comes first. `UNION ALL` would keep both with their respective types.

**4. Can you use ORDER BY inside one of the individual SELECT statements in a UNION chain?**

No — `ORDER BY` inside an individual SELECT in a UNION chain is invalid in most databases including PostgreSQL. `ORDER BY` can only appear once, at the very end of the entire UNION expression, and it applies to the complete combined result. Each individual SELECT in the chain is treated as an unordered set.

**5. How would INTERSECT and EXCEPT work on these three tables?**

`INTERSECT` returns only rows that appear in ALL the combined results — company names present in all three tables simultaneously. In Northwind that would return nothing (no company is simultaneously a customer, supplier, and shipper). `EXCEPT` returns rows from the first query that do not appear in the second — e.g. `SELECT company_name FROM customers EXCEPT SELECT company_name FROM suppliers` returns customer company names that are not also supplier names. These are the other two set operators alongside UNION.

## Learning Outcomes

- Confirm that UNION chains work with any number of SELECT statements and deduplicates across the entire result, not just adjacent pairs.
- Understand the real-world use case for multi-table UNION: building master entity lists from independent source tables.
- Know the `ORDER BY` rule: only one instance, always at the end of the full UNION expression.

---

📄 **SQL File:** [`Q81_Company_Name_Directory.sql`](./Q81_Company_Name_Directory.sql)

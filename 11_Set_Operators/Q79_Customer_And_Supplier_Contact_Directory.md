# Q79. Customer and Supplier Contact Directory

**Category:** Set Operators (UNION)
**Difficulty:** Easy

---

## Problem Statement

Create a single contact list combining the contact names of all customers and all suppliers.

## Objective

Return a single column containing every customer contact name and every supplier contact name as one unified list, with duplicates removed.

## Tables Used

- `customers`
- `suppliers`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| contact_name | Contact name from either the customers or suppliers table |

**Sample output:**

| contact_name |
|--------------|
| Maria Anders |
| Ana Trujillo |
| Antonio Moreno |
| Charlotte Cooper |
| Shelley Burke |

*(Sample values are illustrative. In standard Northwind, customers and suppliers are completely separate entities with no overlapping contact names — but UNION deduplicates regardless.)*

## Concepts Used

- UNION
- Set Operators

## Why This Approach

**What UNION does:** `UNION` combines the result sets of two or more `SELECT` statements into a single result set. It automatically removes duplicate rows — if the same contact name appears in both `customers` and `suppliers`, it appears only once in the output.

**Why UNION and not UNION ALL:** `UNION ALL` includes every row from both queries, including duplicates. `UNION` deduplicates. For a contact directory, showing the same name twice would be confusing — `UNION` is the correct default. Use `UNION ALL` only when you explicitly need duplicates or when you know there are none and want to avoid the deduplication overhead.

**The two rules of UNION:**
1. Both SELECT statements must return the **same number of columns**
2. Corresponding columns must have **compatible data types**

Here both queries return exactly one column (`contact_name` / `contact_name`) of the same type (`varchar`), so UNION works cleanly.

**Why no JOIN is needed:** `customers` and `suppliers` have no shared key. They are completely independent tables whose contact names we want combined into one list. UNION is the correct tool for combining rows from independent sources — JOIN is for combining columns from related rows.

**UNION vs JOIN — the fundamental distinction:**
- `JOIN` — combines **columns** from rows that share a key relationship
- `UNION` — combines **rows** from queries that share the same column structure

## Common Mistakes

- Using `JOIN` instead of `UNION` — `customers` and `suppliers` share no foreign key, making a meaningful JOIN impossible for this requirement.
- Using `UNION ALL` when duplicates should be removed — produces double entries for names that appear in both tables.
- Selecting different numbers of columns in each part of the UNION — causes a column count mismatch error.
- Selecting columns in a different order — UNION maps by position, not by name. `SELECT first_name, last_name UNION SELECT last_name, first_name` would silently swap the columns.

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. What is the difference between UNION and UNION ALL?**

`UNION` combines both result sets and removes duplicate rows — the database must sort or hash the combined result to identify and eliminate duplicates. `UNION ALL` combines both result sets and keeps every row including duplicates — no deduplication step, so it is always faster. Use `UNION` when duplicates are possible and unwanted. Use `UNION ALL` when you know there are no duplicates (faster) or when you explicitly want all rows including duplicates. In this query, `UNION` is correct because a name appearing in both tables should only appear once in the contact directory.

**2. What are the two rules that both SELECT statements in a UNION must satisfy?**

First, both SELECT statements must return the same number of columns. Second, corresponding columns (by position) must have compatible data types — you cannot UNION a `varchar` column with an `integer` column. Column names in the output are taken from the first SELECT statement; the second SELECT's column names are ignored. So `SELECT contact_name FROM customers UNION SELECT contact_name FROM suppliers` produces a column labelled `contact_name` regardless of what the second SELECT calls its column.

**3. How is UNION different from JOIN? When would you use each?**

`JOIN` combines **columns** from two tables based on a shared key — it produces wider rows. `UNION` combines **rows** from two queries that have the same column structure — it produces a longer list. Use `JOIN` when you want to combine attributes of related records (e.g. order + customer details). Use `UNION` when you want to stack independent result sets of the same shape into one list (e.g. all contacts from multiple source tables). A useful mental model: JOIN makes the result wider; UNION makes it taller.

**4. How would you modify this to also show the source of each name (customer vs supplier)?**

Add a literal string column to each part of the UNION:
```sql
SELECT contact_name, 'Customer' AS source FROM customers
UNION
SELECT contact_name, 'Supplier' AS source FROM suppliers
ORDER BY source, contact_name;
```
This produces two columns — the name and its origin — and is the foundation of Q82's approach.

**5. How would you sort the combined list alphabetically?**

Add `ORDER BY` after the final SELECT statement — it applies to the entire UNION result:
```sql
SELECT contact_name FROM customers
UNION
SELECT contact_name FROM suppliers
ORDER BY contact_name;
```
`ORDER BY` can only appear once, at the very end of the full UNION expression. Placing it inside one of the individual SELECT statements is invalid syntax.

## Learning Outcomes

- Understand that `UNION` is for stacking rows from independent result sets — fundamentally different from `JOIN` which combines columns from related rows.
- Know the two rules: same column count, compatible column types.
- Know when to use `UNION` (deduplicate) vs `UNION ALL` (keep all rows, faster).
- Understand that column names in the output come from the first SELECT statement.

---

📄 **SQL File:** [`Q79_Customer_And_Supplier_Contact_Directory.sql`](./Q79_Customer_And_Supplier_Contact_Directory.sql)

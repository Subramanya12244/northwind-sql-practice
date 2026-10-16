# Q83. Master Contact Directory

**Category:** Set Operators (UNION — three-way with type label)
**Difficulty:** Medium

---

## Problem Statement

The Sales department wants a single Master Contact Directory combining contacts from customers, suppliers, and employees so they can search for any business contact from one place.

## Objective

Return a unified three-column result containing the contact name, city, and entity type for every customer, supplier, and employee — labelled so the reader knows which source each contact came from.

## Tables Used

- `customers`
- `suppliers`
- `employees`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| Name | Contact person's name (from `contact_name` for customers and suppliers; `CONCAT(first_name, ' ', last_name)` for employees) |
| City | City of the contact |
| Entity_Type | `'Customer'`, `'Supplier'`, or `'Employee'` — literal label identifying the source |

**Sample output:**

| Name | City | Entity_Type |
|------|------|-------------|
| Maria Anders | Berlin | Customer |
| Nancy Davolio | Seattle | Employee |
| Yoshi Nagase | Osaka | Supplier |
| Ana Trujillo | México D.F. | Customer |
| Andrew Fuller | Tacoma | Employee |

*(Order depends on storage order unless `ORDER BY` is specified. Total rows: 91 customers + 9 employees + 29 suppliers = 129 rows — assuming no duplicate name+city+type combinations.)*

## Concepts Used

- UNION (three-way)
- Set Operators
- Literal String Columns
- String Concatenation (CONCAT)

## Why This Approach

**Why three-way UNION:** the contacts come from three completely independent tables with no shared foreign key that would make a JOIN useful. UNION is the correct tool for stacking independent result sets of the same shape into one list. Each SELECT contributes one table's worth of rows; UNION combines all three into a single result.

**Why each SELECT has the same three-column structure:** UNION maps columns by position — column 1 of SELECT 1 maps to column 1 of SELECT 2, and so on. All three SELECTs must return exactly three columns in the same order (`Name`, `City`, `Entity_Type`) with compatible types. The output column labels (`Name`, `City`, `Entity_Type`) come from the first SELECT statement.

**Why `CONCAT` is only needed for employees:** `customers.contact_name` and `suppliers.contact_name` are already single-column full names. `employees` splits names into `first_name` and `last_name` — two separate columns. `CONCAT(e.first_name, ' ', e.last_name)` combines them into the same single-name format, so all three SELECTs produce one name column.

**Why literal string columns (`'Customer'`, `'Supplier'`, `'Employee'`):** without a type label, the combined list is anonymous — there's no way to tell from the output whether a contact is a customer or a supplier. The literal column tags every row at the time of the UNION, making the directory self-describing. This is the standard pattern for typed UNION directories.

**⚠️ Minor issue — capitalisation inconsistency:** your SQL uses `'employee'` (lowercase) for employees while using `'Customer'` and `'Supplier'` (capitalised) for the other two. In the combined output this produces:
- Customer rows: `Entity_Type = 'Customer'` ✅
- Supplier rows: `Entity_Type = 'Supplier'` ✅
- Employee rows: `Entity_Type = 'employee'` ⚠️

This is inconsistent visually, and any downstream query filtering with `WHERE Entity_Type = 'Employee'` (capitalised) would return **zero rows** for employees — a silent bug. Always match capitalisation consistently across all UNION branches.

**Corrected version:**
```sql
SELECT c.contact_name AS Name, c.city, 'Customer' AS Entity_Type FROM customers c
UNION
SELECT CONCAT(e.first_name,' ',e.last_name), e.city, 'Employee' FROM employees e
UNION
SELECT s.contact_name, s.city, 'Supplier' FROM suppliers s
ORDER BY Entity_Type, Name;
```

## Common Mistakes

- **Inconsistent literal capitalisation** — `'employee'` vs `'Employee'` — causes silent filtering bugs in downstream queries.
- **Selecting different column counts** across the three SELECTs — e.g. adding `phone` to one SELECT but not the others — causes a column count mismatch error.
- **Wrong column order in one SELECT** — UNION maps by position. If one SELECT puts `city` before `name`, that city value silently ends up in the `Name` column with no error.
- **Placing `ORDER BY` inside an individual SELECT** — invalid in a UNION chain. `ORDER BY` can only appear once at the very end.
- **Using `UNION ALL` when deduplication is intended** — if a person happens to be both a customer contact and a supplier contact with the same name and city, `UNION` would deduplicate them; `UNION ALL` would show them twice.

## Difficulty

**Medium**

## Interview Follow-up Questions

**1. What is the capitalisation issue in this query and why does it matter beyond aesthetics?**

The submitted query uses `'employee'` (all lowercase) for the employee rows while using `'Customer'` and `'Supplier'` (title case) for the other two. In PostgreSQL, string comparisons are case-sensitive by default. Any downstream query filtering on `WHERE Entity_Type = 'Employee'` would return zero rows because the stored value is `'employee'`, not `'Employee'`. A report grouping by `Entity_Type` would show three groups — `Customer`, `Supplier`, and `employee` — rather than two neatly formatted groups. Always use consistent capitalisation across all branches of a UNION. Fix: change `'employee'` to `'Employee'`.

**2. Why is `CONCAT` only needed for the employees SELECT and not for customers or suppliers?**

Both `customers` and `suppliers` have a single `contact_name` column that already contains the full contact name. `employees` stores names across two separate columns — `first_name` and `last_name`. UNION requires every SELECT to produce the same number of columns. Since the requirement is one name column, the two employee name columns must be combined into one with `CONCAT(first_name, ' ', last_name)` to match the structure of the other two SELECTs.

**3. How do column names work in a multi-way UNION result?**

The output column names always come from the **first** SELECT statement in the UNION chain. The second and third SELECT's column aliases are completely ignored — only the column types and positions matter for those. In this query, `Name`, `City`, and `Entity_Type` are the output column names because they are defined in the first SELECT (customers). The `as Name` alias on the employees SELECT is technically redundant but makes the intent clear to readers.

**4. How would you sort this directory so employees appear first, then customers, then suppliers — each group alphabetically by name?**

Add `ORDER BY` at the very end of the full UNION expression:
```sql
SELECT c.contact_name AS Name, c.city, 'Customer' AS Entity_Type FROM customers c
UNION
SELECT CONCAT(e.first_name,' ',e.last_name), e.city, 'Employee' FROM employees e
UNION
SELECT s.contact_name, s.city, 'Supplier' FROM suppliers s
ORDER BY
    CASE Entity_Type WHEN 'Employee' THEN 1 WHEN 'Customer' THEN 2 ELSE 3 END,
    Name;
```
The `CASE` expression in `ORDER BY` assigns a sort priority to each entity type, followed by alphabetical sort within each group.

**5. How would you count the total contacts per city across all three entity types in this directory?**

Wrap the UNION as a subquery or CTE and aggregate by city:
```sql
WITH directory AS (
    SELECT c.contact_name AS Name, c.city, 'Customer' AS Entity_Type FROM customers c
    UNION
    SELECT CONCAT(e.first_name,' ',e.last_name), e.city, 'Employee' FROM employees e
    UNION
    SELECT s.contact_name, s.city, 'Supplier' FROM suppliers s
)
SELECT city,
       COUNT(*) AS total_contacts,
       COUNT(CASE WHEN Entity_Type = 'Customer' THEN 1 END) AS customers,
       COUNT(CASE WHEN Entity_Type = 'Employee' THEN 1 END) AS employees,
       COUNT(CASE WHEN Entity_Type = 'Supplier' THEN 1 END) AS suppliers
FROM directory
GROUP BY city
ORDER BY total_contacts DESC;
```

## Learning Outcomes

- Master the three-way UNION pattern with type labels — a directly transferable template for any "master entity directory" requirement combining multiple independent source tables.
- Understand why literal string capitalisation consistency matters for downstream query correctness — not just visual appearance.
- Confirm the UNION column name rule: output labels always come from the first SELECT; subsequent SELECTs only need structural (type and count) compatibility.
- Know when `CONCAT` is required in a UNION context — whenever one source table splits what should be a single display column across multiple physical columns.

---

📄 **SQL File:** [`Q83_Master_Contact_Directory.sql`](./Q83_Master_Contact_Directory.sql)

# Q83 · Master Contact Directory

> **Revision Card**
> **Category:** Set Operators (UNION — three-way with type label) | **Difficulty:** Medium
> **Concepts:** UNION (three-way) · Set Operators · Literal String Columns · String Concatenation (CONCAT)
> **Outcome:** ⚠️ had mistakes (see §4)
> **Watch out for:** keep literal labels case-consistent across all branches — `'employee'` vs `'Employee'` is a silent downstream filtering bug.

## 1. Problem

The Sales department wants a single Master Contact Directory combining contacts from customers, suppliers, and employees so they can search for any business contact from one place.

**Objective:** Return a unified three-column result containing the contact name, city, and entity type for every customer, supplier, and employee — labelled so the reader knows which source each contact came from.

**Tables:** `customers`, `suppliers`, `employees`

**Expected output:**

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

## 2. My Approach

1. SELECT 1 — customers: `contact_name`, `city`, literal `'Customer'`.
2. SELECT 2 — employees: `CONCAT(first_name,' ',last_name)`, `city`, literal `'Employee'`. CONCAT is required because employees split names across two columns; customers and suppliers have a single `contact_name` column.
3. SELECT 3 — suppliers: `contact_name`, `city`, literal `'Supplier'`.
4. Three-way `UNION` combines all three result sets and deduplicates.
5. All three SELECTs return exactly 3 columns with compatible types.
6. Output column names (`Name`, `City`, `Entity_Type`) come from the first SELECT.

## 3. My Solution (as submitted)

```sql
select c.contact_name as Name,
c.city,
'Customer' as Entity_Type
from customers c
union
select concat(e.first_name,' ',e.last_name) as Name,
e.city,
'employee' as Entity_Type
from employees e
Union
select s.contact_name as Name,
s.city,
'Supplier' as Entity_Type
from suppliers s;
```

## 4. Mistakes I Made

- ⚠️ **Capitalisation inconsistency in the type literal** — I used `'employee'` (lowercase) for employees while using `'Customer'` and `'Supplier'` (title case) for the other two branches. **Why it's wrong:** the combined output then shows `Entity_Type = 'employee'` for employee rows, and because PostgreSQL string comparison is case-sensitive, any downstream `WHERE Entity_Type = 'Employee'` returns **zero rows** for employees — a silent bug — while a `GROUP BY Entity_Type` report shows three groups (`Customer`, `Supplier`, `employee`) instead of three clean title-case groups. **The fix:** change `'employee'` to `'Employee'` so all three branches match.

## 5. Correct / Optimal Solution

```sql
SELECT c.contact_name AS Name, c.city, 'Customer' AS Entity_Type FROM customers c
UNION
SELECT CONCAT(e.first_name,' ',e.last_name), e.city, 'Employee' FROM employees e
UNION
SELECT s.contact_name, s.city, 'Supplier' FROM suppliers s
ORDER BY Entity_Type, Name;
```

## 6. Why This Works

**Why three-way UNION:** the contacts come from three completely independent tables with no shared foreign key that would make a JOIN useful. UNION is the correct tool for stacking independent result sets of the same shape into one list. Each SELECT contributes one table's worth of rows; UNION combines all three into a single result.

**Why each SELECT has the same three-column structure:** UNION maps columns by position — column 1 of SELECT 1 maps to column 1 of SELECT 2, and so on. All three SELECTs must return exactly three columns in the same order (`Name`, `City`, `Entity_Type`) with compatible types. The output column labels (`Name`, `City`, `Entity_Type`) come from the first SELECT statement.

**Why `CONCAT` is only needed for employees:** `customers.contact_name` and `suppliers.contact_name` are already single-column full names. `employees` splits names into `first_name` and `last_name` — two separate columns. `CONCAT(e.first_name, ' ', e.last_name)` combines them into the same single-name format, so all three SELECTs produce one name column.

**Why literal string columns (`'Customer'`, `'Supplier'`, `'Employee'`):** without a type label, the combined list is anonymous — there's no way to tell from the output whether a contact is a customer or a supplier. The literal column tags every row at the time of the UNION, making the directory self-describing. This is the standard pattern for typed UNION directories.

**Why capitalisation consistency is a correctness issue, not cosmetics:** the type label is a filter/group key. A single lowercase `'employee'` produces zero rows under `WHERE Entity_Type = 'Employee'` and splits grouped reports. Always match capitalisation across all UNION branches.

## 7. Common Pitfalls (generic)

- **Inconsistent literal capitalisation** — `'employee'` vs `'Employee'` — causes silent filtering bugs in downstream queries.
- **Selecting different column counts** across the three SELECTs — e.g. adding `phone` to one SELECT but not the others — causes a column count mismatch error.
- **Wrong column order in one SELECT** — UNION maps by position. If one SELECT puts `city` before `name`, that city value silently ends up in the `Name` column with no error.
- **Placing `ORDER BY` inside an individual SELECT** — invalid in a UNION chain. `ORDER BY` can only appear once at the very end.
- **Using `UNION ALL` when deduplication is intended** — if a person happens to be both a customer contact and a supplier contact with the same name and city, `UNION` would deduplicate them; `UNION ALL` would show them twice.

## 8. Interview Follow-ups

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

## 9. Key Takeaway

The three-way typed UNION is the master-directory template — but literal labels must share consistent capitalisation across every branch, since case-sensitive comparison turns `'employee'` vs `'Employee'` into a silent correctness bug downstream.

---
📄 **SQL File:** [`Q83_Master_Contact_Directory.sql`](./Q83_Master_Contact_Directory.sql)

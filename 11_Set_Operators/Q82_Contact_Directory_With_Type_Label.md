# Q82. Contact Directory with Type Label

**Category:** Set Operators (UNION with literal columns)
**Difficulty:** Medium

---

## Problem Statement

The HR team wants a single contact directory combining customers and employees, showing where each contact comes from.

## Objective

Return the name, city, and type for every customer and every employee in one unified list, where `type` is `'Customer'` for customers and `'Employee'` for employees.

## Tables Used

- `customers`
- `employees`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| name | Contact name (customer contact name or employee full name) |
| city | City of the customer or employee |
| type | `'Customer'` or `'Employee'` — literal label indicating the source |

**Sample output:**

| name | city | type |
|------|------|------|
| Maria Anders | Berlin | Customer |
| Nancy Davolio | Seattle | Employee |
| Janet Leverling | Kirkland | Employee |
| Ana Trujillo | México D.F. | Customer |

*(Order depends on database storage order unless `ORDER BY` is specified.)*

## Concepts Used

- UNION
- Set Operators
- Literal String Columns
- String Concatenation (CONCAT)

## Why This Approach

**Why UNION with a literal type column:** adding a hard-coded string literal (`'Customer'` or `'Employee'`) as a column in each SELECT gives every row in the combined output a label identifying which source table it came from. This is the standard pattern for building a typed, unified directory from multiple independent source tables.

**Why `CONCAT(e.first_name, ' ', e.last_name)` is needed for employees:** `customers` has a single `contact_name` column. `employees` splits names into `first_name` and `last_name`. To make both SELECTs return the same structure (one name column), the employee name must be concatenated into a single expression matching the customer column's format.

**Why UNION (not UNION ALL):** if a customer and an employee happened to share the exact same name, city, and type label, UNION would deduplicate them — which is unlikely but safe. More practically, UNION is the standard default for combined directory queries.

**Minor consistency note:** your SQL uses `'employee'` (lowercase) while the expected output shows `'Employee'` (capitalised). Both are correct SQL — but the capitalised form matches the expected output and is more consistent with the `'Customer'` literal. For production use, always match the exact string the business expects in reports.

**Why three columns instead of one:** Q79–Q81 returned a single name column. Q82 adds `city` and `type` — demonstrating that UNION can combine multi-column result sets, as long as column count and types match across all SELECT statements.

## Common Mistakes

- Selecting `first_name` and `last_name` as separate columns from `employees` while selecting `contact_name` as one column from `customers` — column count mismatch error.
- Using inconsistent capitalisation for the type literal (`'Customer'` vs `'customer'`) — both values appear in the result, making filtering or grouping on `type` case-sensitive.
- Forgetting that UNION maps columns by position, not by name — if the column order differs between SELECTs, data silently ends up in the wrong column with no error.
- Placing `ORDER BY` inside one of the individual SELECT statements rather than at the end of the full UNION — invalid syntax.

## Difficulty

**Medium**

## Interview Follow-up Questions

**1. How do literal string columns work in a UNION query, and why are they useful?**

A literal string (`'Customer'`, `'Employee'`) in a SELECT list creates a computed column where every row from that SELECT gets the same fixed value. In a UNION, this becomes a "source label" column — every row in the combined result carries a tag identifying which SELECT (and therefore which source table) it came from. This makes the combined result self-describing and allows downstream filtering (`WHERE type = 'Employee'`), grouping (`GROUP BY type`), or display formatting based on the source.

**2. What is the effect of using `'employee'` (lowercase) vs `'Employee'` (capitalised) in the type column?**

Both are valid SQL — string literals are case-sensitive in PostgreSQL for comparison purposes. In the result, the type column would show `'Customer'` for customer rows and `'employee'` for employee rows — an inconsistency. Any downstream query filtering on `WHERE type = 'Employee'` would return no rows for employees (since the stored value is `'employee'`). For consistency and correctness, always match the exact capitalisation the business requirement specifies — here, `'Employee'`.

**3. How would you sort the combined directory by name, then by type?**

Add `ORDER BY` at the very end of the full UNION expression:
```sql
SELECT c.contact_name AS name, c.city, 'Customer' AS type FROM customers c
UNION
SELECT CONCAT(e.first_name,' ',e.last_name), e.city, 'Employee' FROM employees e
ORDER BY type, name;
```
The aliases (`name`, `type`) defined in the first SELECT can be referenced in the `ORDER BY` of the full UNION expression.

**4. How would you extend this to include suppliers as a third source with type `'Supplier'`?**

Add a third SELECT to the UNION chain:
```sql
SELECT contact_name AS name, city, 'Customer' AS type FROM customers
UNION
SELECT CONCAT(first_name,' ',last_name), city, 'Employee' FROM employees
UNION
SELECT contact_name, city, 'Supplier' FROM suppliers
ORDER BY type, name;
```

**5. How would you count the number of contacts per city across both customers and employees?**

Use the UNION as a subquery or CTE, then aggregate:
```sql
WITH directory AS (
    SELECT contact_name AS name, city, 'Customer' AS type FROM customers
    UNION
    SELECT CONCAT(first_name,' ',last_name), city, 'Employee' FROM employees
)
SELECT city, COUNT(*) AS total_contacts
FROM directory
GROUP BY city
ORDER BY total_contacts DESC;
```

## Learning Outcomes

- Master the typed UNION pattern: combining independent source tables into a single labelled directory using literal string columns.
- Understand that UNION maps columns by position, not by name — column count and type compatibility must be maintained manually.
- Know the practical difference between case-consistent (`'Employee'`) and case-inconsistent (`'employee'`) literals in type columns — a subtle but real source of bugs in downstream queries.
- Confirm that multi-column UNION works the same way as single-column UNION — the same rules apply regardless of how many columns are selected.

---

📄 **SQL File:** [`Q82_Contact_Directory_With_Type_Label.sql`](./Q82_Contact_Directory_With_Type_Label.sql)

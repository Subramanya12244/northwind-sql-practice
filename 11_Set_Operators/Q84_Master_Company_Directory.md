# Q84. Master Company Directory

**Category:** Set Operators (UNION — three-way with schema awareness)
**Difficulty:** Medium

---

## Problem Statement

The management team wants a Master Company Directory combining company names and countries from customers, suppliers, and shippers into one unified list.

## Objective

Return `Company_Name`, `Country`, and `Entity_Type` for every company from all three tables, with a label identifying the source.

## Tables Used

- `customers`
- `suppliers`
- `shippers`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| Company_Name | Company name from the source table |
| Country | Country of the company (`'N/A'` for shippers, which have no country column) |
| Entity_Type | `'Customer'`, `'Supplier'`, or `'Shipper'` |

**Sample output:**

| Company_Name | Country | Entity_Type |
|--------------|---------|-------------|
| Alfreds Futterkiste | Germany | Customer |
| Exotic Liquids | UK | Supplier |
| Speedy Express | N/A | Shipper |
| Ana Trujillo Emparedados y helados | Mexico | Customer |

*(Total rows: 91 customers + 29 suppliers + 3 shippers = 123 rows)*

## Concepts Used

- UNION (three-way)
- Set Operators
- Literal String Columns
- Schema Awareness (handling missing columns with placeholder values)

## Why This Approach

**Why this question is harder than Q83:** Q83's three tables all had `contact_name` and `city`. This question requires `country` — but checking the Northwind schema reveals that `shippers` has no `country` column. The `shippers` table only has `shipper_id`, `company_name`, and `phone`. A naive query copying the Q83 pattern would fail immediately with a column-not-found error.

**Why `'N/A' as country` for shippers:** UNION requires all SELECT statements to return the same number of columns with compatible types. Since `shippers` has no `country` column, a placeholder value must be substituted in that position. `'N/A'` is the correct pragmatic choice — it satisfies the structural requirement while clearly communicating to any reader that country data is unavailable for shippers. Alternative placeholders like `NULL` or `'Unknown'` would also work depending on business convention.

**Why this is a schema awareness test:** before writing the query, you need to check whether all three tables have the required columns. The mental checklist:
- `customers`: has `company_name` ✅ has `country` ✅
- `suppliers`: has `company_name` ✅ has `country` ✅
- `shippers`: has `company_name` ✅ has `country` ❌ → substitute `'N/A'`

This is exactly the kind of real-world consideration that distinguishes experienced SQL writers — knowing that column availability must be verified across all sources before writing a UNION.

**Capitalisation:** all three entity type literals use consistent title case — `'Customer'`, `'Supplier'`, `'Shipper'`. No inconsistency issue this time.

## Common Mistakes

- Trying to select `sh.country` from `shippers` — column doesn't exist, causes an error. Must check schema before assuming column availability.
- Using `NULL` instead of `'N/A'` — `NULL` works structurally but may cause issues if downstream reports filter `WHERE country IS NOT NULL` and inadvertently exclude shippers. `'N/A'` is more explicit.
- Forgetting to alias the first column consistently — the output column is labelled by the first SELECT's alias (`Name` in your SQL, which would need to be `Company_Name` to match the expected output exactly).

## Difficulty

**Medium**

## Interview Follow-up Questions

**1. Why did `shippers` require special handling in this query, and how did you identify it?**

`shippers` in the Northwind schema only has three columns: `shipper_id`, `company_name`, and `phone`. It has no `country` column — unlike `customers` and `suppliers`, which both have full address information including `country`. Before writing a UNION across multiple tables, always verify that every required column exists in every source table. When a column is missing from one source, substitute a placeholder value (`'N/A'`, `NULL`, or `'Unknown'`) in that position to maintain structural compatibility.

**2. Why was `'N/A'` chosen instead of `NULL` for the missing country?**

Both work structurally. `NULL` is technically more accurate — shippers genuinely have no country data, so `NULL` (unknown) is semantically precise. However, `'N/A'` is often preferable in a business directory context because it is explicit — a reader sees `N/A` and understands "this data is not available," whereas `NULL` in a report might look like a data error. The choice depends on business convention. If downstream queries filter `WHERE country IS NOT NULL`, `NULL` would exclude shippers entirely — `'N/A'` avoids that risk.

**3. How does this question test schema awareness beyond just knowing SQL syntax?**

It requires knowing (or checking) the column structure of each source table before writing the query. A developer who blindly copies the Q83 pattern would write `sh.country` and get an immediate error. The fix — substituting `'N/A'` — requires understanding why the column is missing and making a deliberate design decision about the placeholder. This "inspect before you write" discipline is a fundamental habit for production SQL development.

**4. How would you handle this if shippers did have country data in a different column — say `ship_country`?**

Alias it to match: `sh.ship_country AS country`. The alias in the UNION doesn't need to match the column name — it just needs to produce a compatible type in the correct position. The output column name comes from the first SELECT regardless.

**5. How would you extend this directory to also count how many companies per country across all three entity types?**

```sql
WITH directory AS (
    SELECT company_name, country, 'Customer' AS entity_type FROM customers
    UNION
    SELECT company_name, country, 'Supplier' FROM suppliers
    UNION
    SELECT company_name, 'N/A', 'Shipper' FROM shippers
)
SELECT country, COUNT(*) AS total_companies
FROM directory
GROUP BY country
ORDER BY total_companies DESC;
```

## Learning Outcomes

- Build the habit of checking column availability in every source table before writing a multi-table UNION — schema awareness is as important as syntax.
- Know the `'N/A'` / `NULL` / placeholder pattern for handling missing columns in UNION queries.
- Reinforce that UNION maps by position — a missing column must be substituted with a compatible placeholder in the correct position, not skipped.

---

📄 **SQL File:** [`Q84_Master_Company_Directory.sql`](./Q84_Master_Company_Directory.sql)

# Q170 · Customers Matching Name Patterns

> **Revision Card**
> **Category:** String Functions (Pattern Matching) | **Difficulty:** Easy
> **Concepts:** LIKE · ILIKE · Wildcards % and _ · OR
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** `LIKE` is case-sensitive in PostgreSQL; use `ILIKE` (or `LOWER()`) for case-insensitive matches.

## 1. Problem

Marketing wants a quick list of customers whose company name begins with "La" or contains the word "market" in any letter case, for a themed campaign.

**Objective:** Return customers whose `company_name` starts with `La` (case-sensitive) or contains `market` (case-insensitive).

**Tables:** `customers`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer identifier |
| company_name | Company name |
| matched_rule | Which pattern matched: `starts with La` or `contains market` |

| customer_id | company_name | matched_rule |
|-------------|--------------|--------------|
| BOTTM | Bottom-Dollar Markets | contains market |
| GREAL | Great Lakes Food Market | contains market |
| LACOR | La corne d'abondance | starts with La |
| LAMAI | La maison d'Asie | starts with La |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Filter with `company_name LIKE 'La%'` OR `company_name ILIKE '%market%'`.
2. Label the matching rule with a `CASE` expression.
3. Order by `customer_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    customer_id,
    company_name,
    CASE
        WHEN company_name LIKE 'La%' THEN 'starts with La'
        ELSE 'contains market'
    END AS matched_rule
FROM customers
WHERE company_name LIKE 'La%'
   OR company_name ILIKE '%market%'
ORDER BY customer_id;
```

## 6. Why This Works

`%` matches any run of characters (including none) and `_` matches exactly one character. Anchoring the pattern (`'La%'`) means "starts with"; wrapping it (`'%market%'`) means "contains". `ILIKE` is PostgreSQL's case-insensitive `LIKE`, so `Market`, `MARKET` and `market` all match.

## 7. Common Pitfalls (generic)

- Expecting `LIKE 'la%'` to match `La` — it does not, because `LIKE` is case-sensitive.
- Forgetting the leading `%` and only matching names that *start* with the word.
- Missing parentheses when mixing `AND` with `OR` in the `WHERE` clause.
- A leading-wildcard pattern (`'%x%'`) cannot use a normal B-tree index.

## 8. Interview Follow-ups

**1. How do you match a literal `%` or `_`?**

Escape it: `LIKE '%\_%'` or declare an escape character with `LIKE '%#_%' ESCAPE '#'`.

**2. What about regular expressions?**

PostgreSQL supports `~` (case-sensitive) and `~*` (case-insensitive), e.g. `company_name ~* '^(la|le) '`.

**3. How can a contains-search be indexed?**

Create a trigram index with the `pg_trgm` extension: `CREATE INDEX ... USING gin (company_name gin_trgm_ops)`.

## 9. Key Takeaway

Anchor with `%` to choose starts-with vs contains, and reach for `ILIKE` whenever letter case should not matter.

---
📄 **SQL File:** [`Q170_Customers_Matching_Name_Patterns.sql`](./Q170_Customers_Matching_Name_Patterns.sql)

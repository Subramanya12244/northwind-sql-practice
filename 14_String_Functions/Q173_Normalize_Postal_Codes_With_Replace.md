# Q173 · Normalize Postal Codes With Replace

> **Revision Card**
> **Category:** String Functions (Cleaning) | **Difficulty:** Medium
> **Concepts:** REPLACE · UPPER · LENGTH · Regex Match ~
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** `REPLACE` is literal and case-sensitive; nest calls to strip several different characters.

## 1. Problem

The shipping API rejects postal codes that contain spaces or hyphens. Operations needs a cleaned version of every customer postal code that contains either character.

**Objective:** For customers whose `postal_code` contains a space or a hyphen, return the original code, a cleaned upper-case code with spaces and hyphens removed, and both lengths.

**Tables:** `customers`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer identifier |
| country | Customer country |
| postal_code | Original postal code |
| clean_code | Upper-case code with spaces and hyphens removed |
| original_len | Length of the original code |
| clean_len | Length of the cleaned code |

| customer_id | country | postal_code | clean_code | original_len | clean_len |
|-------------|---------|-------------|------------|--------------|-----------|
| AROUT | UK | WA1 1DP | WA11DP | 7 | 6 |
| BERGS | Sweden | S-958 22 | S95822 | 8 | 6 |
| BOTTM | Canada | T2F 8M4 | T2F8M4 | 7 | 6 |
| BSBEV | UK | EC2 5NT | EC25NT | 7 | 6 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Keep rows where `postal_code ~ '[ -]'`.
2. Nest `REPLACE(REPLACE(postal_code, ' ', ''), '-', '')` and wrap in `UPPER`.
3. Compare lengths before and after, ordered by `customer_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    customer_id,
    country,
    postal_code,
    UPPER(REPLACE(REPLACE(postal_code, ' ', ''), '-', ''))          AS clean_code,
    LENGTH(postal_code)                                            AS original_len,
    LENGTH(REPLACE(REPLACE(postal_code, ' ', ''), '-', ''))        AS clean_len
FROM customers
WHERE postal_code ~ '[ -]'
ORDER BY customer_id;
```

## 6. Why This Works

`REPLACE(text, from, to)` substitutes every literal occurrence of `from`. Nesting two calls removes two different characters. The regex filter `~ '[ -]'` keeps only rows that actually need cleaning, and the length columns prove what changed.

## 7. Common Pitfalls (generic)

- Expecting `REPLACE` to accept a character class — it is literal; use `REGEXP_REPLACE(code, '[ -]', '', 'g')` for patterns.
- Forgetting the `'g'` flag in `REGEXP_REPLACE`, which then replaces only the first match.
- Filtering with `LIKE '% %'` only and missing hyphenated codes.

## 8. Interview Follow-ups

**1. Rewrite it with one function call.**

`UPPER(REGEXP_REPLACE(postal_code, '[ -]', '', 'g'))`.

**2. What does `TRANSLATE` do?**

`TRANSLATE(text, from, to)` maps characters one-to-one; `TRANSLATE(code, ' -', '')` deletes both characters in one call.

**3. How would you trim only leading and trailing spaces?**

`TRIM(postal_code)`, or `BTRIM`/`LTRIM`/`RTRIM` for specific sides and characters.

## 9. Key Takeaway

`REPLACE` for literal substitutions (nest for several), `REGEXP_REPLACE ... 'g'` or `TRANSLATE` for character sets.

---
📄 **SQL File:** [`Q173_Normalize_Postal_Codes_With_Replace.sql`](./Q173_Normalize_Postal_Codes_With_Replace.sql)

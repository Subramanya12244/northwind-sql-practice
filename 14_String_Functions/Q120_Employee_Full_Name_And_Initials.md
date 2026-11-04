# Q120 · Employee Full Name And Initials

> **Revision Card**
> **Category:** String Functions (Concatenation + Case) | **Difficulty:** Easy
> **Concepts:** || Concatenation · CONCAT · UPPER · LOWER · LEFT
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** `||` returns NULL if any operand is NULL; `CONCAT()` treats NULL as an empty string.

## 1. Problem

HR is printing name badges and needs each employee's display name, monogram initials and a lower-case login stem.

**Objective:** For every employee, return the full name (`first_name last_name`), upper-case initials, and the last name in lower case.

**Tables:** `employees`

**Expected output:**

| Column | Description |
|--------|-------------|
| employee_id | Employee identifier |
| full_name | First and last name separated by a space |
| initials | Upper-case first letters of first and last name |
| login_stem | Last name in lower case |

| employee_id | full_name | initials | login_stem |
|-------------|-----------|----------|------------|
| 1 | Nancy Davolio | ND | davolio |
| 2 | Andrew Fuller | AF | fuller |
| 3 | Janet Leverling | JL | leverling |
| 4 | Margaret Peacock | MP | peacock |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Concatenate `first_name || ' ' || last_name` for the full name.
2. Take `LEFT(..., 1)` of each name, concatenate and wrap in `UPPER()`.
3. Apply `LOWER(last_name)` and order by `employee_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    employee_id,
    first_name || ' ' || last_name                    AS full_name,
    UPPER(LEFT(first_name, 1) || LEFT(last_name, 1))  AS initials,
    LOWER(last_name)                                  AS login_stem
FROM employees
ORDER BY employee_id;
```

## 6. Why This Works

`||` is the SQL-standard concatenation operator and is the most readable choice when the inputs are `NOT NULL` (both name columns are). `LEFT(text, n)` returns the first *n* characters, so two calls give the monogram. `UPPER`/`LOWER` only change letter case and leave other characters untouched, so they are safe for names with accents.

## 7. Common Pitfalls (generic)

- Using `||` on nullable columns: one NULL turns the whole result NULL — use `CONCAT()` or `COALESCE` there.
- Using `+` for concatenation (SQL Server habit) — PostgreSQL raises an operator error.
- Forgetting the space literal and producing `NancyDavolio`.
- Calling `SUBSTRING(name, 0, 1)` — PostgreSQL positions start at 1, so this returns an empty string.

## 8. Interview Follow-ups

**1. What is the difference between `||` and `CONCAT()`?**

`'a' || NULL` is NULL, while `CONCAT('a', NULL)` is `'a'`. `CONCAT_WS(' ', a, b)` also inserts a separator and skips NULL arguments.

**2. How would you capitalise only the first letter of each word?**

Use `INITCAP(text)`, e.g. `INITCAP('nancy DAVOLIO')` returns `Nancy Davolio`.

**3. How would you add the courtesy title when it exists?**

`CONCAT_WS(' ', title_of_courtesy, first_name, last_name)` — the NULL title is skipped, so no leading space appears.

## 9. Key Takeaway

`||` for NOT NULL inputs, `CONCAT`/`CONCAT_WS` when NULLs are possible; `LEFT`, `UPPER` and `LOWER` handle simple formatting.

---
📄 **SQL File:** [`Q120_Employee_Full_Name_And_Initials.sql`](./Q120_Employee_Full_Name_And_Initials.sql)

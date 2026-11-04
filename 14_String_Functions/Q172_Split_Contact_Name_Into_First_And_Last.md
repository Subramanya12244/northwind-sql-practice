# Q172 · Split Contact Name Into First And Last

> **Revision Card**
> **Category:** String Functions (Splitting) | **Difficulty:** Medium
> **Concepts:** SPLIT_PART · POSITION · SUBSTRING · LENGTH
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Names can have more than two words; `SPLIT_PART(name, ' ', 2)` drops everything after the second word.

## 1. Problem

The CRM import needs separate first-name and last-name fields, but Northwind stores a single `contact_name`. Treat the first word as the first name and everything after the first space as the last name.

**Objective:** For customers in Germany, split `contact_name` into `first_name` and `last_name` and show the position of the first space.

**Tables:** `customers`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer identifier |
| contact_name | Original contact name |
| space_pos | Position of the first space |
| first_name | Text before the first space |
| last_name | Text after the first space |

| customer_id | contact_name | space_pos | first_name | last_name |
|-------------|--------------|-----------|------------|-----------|
| ALFKI | Maria Anders | 6 | Maria | Anders |
| BLAUS | Hanna Moos | 6 | Hanna | Moos |
| DRACD | Sven Ottlieb | 5 | Sven | Ottlieb |
| FRANK | Peter Franken | 6 | Peter | Franken |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Find the first space with `POSITION(' ' IN contact_name)`.
2. `SPLIT_PART(contact_name, ' ', 1)` gives the first word.
3. `SUBSTRING(contact_name FROM space_pos + 1)` keeps the rest, including multi-word surnames.
4. Filter to Germany and order by `customer_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    customer_id,
    contact_name,
    POSITION(' ' IN contact_name)                           AS space_pos,
    SPLIT_PART(contact_name, ' ', 1)                        AS first_name,
    SUBSTRING(contact_name FROM POSITION(' ' IN contact_name) + 1) AS last_name
FROM customers
WHERE country = 'Germany'
ORDER BY customer_id;
```

## 6. Why This Works

`POSITION(sub IN text)` returns the 1-based index of the first match (0 if none). `SPLIT_PART(text, delim, n)` returns the *n*-th field, which is ideal for the first word. For the surname, `SUBSTRING(... FROM pos + 1)` takes everything after the first space, so a name like `Carlos González Lima` keeps `González Lima` intact.

## 7. Common Pitfalls (generic)

- Using `SPLIT_PART(..., 2)` for the surname and losing third and later words.
- Forgetting that `POSITION` returns 0 when there is no space — `SUBSTRING(... FROM 1)` then returns the whole name as the last name.
- Off-by-one: `FROM pos` would keep the leading space.

## 8. Interview Follow-ups

**1. How do you take the *last* word instead?**

`SPLIT_PART(contact_name, ' ', -1)` (PostgreSQL 14+) or `REGEXP_REPLACE(contact_name, '^.* ', '')`.

**2. How do you handle names without a space?**

Wrap with `CASE WHEN POSITION(' ' IN contact_name) = 0 THEN NULL ELSE ... END` or use `NULLIF(SPLIT_PART(contact_name, ' ', 2), '')`.

**3. What is `STRPOS`?**

`STRPOS(text, sub)` is the function form of `POSITION(sub IN text)`; they are equivalent.

## 9. Key Takeaway

`SPLIT_PART` for a fixed field, `POSITION` + `SUBSTRING` for "everything after the first delimiter".

---
📄 **SQL File:** [`Q172_Split_Contact_Name_Into_First_And_Last.sql`](./Q172_Split_Contact_Name_Into_First_And_Last.sql)

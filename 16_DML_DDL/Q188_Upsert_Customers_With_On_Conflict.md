# Q188 · Upsert Customers With On Conflict

> **Revision Card**
> **Category:** DML (UPSERT) | **Difficulty:** Hard
> **Concepts:** INSERT … ON CONFLICT · DO UPDATE · EXCLUDED · RETURNING · xmax
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** `ON CONFLICT` needs a unique index or constraint on the conflict columns; `EXCLUDED` refers to the proposed row.

## 1. Problem

A CRM sync sends customer records that may already exist. Existing customers should get their city and postal code updated; new ones should be inserted.

**Objective:** Upsert `ALFKI` (new city `Hamburg`, postal code `20095`) and a new customer `ZZTOP` (`ZZ Top Traders`, contact `Billy Gibbons`, `Houston`, `77002`, `USA`). Return each row and whether it was inserted or updated. Runs inside `BEGIN … ROLLBACK`, so the data change is undone after grading.

**Tables:** `customers`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer identifier |
| company_name | Company name |
| city | City after the upsert |
| postal_code | Postal code after the upsert |
| action | `inserted` or `updated` |

| customer_id | company_name | city | postal_code | action |
|-------------|--------------|------|-------------|--------|
| ALFKI | Alfreds Futterkiste | Hamburg | 20095 | updated |
| ZZTOP | ZZ Top Traders | Houston | 77002 | inserted |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. `INSERT INTO customers (...) VALUES (...), (...)`.
2. `ON CONFLICT (customer_id) DO UPDATE SET city = EXCLUDED.city, postal_code = EXCLUDED.postal_code`.
3. `RETURNING ..., CASE WHEN xmax = 0 THEN 'inserted' ELSE 'updated' END`.
4. Wrap in a CTE and order by `customer_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH upserted AS (
    INSERT INTO customers (customer_id, company_name, contact_name, city, postal_code, country)
    VALUES ('ALFKI', 'Alfreds Futterkiste', 'Maria Anders',  'Hamburg', '20095', 'Germany'),
           ('ZZTOP', 'ZZ Top Traders',      'Billy Gibbons', 'Houston', '77002', 'USA')
    ON CONFLICT (customer_id) DO UPDATE
        SET city        = EXCLUDED.city,
            postal_code = EXCLUDED.postal_code
    RETURNING customer_id, company_name, city, postal_code,
              CASE WHEN xmax = 0 THEN 'inserted' ELSE 'updated' END AS action
)
SELECT customer_id, company_name, city, postal_code, action
FROM upserted
ORDER BY customer_id;
```

## 6. Why This Works

`ON CONFLICT (customer_id)` uses the primary-key index to detect existing rows atomically, so there is no race between a check and an insert. In `DO UPDATE`, `EXCLUDED` is the row that was proposed for insertion. The system column `xmax` is 0 for a freshly inserted row version and non-zero for one produced by the update path — a well-known (implementation-specific) way to tell the two apart.

## 7. Common Pitfalls (generic)

- Using a conflict target without a unique index — error: there is no unique or exclusion constraint matching the ON CONFLICT specification.
- Updating the same row twice in one statement (duplicate keys in `VALUES`) — error: ON CONFLICT DO UPDATE command cannot affect row a second time.
- Writing `SET city = city` (keeps the old value) instead of `EXCLUDED.city`.
- Relying on `xmax` in production logic — it is an internal detail.

## 8. Interview Follow-ups

**1. `DO NOTHING` vs `DO UPDATE`?**

`DO NOTHING` skips conflicting rows (and `RETURNING` omits them); `DO UPDATE` modifies the existing row.

**2. How do you update only when values changed?**

Add `WHERE customers.city IS DISTINCT FROM EXCLUDED.city` to the `DO UPDATE` clause.

**3. What about `MERGE`?**

PostgreSQL 15+ supports SQL-standard `MERGE INTO ... USING ... WHEN MATCHED THEN UPDATE WHEN NOT MATCHED THEN INSERT`, which can also delete; `ON CONFLICT` is still the concurrency-safe upsert.

## 9. Key Takeaway

Upsert = `INSERT ... ON CONFLICT (key) DO UPDATE SET col = EXCLUDED.col`, backed by a unique index.

---
📄 **SQL File:** [`Q188_Upsert_Customers_With_On_Conflict.sql`](./Q188_Upsert_Customers_With_On_Conflict.sql)

# Q135 · Insert New Shipper With Returning

> **Revision Card**
> **Category:** DML (INSERT … RETURNING) | **Difficulty:** Easy
> **Concepts:** INSERT · RETURNING · SERIAL Default · Multi-row VALUES
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Do not supply `shipper_id`; let the `SERIAL` default assign it and read it back with `RETURNING`.

## 1. Problem

Logistics signed two new carriers. Add them to `shippers` and show the ids the database assigned.

**Objective:** Insert shippers `Speedy Freight` (phone `(503) 555-0101`) and `Polar Logistics` (phone `(503) 555-0102`) and return the new rows. Runs inside `BEGIN … ROLLBACK`, so the data change is undone after grading.

**Tables:** `shippers`

**Expected output:**

| Column | Description |
|--------|-------------|
| shipper_id | Generated id |
| company_name | Shipper name |
| phone | Phone |

| shipper_id | company_name | phone |
|------------|--------------|-------|
| 7 | Speedy Freight | (503) 555-0101 |
| 8 | Polar Logistics | (503) 555-0102 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. `INSERT INTO shippers (company_name, phone) VALUES (...), (...)` — omit the id.
2. Add `RETURNING shipper_id, company_name, phone`.
3. Wrap in a CTE and `SELECT ... ORDER BY shipper_id` so the output order is guaranteed.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH new_shippers AS (
    INSERT INTO shippers (company_name, phone)
    VALUES ('Speedy Freight',  '(503) 555-0101'),
           ('Polar Logistics', '(503) 555-0102')
    RETURNING shipper_id, company_name, phone
)
SELECT shipper_id, company_name, phone
FROM new_shippers
ORDER BY shipper_id;
```

## 6. Why This Works

`RETURNING` sends back the rows as stored, including values produced by defaults such as the `SERIAL` id — no follow-up `SELECT MAX(id)` is needed (which would be unsafe under concurrency). Putting the `INSERT` in a CTE lets the outer `SELECT` sort the returned rows; `RETURNING` itself has no `ORDER BY`.

## 7. Common Pitfalls (generic)

- Supplying an explicit id that collides with an existing row, or that leaves the sequence behind.
- Reading the new id with `SELECT MAX(shipper_id)` — another session may insert in between.
- Listing values in a different order from the column list.

## 8. Interview Follow-ups

**1. What if the sequence is behind the data?**

Inserts fail with a duplicate-key error; fix with `SELECT setval('shippers_shipper_id_seq', (SELECT MAX(shipper_id) FROM shippers))`.

**2. Does ROLLBACK undo the sequence increment?**

No — sequences are non-transactional, so ids used in a rolled-back transaction are skipped later.

**3. How do you insert from a query?**

`INSERT INTO t (cols) SELECT ... FROM ...` — no `VALUES` keyword.

## 9. Key Takeaway

Insert without the id, read generated values with `RETURNING`, and wrap in a CTE when you need ordered output.

---
📄 **SQL File:** [`Q135_Insert_New_Shipper_With_Returning.sql`](./Q135_Insert_New_Shipper_With_Returning.sql)

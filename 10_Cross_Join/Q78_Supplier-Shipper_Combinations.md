# Q78 · Supplier–Shipper Combinations

> **Revision Card**
> **Category:** CROSS JOIN | **Difficulty:** Easy
> **Concepts:** CROSS JOIN · Cartesian product · No ON clause · Column selection (company_name vs contact_name)
> **Outcome:** ⚠️ had mistakes (see §4)
> **Watch out for:** "Supplier Name" means the company (`company_name`), not the contact person (`contact_name`).

## 1. Problem

Generate every possible combination of suppliers and shippers.

**Objective:** Return the supplier name and shipper name for every possible supplier–shipper pairing.

**Tables:** `suppliers`, `shippers`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| supplier_name | Company name of the supplier |
| shipper_name | Company name of the shipping company |

**Sample output:**

| supplier_name | shipper_name |
|---------------|--------------|
| Exotic Liquids | Speedy Express |
| Exotic Liquids | United Package |
| Exotic Liquids | Federal Shipping |
| New Orleans Cajun Delights | Speedy Express |
| New Orleans Cajun Delights | United Package |

*(Sample values are illustrative, based on the standard Northwind dataset. Showing first 5 of 29 suppliers × 3 shippers = **87 rows**.)*

**Result size:** 29 suppliers × 3 shippers = **87 rows**

## 2. My Approach

1. Recognise "every supplier × every shipper" as a combinatorial request → `CROSS JOIN`.
2. Use only the two tables named — `suppliers` and `shippers`.
3. `CROSS JOIN` with no `ON` clause to produce the Cartesian product.
4. Select the supplier's `company_name` (the "Supplier Name") and the shipper's `company_name`.

## 3. My Solution (as submitted)

```sql
select s.contact_name, sh.company_name from shippers sh cross join suppliers s
```

## 4. Mistakes I Made

- ⚠️ **Submitted `s.contact_name` instead of `s.company_name`** → `contact_name` is the supplier's contact person; `company_name` is the supplier entity itself, which is what "Supplier Name" refers to → use `s.company_name AS supplier_name`. (The CROSS JOIN logic was correct.)

## 5. Correct / Optimal Solution

```sql
SELECT
    s.company_name AS supplier_name,
    sh.company_name AS shipper_name
FROM suppliers s
CROSS JOIN shippers sh;
```

## 6. Why This Works

**What CROSS JOIN does:** produces every possible combination of every row from both tables — N × M rows total, with no join condition. There is no `ON` clause. CROSS JOIN intentionally ignores relationships between tables; it is used specifically when every combination is desired.

**The one rule for CROSS JOIN:** if you write `ON`, you are not doing a CROSS JOIN. The presence of an `ON` clause turns it into an `INNER JOIN` by a different name.

**When to recognise CROSS JOIN:** the trigger phrases are:
- "Every X with every Y"
- "All possible combinations of X and Y"
- "Generate a combination matrix"

**Table order does not matter:** `FROM A CROSS JOIN B` and `FROM B CROSS JOIN A` produce identical result sets — just in a different row order.

**Note on column selection:** `s.contact_name` (the supplier's contact person) vs `s.company_name` (the supplier company) are two different attributes. The question asks for "Supplier Name" — meaning the company. Always confirm which supplier attribute the question requires before selecting:
- "Supplier Name" → `s.company_name`
- "Supplier Contact" → `s.contact_name`

## 7. Common Pitfalls (generic)

- **Adding an `ON` clause to CROSS JOIN** — `CROSS JOIN` never takes an `ON` clause. Adding one converts it to an `INNER JOIN` by another name, which filters rows based on a condition — the opposite of generating all combinations.
- **Joining through related tables unnecessarily** — Q71 demonstrates this perfectly. "Every employee × every category" requires only `employees` and `categories`. Joining through `orders`, `order_details`, and `products` turns it into "employees who sold products in that category" — a completely different query.
- **Assuming table order matters** — unlike `LEFT JOIN`/`RIGHT JOIN`, `CROSS JOIN` is symmetric. `FROM A CROSS JOIN B` and `FROM B CROSS JOIN A` produce the same result set.
- **`contact_name` vs `company_name`** — 'Supplier Name' refers to the company entity (`s.company_name`), not the contact person (`s.contact_name`). Always verify which attribute the question requires.

## 8. Interview Follow-ups

**1. What does CROSS JOIN do, and when would you use it in a real business scenario?**

`CROSS JOIN` produces a Cartesian product — every row from the left table paired with every row from the right table, with no filtering condition. Real use cases include: generating a complete combination matrix as the base for a pivot-table report (e.g. all employee × category combinations, then LEFT JOIN actual sales data so zero-activity cells appear as 0 rather than being absent); creating a date spine by crossing a list of dates with a list of entities; and generating test data by crossing small lookup tables.

**2. Why does CROSS JOIN have no ON clause?**

Because it has no matching condition — it deliberately pairs every row with every other row. Adding `ON` would filter the result to only matching pairs, which is what `INNER JOIN` does. The defining characteristic of `CROSS JOIN` is the absence of any join predicate. If you find yourself writing `CROSS JOIN ... ON`, stop — you almost certainly want `INNER JOIN` instead.

**3. How does CROSS JOIN differ from INNER JOIN and FULL OUTER JOIN?**

`INNER JOIN` returns only rows where the join condition is satisfied — matched rows only. `FULL OUTER JOIN` returns matched rows plus unmatched rows from both sides (with NULLs). `CROSS JOIN` returns every possible combination of rows from both tables regardless of any relationship — no condition, no filtering. For a 91-row and 8-row table: `INNER JOIN` might return ~80 rows, `FULL OUTER JOIN` might return ~95 rows, `CROSS JOIN` always returns exactly 91 × 8 = 728 rows.

**4. How would you use a CROSS JOIN as the base for a "purchase coverage" report — showing every customer × category, with actual revenue filled in where it exists?**

Start with the CROSS JOIN to get all combinations, then LEFT JOIN to actual sales data:
```sql
SELECT
    cu.contact_name,
    c.category_name,
    COALESCE(ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2), 0) AS revenue
FROM customers cu
CROSS JOIN categories c
LEFT JOIN orders o ON o.customer_id = cu.customer_id
LEFT JOIN order_details od ON od.order_id = o.order_id
LEFT JOIN products p ON p.product_id = od.product_id AND p.category_id = c.category_id
GROUP BY cu.customer_id, cu.contact_name, c.category_id, c.category_name
ORDER BY cu.contact_name, c.category_name;
```
The CROSS JOIN guarantees every cell exists; the LEFT JOINs fill in the revenue where it exists and leave 0 elsewhere.

**5. What is the result size formula for CROSS JOIN, and why does it matter?**

Result size = rows in table A × rows in table B. This matters because CROSS JOIN can silently produce enormous result sets: 1,000 rows × 1,000 rows = 1,000,000 rows. Always calculate the expected result size before running a CROSS JOIN on large tables. The small lookup tables in Northwind (categories=8, shippers=3, employees=9) make CROSS JOINs safe here, but in production systems with millions of rows, an accidental CROSS JOIN can bring a database to its knees.

## 9. Key Takeaway

"Supplier Name" = `company_name`; "Supplier Contact" = `contact_name` — always confirm which attribute the question requires before selecting.

---
📄 **SQL File:** [`Q78_Supplier-Shipper_Combinations.sql`](./Q78_Supplier-Shipper_Combinations.sql)

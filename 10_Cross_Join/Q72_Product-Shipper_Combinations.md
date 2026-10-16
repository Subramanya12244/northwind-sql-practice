# Q72 · Product–Shipper Combinations

> **Revision Card**
> **Category:** CROSS JOIN | **Difficulty:** Easy
> **Concepts:** CROSS JOIN · Cartesian product · No ON clause
> **Outcome:** ✅ correct first attempt
> **Watch out for:** products and shippers have no direct relationship in Northwind — do not try to join them; `CROSS JOIN` is the correct tool for every pairing.

## 1. Problem

Generate every possible combination of products and shippers.

**Objective:** Return the product name and shipper name for every possible product–shipper pairing.

**Tables:** `products`, `shippers`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| product_name | Name of the product |
| company_name | Name of the shipping company |

**Sample output:**

| product_name | company_name |
|--------------|--------------|
| Chai | Speedy Express |
| Chai | United Package |
| Chai | Federal Shipping |
| Chang | Speedy Express |
| Chang | United Package |

*(Sample values are illustrative, based on the standard Northwind dataset. Showing first 5 of 77 products × 3 shippers = **231 rows**.)*

**Result size:** 77 products × 3 shippers = **231 rows**

## 2. My Approach

1. Recognise "every product × every shipper" as a combinatorial request → `CROSS JOIN`.
2. Use only the two tables named — `products` and `shippers`.
3. `CROSS JOIN` with no `ON` clause to produce the Cartesian product.
4. Select `product_name` and the shipper's `company_name`.

## 3. My Solution (as submitted)

```sql
SELECT
    p.product_name,
    sh.company_name
FROM products p
CROSS JOIN shippers sh;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**What CROSS JOIN does:** produces every possible combination of every row from both tables — N × M rows total, with no join condition. There is no `ON` clause. CROSS JOIN intentionally ignores relationships between tables; it is used specifically when every combination is desired.

**The one rule for CROSS JOIN:** if you write `ON`, you are not doing a CROSS JOIN. The presence of an `ON` clause turns it into an `INNER JOIN` by a different name.

**When to recognise CROSS JOIN:** the trigger phrases are:
- "Every X with every Y"
- "All possible combinations of X and Y"
- "Generate a combination matrix"

**Table order does not matter:** `FROM A CROSS JOIN B` and `FROM B CROSS JOIN A` produce identical result sets — just in a different row order.

**Why no relationship between products and shippers is needed:** in Northwind, shippers are linked to orders (via `ship_via`), not to products directly. The question doesn't ask which shipper handled which product — it asks for every possible product–shipper combination. CROSS JOIN is the only correct tool here.

## 7. Common Pitfalls (generic)

- **Adding an `ON` clause to CROSS JOIN** — `CROSS JOIN` never takes an `ON` clause. Adding one converts it to an `INNER JOIN` by another name, which filters rows based on a condition — the opposite of generating all combinations.
- **Joining through related tables unnecessarily** — Q71 demonstrates this perfectly. "Every employee × every category" requires only `employees` and `categories`. Joining through `orders`, `order_details`, and `products` turns it into "employees who sold products in that category" — a completely different query.
- **Assuming table order matters** — unlike `LEFT JOIN`/`RIGHT JOIN`, `CROSS JOIN` is symmetric. `FROM A CROSS JOIN B` and `FROM B CROSS JOIN A` produce the same result set.

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

For "every X with every Y", use `CROSS JOIN` on exactly the two required tables, no `ON` clause — and table order never changes the result set.

---
📄 **SQL File:** [`Q72_Product-Shipper_Combinations.sql`](./Q72_Product-Shipper_Combinations.sql)

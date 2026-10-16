# Q77 · Product–Employee Combinations

> **Revision Card**
> **Category:** CROSS JOIN | **Difficulty:** Easy
> **Concepts:** CROSS JOIN · Cartesian product · No ON clause · CONCAT
> **Outcome:** ✅ correct first attempt
> **Watch out for:** `CROSS JOIN` is fully symmetric — table order affects only display order, never which rows are returned.

## 1. Problem

Generate every possible combination of products and employees.

**Objective:** Return the product name and employee name for every possible product–employee pairing.

**Tables:** `products`, `employees`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| product_name | Name of the product |
| employee_name | Full name of the employee |

**Sample output:**

| product_name | employee_name |
|--------------|---------------|
| Chai | Nancy Davolio |
| Chai | Andrew Fuller |
| Chai | Janet Leverling |
| Chang | Nancy Davolio |
| Chang | Andrew Fuller |

*(Sample values are illustrative, based on the standard Northwind dataset. Showing first 5 of 77 products × 9 employees = **693 rows**.)*

**Result size:** 77 products × 9 employees = **693 rows**

## 2. My Approach

1. Recognise "every product × every employee" as a combinatorial request → `CROSS JOIN`.
2. Use only the two tables named — `products` and `employees`.
3. `CROSS JOIN` with no `ON` clause to produce the Cartesian product.
4. Select `product_name` and build `employee_name` with `CONCAT(first_name, ' ', last_name)`.

## 3. My Solution (as submitted)

```sql
select p.product_name,
concat(e.first_name,' ',e.last_name) as employee_name
from employees e
cross join products p;
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

**Why table order does not matter for CROSS JOIN:** `FROM employees e CROSS JOIN products p` and `FROM products p CROSS JOIN employees e` produce the same 693 rows — just potentially in a different order. Unlike `LEFT JOIN` and `RIGHT JOIN`, where the left/right position determines which table is preserved, `CROSS JOIN` is fully symmetric.

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

`CROSS JOIN` is symmetric — table order does not affect which rows are returned, only their display order.

---
📄 **SQL File:** [`Q77_Product-Employee_Combinations.sql`](./Q77_Product-Employee_Combinations.sql)

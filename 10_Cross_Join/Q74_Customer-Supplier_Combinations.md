# Q74. Customer–Supplier Combinations

**Category:** CROSS JOIN
**Difficulty:** Easy

---

## Problem Statement

Generate every possible combination of customers and suppliers.

## Objective

Return the customer name and supplier name for every possible customer–supplier pairing.

## Tables Used

- `customers`
- `suppliers`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| customer_name | Contact name of the customer |
| supplier_name | Company name of the supplier |

**Sample output:**

| customer_name | supplier_name |
|---------------|---------------|
| Maria Anders | Exotic Liquids |
| Maria Anders | New Orleans Cajun Delights |
| Ana Trujillo | Exotic Liquids |
| Ana Trujillo | New Orleans Cajun Delights |

*(Sample values are illustrative, based on the standard Northwind dataset. Showing first 5 of 91 customers × 29 suppliers = **2,639 rows**)*

## Result Size

91 customers × 29 suppliers = **2,639 rows**

## Concepts Used

- CROSS JOIN
- No ON clause

## Why This Approach

**What CROSS JOIN does:** produces every possible combination of every row from both tables — N × M rows total, with no join condition. There is no `ON` clause. CROSS JOIN intentionally ignores relationships between tables; it is used specifically when every combination is desired.

**The one rule for CROSS JOIN:** if you write `ON`, you are not doing a CROSS JOIN. The presence of an `ON` clause turns it into an `INNER JOIN` by a different name.

**When to recognise CROSS JOIN:** the trigger phrases are:
- "Every X with every Y"
- "All possible combinations of X and Y"
- "Generate a combination matrix"

**Table order does not matter:** `FROM A CROSS JOIN B` and `FROM B CROSS JOIN A` produce identical result sets — just in a different row order.

**Why no relationship join is needed:** customers and suppliers have no direct foreign key relationship in Northwind — they are connected only indirectly through products and orders. The question asks for every possible pairing regardless of actual purchasing history, so CROSS JOIN is correct and those intermediate tables are irrelevant.

## Common Mistakes

- **Adding an `ON` clause to CROSS JOIN** — `CROSS JOIN` never takes an `ON` clause. Adding one converts it to an `INNER JOIN` by another name, which filters rows based on a condition — the opposite of generating all combinations.
- **Joining through related tables unnecessarily** — Q71 demonstrates this perfectly. "Every employee × every category" requires only `employees` and `categories`. Joining through `orders`, `order_details`, and `products` turns it into "employees who sold products in that category" — a completely different query.
- **Assuming table order matters** — unlike `LEFT JOIN`/`RIGHT JOIN`, `CROSS JOIN` is symmetric. `FROM A CROSS JOIN B` and `FROM B CROSS JOIN A` produce the same result set.
- **`contact_name` vs `company_name`** — 'Supplier Name' refers to the company entity (`s.company_name`), not the contact person (`s.contact_name`). Always verify which attribute the question requires.

## Difficulty

**Easy**

## Interview Follow-up Questions

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

## Learning Outcomes

- Know the single defining rule of `CROSS JOIN`: no `ON` clause, produces N × M rows.
- Recognise the trigger phrases: "every X with every Y", "all possible combinations", "generate a combination matrix."
- Understand that `CROSS JOIN` is symmetric — table order does not matter.
- Know the primary real-world use case: generating a complete combination grid as the base for a report, then LEFT JOINing actual data to fill in values.
- Always calculate result size (N × M) before running a CROSS JOIN in production.

---

**Score from review session: 10/10**

**Interview Takeaway:** CROSS JOIN works between any two tables regardless of whether they share a foreign key relationship.

📄 **SQL File:** [`Q74_Customer-Supplier_Combinations.sql`](./Q74_Customer-Supplier_Combinations.sql)

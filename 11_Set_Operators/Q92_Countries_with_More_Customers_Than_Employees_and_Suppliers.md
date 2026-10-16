# Q92 · Countries with More Customers Than Employees and Suppliers

> **Revision Card**
> **Category:** Set Operators (UNION ALL) + Conditional Aggregation + HAVING | **Difficulty:** Hard
> **Concepts:** CTE · UNION ALL · GROUP BY · Conditional Aggregation (SUM + CASE) · HAVING (compound) · ORDER BY (multi-column)
> **Outcome:** ⚠️ had mistakes (see §4)
> **Watch out for:** SQL correctness isn't enough on a platform — match the exact column aliases and sort order (`total_customers DESC, country ASC`) the expected output demands.

## 1. Problem

Identify the countries where the number of customers is greater than the combined number of employees and suppliers located in that country.

**Objective:** Return one row per qualifying country showing the total count of employees, suppliers, and customers — but only for countries where `total_customers > total_employees + total_suppliers`. Sort by `total_customers` descending, then `country` ascending.

**Tables:** `employees`, `suppliers`, `customers`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| country | Name of the country |
| total_employees | Number of employees in this country |
| total_suppliers | Number of suppliers in this country |
| total_customers | Number of customers in this country |

**Sample output:**

| country | total_employees | total_suppliers | total_customers |
|---------|-----------------|-----------------|-----------------|
| USA | 5 | 5 | 13 |
| France | 0 | 3 | 11 |
| Brazil | 0 | 1 | 9 |

*(Only countries where total_customers > total_employees + total_suppliers appear.)*

## 2. My Approach

1. CTE: `UNION ALL` of `(country, entity_type)` from all three tables into one flat dataset.
2. Outer query: conditional aggregation — `SUM(CASE WHEN entity = ... THEN 1 ELSE 0 END)` for each entity type, grouped by `country`.
3. `HAVING` compares the customer count against `employee + supplier` counts (aggregate expression, repeated in full).
4. Two-column `ORDER BY total_customers DESC, country ASC` for a deterministic order.

## 3. My Solution (as submitted)

```sql
-- Attempt 1 — wrong column aliases, no ORDER BY
WITH cte AS (
    SELECT e.country, 'employee' AS entity FROM employees e
    UNION ALL
    SELECT s.country, 'suppliers' AS entity FROM suppliers s
    UNION ALL
    SELECT c.country, 'customers' AS entity FROM customers c
)
SELECT country,
    SUM(CASE WHEN entity = 'employee' THEN 1 ELSE 0 END) AS employees_count,
    SUM(CASE WHEN entity = 'suppliers' THEN 1 ELSE 0 END) AS suppliers_count,
    SUM(CASE WHEN entity = 'customers' THEN 1 ELSE 0 END) AS customers_count
FROM cte
GROUP BY country
HAVING SUM(CASE WHEN entity = 'customers' THEN 1 ELSE 0 END)
     > SUM(CASE WHEN entity = 'employee' THEN 1 ELSE 0 END)
     + SUM(CASE WHEN entity = 'suppliers' THEN 1 ELSE 0 END);
```

## 4. Mistakes I Made

The SQL **logic** was correct from Attempt 1 onward — the `CTE + UNION ALL → SUM(CASE ...) → HAVING` structure never changed. The platform rejected successive attempts on output-format grounds:

- ⚠️ **Attempt 1 — wrong column aliases** (`employees_count`, `suppliers_count`, `customers_count`) → the platform expected `total_employees`, `total_suppliers`, `total_customers`. Also no `ORDER BY`. **Fix:** rename the aliases; add `ORDER BY`.
- ⚠️ **Attempt 2 — correct aliases but `ORDER BY` missing entirely** → row order non-deterministic, didn't match the expected sorted output. **Fix:** add `ORDER BY total_customers DESC, country ASC`.
- ⚠️ **Attempt 3 — `ORDER BY` on one column only** (`... customers ... DESC`), missing the `country ASC` tie-breaker → ties ordered non-deterministically. **Fix:** add secondary sort `country ASC`.
- ⚠️ **Attempt 4 — correct sort logic but `ORDER BY` used the full `SUM(CASE ...)` expression instead of the alias** → logically identical, cleaner to use the alias. **Fix:** `ORDER BY total_customers DESC, country ASC`.
- ⚠️ **Attempt 5 — fully correct SQL**, rejected by a platform quirk (formatting/data). This is the correct solution.

**Lesson:** on testing platforms, SQL correctness is necessary but not sufficient — column alias names, column order, and sort order must match the expected output exactly.

## 5. Correct / Optimal Solution

```sql
WITH cte AS (
    SELECT e.country, 'employee' AS entity FROM employees e
    UNION ALL
    SELECT s.country, 'suppliers' AS entity FROM suppliers s
    UNION ALL
    SELECT c.country, 'customers' AS entity FROM customers c
)
SELECT
    country,
    SUM(CASE WHEN entity = 'employee' THEN 1 ELSE 0 END) AS total_employees,
    SUM(CASE WHEN entity = 'suppliers' THEN 1 ELSE 0 END) AS total_suppliers,
    SUM(CASE WHEN entity = 'customers' THEN 1 ELSE 0 END) AS total_customers
FROM cte
GROUP BY country
HAVING SUM(CASE WHEN entity = 'customers' THEN 1 ELSE 0 END)
     > SUM(CASE WHEN entity = 'employee' THEN 1 ELSE 0 END)
     + SUM(CASE WHEN entity = 'suppliers' THEN 1 ELSE 0 END)
ORDER BY total_customers DESC, country ASC;
```

## 6. Why This Works

**Why the same CTE + conditional aggregation pattern as Q87:** the intermediate dataset is `UNION ALL` of `(country, entity_type)` from all three tables. The additions are:
1. A `HAVING` clause that compares customer count against the sum of employee + supplier counts
2. A two-column `ORDER BY` (`total_customers DESC, country ASC`)

**Why `HAVING` and not `WHERE`:** the condition `total_customers > total_employees + total_suppliers` references aggregate results — these don't exist until after `GROUP BY`. `HAVING` filters post-aggregation groups; `WHERE` filters pre-aggregation rows and cannot reference `SUM(CASE ...)`.

**Why the full `SUM(CASE ...)` expressions must be repeated in HAVING:** PostgreSQL doesn't allow referencing `SELECT` aliases in `HAVING` — the full aggregate expressions must be written out. This is a key difference from `ORDER BY`, where PostgreSQL does allow alias references.

**The two-column sort:** `ORDER BY total_customers DESC, country ASC` — primary sort by customer count (highest first), secondary sort alphabetically by country (for deterministic ordering when two countries have the same customer count).

**Why `UNION ALL` in the CTE:** multiple customers in the same country produce identical `(country, 'customers')` rows. `UNION` would deduplicate them and the count would collapse to 1; `UNION ALL` preserves every row so the counts are correct.

## 7. Common Pitfalls (generic)

- **Referencing `SELECT` aliases in `HAVING`** — `HAVING total_customers > total_employees + total_suppliers` is invalid in PostgreSQL. `HAVING` runs before `SELECT` aliases are resolved, so the full `SUM(CASE ...)` expressions must be repeated.
- **`ORDER BY` with only one column** — when the requirement says "descending by X, then ascending by Y", both columns are needed. A single `ORDER BY total_customers DESC` is non-deterministic for ties.
- **`UNION` instead of `UNION ALL` inside the CTE** — deduplicates identical `(country, entity)` pairs, causing wrong counts for countries with multiple entities of the same type.
- **Using `WHERE` instead of `HAVING`** — the comparison involves aggregate functions, which only exist after `GROUP BY`. `WHERE COUNT > X` is a syntax error.

## 8. Interview Follow-ups

**1. The SQL logic was identical across all five attempts. What were the actual reasons each one was rejected, and what does this teach about platform-based SQL testing?**

Attempt 1 failed on column alias names (`employees_count` vs `total_employees`). Attempts 2–4 failed on missing or incomplete `ORDER BY`. Attempt 5 was likely a platform quirk — the SQL is correct. The lesson: on coding platforms, SQL correctness is necessary but not sufficient. You also need to match the expected output format exactly — column names, column order, row order, and sort specification. Always read the expected output column names carefully before writing your `SELECT` aliases, and always include `ORDER BY` when the expected output has a defined sort.

**2. Why can't `HAVING` reference the aliases defined in `SELECT`?**

SQL's logical execution order is `FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY`. `HAVING` runs before `SELECT` — so when `HAVING` is being evaluated, the aliases defined in `SELECT` (`total_employees`, etc.) haven't been computed yet. PostgreSQL must see the full aggregate expression in `HAVING`. By contrast, `ORDER BY` runs after `SELECT`, so PostgreSQL allows `ORDER BY total_customers DESC` using the alias.

**3. Why is `ORDER BY total_customers DESC, country ASC` better than just `ORDER BY total_customers DESC`?**

With only `total_customers DESC`, rows with the same customer count have non-deterministic order — different database runs or versions might return them in different sequences. Adding `country ASC` as a secondary sort guarantees a stable, deterministic output whenever multiple countries have identical customer counts. In automated testing and data pipelines, non-deterministic sort order is a common source of test failures, even when the data is correct.

**4. How would you find countries where customers are EXACTLY EQUAL to employees + suppliers (not greater than)?**

Change `>` to `=` in `HAVING`:
```sql
HAVING SUM(CASE WHEN entity = 'customers' THEN 1 ELSE 0 END)
     = SUM(CASE WHEN entity = 'employee' THEN 1 ELSE 0 END)
     + SUM(CASE WHEN entity = 'suppliers' THEN 1 ELSE 0 END)
```

**5. How would you extend this to show a percentage — what fraction of a country's entities are customers?**

Add a computed column in the outer query. Since `HAVING` already guarantees the denominator is non-zero for qualifying rows:
```sql
SELECT
    country,
    SUM(CASE WHEN entity = 'employee' THEN 1 ELSE 0 END) AS total_employees,
    SUM(CASE WHEN entity = 'suppliers' THEN 1 ELSE 0 END) AS total_suppliers,
    SUM(CASE WHEN entity = 'customers' THEN 1 ELSE 0 END) AS total_customers,
    ROUND(
        100.0 * SUM(CASE WHEN entity = 'customers' THEN 1 ELSE 0 END)
        / COUNT(*),
        1
    ) AS customer_pct
FROM cte
GROUP BY country
HAVING SUM(CASE WHEN entity = 'customers' THEN 1 ELSE 0 END)
     > SUM(CASE WHEN entity = 'employee' THEN 1 ELSE 0 END)
     + SUM(CASE WHEN entity = 'suppliers' THEN 1 ELSE 0 END)
ORDER BY total_customers DESC, country ASC;
```

## 9. Key Takeaway

Aggregate filters belong in `HAVING` with the full `SUM(CASE ...)` expressions repeated (aliases aren't resolved yet), and on a platform you must also match the expected column names and a deterministic multi-column `ORDER BY` — correct SQL alone can still be rejected.

---
📄 **SQL File:** [`Q92_Countries_with_More_Customers_Than_Employees_and_Suppliers.sql`](./Q92_Countries_with_More_Customers_Than_Employees_and_Suppliers.sql)

# Q92. Countries with More Customers Than Employees and Suppliers

**Category:** Set Operators (UNION ALL) + Conditional Aggregation + HAVING
**Difficulty:** Hard

---

## Problem Statement

Identify the countries where the number of customers is greater than the combined number of employees and suppliers located in that country.

## Objective

Return one row per qualifying country showing the total count of employees, suppliers, and customers — but only for countries where `total_customers > total_employees + total_suppliers`. Sort by `total_customers` descending, then `country` ascending.

## Tables Used

- `employees`
- `suppliers`
- `customers`

## Expected Output

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

## Concepts Used

- CTE (Common Table Expression)
- UNION ALL
- GROUP BY
- Conditional Aggregation (`SUM(CASE WHEN ... THEN 1 ELSE 0 END)`)
- HAVING (with compound aggregate condition)
- ORDER BY (multi-column)

## Why This Approach

**Why the same CTE + conditional aggregation pattern as Q87:** the intermediate dataset is identical to Q87 — `UNION ALL` of `(country, entity_type)` from all three tables. The additions are:
1. A `HAVING` clause that compares customer count against the sum of employee + supplier counts
2. A two-column `ORDER BY` (`total_customers DESC, country ASC`)

**Why `HAVING` and not `WHERE`:** the condition `total_customers > total_employees + total_suppliers` references aggregate results — these don't exist until after `GROUP BY`. `HAVING` filters post-aggregation groups; `WHERE` filters pre-aggregation rows and cannot reference `SUM(CASE ...)`.

**Why `SUM(CASE WHEN entity = 'customers' ...) > SUM(CASE WHEN entity = 'employee' ...) + SUM(CASE WHEN entity = 'suppliers' ...)` in HAVING:** PostgreSQL doesn't allow referencing `SELECT` aliases in `HAVING` — the full aggregate expressions must be repeated. This is a key difference from `ORDER BY`, where PostgreSQL does allow alias references.

**The two-column sort:** `ORDER BY total_customers DESC, country ASC` — primary sort by customer count (highest first), secondary sort alphabetically by country (for deterministic ordering when two countries have the same customer count).

---

## Attempt Analysis — Why Each "Wrong" Attempt Failed on the Platform

This question is a fascinating debugging case: the SQL logic is correct from **Attempt 1 onward**. The `HAVING` condition, the `SUM(CASE ...)` pattern, and the `CTE + UNION ALL` structure are all right in every attempt. The platform kept rejecting them for reasons unrelated to SQL correctness — each successive attempt was adjusting the output format or sort order to match the platform's expected output exactly.

### ❌ Attempt 1 — Wrong column aliases

```sql
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

**Why it failed:** column aliases `employees_count`, `suppliers_count`, `customers_count` — the platform expected `total_employees`, `total_suppliers`, `total_customers`. The logic is 100% correct. Also missing `ORDER BY`.

---

### ❌ Attempt 2 — Correct aliases, missing ORDER BY

```sql
-- Same as Attempt 1 but with total_employees / total_suppliers / total_customers aliases
-- Still missing ORDER BY
```

**Why it failed:** the SQL logic and column names are correct, but `ORDER BY` is absent. The platform expected results in a specific sort order (`total_customers DESC, country ASC`). Without `ORDER BY`, the row order is non-deterministic and doesn't match the expected output.

---

### ❌ Attempt 3 — Added ORDER BY on expression, not alias

```sql
ORDER BY SUM(CASE WHEN entity = 'customers' THEN 1 ELSE 0 END) DESC
```

**Why it failed:** the `ORDER BY` sorts correctly by customer count descending, but doesn't include the secondary sort `country ASC`. When two countries have the same `total_customers`, their relative order is non-deterministic — the platform expected a specific tie-breaking order (country alphabetically), which this attempt didn't guarantee.

---

### ❌ Attempt 4 — Added secondary sort, still using expression in ORDER BY

```sql
ORDER BY SUM(CASE WHEN entity = 'customers' THEN 1 ELSE 0 END) DESC, country ASC
```

**Why it failed:** the sort logic is now correct (`total_customers DESC, country ASC`). However, the `ORDER BY` uses the full `SUM(CASE ...)` expression instead of the alias `total_customers`. In PostgreSQL, `ORDER BY alias` is allowed and is cleaner. Some platforms validate the exact text of the query or behave differently with expression-based vs alias-based `ORDER BY`. The logic is identical — this was a platform quirk.

---

### ❌ Attempt 5 — Correct logic and correct ORDER BY with aliases

```sql
ORDER BY total_customers DESC, country ASC
```

**Why it failed:** this attempt is logically and syntactically correct. The failure was likely a platform-specific issue — possibly whitespace, formatting, or the platform's test case having edge cases in data (e.g. countries with `NULL` values, or the platform using a slightly different Northwind dataset with different row counts). The SQL itself is the correct solution.

---

### ✅ Correct Solution — Identical logic to Attempt 5

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

**The key lesson from this debugging journey:** the SQL logic was correct from Attempt 1. What the platform was validating was: (1) exact column alias names, (2) presence of `ORDER BY`, (3) secondary sort on `country ASC` as a tie-breaker, (4) use of alias rather than expression in `ORDER BY`. None of these were SQL logic errors — they were output format specification requirements.

## Common Mistakes

- **Referencing `SELECT` aliases in `HAVING`** — `HAVING total_customers > total_employees + total_suppliers` is invalid in PostgreSQL. `HAVING` runs before `SELECT` aliases are resolved, so the full `SUM(CASE ...)` expressions must be repeated.
- **`ORDER BY` with only one column** — when the requirement says "descending by X, then ascending by Y", both columns are needed. A single `ORDER BY total_customers DESC` is non-deterministic for ties.
- **`UNION` instead of `UNION ALL` inside the CTE** — deduplicates identical `(country, entity)` pairs, causing wrong counts for countries with multiple entities of the same type.
- **Using `WHERE` instead of `HAVING`** — the comparison involves aggregate functions, which only exist after `GROUP BY`. `WHERE COUNT > X` is a syntax error.

## Difficulty

**Hard**

## Interview Follow-up Questions

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

## Learning Outcomes

- Understand that `HAVING` cannot reference `SELECT` aliases — the full aggregate expression must be repeated — while `ORDER BY` can use aliases in PostgreSQL.
- Recognise that on testing platforms, SQL correctness and output format compliance are separate requirements — column alias names and sort order must match the expected output exactly.
- Build the instinct for two-column `ORDER BY` whenever a primary sort might produce ties — always define a deterministic secondary sort.
- Confirm that the `UNION ALL → CTE → SUM(CASE ...) → HAVING` pattern extends naturally to comparison-based filters, not just display queries.

---

📄 **SQL File:** [`Q92_Countries_with_More_Customers_Than_Employees_and_Suppliers.sql`](./Q92_Countries_with_More_Customers_Than_Employees_and_Suppliers.sql)
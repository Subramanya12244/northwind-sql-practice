# Q65 · Employees Hired in the Same Year

> **Revision Card**
> **Category:** Self Join | **Difficulty:** Easy
> **Concepts:** SELF JOIN · INNER JOIN · date functions (EXTRACT) · duplicate-pair elimination (`id < id`)
> **Outcome:** ✅ correct first attempt
> **Watch out for:** compare `EXTRACT(YEAR FROM hire_date)`, not `hire_date` itself — the latter matches only employees hired on the exact same day.

## 1. Problem

Retrieve employee pairs hired in the same year.

**Objective:** Return every unique pair of employees who share the same hire year, along with that year. Exclude self-pairs and duplicate pairs.

**Tables:** `employees` (aliased twice: `e1`, `e2`)

**Expected output:**

| Column | Description |
|---|---|
| employee_name1 | Full name of the first employee in the pair |
| employee_name2 | Full name of the second employee in the pair |
| hire_year | The year both employees were hired |

| employee_name1 | employee_name2 | hire_year |
|----------------|----------------|-----------|
| Nancy Davolio | Janet Leverling | 1992 |
| Andrew Fuller | Margaret Peacock | 1992 |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## 2. My Approach

1. Self-join `employees e1` to `employees e2`.
2. Reduce each `hire_date` to its year with `EXTRACT(YEAR FROM ...)` and compare the two.
3. Add `e1.employee_id < e2.employee_id` to drop self/duplicate pairs.
4. Select both names and the shared hire year (aliased).

## 3. My Solution (as submitted)

```sql
SELECT CONCAT(e1.first_name,' ',e1.last_name) AS employee_name1,
       CONCAT(e2.first_name,' ',e2.last_name) AS employee_name2,
       EXTRACT(YEAR FROM e1.hire_date) AS hire_year
FROM employees e1
JOIN employees e2
    ON e1.employee_id < e2.employee_id
    AND EXTRACT(YEAR FROM e1.hire_date) = EXTRACT(YEAR FROM e2.hire_date);
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why `EXTRACT(YEAR FROM hire_date)`:** the `hire_date` column stores a full date (year, month, day). Comparing full dates directly (`e1.hire_date = e2.hire_date`) would only match employees hired on the exact same day — much too restrictive. `EXTRACT(YEAR FROM hire_date)` reduces the date to just the year component, allowing the "same year" comparison intended by the business requirement.

**Why the standard pair pattern applies directly:** `ON e1.employee_id < e2.employee_id AND EXTRACT(YEAR FROM e1.hire_date) = EXTRACT(YEAR FROM e2.hire_date)` — the `<` handles deduplication, and the `EXTRACT` comparison handles the "same year" condition. No additional complexity is needed.

## 7. Common Pitfalls (generic)

- Forgetting to alias the `EXTRACT` expression in the SELECT (`EXTRACT(YEAR FROM e1.hire_date) AS hire_year`) — produces an unnamed column that is confusing in output and may cause errors in some tools.
- Comparing `e1.hire_date = e2.hire_date` instead of extracting the year — finds employees hired on the exact same day, not the same year.

## 8. Interview Follow-ups

**1. Why is `EXTRACT(YEAR FROM hire_date)` used instead of comparing `hire_date` directly?**

`hire_date` is a full date value (e.g. 1992-04-01). Comparing two dates directly with `=` checks for identical day, month, and year — far more restrictive than 'same year.' `EXTRACT(YEAR FROM hire_date)` returns just the integer year (e.g. 1992), allowing comparison at the intended grain.

**2. How would you find employee pairs hired in the same month of the same year?**

Extract both year and month and compare both: `EXTRACT(YEAR FROM e1.hire_date) = EXTRACT(YEAR FROM e2.hire_date) AND EXTRACT(MONTH FROM e1.hire_date) = EXTRACT(MONTH FROM e2.hire_date)`. Alternatively, use `DATE_TRUNC('month', e1.hire_date) = DATE_TRUNC('month', e2.hire_date)` which truncates both dates to the first of the month and compares them — more concise.

**3. How does `DATE_TRUNC` compare to `EXTRACT` for year-level comparisons in PostgreSQL?**

`DATE_TRUNC('year', hire_date)` returns a timestamp truncated to January 1st of that year (e.g. `1992-01-01 00:00:00`). Comparing two `DATE_TRUNC` results checks year equality just as `EXTRACT(YEAR FROM ...)` does. `EXTRACT` returns a plain integer; `DATE_TRUNC` returns a timestamp. For simple equality comparisons, both work — `EXTRACT` is often more readable for year-only comparisons.

**4. How would you count how many same-year hire pairs exist per year?**

`SELECT EXTRACT(YEAR FROM e1.hire_date) AS hire_year, COUNT(*) AS pairs FROM employees e1 JOIN employees e2 ON e1.employee_id < e2.employee_id AND EXTRACT(YEAR FROM e1.hire_date) = EXTRACT(YEAR FROM e2.hire_date) GROUP BY hire_year ORDER BY hire_year`.

## 9. Key Takeaway

To compare dates at year granularity in PostgreSQL, use `EXTRACT(YEAR FROM date_column)` as the match condition inside the standard self-join pair pattern.

---
📄 **SQL File:** [`Q65_Employees_Hired_in_the_Same_Year.sql`](./Q65_Employees_Hired_in_the_Same_Year.sql)

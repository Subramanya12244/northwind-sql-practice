# Q65. Employees Hired in the Same Year

**Category:** SELF JOIN
**Difficulty:** Easy

---

## Problem Statement

Retrieve employee pairs hired in the same year.

## Objective

Return every unique pair of employees who share the same hire year, along with that year. Exclude self-pairs and duplicate pairs.

## Tables Used

- `employees (aliased twice: e1, e2)`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| employee_name1 | Full name of the first employee in the pair |
| employee_name2 | Full name of the second employee in the pair |
| hire_year | The year both employees were hired |

**Sample output:**

| employee_name1 | employee_name2 | hire_year |
|----------------|----------------|-----------|
| Nancy Davolio | Janet Leverling | 1992 |
| Andrew Fuller | Margaret Peacock | 1992 |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## Concepts Used

- SELF JOIN
- INNER JOIN
- Date Functions (EXTRACT)
- Duplicate pair elimination (id < id)

## Why This Approach

**Why `EXTRACT(YEAR FROM hire_date)`:** the `hire_date` column stores a full date (year, month, day). Comparing full dates directly (`e1.hire_date = e2.hire_date`) would only match employees hired on the exact same day — much too restrictive. `EXTRACT(YEAR FROM hire_date)` reduces the date to just the year component, allowing the "same year" comparison intended by the business requirement.

**Why the standard pair pattern applies directly:** `ON e1.employee_id < e2.employee_id AND EXTRACT(YEAR FROM e1.hire_date) = EXTRACT(YEAR FROM e2.hire_date)` — the `<` handles deduplication, and the `EXTRACT` comparison handles the "same year" condition. No additional complexity is needed.

## Common Mistakes

- Forgetting to alias the `EXTRACT` expression in the SELECT (`EXTRACT(YEAR FROM e1.hire_date) AS hire_year`) — produces an unnamed column that is confusing in output and may cause errors in some tools.
- Comparing `e1.hire_date = e2.hire_date` instead of extracting the year — finds employees hired on the exact same day, not the same year.

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. Why is `EXTRACT(YEAR FROM hire_date)` used instead of comparing `hire_date` directly?**

`hire_date` is a full date value (e.g. 1992-04-01). Comparing two dates directly with `=` checks for identical day, month, and year — far more restrictive than 'same year.' `EXTRACT(YEAR FROM hire_date)` returns just the integer year (e.g. 1992), allowing comparison at the intended grain.

**2. How would you find employee pairs hired in the same month of the same year?**

Extract both year and month and compare both: `EXTRACT(YEAR FROM e1.hire_date) = EXTRACT(YEAR FROM e2.hire_date) AND EXTRACT(MONTH FROM e1.hire_date) = EXTRACT(MONTH FROM e2.hire_date)`. Alternatively, use `DATE_TRUNC('month', e1.hire_date) = DATE_TRUNC('month', e2.hire_date)` which truncates both dates to the first of the month and compares them — more concise.

**3. How does `DATE_TRUNC` compare to `EXTRACT` for year-level comparisons in PostgreSQL?**

`DATE_TRUNC('year', hire_date)` returns a timestamp truncated to January 1st of that year (e.g. `1992-01-01 00:00:00`). Comparing two `DATE_TRUNC` results checks year equality just as `EXTRACT(YEAR FROM ...)` does. `EXTRACT` returns a plain integer; `DATE_TRUNC` returns a timestamp. For simple equality comparisons, both work — `EXTRACT` is often more readable for year-only comparisons.

**4. How would you count how many same-year hire pairs exist per year?**

`SELECT EXTRACT(YEAR FROM e1.hire_date) AS hire_year, COUNT(*) AS pairs FROM employees e1 JOIN employees e2 ON e1.employee_id < e2.employee_id AND EXTRACT(YEAR FROM e1.hire_date) = EXTRACT(YEAR FROM e2.hire_date) GROUP BY hire_year ORDER BY hire_year`.

## Learning Outcomes

- Know when to use `EXTRACT(YEAR FROM date_column)` vs comparing full dates — a common date-handling decision in SQL.
- Confirm that `DATE_TRUNC` is an alternative for year/month truncation comparisons in PostgreSQL.
- Reinforce the standard SELF JOIN pair pattern, now with a date-function comparison as the matching condition.

---

**Score from review session: 10/10**

**Interview Takeaway:** When comparing dates at year granularity in PostgreSQL: `EXTRACT(YEAR FROM date_column)`.

📄 **SQL File:** [`Q65_Employees_Hired_in_the_Same_Year.sql`](./Q65_Employees_Hired_in_the_Same_Year.sql)

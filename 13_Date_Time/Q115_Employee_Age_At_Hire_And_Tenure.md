# Q115 · Employee Age At Hire And Tenure

> **Revision Card**
> **Category:** Date & Time (AGE & Intervals) | **Difficulty:** Medium
> **Concepts:** AGE() · EXTRACT from INTERVAL · DATE Subtraction · Fixed Reference Date
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** AGE(later, earlier) — argument order matters; and dividing day counts by 365 drifts on leap years, so use AGE for completed years.

## 1. Problem

HR is analysing hiring patterns. For each employee, show how old they were (in completed years) on their hire date, and their tenure as of **DATE '1998-12-31'** both in completed years and in total days.

**Objective:** Return each employee's age at hire, tenure in completed years and tenure in days as of 1998-12-31.

**Tables:** `employees`

**Expected output:**

| Column | Description |
|--------|-------------|
| employee_id | Employee identifier |
| first_name | First name |
| last_name | Last name |
| birth_date | Date of birth |
| hire_date | Date hired |
| age_at_hire | Completed years between birth_date and hire_date |
| tenure_years | Completed years between hire_date and 1998-12-31 |
| tenure_days | 1998-12-31 − hire_date in days |

| employee_id | first_name | last_name | birth_date | hire_date | age_at_hire | tenure_years | tenure_days |
|---|---|---|---|---|---|---|---|
| 3 | Janet | Leverling | 1963-08-30 | 1992-04-01 | 28 | 6 | 2465 |
| 9 | Anne | Dodsworth | 1966-01-27 | 1994-11-15 | 28 | 4 | 1507 |
| 6 | Michael | Suyama | 1963-07-02 | 1993-10-17 | 30 | 5 | 1901 |

*(Sample rows are illustrative — taken from the practice dataset to show shape/format; your instance may differ.)*

## 2. My Approach

1. `AGE(hire_date, birth_date)` gives an interval in years/months/days; extract YEAR for completed years.
2. `AGE(DATE '1998-12-31', hire_date)` for tenure years.
3. `DATE '1998-12-31' - hire_date` for tenure in days.
4. Sort youngest hire first, tie-break on `employee_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.birth_date,
    e.hire_date,
    EXTRACT(YEAR FROM AGE(e.hire_date, e.birth_date))::int AS age_at_hire,
    EXTRACT(YEAR FROM AGE(DATE '1998-12-31', e.hire_date))::int AS tenure_years,
    (DATE '1998-12-31' - e.hire_date) AS tenure_days
FROM employees e
WHERE e.birth_date IS NOT NULL
  AND e.hire_date IS NOT NULL
ORDER BY age_at_hire, employee_id;
```

## 6. Why This Works

`AGE(a, b)` returns a symbolic interval like `28 years 7 mons 2 days` that respects calendar months and leap years. Extracting `YEAR` from it yields completed years — exactly how age is normally stated. Plain DATE subtraction is the right tool when an exact day count is wanted.

## 7. Common Pitfalls (generic)

- Swapping AGE arguments, producing negative intervals.
- Computing age as `(hire_date - birth_date) / 365`, which is wrong around birthdays because of leap days, and is integer division.
- `EXTRACT(DAY FROM AGE(...))` returns only the days component, not total days.
- Single-argument `AGE(x)` measures from `CURRENT_DATE` — non-reproducible.

## 8. Interview Follow-ups

**1. What does single-argument AGE(birth_date) do?**

It computes `AGE(CURRENT_DATE, birth_date)` — midnight of today. It is handy interactively but makes results change daily, so pass an explicit as-of date in reports.

**2. How would you get tenure in fractional years, e.g. 6.75?**

Use `EXTRACT(EPOCH FROM AGE(...)) / (365.25 * 86400)`, or `(as_of - hire_date) / 365.25` with numeric division. State the convention, because 'fractional years' has no single standard definition.

**3. How would you find employees whose work anniversary falls in December?**

Filter `EXTRACT(MONTH FROM hire_date) = 12`. To find the next anniversary date, add `(tenure_years + 1) * INTERVAL '1 year'` to `hire_date`.

## 9. Key Takeaway

Use `AGE(later, earlier)` + `EXTRACT(YEAR ...)` for completed years and plain `date - date` for exact days.

---
📄 **SQL File:** [`Q115_Employee_Age_At_Hire_And_Tenure.sql`](./Q115_Employee_Age_At_Hire_And_Tenure.sql)

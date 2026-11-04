# Q132 · Custom Country Sort Order With CASE

> **Revision Card**
> **Category:** CASE Expressions (Ordering) | **Difficulty:** Medium
> **Concepts:** CASE in ORDER BY · Custom Sort · Tie-breakers
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** The CASE gives the priority group only; you still need secondary keys for a deterministic order.

## 1. Problem

The sales director wants the customer call list to start with the home markets — USA first, then Canada and Mexico — and then every other country alphabetically.

**Objective:** Return customers in USA, Canada, Mexico, Brazil and Argentina ordered by a custom priority (USA, then Canada/Mexico, then others), then by country and company name.

**Tables:** `customers`

**Expected output:**

| Column | Description |
|--------|-------------|
| sort_group | 1 = USA, 2 = Canada/Mexico, 3 = other |
| country | Country |
| customer_id | Customer identifier |
| company_name | Company name |

| sort_group | country | customer_id | company_name |
|------------|---------|-------------|--------------|
| 1 | USA | GREAL | Great Lakes Food Market |
| 1 | USA | HUNGC | Hungry Coyote Import Store |
| 1 | USA | LAZYK | Lazy K Kountry Store |
| 1 | USA | LETSS | Let's Stop N Shop |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Filter to the five Americas countries.
2. Map country to a priority number with `CASE`.
3. Order by the priority, then `country`, then `company_name`, then `customer_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    CASE country
        WHEN 'USA'    THEN 1
        WHEN 'Canada' THEN 2
        WHEN 'Mexico' THEN 2
        ELSE 3
    END AS sort_group,
    country,
    customer_id,
    company_name
FROM customers
WHERE country IN ('USA', 'Canada', 'Mexico', 'Brazil', 'Argentina')
ORDER BY sort_group, country, company_name, customer_id;
```

## 6. Why This Works

`ORDER BY` accepts any expression, so a `CASE` can map values to an arbitrary rank. Here a simple `CASE` (equality on `country`) returns 1, 2 or 3. Rows with the same rank fall back to the next keys; `customer_id` is unique, so the order is fully deterministic. Exposing `sort_group` in `SELECT` makes the sort visible for checking.

## 7. Common Pitfalls (generic)

- Sorting by `country` alone — alphabetical order puts Argentina first.
- Returning text ranks (`'1'`, `'10'`) that sort lexically instead of numerically.
- Forgetting secondary keys so rows within a group come back in arbitrary order.

## 8. Interview Follow-ups

**1. Can you sort by a CASE without selecting it?**

Yes — `ORDER BY CASE ... END, country` works without it in the select list (unless `SELECT DISTINCT` is used).

**2. Another way to do a custom order?**

`ORDER BY ARRAY_POSITION(ARRAY['USA','Canada','Mexico'], country) NULLS LAST, country`.

**3. How would you make NULL countries come last?**

`ORDER BY sort_group, country NULLS LAST` — or give NULL its own `WHEN country IS NULL THEN 4` branch.

## 9. Key Takeaway

Custom sort = `ORDER BY CASE ... END` for the priority, then real columns down to a unique key.

---
📄 **SQL File:** [`Q132_Custom_Country_Sort_Order_With_CASE.sql`](./Q132_Custom_Country_Sort_Order_With_CASE.sql)

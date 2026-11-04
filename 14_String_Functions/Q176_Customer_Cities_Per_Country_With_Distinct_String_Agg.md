# Q176 · Customer Cities Per Country With Distinct String Agg

> **Revision Card**
> **Category:** String Functions (Aggregation) | **Difficulty:** Hard
> **Concepts:** STRING_AGG DISTINCT · COUNT DISTINCT · HAVING · UPPER · LEFT
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** With `DISTINCT` inside `STRING_AGG`, the inner `ORDER BY` must use the same expression being aggregated.

## 1. Problem

Regional sales leads want a compact view of their biggest markets: for each country with at least 5 customers, how many customers and cities there are, the city list, and a short country code.

**Objective:** For countries with 5 or more customers, return a 3-letter upper-case country code, the country, the customer count, the distinct city count, and the distinct cities as a ` | `-separated alphabetical list.

**Tables:** `customers`

**Expected output:**

| Column | Description |
|--------|-------------|
| country_code | First 3 letters of the country, upper case |
| country | Country |
| customer_count | Number of customers |
| city_count | Number of distinct cities |
| cities | Distinct cities, alphabetical, separated by ` \| ` |

| country_code | country | customer_count | city_count | cities |
|--------------|---------|----------------|------------|--------|
| USA | USA | 13 | 12 | Albuquerque \| Anchorage \| Boise \| Butte \| Elgin \| Eugene \| Kirkland \| Lander \| Portland \| San Francisco \| Seattle \| Walla Walla |
| FRA | France | 11 | 9 | Lille \| Lyon \| Marseille \| Nantes \| Paris \| Reims \| Strasbourg \| Toulouse \| Versailles |
| GER | Germany | 11 | 11 | Aachen \| Berlin \| Brandenburg \| Cunewalde \| Frankfurt a.M. \| Köln \| Leipzig \| Mannheim \| München \| Münster \| Stuttgart |
| BRA | Brazil | 9 | 4 | Campinas \| Resende \| Rio de Janeiro \| São Paulo |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Group customers by `country`.
2. `COUNT(*)` customers and `COUNT(DISTINCT city)` cities.
3. `STRING_AGG(DISTINCT city, ' | ' ORDER BY city)` for the list.
4. `HAVING COUNT(*) >= 5`; order by customer count descending, then country.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    UPPER(LEFT(country, 3))                          AS country_code,
    country,
    COUNT(*)                                         AS customer_count,
    COUNT(DISTINCT city)                             AS city_count,
    STRING_AGG(DISTINCT city, ' | ' ORDER BY city)   AS cities
FROM customers
GROUP BY country
HAVING COUNT(*) >= 5
ORDER BY customer_count DESC, country;
```

## 6. Why This Works

`DISTINCT` inside an aggregate removes duplicates before aggregation, so each city appears once even when several customers share it. PostgreSQL requires that, with `DISTINCT`, the inner `ORDER BY` expressions appear in the argument list — ordering by `city` satisfies that. `HAVING` filters on the group count after grouping, and `country` is a unique tie-breaker per group.

## 7. Common Pitfalls (generic)

- `STRING_AGG(DISTINCT city, ' | ' ORDER BY country)` — error: in an aggregate with DISTINCT, ORDER BY expressions must appear in the argument list.
- Filtering the count in `WHERE` instead of `HAVING`.
- Sorting only by `customer_count DESC` — France and Germany both have 11 customers, so their order would be arbitrary.

## 8. Interview Follow-ups

**1. Why is `LEFT(country, 3)` not a real ISO code?**

`UK` would stay `UK` and `Germany` becomes `GER` (ISO is `DEU`); a real solution joins a country-code lookup table.

**2. How would you show the top city per country?**

Count per (country, city) in a CTE, then use `ROW_NUMBER() OVER (PARTITION BY country ORDER BY cnt DESC, city)` and keep row 1.

**3. How do you limit the list to the first 3 cities?**

Aggregate into an array, then slice: `(ARRAY_AGG(DISTINCT city ORDER BY city))[1:3]`.

## 9. Key Takeaway

`STRING_AGG(DISTINCT x, sep ORDER BY x)` deduplicates a list; filter groups with `HAVING` and tie-break the outer sort.

---
📄 **SQL File:** [`Q176_Customer_Cities_Per_Country_With_Distinct_String_Agg.sql`](./Q176_Customer_Cities_Per_Country_With_Distinct_String_Agg.sql)

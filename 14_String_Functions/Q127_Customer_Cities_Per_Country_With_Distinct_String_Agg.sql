/* =====================================================================
   Q127 · Customer Cities Per Country With Distinct String Agg
   Category : String Functions (Aggregation)     Difficulty : Hard
   Concepts : STRING_AGG DISTINCT · COUNT DISTINCT · HAVING · UPPER · LEFT
   ---------------------------------------------------------------------
   PROBLEM : For countries with 5 or more customers, return a 3-letter upper-case country code, the country, the customer count, the distinct city count, and the distinct cities as a  | -separated alphabetical list.
   APPROACH:
     1. Group customers by country.
     2. COUNT(*) customers and COUNT(DISTINCT city) cities.
     3. STRING_AGG(DISTINCT city, ' | ' ORDER BY city) for the list.
     4. HAVING COUNT(*) >= 5; order by customer count descending, then country.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
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

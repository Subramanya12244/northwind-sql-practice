/* =====================================================================
   Q181 · Custom Country Sort Order With CASE
   Category : CASE Expressions (Ordering)     Difficulty : Medium
   Concepts : CASE in ORDER BY · Custom Sort · Tie-breakers
   ---------------------------------------------------------------------
   PROBLEM : Return customers in USA, Canada, Mexico, Brazil and Argentina ordered by a custom priority (USA, then Canada/Mexico, then others), then by country and company name.
   APPROACH:
     1. Filter to the five Americas countries.
     2. Map country to a priority number with CASE.
     3. Order by the priority, then country, then company_name, then customer_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
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

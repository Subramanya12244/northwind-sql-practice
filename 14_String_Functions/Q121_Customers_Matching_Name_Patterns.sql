/* =====================================================================
   Q121 · Customers Matching Name Patterns
   Category : String Functions (Pattern Matching)     Difficulty : Easy
   Concepts : LIKE · ILIKE · Wildcards % and _ · OR
   ---------------------------------------------------------------------
   PROBLEM : Return customers whose company_name starts with La (case-sensitive) or contains market (case-insensitive).
   APPROACH:
     1. Filter with company_name LIKE 'La%' OR company_name ILIKE '%market%'.
     2. Label the matching rule with a CASE expression.
     3. Order by customer_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    customer_id,
    company_name,
    CASE
        WHEN company_name LIKE 'La%' THEN 'starts with La'
        ELSE 'contains market'
    END AS matched_rule
FROM customers
WHERE company_name LIKE 'La%'
   OR company_name ILIKE '%market%'
ORDER BY customer_id;

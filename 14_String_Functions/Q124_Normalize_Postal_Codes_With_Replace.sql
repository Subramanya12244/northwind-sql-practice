/* =====================================================================
   Q124 · Normalize Postal Codes With Replace
   Category : String Functions (Cleaning)     Difficulty : Medium
   Concepts : REPLACE · UPPER · LENGTH · Regex Match ~
   ---------------------------------------------------------------------
   PROBLEM : For customers whose postal_code contains a space or a hyphen, return the original code, a cleaned upper-case code with spaces and hyphens removed, and both lengths.
   APPROACH:
     1. Keep rows where postal_code ~ '[ -]'.
     2. Nest REPLACE(REPLACE(postal_code, ' ', ''), '-', '') and wrap in UPPER.
     3. Compare lengths before and after, ordered by customer_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    customer_id,
    country,
    postal_code,
    UPPER(REPLACE(REPLACE(postal_code, ' ', ''), '-', ''))          AS clean_code,
    LENGTH(postal_code)                                            AS original_len,
    LENGTH(REPLACE(REPLACE(postal_code, ' ', ''), '-', ''))        AS clean_len
FROM customers
WHERE postal_code ~ '[ -]'
ORDER BY customer_id;

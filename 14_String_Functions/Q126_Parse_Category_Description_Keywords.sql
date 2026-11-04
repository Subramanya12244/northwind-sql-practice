/* =====================================================================
   Q126 · Parse Category Description Keywords
   Category : String Functions (Parsing)     Difficulty : Hard
   Concepts : SPLIT_PART · REPLACE · LENGTH · TRIM · Delimiter Counting
   ---------------------------------------------------------------------
   PROBLEM : For each category, return the first keyword of the description (text before the first comma), the number of comma-separated items, and the final item with any leading and  removed.
   APPROACH:
     1. SPLIT_PART(description, ',', 1) gives the first keyword.
     2. Count commas with LENGTH(description) - LENGTH(REPLACE(description, ',', '')), then add 1.
     3. Take the last comma field with SPLIT_PART(description, ',', -1), TRIM it and strip a leading and  with REGEXP_REPLACE.
     4. Order by category_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    category_id,
    category_name,
    TRIM(SPLIT_PART(description, ',', 1))                                   AS first_keyword,
    LENGTH(description) - LENGTH(REPLACE(description, ',', '')) + 1         AS item_count,
    REGEXP_REPLACE(TRIM(SPLIT_PART(description, ',', -1)), '^and ', '')     AS last_item
FROM categories
ORDER BY category_id;

/* =====================================================================
   Q171 · Longest Product Names
   Category : String Functions (Length)     Difficulty : Easy
   Concepts : LENGTH · CHAR_LENGTH · ORDER BY · LIMIT
   ---------------------------------------------------------------------
   PROBLEM : Return the 10 products with the longest product_name, with the character count.
   APPROACH:
     1. Compute LENGTH(product_name).
     2. Sort by length descending, then product_id to break ties.
     3. Keep the first 10 rows with LIMIT.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    product_id,
    product_name,
    LENGTH(product_name) AS name_length
FROM products
ORDER BY name_length DESC, product_id
LIMIT 10;

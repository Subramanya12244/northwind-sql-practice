/* =====================================================================
   Q195 · Product Names With Three Or More Words
   Category : String Functions (Splitting Text into Words)     Difficulty : Medium
   Concepts : REGEXP_SPLIT_TO_ARRAY · ARRAY_LENGTH · UNNEST · TRIM · Scalar subquery
   ---------------------------------------------------------------------
   PROBLEM : For each product whose name has at least three words, show the word count and its longest word (ties broken alphabetically), most words first.
   APPROACH:
     1. REGEXP_SPLIT_TO_ARRAY(TRIM(product_name), '\s+') gives the words as an array.
     2. ARRAY_LENGTH(..., 1) counts them; keep names with 3 or more.
     3. A scalar subquery UNNESTs the array and picks the longest word.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT product_id,
       product_name,
       ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY(TRIM(product_name), '\s+'), 1) AS word_count,
       (SELECT w FROM UNNEST(REGEXP_SPLIT_TO_ARRAY(TRIM(product_name), '\s+')) AS w
        ORDER BY LENGTH(w) DESC, w LIMIT 1)                               AS longest_word
FROM products
WHERE ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY(TRIM(product_name), '\s+'), 1) >= 3
ORDER BY word_count DESC, product_id;

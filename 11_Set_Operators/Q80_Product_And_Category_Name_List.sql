/* =====================================================================
   Q80 · Product and Category Name List
   Category : Set Operators (UNION)     Difficulty : Easy
   Concepts : UNION · Set Operators
   ---------------------------------------------------------------------
   PROBLEM : Return one column of all product names and all category names
             combined into a single unified list, with duplicates removed.
   APPROACH:
     1. SELECT product_name FROM products — all 77 product names.
     2. UNION SELECT category_name FROM categories — all 8 category names.
     3. UNION removes any duplicate values across both sets.
     4. Output column is labelled product_name (from the FIRST SELECT);
        alias the first column to override it.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select p.product_name from products p
union
select c.category_name from categories c;

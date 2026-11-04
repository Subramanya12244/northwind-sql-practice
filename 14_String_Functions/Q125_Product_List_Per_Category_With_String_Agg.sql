/* =====================================================================
   Q125 · Product List Per Category With String Agg
   Category : String Functions (Aggregation)     Difficulty : Medium
   Concepts : STRING_AGG · ORDER BY inside aggregate · JOIN · GROUP BY · COUNT
   ---------------------------------------------------------------------
   PROBLEM : For each category, return the number of non-discontinued products and an alphabetical comma-separated list of their names.
   APPROACH:
     1. Join categories to products and keep discontinued = false.
     2. Group by category.
     3. STRING_AGG(product_name, ', ' ORDER BY product_name) builds the list; COUNT(*) counts.
     4. Order by category_name.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    c.category_name,
    COUNT(*)                                             AS product_count,
    STRING_AGG(p.product_name, ', ' ORDER BY p.product_name) AS product_list
FROM categories c
JOIN products p ON p.category_id = c.category_id
WHERE p.discontinued = false
GROUP BY c.category_id, c.category_name
ORDER BY c.category_name;

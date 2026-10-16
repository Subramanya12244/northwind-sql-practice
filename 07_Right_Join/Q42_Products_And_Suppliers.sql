/* =====================================================================
   Q42 · Products and Suppliers
   Category : RIGHT JOIN          Difficulty : Easy
   Concepts : RIGHT JOIN · NULL Handling
   ---------------------------------------------------------------------
   PROBLEM : Return all products with their supplier name, preserving
             every product even if it has no matching supplier (NULL if none).
   APPROACH:
     1. Place suppliers on the LEFT, products on the RIGHT.
     2. RIGHT JOIN preserves every product regardless of a matching supplier.
     3. For unmatched products, supplier_name is NULL.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    p.product_name,
    s.company_name AS supplier_name
FROM suppliers s
RIGHT JOIN products p
    ON p.supplier_id = s.supplier_id;

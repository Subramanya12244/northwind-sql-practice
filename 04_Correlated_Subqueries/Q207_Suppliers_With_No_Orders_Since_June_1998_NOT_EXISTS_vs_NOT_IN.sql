/* =====================================================================
   Q207 · Suppliers With No Orders Since June 1998 (NOT EXISTS vs NOT IN)
   Category : Correlated Subqueries (Anti-Join, NULL-Safe)     Difficulty : Hard
   Concepts : NOT EXISTS · Anti-join · NOT IN NULL trap · Multi-table correlated subquery · Sargable date filter
   ---------------------------------------------------------------------
   PROBLEM : List suppliers none of whose products appear on an order dated on or after 1998-06-01, by supplier id.
   APPROACH:
     1. For each supplier, look for any order line of their products with order_date >= '1998-06-01'.
     2. Keep suppliers where that search finds nothing (NOT EXISTS).
     3. Order by supplier_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT s.supplier_id, s.company_name
FROM suppliers s
WHERE NOT EXISTS (
    SELECT 1
    FROM products p
    JOIN order_details d ON d.product_id = p.product_id
    JOIN orders o ON o.order_id = d.order_id
    WHERE p.supplier_id = s.supplier_id
      AND o.order_date >= DATE '1998-06-01'
)
ORDER BY s.supplier_id;

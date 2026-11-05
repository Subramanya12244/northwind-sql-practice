/* =====================================================================
   Q194 · Customers Whose Every Order Shipped On Time
   Category : Correlated Subqueries (Universal Condition with NOT EXISTS)     Difficulty : Medium
   Concepts : NOT EXISTS · Correlated subquery · Universal quantification · NULL handling
   ---------------------------------------------------------------------
   PROBLEM : List customers with at least one order where none of their orders is unshipped or shipped after its required date, with their number of orders, most orders first.
   APPROACH:
     1. Join customers to their orders and group, so customers without orders drop out.
     2. WHERE NOT EXISTS (an order of this customer that is unshipped OR shipped later than required).
     3. Order by order count, then customer_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT c.customer_id, c.company_name, COUNT(*) AS shipped_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o2
    WHERE o2.customer_id = c.customer_id
      AND (o2.shipped_date IS NULL OR o2.shipped_date > o2.required_date)
)
GROUP BY c.customer_id, c.company_name
ORDER BY shipped_orders DESC, c.customer_id;

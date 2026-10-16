/* =====================================================================
   Q41 · Customers and Orders
   Category : RIGHT JOIN          Difficulty : Easy
   Concepts : RIGHT JOIN · NULL Handling
   ---------------------------------------------------------------------
   PROBLEM : Return all orders and their customer name, preserving every
             order even if it has no matching customer (NULL if none).
   APPROACH:
     1. Place customers on the LEFT, orders on the RIGHT.
     2. RIGHT JOIN preserves every order regardless of a matching customer.
     3. For unmatched orders, contact_name is NULL.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT o.order_id, c.contact_name
FROM customers c
RIGHT JOIN orders o ON o.customer_id = c.customer_id;

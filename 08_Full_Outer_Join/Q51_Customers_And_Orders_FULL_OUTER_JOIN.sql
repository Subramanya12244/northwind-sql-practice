/* =====================================================================
   Q51 · Customers and Orders (FULL OUTER JOIN)
   Category : FULL OUTER JOIN        Difficulty : Medium
   Concepts : FULL OUTER JOIN · NULL Handling
   ---------------------------------------------------------------------
   PROBLEM : Return the customer name and order ID for every customer and
             every order — no row from either table should be excluded.
   APPROACH:
     1. FULL OUTER JOIN customers to orders on customer_id.
     2. Matched rows: customer has at least one order — both sides populated.
     3. Left-only rows: customer has no orders — order_id is NULL.
     4. Right-only rows: order has no matching customer — contact_name is NULL.
   MISTAKES I MADE:
     • none — clean on first attempt
   ---------------------------------------------------------------------
   NOTE: FULL OUTER JOIN = LEFT JOIN UNION RIGHT JOIN (equivalent, less
   efficient) for engines without native FULL OUTER JOIN support.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select c.contact_name, o.order_id
from customers c
full outer join orders o on o.customer_id = c.customer_id;

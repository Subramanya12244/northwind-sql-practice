/* =====================================================================
   Q55 · Customers and Total Orders (FULL OUTER JOIN)
   Category : FULL OUTER JOIN        Difficulty : Hard
   Concepts : FULL OUTER JOIN · GROUP BY · COUNT · NULL Handling
              · NULL grouping behaviour
   ---------------------------------------------------------------------
   PROBLEM : Return all customers and their total order count, including
             customers with no orders (0) and a row for orphaned orders
             with no matching customer (NULL contact_name).
   APPROACH:
     1. FULL OUTER JOIN customers to orders on customer_id.
     2. COUNT(o.order_id) per customer — returns 0 for no-order customers
        and the orphaned-order count for the NULL group.
     3. GROUP BY c.customer_id, c.contact_name — both required.
   MISTAKES I MADE:
     • none — clean on first attempt
   ---------------------------------------------------------------------
   KEY BEHAVIOUR:
     • COUNT(o.order_id) → 0 for no-order customers; COUNT(*) → 1 (wrong,
       counts the NULL-padded row).
     • GROUP BY groups all NULL customer_id rows together → exactly ONE
       orphaned-order row (NULL = NULL is TRUE for GROUP BY, FALSE for WHERE).
   Compare Q25 (LEFT JOIN) which cannot surface the orphaned-order row.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select c.contact_name,
count(o.order_id) as total_orders
from customers c
full outer join orders o on o.customer_id = c.customer_id
group by c.customer_id, c.contact_name;

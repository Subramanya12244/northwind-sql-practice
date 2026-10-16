/* =====================================================================
   Q45 · Customers and Total Revenue
   Category : RIGHT JOIN          Difficulty : Medium
   Concepts : RIGHT JOIN (chained, two levels) · GROUP BY · SUM
              · NULL Handling (COALESCE) · ROUND/CAST
   ---------------------------------------------------------------------
   PROBLEM : Return all customers with total discounted revenue, showing
             0.00 for customers with no orders.
   APPROACH:
     1. Chain order_details -> orders -> customers (customers = rightmost,
        the preserved entity).
     2. Both joins RIGHT JOIN so customers is preserved all the way through.
     3. SUM(quantity*unit_price*(1-discount)); COALESCE NULL -> 0.
     4. Cast to numeric, ROUND to 2 dp; GROUP BY contact_name, customer_id.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    c.contact_name,
    COALESCE(
        ROUND(
            SUM(od.quantity * od.unit_price * (1 - od.discount))::numeric,
            2
        ),
        0
    ) AS total_revenue
FROM order_details od
RIGHT JOIN orders o
    ON o.order_id = od.order_id
RIGHT JOIN customers c
    ON c.customer_id = o.customer_id
GROUP BY c.contact_name, c.customer_id;

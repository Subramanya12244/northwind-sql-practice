/* =====================================================================
   Q104 · Days Until Next Customer Order
   Category : Window Functions (Offset)     Difficulty : Medium
   Concepts : LEAD · PARTITION BY · Date Arithmetic · Named WINDOW
   ---------------------------------------------------------------------
   PROBLEM : For each order, return the same customer's next order ID, its date, and the number of days between the two (NULL if there is no next order).
   APPROACH:
     1. Define WINDOW w AS (PARTITION BY customer_id ORDER BY order_date, order_id).
     2. Use LEAD(order_id) and LEAD(order_date) over w.
     3. Subtract order_date from the lead date to get days (date − date = integer).
     4. Order by customer, date, order_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    customer_id,
    order_id,
    order_date,
    LEAD(order_id)   OVER w AS next_order_id,
    LEAD(order_date) OVER w AS next_order_date,
    LEAD(order_date) OVER w - order_date AS days_until_next_order
FROM orders
WINDOW w AS (PARTITION BY customer_id ORDER BY order_date, order_id)
ORDER BY customer_id, order_date, order_id;

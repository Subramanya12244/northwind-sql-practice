/* =====================================================================
   Q123 · Split Contact Name Into First And Last
   Category : String Functions (Splitting)     Difficulty : Medium
   Concepts : SPLIT_PART · POSITION · SUBSTRING · LENGTH
   ---------------------------------------------------------------------
   PROBLEM : For customers in Germany, split contact_name into first_name and last_name and show the position of the first space.
   APPROACH:
     1. Find the first space with POSITION(' ' IN contact_name).
     2. SPLIT_PART(contact_name, ' ', 1) gives the first word.
     3. SUBSTRING(contact_name FROM space_pos + 1) keeps the rest, including multi-word surnames.
     4. Filter to Germany and order by customer_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    customer_id,
    contact_name,
    POSITION(' ' IN contact_name)                           AS space_pos,
    SPLIT_PART(contact_name, ' ', 1)                        AS first_name,
    SUBSTRING(contact_name FROM POSITION(' ' IN contact_name) + 1) AS last_name
FROM customers
WHERE country = 'Germany'
ORDER BY customer_id;

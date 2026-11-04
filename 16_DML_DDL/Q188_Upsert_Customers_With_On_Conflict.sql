/* =====================================================================
   Q188 · Upsert Customers With On Conflict
   Category : DML (UPSERT)     Difficulty : Hard
   Concepts : INSERT … ON CONFLICT · DO UPDATE · EXCLUDED · RETURNING · xmax
   ---------------------------------------------------------------------
   PROBLEM : Upsert ALFKI (new city Hamburg, postal code 20095) and a new customer ZZTOP (ZZ Top Traders, contact Billy Gibbons, Houston, 77002, USA). Return each row and whether it was inserted or updated. Runs inside BEGIN … ROLLBACK, so the data change is undone after grading.
   APPROACH:
     1. INSERT INTO customers (...) VALUES (...), (...).
     2. ON CONFLICT (customer_id) DO UPDATE SET city = EXCLUDED.city, postal_code = EXCLUDED.postal_code.
     3. RETURNING ..., CASE WHEN xmax = 0 THEN 'inserted' ELSE 'updated' END.
     4. Wrap in a CTE and order by customer_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH upserted AS (
    INSERT INTO customers (customer_id, company_name, contact_name, city, postal_code, country)
    VALUES ('ALFKI', 'Alfreds Futterkiste', 'Maria Anders',  'Hamburg', '20095', 'Germany'),
           ('ZZTOP', 'ZZ Top Traders',      'Billy Gibbons', 'Houston', '77002', 'USA')
    ON CONFLICT (customer_id) DO UPDATE
        SET city        = EXCLUDED.city,
            postal_code = EXCLUDED.postal_code
    RETURNING customer_id, company_name, city, postal_code,
              CASE WHEN xmax = 0 THEN 'inserted' ELSE 'updated' END AS action
)
SELECT customer_id, company_name, city, postal_code, action
FROM upserted
ORDER BY customer_id;

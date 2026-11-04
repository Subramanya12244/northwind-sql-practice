/* =====================================================================
   Q184 · Insert New Shipper With Returning
   Category : DML (INSERT … RETURNING)     Difficulty : Easy
   Concepts : INSERT · RETURNING · SERIAL Default · Multi-row VALUES
   ---------------------------------------------------------------------
   PROBLEM : Insert shippers Speedy Freight (phone (503) 555-0101) and Polar Logistics (phone (503) 555-0102) and return the new rows. Runs inside BEGIN … ROLLBACK, so the data change is undone after grading.
   APPROACH:
     1. INSERT INTO shippers (company_name, phone) VALUES (...), (...) — omit the id.
     2. Add RETURNING shipper_id, company_name, phone.
     3. Wrap in a CTE and SELECT ... ORDER BY shipper_id so the output order is guaranteed.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH new_shippers AS (
    INSERT INTO shippers (company_name, phone)
    VALUES ('Speedy Freight',  '(503) 555-0101'),
           ('Polar Logistics', '(503) 555-0102')
    RETURNING shipper_id, company_name, phone
)
SELECT shipper_id, company_name, phone
FROM new_shippers
ORDER BY shipper_id;

/* =====================================================================
   Q84 · Master Company Directory
   Category : Set Operators (UNION — three-way, schema-aware)  Difficulty : Medium
   Concepts : UNION (three-way) · Set Operators · Literal String Columns · Schema Awareness
   ---------------------------------------------------------------------
   PROBLEM : Return a unified Master Company Directory combining company
             names, countries, and entity-type labels from customers,
             suppliers, and shippers.
   APPROACH:
     1. Schema check: customers & suppliers have company_name + country;
        shippers has company_name but NO country column.
     2. SELECT 1 — customers: company_name, country, 'Customer'.
     3. SELECT 2 — suppliers: company_name, country, 'Supplier'.
     4. SELECT 3 — shippers: company_name, 'N/A' placeholder, 'Shipper'.
     5. Three-way UNION combines all three and deduplicates.
   MISTAKES I MADE:
     • First column aliased as 'Name' instead of 'Company_Name' (and country
       not aliased 'Country') → output headers didn't match the required
       Company_Name / Country → fix: alias the FIRST SELECT's columns.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (buggy: output labels Name/country, not Company_Name/Country) ──
-- select c.company_name as Name,
-- c.country,
-- 'Customer' as Entity_Type
-- from customers c
-- Union
-- select s.company_name as Name,
-- s.country,
-- 'Supplier' as Entity_Type
-- from suppliers s
-- union
-- select sh.company_name as Name,
-- 'N/A' as country,
-- 'Shipper' as Entity_Type
-- from shippers sh;

-- ── FINAL CORRECT SOLUTION (first SELECT aliases set the output names) ──
SELECT c.company_name AS Company_Name, c.country AS Country, 'Customer' AS Entity_Type
FROM customers c
UNION
SELECT s.company_name, s.country, 'Supplier'
FROM suppliers s
UNION
SELECT sh.company_name, 'N/A', 'Shipper'
FROM shippers sh;

/*
Question:
Return every unique pair of products that share the same `supplier_id`, along with that supplier ID. Exclude self-pairs and duplicate pairs.

Business Requirement:
Retrieve pairs of products supplied by the same supplier.

Approach:
See markdown file for full reasoning. Key points:



-- Attempt 1 — Missing same-supplier condition (Cartesian product):
-- Reason it fails: Pairs every product with every other product — a Cartesian product. Missing `AND p1.supplier_id = p2.supplier_id`.
--
-- 
select p1.product_name as Product_1_Name,-- p2.product_name as Product_2_Name,-- p1.supplier_id-- from products p1-- join products p2-- on p1.product_id < p2.product_id  -- ❌ missing: AND p1.supplier_id = p2.supplier_id

Expected Output:
| product_1_name | product_2_name | supplier_id |
|----------------|----------------|-------------|
| Chai | Chang | 1 |
| Chai | Aniseed Syrup | 1 |

Concepts Used:
- SELF JOIN
- INNER JOIN
- Duplicate pair elimination (id < id)

Score: 8.5/10
Takeaway: Always ask 'what does same mean?' — the answer goes in the second condition of the ON clause.

Complexity:
Easy
*/

SELECT
    p1.product_name AS product_1_name,
    p2.product_name AS product_2_name,
    p1.supplier_id
FROM products p1
JOIN products p2
    ON p1.product_id < p2.product_id
    AND p1.supplier_id = p2.supplier_id;

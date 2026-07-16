# Q54. Suppliers and Products (FULL OUTER JOIN)

**Category:** FULL OUTER JOIN
**Difficulty:** Medium

---

## Problem Statement

Generate a report showing all suppliers and all products. The report should include suppliers who supply products, suppliers who do not supply any products, and products that are not assigned to any supplier.

## Objective

Return the supplier name and product name — no supplier and no product should be excluded from the result.

## Tables Used

- `suppliers`
- `products`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| company_name | Name of the supplier (NULL if the product has no matching supplier) |
| product_name | Name of the product (NULL if the supplier has no products) |

**Sample output:**

| company_name | product_name |
|--------------|--------------|
| Exotic Liquids | Chai |
| Grandma Kelly's Homestead | Northwoods Cranberry Sauce |
| Supplier X | NULL |
| NULL | Product Y |

*(In standard Northwind, all products have a valid supplier and all suppliers have at least one product — the NULL rows demonstrate FULL OUTER JOIN behaviour for data quality scenarios.)*

## Concepts Used

- FULL OUTER JOIN
- NULL Handling

## Why This Approach

**Why FULL OUTER JOIN:** the three row types required are:
1. A supplier-product pair where both exist and are linked — both sides populated
2. A supplier with no products (`product_name = NULL`)
3. A product with no matching supplier (`company_name = NULL`)

`LEFT JOIN suppliers → products` would miss type 3 (supplier-less products). `RIGHT JOIN` would miss type 2 (product-less suppliers). `FULL OUTER JOIN` captures all three.

**Practical use case:** this report is directly useful after a supplier migration or data import. If new products arrive before their supplier records are created, they show as `NULL | product_name` rows. If supplier records are created before their first products are added, they show as `company_name | NULL` rows. `FULL OUTER JOIN` flags both anomaly types in one query.

**Structural pattern across Q51–Q54:** all four questions in this section follow the identical structure:

```sql
SELECT <left_display_col>, <right_display_col>
FROM <table_A>
FULL OUTER JOIN <table_B> ON <shared_key>;
```

The only thing that changes per question is which tables and which display columns. The `FULL OUTER JOIN` logic — both sides preserved, NULLs on unmatched sides — is the same in every case.

## Common Mistakes

- Using `INNER JOIN`, which drops both unmatched suppliers and unmatched products entirely.
- Using `LEFT JOIN suppliers → products`, which correctly shows supplier-less products as NULLs but completely drops product-less suppliers.
- Assuming that if standard Northwind has no NULL rows in practice, the `FULL OUTER JOIN` was unnecessary — the join type is chosen for correctness by design, not for whether the current dataset happens to have gaps.

## Difficulty

**Medium**

## Interview Follow-up Questions

**1. Across Q51–Q54, all four queries share the same FULL OUTER JOIN structure. What is the single rule that determines when to use FULL OUTER JOIN?**

Use `FULL OUTER JOIN` whenever the requirement says "show everything from both tables" or "no row from either side should be missing." Specifically: if missing a row from the left would be a problem, `LEFT JOIN` isn't enough. If missing a row from the right would also be a problem, `RIGHT JOIN` isn't enough either. When both conditions apply simultaneously, `FULL OUTER JOIN` is the only correct choice. In practice, `FULL OUTER JOIN` is most commonly used for reconciliation reports, data quality audits, and comparing two independent datasets.

**2. How would you find only the anomalous rows — suppliers with no products AND products with no supplier — in one query?**

```sql
SELECT s.company_name, p.product_name
FROM suppliers s
FULL OUTER JOIN products p ON p.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL   -- products with no supplier
   OR p.product_id IS NULL;   -- suppliers with no products
```

**3. How would you extend this to also show the count of products per supplier, including suppliers with zero products and a row for supplier-less products?**

```sql
SELECT
    s.company_name,
    COUNT(p.product_id) AS product_count
FROM suppliers s
FULL OUTER JOIN products p ON p.supplier_id = s.supplier_id
GROUP BY s.supplier_id, s.company_name
ORDER BY product_count DESC;
```

`COUNT(p.product_id)` returns 0 for suppliers with no products (NULL product_id not counted). Supplier-less products are grouped under a single NULL-supplier row with their count. The `FULL OUTER JOIN` ensures neither side loses rows.

**4. In your Northwind ER diagram, both `categories` and `suppliers` link to `products`. How would a three-way FULL OUTER JOIN look — products, categories, and suppliers all reconciled together?**

Three-way `FULL OUTER JOIN` chains work the same way:

```sql
SELECT
    p.product_name,
    c.category_name,
    s.company_name AS supplier_name
FROM products p
FULL OUTER JOIN categories c ON c.category_id = p.category_id
FULL OUTER JOIN suppliers s ON s.supplier_id = p.supplier_id;
```

Each `FULL OUTER JOIN` in the chain preserves unmatched rows from that step. A product with no category and no supplier would appear with NULLs in both `category_name` and `supplier_name`. An empty category would appear with NULL for `product_name` and `supplier_name`. This is a complete three-way reconciliation in a single query.

## Learning Outcomes

- Confirm the `FULL OUTER JOIN` structural template: identical across Q51–Q54, transferable to any two-table reconciliation requirement.
- Know the decision rule: when neither table can lose rows in the output, `FULL OUTER JOIN` is the only correct join type.
- Understand how `FULL OUTER JOIN` chains extend naturally to three or more tables, with each additional `FULL OUTER JOIN` preserving unmatched rows from that table.

---

📄 **SQL File:** [`Q54_Suppliers_And_Products_FULL_OUTER_JOIN.sql`](./Q54_Suppliers_And_Products_FULL_OUTER_JOIN.sql)

# Q68. Products with the Same Supplier

**Category:** SELF JOIN
**Difficulty:** Easy

---

## Problem Statement

Retrieve pairs of products supplied by the same supplier.

## Objective

Return every unique pair of products that share the same `supplier_id`, along with that supplier ID. Exclude self-pairs and duplicate pairs.

## Tables Used

- `products (aliased twice: p1, p2)`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| product_1_name | Name of the first product in the pair |
| product_2_name | Name of the second product in the pair |
| supplier_id | The shared supplier ID |

**Sample output:**

| product_1_name | product_2_name | supplier_id |
|----------------|----------------|-------------|
| Chai | Chang | 1 |
| Chai | Aniseed Syrup | 1 |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## Concepts Used

- SELF JOIN
- INNER JOIN
- Duplicate pair elimination (id < id)

## Why This Approach

**Why the standard pair pattern applies:** `ON p1.product_id < p2.product_id AND p1.supplier_id = p2.supplier_id` — `<` deduplicates, `supplier_id =` defines the "same supplier" condition. The template is unchanged from Q66/Q67.

**What "same" means here:** two products share the same supplier when `p1.supplier_id = p2.supplier_id`. Without this condition, the join pairs every product with every other product that also satisfies the `<` condition — a Cartesian product over all products, which is not what the question asks.

### ❌ Attempt 1 — Missing same-supplier condition (Cartesian product):

```sql
select p1.product_name as Product_1_Name,
p2.product_name as Product_2_Name,
p1.supplier_id
from products p1
join products p2
on p1.product_id < p2.product_id  -- ❌ missing: AND p1.supplier_id = p2.supplier_id
```

**Why it fails:** Pairs every product with every other product — a Cartesian product. Missing `AND p1.supplier_id = p2.supplier_id`.


## Common Mistakes

- **Attempt 1 — Missing the 'same supplier' condition:** `on p1.product_id < p2.product_id  -- ❌ only deduplicates, does not filter by supplier` — Without `p1.supplier_id = p2.supplier_id`, every product is paired with every other product (where p1.id < p2.id) — a full Cartesian product. The 'same supplier' condition is what makes this a meaningful business query.

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. What happens if you only write `ON p1.product_id < p2.product_id` without the supplier condition?**

You get every possible unique product pair — a Cartesian product restricted only by the `<` condition. For a catalog with 77 products, this produces 77 × 76 / 2 = 2,926 rows, with no regard for whether they share a supplier. Adding `AND p1.supplier_id = p2.supplier_id` filters to only the pairs where both products come from the same supplier — the actual business requirement.

**2. How would you extend this to also show the supplier's company name?**

Join the `suppliers` table: `SELECT p1.product_name, p2.product_name, s.company_name FROM products p1 JOIN products p2 ON p1.product_id < p2.product_id AND p1.supplier_id = p2.supplier_id JOIN suppliers s ON s.supplier_id = p1.supplier_id`. Since `p1.supplier_id = p2.supplier_id`, joining on `p1.supplier_id` is sufficient.

**3. How would you find suppliers who supply more than 3 products without using a SELF JOIN?**

`SELECT supplier_id, COUNT(*) AS product_count FROM products GROUP BY supplier_id HAVING COUNT(*) > 3`. The SELF JOIN is only needed when the output requires showing actual product pairs, not just supplier-level counts.

**4. The mistake in Attempt 1 produced a Cartesian product. How would you detect this in a real query?**

Check the row count of the result against expectations. For 77 products, `p1.product_id < p2.product_id` alone produces 2,926 pairs — far more than the number of same-supplier pairs. Any time a SELF JOIN produces significantly more rows than expected, the first thing to check is whether the 'same' condition is missing from the join.

## Learning Outcomes

- Understand that `t1.id < t2.id` alone is insufficient — it deduplicates but does not filter. The 'same column' condition is what makes the query meaningful.
- Always ask 'what does same mean here?' before writing the join condition — the answer determines the second part of the ON clause.

---

**Score from review session: 8.5/10**

**Interview Takeaway:** Always ask 'what does same mean?' — the answer goes in the second condition of the ON clause.

📄 **SQL File:** [`Q68_Products_with_the_Same_Supplier.sql`](./Q68_Products_with_the_Same_Supplier.sql)

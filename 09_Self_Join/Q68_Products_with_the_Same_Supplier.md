# Q68 · Products with the Same Supplier

> **Revision Card**
> **Category:** Self Join | **Difficulty:** Easy
> **Concepts:** SELF JOIN · INNER JOIN · duplicate-pair elimination (`id < id`)
> **Outcome:** ⚠️ had mistakes (see §4)
> **Watch out for:** `id < id` only deduplicates — without the `p1.supplier_id = p2.supplier_id` condition you get a Cartesian product.

## 1. Problem

Retrieve pairs of products supplied by the same supplier.

**Objective:** Return every unique pair of products that share the same `supplier_id`, along with that supplier ID. Exclude self-pairs and duplicate pairs.

**Tables:** `products` (aliased twice: `p1`, `p2`)

**Expected output:**

| Column | Description |
|---|---|
| product_1_name | Name of the first product in the pair |
| product_2_name | Name of the second product in the pair |
| supplier_id | The shared supplier ID |

| product_1_name | product_2_name | supplier_id |
|----------------|----------------|-------------|
| Chai | Chang | 1 |
| Chai | Aniseed Syrup | 1 |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## 2. My Approach

1. Self-join `products p1` to `products p2`.
2. Use `p1.product_id < p2.product_id` to drop self/duplicate pairs.
3. Restrict to the same supplier with `p1.supplier_id = p2.supplier_id`.
4. Select both product names and the shared supplier ID.

## 3. My Solution (as submitted)

```sql
-- First attempt: missing the same-supplier condition → Cartesian product
SELECT p1.product_name AS product_1_name,
       p2.product_name AS product_2_name,
       p1.supplier_id
FROM products p1
JOIN products p2
    ON p1.product_id < p2.product_id;   -- missing AND p1.supplier_id = p2.supplier_id
```

## 4. Mistakes I Made

- ⚠️ **Missing the "same supplier" condition:** the join had only `p1.product_id < p2.product_id`, which deduplicates but does not filter → every product was paired with every other product (a Cartesian product restricted only by `<`). → Fix: add `AND p1.supplier_id = p2.supplier_id` — the condition that makes it a meaningful business query.

## 5. Correct / Optimal Solution

```sql
SELECT p1.product_name AS product_1_name,
       p2.product_name AS product_2_name,
       p1.supplier_id
FROM products p1
JOIN products p2
    ON p1.product_id < p2.product_id
    AND p1.supplier_id = p2.supplier_id;
```

## 6. Why This Works

**Why the standard pair pattern applies:** `ON p1.product_id < p2.product_id AND p1.supplier_id = p2.supplier_id` — `<` deduplicates, `supplier_id =` defines the "same supplier" condition. The template is unchanged from Q66/Q67.

**What "same" means here:** two products share the same supplier when `p1.supplier_id = p2.supplier_id`. Without this condition, the join pairs every product with every other product that also satisfies the `<` condition — a Cartesian product over all products, which is not what the question asks.

## 7. Common Pitfalls (generic)

- Writing only `t1.id < t2.id` and omitting the "same" condition — deduplicates but does not filter, producing a Cartesian product.
- Not sanity-checking the result row count — an unexpectedly large count is the tell-tale sign of a missing join condition.
- Using `<>` instead of `<` — keeps both (A,B) and (B,A).

## 8. Interview Follow-ups

**1. What happens if you only write `ON p1.product_id < p2.product_id` without the supplier condition?**

You get every possible unique product pair — a Cartesian product restricted only by the `<` condition. For a catalog with 77 products, this produces 77 × 76 / 2 = 2,926 rows, with no regard for whether they share a supplier. Adding `AND p1.supplier_id = p2.supplier_id` filters to only the pairs where both products come from the same supplier — the actual business requirement.

**2. How would you extend this to also show the supplier's company name?**

Join the `suppliers` table: `SELECT p1.product_name, p2.product_name, s.company_name FROM products p1 JOIN products p2 ON p1.product_id < p2.product_id AND p1.supplier_id = p2.supplier_id JOIN suppliers s ON s.supplier_id = p1.supplier_id`. Since `p1.supplier_id = p2.supplier_id`, joining on `p1.supplier_id` is sufficient.

**3. How would you find suppliers who supply more than 3 products without using a SELF JOIN?**

`SELECT supplier_id, COUNT(*) AS product_count FROM products GROUP BY supplier_id HAVING COUNT(*) > 3`. The SELF JOIN is only needed when the output requires showing actual product pairs, not just supplier-level counts.

**4. The mistake in Attempt 1 produced a Cartesian product. How would you detect this in a real query?**

Check the row count of the result against expectations. For 77 products, `p1.product_id < p2.product_id` alone produces 2,926 pairs — far more than the number of same-supplier pairs. Any time a SELF JOIN produces significantly more rows than expected, the first thing to check is whether the 'same' condition is missing from the join.

## 9. Key Takeaway

`t1.id < t2.id` alone only deduplicates — always ask "what does *same* mean here?" and put that equality as the second condition of the ON clause, or you get a Cartesian product.

---
📄 **SQL File:** [`Q68_Products_with_the_Same_Supplier.sql`](./Q68_Products_with_the_Same_Supplier.sql)

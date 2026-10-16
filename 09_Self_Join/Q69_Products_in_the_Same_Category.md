# Q69 · Products in the Same Category

> **Revision Card**
> **Category:** Self Join | **Difficulty:** Easy
> **Concepts:** SELF JOIN · INNER JOIN · LEFT JOIN (name lookup) · duplicate-pair elimination (`id < id`)
> **Outcome:** ⚠️ had mistakes (see §4)
> **Watch out for:** `id < id` alone is a Cartesian product — the `p1.category_id = p2.category_id` condition is the essential filter.

## 1. Problem

Retrieve pairs of products belonging to the same category.

**Objective:** Return every unique pair of products that share the same `category_id`, along with the category name. Exclude self-pairs and duplicate pairs.

**Tables:** `products` (aliased twice: `p1`, `p2`), `categories`

**Expected output:**

| Column | Description |
|---|---|
| product_1_name | Name of the first product in the pair |
| product_2_name | Name of the second product in the pair |
| category_name | Name of the shared category |

| product_1_name | product_2_name | category_name |
|----------------|----------------|---------------|
| Chai | Chang | Beverages |
| Chai | Guaraná Fantástica | Beverages |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## 2. My Approach

1. Self-join `products p1` to `products p2`.
2. Use `p1.product_id < p2.product_id` to drop self/duplicate pairs and `p1.category_id = p2.category_id` to restrict to the same category.
3. `LEFT JOIN categories` on `p1.category_id` to fetch the category name (not present on `products`).
4. Select both product names and the category name.

## 3. My Solution (as submitted)

```sql
-- First attempt: missing the same-category condition → Cartesian product
SELECT p1.product_name AS product_1_name,
       p2.product_name AS product_2_name,
       c.category_name
FROM products p1
JOIN products p2
    ON p1.product_id < p2.product_id   -- missing AND p1.category_id = p2.category_id
LEFT JOIN categories c ON c.category_id = p1.category_id;
```

## 4. Mistakes I Made

- ⚠️ **Missing the "same category" condition:** the join had only `p1.product_id < p2.product_id`, so every product was paired with every other product — a Cartesian product (same class of mistake as Q68). → Fix: add `AND p1.category_id = p2.category_id` as the essential filter.

## 5. Correct / Optimal Solution

```sql
SELECT p1.product_name AS product_1_name,
       p2.product_name AS product_2_name,
       c.category_name
FROM products p1
JOIN products p2
    ON p1.product_id < p2.product_id
    AND p1.category_id = p2.category_id
LEFT JOIN categories c ON c.category_id = p1.category_id;
```

## 6. Why This Works

**Why an additional `LEFT JOIN categories`:** unlike Q64–Q68 where the display value (`title`, `country`, `city`, `supplier_id`) was directly available on the self-joined table, the question asks for `category_name` — which lives in the `categories` table, not `products`. A third join on `categories c ON c.category_id = p1.category_id` is needed to fetch the name. Since `p1.category_id = p2.category_id`, joining on `p1.category_id` is sufficient.

**Why `LEFT JOIN` for categories:** `INNER JOIN` would also work here since every product in Northwind has a valid category. `LEFT JOIN` is slightly more defensive — it preserves product pairs even if their `category_id` somehow has no matching category row, displaying NULL for `category_name` in that edge case rather than dropping the pair entirely.

**Why the same-category condition is essential:** without `p1.category_id = p2.category_id`, the `<` condition alone pairs every product with every other product — a Cartesian product, not the intended "same category" result.

## 7. Common Pitfalls (generic)

- Omitting the `p1.category_id = p2.category_id` condition — `id < id` alone produces a Cartesian product.
- Forgetting the extra lookup join when the required display value (e.g. category name) lives in a separate table rather than on the self-joined table.
- Joining the lookup table redundantly on both `p1` and `p2` — joining once on `p1.category_id` is sufficient because the two are equal.

## 8. Interview Follow-ups

**1. This question adds a `LEFT JOIN categories` on top of the SELF JOIN. When is a third table join needed in a SELF JOIN pair query?**

When the display value you need for a shared attribute is a description or name stored in a separate lookup table, rather than the raw ID or value already on the self-joined table. In Q66–Q68, the shared values (`country`, `city`, `supplier_id`) were directly selectable from `p1` or `c1`. Here, `category_id` is on both `p1` and `p2`, but the required output is `category_name`, which only exists in `categories`. The join to `categories` is purely for display — the deduplication and filtering logic is handled entirely by the SELF JOIN.

**2. Why join `categories` on `p1.category_id` rather than `p2.category_id`?**

Since the SELF JOIN condition `p1.category_id = p2.category_id` guarantees both are equal, joining on either produces the same result. Convention is to use `p1` (the 'first' alias) — `c.category_id = p1.category_id` — for consistency and readability.

**3. How would you further extend this to show the category's description alongside the name?**

Simply add `c.description` to the SELECT list — it's already available once the `LEFT JOIN categories c` is in place: `SELECT p1.product_name, p2.product_name, c.category_name, c.description FROM products p1 JOIN products p2 ON p1.product_id < p2.product_id AND p1.category_id = p2.category_id LEFT JOIN categories c ON c.category_id = p1.category_id`.

**4. How many same-category product pairs exist in Northwind, and how would you count them per category?**

`SELECT c.category_name, COUNT(*) AS pair_count FROM products p1 JOIN products p2 ON p1.product_id < p2.product_id AND p1.category_id = p2.category_id LEFT JOIN categories c ON c.category_id = p1.category_id GROUP BY c.category_name ORDER BY pair_count DESC`.

## 9. Key Takeaway

Reuse `id < id AND category = category`, and add a lookup join only when the display value (the name) isn't already on the self-joined table.

---
📄 **SQL File:** [`Q69_Products_in_the_Same_Category.sql`](./Q69_Products_in_the_Same_Category.sql)

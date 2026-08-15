# Q69. Products in the Same Category

**Category:** SELF JOIN
**Difficulty:** Easy

---

## Problem Statement

Retrieve pairs of products belonging to the same category.

## Objective

Return every unique pair of products that share the same `category_id`, along with the category name. Exclude self-pairs and duplicate pairs.

## Tables Used

- `products (aliased twice: p1, p2)`
- `categories`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| product_1_name | Name of the first product in the pair |
| product_2_name | Name of the second product in the pair |
| category_name | Name of the shared category |

**Sample output:**

| product_1_name | product_2_name | category_name |
|----------------|----------------|---------------|
| Chai | Chang | Beverages |
| Chai | Guaraná Fantástica | Beverages |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## Concepts Used

- SELF JOIN
- INNER JOIN
- LEFT JOIN (to lookup category name)
- Duplicate pair elimination (id < id)

## Why This Approach

**Why an additional `LEFT JOIN categories`:** unlike Q64–Q68 where the display value (`title`, `country`, `city`, `supplier_id`) was directly available on the self-joined table, the question asks for `category_name` — which lives in the `categories` table, not `products`. A third join on `categories c ON c.category_id = p1.category_id` is needed to fetch the name. Since `p1.category_id = p2.category_id`, joining on `p1.category_id` is sufficient.

**Why `LEFT JOIN` for categories:** `INNER JOIN` would also work here since every product in Northwind has a valid category. `LEFT JOIN` is slightly more defensive — it preserves product pairs even if their `category_id` somehow has no matching category row, displaying NULL for `category_name` in that edge case rather than dropping the pair entirely.

### ❌ Attempt 1 — Missing same-category condition:

```sql
select p1.product_name as Product_1_Name,
p2.product_name as Product_2_Name,
c.category_name
from products p1
join products p2
on p1.product_id < p2.product_id
left join categories c on c.category_id = p1.category_id
```

**Why it fails:** Missing `AND p1.category_id = p2.category_id` — pairs every product with every other product.


## Common Mistakes

- **Attempt 1 — Missing same-category condition:** `from products p1
join products p2
on p1.product_id < p2.product_id
-- ❌ missing: AND p1.category_id = p2.category_id` — Same mistake as Q68 — `id < id` alone pairs every product with every other product. `AND p1.category_id = p2.category_id` is the essential filter.

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. This question adds a `LEFT JOIN categories` on top of the SELF JOIN. When is a third table join needed in a SELF JOIN pair query?**

When the display value you need for a shared attribute is a description or name stored in a separate lookup table, rather than the raw ID or value already on the self-joined table. In Q66–Q68, the shared values (`country`, `city`, `supplier_id`) were directly selectable from `p1` or `c1`. Here, `category_id` is on both `p1` and `p2`, but the required output is `category_name`, which only exists in `categories`. The join to `categories` is purely for display — the deduplication and filtering logic is handled entirely by the SELF JOIN.

**2. Why join `categories` on `p1.category_id` rather than `p2.category_id`?**

Since the SELF JOIN condition `p1.category_id = p2.category_id` guarantees both are equal, joining on either produces the same result. Convention is to use `p1` (the 'first' alias) — `c.category_id = p1.category_id` — for consistency and readability.

**3. How would you further extend this to show the category's description alongside the name?**

Simply add `c.description` to the SELECT list — it's already available once the `LEFT JOIN categories c` is in place: `SELECT p1.product_name, p2.product_name, c.category_name, c.description FROM products p1 JOIN products p2 ON p1.product_id < p2.product_id AND p1.category_id = p2.category_id LEFT JOIN categories c ON c.category_id = p1.category_id`.

**4. How many same-category product pairs exist in Northwind, and how would you count them per category?**

`SELECT c.category_name, COUNT(*) AS pair_count FROM products p1 JOIN products p2 ON p1.product_id < p2.product_id AND p1.category_id = p2.category_id LEFT JOIN categories c ON c.category_id = p1.category_id GROUP BY c.category_name ORDER BY pair_count DESC`.

## Learning Outcomes

- Know when a third table join is needed alongside a SELF JOIN — when the shared attribute's display name lives in a separate lookup table.
- Confirm that joining the lookup table on `p1.column` is correct and sufficient since `p1.column = p2.column` is already guaranteed by the SELF JOIN condition.

---

**Score from review session: 10/10**

**Interview Takeaway:** Pattern: `id < id AND category = category`. Join a lookup table only when the display value (name) isn't already on the self-joined table.

📄 **SQL File:** [`Q69_Products_in_the_Same_Category.sql`](./Q69_Products_in_the_Same_Category.sql)

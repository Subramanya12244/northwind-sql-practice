# Q122 · Longest Product Names

> **Revision Card**
> **Category:** String Functions (Length) | **Difficulty:** Easy
> **Concepts:** LENGTH · CHAR_LENGTH · ORDER BY · LIMIT
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Ties on length are common, so add a unique tie-breaker after `name_length DESC`.

## 1. Problem

The web team's product cards truncate long names. They want the ten longest product names so they can design the card for the worst case.

**Objective:** Return the 10 products with the longest `product_name`, with the character count.

**Tables:** `products`

**Expected output:**

| Column | Description |
|--------|-------------|
| product_id | Product identifier |
| product_name | Product name |
| name_length | Number of characters in the name |

| product_id | product_name | name_length |
|------------|--------------|-------------|
| 65 | Louisiana Fiery Hot Pepper Sauce | 32 |
| 7 | Uncle Bob's Organic Dried Pears | 31 |
| 41 | Jack's New England Clam Chowder | 31 |
| 77 | Original Frankfurter grüne Soße | 31 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Compute `LENGTH(product_name)`.
2. Sort by length descending, then `product_id` to break ties.
3. Keep the first 10 rows with `LIMIT`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    product_id,
    product_name,
    LENGTH(product_name) AS name_length
FROM products
ORDER BY name_length DESC, product_id
LIMIT 10;
```

## 6. Why This Works

`LENGTH(text)` (same as `CHAR_LENGTH`) counts characters, not bytes, so accented names like `Côte de Blaye` are counted correctly. Sorting by the computed alias is allowed in `ORDER BY`, and the `product_id` tie-breaker makes the top-10 cut deterministic.

## 7. Common Pitfalls (generic)

- Using `OCTET_LENGTH`, which counts bytes and over-counts multi-byte characters.
- No tie-breaker: products with equal length can swap places between runs, changing which rows make the cut.
- Trailing spaces in `CHAR(n)` columns are ignored by `LENGTH` — not an issue for `VARCHAR`.

## 8. Interview Follow-ups

**1. How would you return all products tied at the 10th length?**

Use `DENSE_RANK() OVER (ORDER BY LENGTH(product_name) DESC)` in a CTE and filter `<= 10`, or `FETCH FIRST 10 ROWS WITH TIES`.

**2. How do you count words in a name?**

`ARRAY_LENGTH(STRING_TO_ARRAY(product_name, ' '), 1)` or `LENGTH(name) - LENGTH(REPLACE(name, ' ', '')) + 1`.

**3. Bytes vs characters?**

`OCTET_LENGTH('Côte')` is 5 while `LENGTH('Côte')` is 4, because `ô` takes two bytes in UTF-8.

## 9. Key Takeaway

`LENGTH` counts characters; always pair a computed sort key with a unique tie-breaker before `LIMIT`.

---
📄 **SQL File:** [`Q122_Longest_Product_Names.sql`](./Q122_Longest_Product_Names.sql)

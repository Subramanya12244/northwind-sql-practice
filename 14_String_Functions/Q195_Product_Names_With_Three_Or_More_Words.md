# Q195 · Product Names With Three Or More Words

> **Revision Card**
> **Category:** String Functions (Splitting Text into Words) | **Difficulty:** Medium
> **Concepts:** REGEXP_SPLIT_TO_ARRAY · ARRAY_LENGTH · UNNEST · TRIM · Scalar subquery
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Split on '\s+' (one or more whitespace characters), not ' ', or double spaces create empty words.

## 1. Problem

The catalogue team is shortening long product names for a mobile app and wants to see which names have three or more words, and the longest word in each.

**Objective:** For each product whose name has at least three words, show the word count and its longest word (ties broken alphabetically), most words first.

**Tables:** `products`

**Expected output:**

| Column | Description |
|--------|-------------|
| product_id | Product |
| product_name | Name |
| word_count | Number of words |
| longest_word | Longest word in the name |

| product_id | product_name | word_count | longest_word |
|------------|--------------|------------|--------------|
| 7 | Uncle Bob's Organic Dried Pears | 5 | Organic |
| 41 | Jack's New England Clam Chowder | 5 | Chowder |
| 65 | Louisiana Fiery Hot Pepper Sauce | 5 | Louisiana |
| 4 | Chef Anton's Cajun Seasoning | 4 | Seasoning |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. REGEXP_SPLIT_TO_ARRAY(TRIM(product_name), '\s+') gives the words as an array.
2. ARRAY_LENGTH(..., 1) counts them; keep names with 3 or more.
3. A scalar subquery UNNESTs the array and picks the longest word.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT product_id,
       product_name,
       ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY(TRIM(product_name), '\s+'), 1) AS word_count,
       (SELECT w FROM UNNEST(REGEXP_SPLIT_TO_ARRAY(TRIM(product_name), '\s+')) AS w
        ORDER BY LENGTH(w) DESC, w LIMIT 1)                               AS longest_word
FROM products
WHERE ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY(TRIM(product_name), '\s+'), 1) >= 3
ORDER BY word_count DESC, product_id;
```

## 6. Why This Works

Regular-expression splitting handles any run of whitespace in one go, and TRIM removes leading or trailing spaces that would otherwise create empty first or last elements. UNNEST turns the array back into rows so ordinary ORDER BY and LIMIT can pick the longest word.

## 7. Common Pitfalls (generic)

- Splitting on a single space, which counts double spaces as an extra empty word.
- Using LENGTH(product_name) - LENGTH(REPLACE(product_name, ' ', '')) + 1, which miscounts with repeated spaces.
- Writing '\\s+' in a standard string: with standard_conforming_strings on, that is a literal backslash, not whitespace.

## 8. Interview Follow-ups

**1. How would you count how often each word appears across all products?**

SELECT word, COUNT(*) FROM products, REGEXP_SPLIT_TO_TABLE(product_name, '\s+') AS word GROUP BY word ORDER BY 2 DESC.

**2. How would you keep only the first two words?**

ARRAY_TO_STRING((REGEXP_SPLIT_TO_ARRAY(TRIM(product_name), '\s+'))[1:2], ' ').

**3. What about punctuation such as apostrophes?**

Remove or normalise it first with REGEXP_REPLACE(product_name, '[^[:alnum:][:space:]]', '', 'g').

## 9. Key Takeaway

REGEXP_SPLIT_TO_ARRAY plus UNNEST turns text into words you can count, sort and filter with normal SQL.

---
📄 **SQL File:** [`Q195_Product_Names_With_Three_Or_More_Words.sql`](./Q195_Product_Names_With_Three_Or_More_Words.sql)

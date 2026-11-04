# 🗂️ Flashcards — Northwind SQL Practice

A single-page revision deck for all **133 questions**. Each card shows the **question**, the
**core answer/approach**, any **mistake** I made, and the **one-line learning**.

> **How to use:** click a card to expand the answer. Try to recall the approach *before*
> expanding. ⚠️ cards are ones where I slipped up — revisit those first.

Jump to: [01 Aggregations](#01--aggregations) ·
[02 GROUP BY/HAVING](#02--group-by--having) ·
[03 Category & Product](#03--category--product-analytics) ·
[04 Correlated Subqueries](#04--correlated-subqueries) ·
[05 CTEs](#05--common-table-expressions-ctes) ·
[06 LEFT JOIN](#06--left-join) ·
[07 RIGHT JOIN](#07--right-join) ·
[08 FULL OUTER JOIN](#08--full-outer-join) ·
[09 SELF JOIN](#09--self-join) ·
[10 CROSS JOIN](#10--cross-join) ·
[11 Set Operators](#11--set-operators) ·
[12 Window Functions](#12--window-functions) ·
[13 Date & Time](#13--date--time) ·
[14 String Functions](#14--string-functions) ·
[15 CASE & Conditional](#15--case--conditional-logic) ·
[16 DML & DDL](#16--dml--ddl)

---

## 01 · Aggregations

<details>
<summary><strong>Q01 · Product Revenue</strong> — Easy — INNER JOIN · GROUP BY · SUM · ROUND/CAST</summary>

**Q:** Calculate total discounted revenue per product, where revenue = `unit_price * quantity * (1 - discount)`.

**A:** `JOIN products → order_details` on `product_id`, `SUM` the per-line discounted revenue, `GROUP BY product_id, product_name`, `ORDER BY total_revenue DESC`. Use `order_details.unit_price` (price at sale), not `products.unit_price`.

**⚠️ Mistake:** — (solved correctly on first attempt)

**💡 Learning:** Transactional point-in-time price fields differ from current catalog price — always aggregate historical revenue from the transaction-level price, and every non-aggregated column must appear in `GROUP BY`.

</details>

<details>
<summary><strong>Q02 · Category Revenue</strong> — Easy — INNER JOIN (multi-table) · GROUP BY · SUM</summary>

**Q:** Calculate total discounted revenue per product category.

**A:** Join `categories → products → order_details` (products is the bridge, as `order_details` has no `category_id`), `SUM` the discounted revenue, `GROUP BY category_id, category_name`, order descending.

**⚠️ Mistake:** — (solved correctly on first attempt)

**💡 Learning:** When two tables share no direct foreign key, route through the intermediate bridge table — and keep applying the transaction-level revenue formula at whatever grain you aggregate.

</details>

<details>
<summary><strong>Q03 · Top 10 Customers by Revenue</strong> — Easy — INNER JOIN (multi-table) · GROUP BY · SUM · ORDER BY · LIMIT</summary>

**Q:** Identify the 10 customers with the highest total discounted revenue across all orders.

**A:** Join `customers → orders → order_details`, `SUM` discounted revenue, `GROUP BY` customer, `ORDER BY total_revenue DESC` then `LIMIT 10` (sort before limit).

**⚠️ Mistake:** — (solved correctly on first attempt)

**💡 Learning:** For deterministic top-N reporting, always `ORDER BY` before `LIMIT`, and reach for window ranking when ties must be preserved.

</details>

<details>
<summary><strong>Q04 · Top 5 Employees by Revenue</strong> — Easy — INNER JOIN (multi-table) · GROUP BY · SUM · ORDER BY · LIMIT</summary>

**Q:** Identify the 5 employees who generated the highest total discounted revenue across orders they processed.

**A:** Join `employees → orders → order_details`, `SUM` discounted revenue, `GROUP BY employee_id, first_name, last_name`, order descending, `LIMIT 5`.

**⚠️ Mistake:** — (solved correctly on first attempt)

**💡 Learning:** Group by the stable key (`employee_id`), not display attributes — and remember `INNER JOIN` quietly drops zero-activity rows.

</details>

<details>
<summary><strong>Q05 · Top 5 Customers by Number of Orders</strong> — Easy — INNER JOIN · GROUP BY · COUNT · ORDER BY · LIMIT</summary>

**Q:** Identify the 5 customers who placed the highest number of distinct orders.

**A:** Join `customers → orders`, `COUNT(DISTINCT order_id)` per customer, `GROUP BY` customer, `ORDER BY order_count DESC`, `LIMIT 5`.

**⚠️ Mistake:** — (solved correctly on first attempt)

**💡 Learning:** Separate frequency metrics from value metrics, and use `COUNT(DISTINCT ...)` defensively in joins that may later fan out to a finer grain.

</details>

---

## 02 · GROUP BY & HAVING

<details>
<summary><strong>Q06 · Customers Above Average Revenue</strong> — Medium — INNER JOIN · GROUP BY · CTE · SUM/AVG · Scalar Subquery</summary>

**Q:** Return all customers whose total lifetime revenue is strictly greater than the average total revenue across all customers.

**A:** Build a CTE of per-customer `SUM(unit_price*quantity*(1-discount))`, then filter where `total_revenue > (SELECT AVG(total_revenue) FROM customer_revenue)` — the CTE is referenced twice (list rows + compute global average).

**⚠️ Mistake:** —

**💡 Learning:** 'Above average' needs two passes — aggregate per entity first, then aggregate across entities; the CTE materializes that set for both display and comparison.

</details>

<details>
<summary><strong>Q07 · Employees Above Average Revenue</strong> — Medium — INNER JOIN · GROUP BY · CTE · SUM/AVG · Scalar Subquery</summary>

**Q:** Return all employees whose total revenue exceeds the average total revenue computed across all employees.

**A:** Same CTE + scalar-subquery-average pattern as Q6, but group `employees` by `employee_id` and join on `orders.employee_id`; filter `total_revenue > (SELECT AVG(total_revenue) FROM employee_revenue)`.

**⚠️ Mistake:** —

**💡 Learning:** Reuse the 'CTE + scalar subquery average comparison' pattern across entities — only the base table and key change, the structure transfers directly.

</details>

<details>
<summary><strong>Q08 · Customers Above Average Order Count</strong> — Medium — INNER JOIN · GROUP BY · CTE · COUNT/AVG · Scalar Subquery</summary>

**Q:** Return all customers whose order count exceeds the average order count per customer.

**A:** CTE counting `COUNT(o.order_id)` per customer, then filter `order_count > (SELECT AVG(order_count) FROM customer_orders)` — same pattern as Q6/Q7 with COUNT instead of SUM.

**⚠️ Mistake:** —

**💡 Learning:** The above-average pattern works for any aggregate (swap SUM for COUNT); watch how INNER vs LEFT JOIN shifts the computed average by excluding/including zero-order customers.

</details>

---

## 03 · Category & Product Analytics

<details>
<summary><strong>Q09 · Top Categories by Number of Orders</strong> — Medium — INNER JOIN · GROUP BY · COUNT(DISTINCT) · LIMIT</summary>

**Q:** Find the 5 categories that appear in the highest number of distinct orders.

**A:** Join categories→products→order_details→orders, then `COUNT(DISTINCT o.order_id)` per category, order desc, LIMIT 5.

**⚠️ Mistake:** —

**💡 Learning:** Know when `COUNT(DISTINCT)` is required vs merely a safety habit — fan-out through `order_details` can multiply an order's contribution.

</details>

<details>
<summary><strong>Q10 · Customers Purchasing from Most Categories</strong> — Medium — INNER JOIN · GROUP BY · COUNT(DISTINCT) · LIMIT</summary>

**Q:** Find the 10 customers who have purchased from the most distinct product categories.

**A:** Join customers→orders→order_details→products, `COUNT(DISTINCT p.category_id)` per customer, order desc, LIMIT 10.

**⚠️ Mistake:** —

**💡 Learning:** Distinguish breadth metrics (distinct count of a dimension) from volume metrics (raw counts/sums), and trace the full multi-hop join.

</details>

<details>
<summary><strong>Q11 · Revenue by Shipper</strong> — Easy — INNER JOIN · GROUP BY · SUM</summary>

**Q:** Calculate total discounted order revenue handled by each shipping company.

**A:** Join shippers→orders on `ship_via = shipper_id`→order_details, `SUM(unit_price*quantity*(1-discount))` per shipper.

**⚠️ Mistake:** —

**💡 Learning:** Joining through a differently-named FK (`ship_via` vs `shipper_id`) is routine; always confirm "revenue" means order value, not freight cost.

</details>

<details>
<summary><strong>Q12 · Employees by Unique Customers Served</strong> — Easy — INNER JOIN · GROUP BY · COUNT(DISTINCT)</summary>

**Q:** Count how many unique customers each employee has served, ranked high to low.

**A:** Join employees→orders, `COUNT(DISTINCT o.customer_id)` per employee, order desc.

**⚠️ Mistake:** —

**💡 Learning:** Relationship-breadth metrics (unique customer count) answer a different question than volume/value metrics — reach for `COUNT(DISTINCT)` for distinct relationships.

</details>

<details>
<summary><strong>Q13 · Products Sold Above Category Average Quantity</strong> — Hard — CTE · GROUP BY · AVG · Window Functions · Compare-to-peer-group</summary>

**Q:** Find products whose total quantity sold exceeds the average of per-product totals within their own category.

**A:** CTE sums qty per product; second CTE averages those per category; join on category_id and filter `total_qty > avg`. Or `AVG(SUM(qty)) OVER (PARTITION BY category_id)` in one pass.

**⚠️ Mistake:** —

**💡 Learning:** Multi-level aggregation (averaging an aggregate up to a coarser grain) powers the "compare to peer-group average" pattern; a window function collapses it into one pass.

</details>

<details>
<summary><strong>Q14 · Highest Revenue Product per Category</strong> — Hard — CTE · RANK · PARTITION BY · SUM · Tie Handling</summary>

**Q:** For each category return the product(s) with the highest revenue, including all ties for first.

**A:** CTE sums revenue per product; `RANK() OVER (PARTITION BY category_id ORDER BY total_revenue DESC)`; filter `rnk = 1`.

**⚠️ Mistake:** —

**💡 Learning:** For "top N per group with correct tie handling", `RANK() OVER (PARTITION BY ...)` filtered on `rnk = 1` keeps every tied winner — know how RANK/DENSE_RANK/ROW_NUMBER differ.

</details>

---

## 04 · Correlated Subqueries

<details>
<summary><strong>Q15 · Customers Above Average Orders (Correlated Subquery)</strong> — Medium — INNER JOIN · GROUP BY · HAVING · non-correlated subquery · COUNT/AVG</summary>

**Q:** Return customers whose order count exceeds the average order count across all customers, using a subquery referenced inside `HAVING`.

**A:** Join `customers` to `orders`, `COUNT(order_id)` per customer, and compare in `HAVING` against a subquery that averages a derived table of per-customer counts. The subquery is non-correlated — it yields one global average.

**⚠️ Mistake:** —

**💡 Learning:** Distinguish correlated from non-correlated by whether the inner query references an outer-row column; and aggregates can't be nested — average a derived table of per-group counts instead.

</details>

<details>
<summary><strong>Q16 · Customers Above Average Revenue (Correlated Subquery)</strong> — Medium — INNER JOIN (multi) · GROUP BY · HAVING · non-correlated subquery · SUM/AVG</summary>

**Q:** Return customers whose total discounted revenue exceeds the average revenue across all customers, using `HAVING` + a subquery instead of a CTE.

**A:** Join `customers`/`orders`/`order_details`, `SUM(unit_price*quantity*(1-discount))` per customer, and compare in `HAVING` to a subquery that recomputes revenue per customer and averages it. The revenue formula is duplicated in both layers.

**⚠️ Mistake:** —

**💡 Learning:** A `HAVING` + subquery can replace a CTE for 'above average' filters, but it forces you to duplicate the revenue logic — a real maintainability cost that usually favors the CTE.

</details>

<details>
<summary><strong>Q17 · Employees Above Average Revenue (Correlated Subquery)</strong> — Medium — INNER JOIN (multi) · GROUP BY · HAVING · non-correlated subquery · SUM/AVG</summary>

**Q:** Return employees whose total revenue exceeds the average revenue across all employees, via `HAVING` and a nested subquery.

**A:** Structurally identical to Q16 but on `employees`/`orders`/`order_details`, grouped by `employee_id`. The inner subquery recomputes per-employee revenue over all employees and averages it into one company-wide figure.

**⚠️ Mistake:** —

**💡 Learning:** The subquery-vs-CTE 'above average' pattern transfers directly from customers to employees — group by the stable key (`employee_id`) and watch the duplicated revenue formula.

</details>

<details>
<summary><strong>Q18 · Customer Revenue Above Employee Average</strong> — Hard — CTE · Correlated Subquery · GROUP BY · SUM/AVG</summary>

**Q:** For each employee, return the customers whose revenue (from that employee's orders) exceeds the average revenue across that same employee's own customer base.

**A:** A CTE pre-aggregates revenue per employee-customer pair; the outer query filters with a correlated subquery whose `WHERE ecr2.employee_id = ecr.employee_id` makes the average per-employee rather than global.

**⚠️ Mistake:** —

**💡 Learning:** A correlated subquery references an outer-row column and re-evaluates per row — here it yields a per-employee average; pre-aggregate into a CTE first to keep it cheap and readable.

</details>

---

## 05 · Common Table Expressions (CTEs)

<details>
<summary><strong>Q19 · Customers Above Average Revenue Using CTE</strong> — Medium — CTE (multiple) · INNER JOIN · GROUP BY · SUM/AVG · implicit cross join</summary>

**Q:** Using one CTE for per-customer revenue and a second CTE for the overall average, return customers whose revenue exceeds that average.

**A:** `customer_revenue` aggregates discounted revenue per customer; `overall_avg` computes a single `AVG(total_revenue)`; the final query comma-joins them (`FROM customer_revenue cr, overall_avg oa`) and filters `cr.total_revenue > oa.avg_revenue`.

**⚠️ Mistake:** —

**💡 Learning:** Compose CTEs so one holds detail and another a single benchmark; an implicit cross join safely broadcasts a one-row scalar across every detail row.

</details>

<details>
<summary><strong>Q20 · Top 5 Customers by Revenue Using CTE</strong> — Easy — CTE · INNER JOIN · GROUP BY · SUM · ORDER BY · LIMIT</summary>

**Q:** Use a CTE to compute per-customer revenue, then return the top 5 customers by revenue.

**A:** `customer_revenue` aggregates discounted revenue per customer; the outer query does `SELECT * ... ORDER BY total_revenue DESC LIMIT 5`.

**⚠️ Mistake:** —

**💡 Learning:** CTEs are mainly a readability/composability tool, not a performance win for simple single-use cases — the foundational pattern Q21–Q24 build on.

</details>

<details>
<summary><strong>Q21 · Employees Above Average Revenue Using Multiple CTEs</strong> — Medium — CTE (multiple) · INNER JOIN (non-equality) · GROUP BY · SUM/AVG</summary>

**Q:** Compute employee revenue in one CTE, the average in a second, and join them using the comparison itself as the join condition.

**A:** `employee_revenue` aggregates per employee; `avg_revenue` returns the single average; join with `ON er.total_revenue > ar.avg_rev` so the inequality acts as the filter.

**⚠️ Mistake:** —

**💡 Learning:** `JOIN ... ON` accepts arbitrary boolean conditions, not just equality — but `ON >` is safe only when the right side is guaranteed single-row.

</details>

<details>
<summary><strong>Q22 · Top Employee by Revenue Using 3 CTEs</strong> — Medium — CTE (chained) · GROUP BY · SUM/MAX · Tie Handling · INNER JOIN</summary>

**Q:** Find the single highest-revenue employee company-wide, returning all employees if tied for first.

**A:** Chain three CTEs: `employee_revenue` (aggregate), `max_revenue` (`MAX(total_revenue)` scalar), `ranked_employees` (join on `total_revenue = max_rev`); final SELECT rounds revenue.

**⚠️ Mistake:** —

**💡 Learning:** For 'top 1 with ties', compare against `MAX()` (not `LIMIT 1`) so every tied row surfaces; give each CTE one clear job — aggregate, reduce, filter.

</details>

<details>
<summary><strong>Q23 · Best Customer per Employee</strong> — Hard — CTE · Window (RANK) · PARTITION BY · GROUP BY · SUM · Tie Handling · INNER JOIN</summary>

**Q:** For every employee, return the customer(s) generating the most revenue from orders that employee handled, keeping ties.

**A:** `employee_customer_revenue` aggregates per employee-customer pair; `ranked` applies `RANK() OVER (PARTITION BY employee_id ORDER BY total_revenue DESC)`; filter `rnk = 1` and join employees/customers for names.

**⚠️ Mistake:** —

**💡 Learning:** 'Best X per Y' = partitioned window ranking (`RANK() OVER (PARTITION BY Y ORDER BY metric DESC)`, filter `rnk = 1`); `RANK()` preserves ties and presentation joins belong after the windowing step.

</details>

<details>
<summary><strong>Q24 · Highest Revenue Product per Category (CTE + Window)</strong> — Hard — CTE (multiple) · Window (RANK) · PARTITION BY · GROUP BY · SUM · Tie Handling · INNER JOIN</summary>

**Q:** For every category, return the product(s) with the highest revenue, including all ties, with the category name shown.

**A:** `product_revenue` aggregates per product (keeping `category_id`); `ranked` applies `RANK() OVER (PARTITION BY category_id ORDER BY total_revenue DESC)`; filter `rnk = 1` and join `categories` for `category_name`.

**⚠️ Mistake:** —

**💡 Learning:** The 'top N per group with ties' window pattern transfers across entities; adding descriptive dimension columns after ranking improves readability without changing the result.

</details>

---

## 06 · LEFT JOIN

<details>
<summary><strong>Q25 · Customers and Order Count</strong> — Medium — LEFT JOIN · GROUP BY · COUNT · NULL Handling</summary>

**Q:** Return every customer with their order count, including customers with zero orders (shown as 0).

**A:** `customers LEFT JOIN orders`, then `COUNT(o.order_id)` grouped by customer — the LEFT JOIN keeps no-order customers and `COUNT(column)` reports 0 for them.

**⚠️ Mistake:** —

**💡 Learning:** Ask "should no-match rows still appear?" to choose LEFT vs INNER, and always count the joined column (`COUNT(o.order_id)`), never `COUNT(*)`.

</details>

<details>
<summary><strong>Q26 · Customers and Latest Order Date</strong> — Medium — LEFT JOIN · GROUP BY · MAX · NULL Handling · ORDER BY NULLS</summary>

**Q:** Return every customer with the date of their most recent order, showing NULL for never-ordered customers.

**A:** `customers LEFT JOIN orders` with `MAX(o.order_date)` grouped by customer; `ORDER BY latest_order_date DESC NULLS LAST` to keep never-ordered customers at the bottom.

**⚠️ Mistake:** —

**💡 Learning:** Most aggregates (except COUNT) propagate NULL correctly on their own, but you must set NULL sort position explicitly with `NULLS FIRST`/`NULLS LAST`.

</details>

<details>
<summary><strong>Q27 · Products and Total Quantity Sold</strong> — Medium — LEFT JOIN · GROUP BY · SUM · COALESCE · NULL Handling</summary>

**Q:** Return every product and total units sold, displaying 0 (not blank) for never-ordered products.

**A:** `products LEFT JOIN order_details` with `COALESCE(SUM(od.quantity), 0)` grouped by product — COALESCE converts the all-NULL-group NULL into 0.

**⚠️ Mistake:** —

**💡 Learning:** Know the difference between "NULL is the correct answer" (Q26) and "NULL must become a business default 0" — COALESCE is the tool for the latter over SUM.

</details>

<details>
<summary><strong>Q28 · Customers with No Orders</strong> — Easy — LEFT JOIN · NULL Handling · WHERE · NOT EXISTS</summary>

**Q:** Return only customers who have never placed any order.

**A:** `customers LEFT JOIN orders` then `WHERE o.order_id IS NULL` — the anti-join isolates customers with no matching order (or equivalently `NOT EXISTS`).

**⚠️ Mistake:** —

**💡 Learning:** Master the anti-join (`LEFT JOIN ... WHERE key IS NULL` or `NOT EXISTS`) for "find rows with no match"; avoid `NOT IN` when the subquery column can be NULL.

</details>

<details>
<summary><strong>Q29 · Products Never Ordered</strong> — Easy — LEFT JOIN · NULL Handling · WHERE · NOT EXISTS</summary>

**Q:** Return only products that have never appeared in any order.

**A:** `products LEFT JOIN order_details` then `WHERE od.order_id IS NULL` — same anti-join pattern as Q28, applied to products.

**⚠️ Mistake:** —

**💡 Learning:** The anti-join is about the pattern, not the tables — once learned on customers it transfers directly to products or any "entity with no matching child" question.

</details>

<details>
<summary><strong>Q30 · Products Never Ordered</strong> — Easy — LEFT JOIN · NULL Handling · WHERE · NOT EXISTS</summary>

**Q:** Return only products never ordered, filtering on the join-key column itself.

**A:** `products LEFT JOIN order_details ON p.product_id = od.product_id` then `WHERE od.product_id IS NULL` — filtering the right-hand join key, which mirrors the ON clause.

**⚠️ Mistake:** —

**💡 Learning:** Any right-hand column works in the `IS NULL` filter since an unmatched LEFT JOIN row NULL-pads them all — just never filter a left-side column, which can't be NULL for a real row.

</details>

<details>
<summary><strong>Q31 · Customers and Total Revenue</strong> — Medium — LEFT JOIN (chained) · GROUP BY · SUM · COALESCE · ROUND/CAST</summary>

**Q:** Return every customer and total discounted revenue, showing 0.00 for no-order customers.

**A:** Chain `customers LEFT JOIN orders LEFT JOIN order_details`, `COALESCE(ROUND(SUM(unit_price*quantity*(1-discount))::numeric,2),0)`, grouped by customer_id + contact_name.

**⚠️ Mistake:** —

**💡 Learning:** Every link in a chained LEFT JOIN must stay LEFT or no-match rows vanish downstream; SUM returns NULL for empty groups so COALESCE is always the fix for a zero default.

</details>

<details>
<summary><strong>Q32 · Customers and Distinct Products Purchased</strong> — Medium — LEFT JOIN (4-level) · GROUP BY · COUNT DISTINCT · NULL Handling</summary>

**Q:** Return every customer and the count of distinct products purchased, 0 for no-order customers.

**A:** Chain `customers → orders → order_details → products` all LEFT, then `COUNT(DISTINCT p.product_id)` grouped by customer — DISTINCT dedupes repeat purchases.

**⚠️ Mistake:** —

**💡 Learning:** Every link in a multi-table chain must stay LEFT; `COUNT(col)` vs `COUNT(DISTINCT col)` is the difference between counting occurrences and counting unique values.

</details>

<details>
<summary><strong>Q33 · Customers and Total Orders Shipped</strong> — Medium — LEFT JOIN (chained) · GROUP BY · COUNT · COALESCE</summary>

**Q:** Return every customer and the number of orders shipped to them, 0 for no-order customers.

**A:** `customers LEFT JOIN orders LEFT JOIN shippers`, `COUNT(o.order_id)` grouped by customer; to restrict to dispatched orders put `shipped_date IS NOT NULL` in the ON clause.

**⚠️ Mistake:** —

**💡 Learning:** Joins attach data, they don't filter rows — "has a shipper" ≠ "has been dispatched"; put filter conditions in ON (not WHERE) to keep no-order customers at 0.

</details>

<details>
<summary><strong>Q34 · Employees and Customers Served</strong> — Medium — LEFT JOIN · GROUP BY · COUNT DISTINCT · String Concat · NULL Handling</summary>

**Q:** Return every employee and the number of distinct customers served, 0 for those with no orders.

**A:** `employees LEFT JOIN orders`, `COUNT(DISTINCT o.customer_id)`, name via `first_name || ' ' || last_name`, grouped by employee_id.

**⚠️ Mistake:** —

**💡 Learning:** `COUNT(order_id)`, `COUNT(customer_id)`, and `COUNT(DISTINCT customer_id)` answer different questions — pick the one matching the grain, and group on the primary key.

</details>

<details>
<summary><strong>Q35 · Categories and Number of Products</strong> — Easy — LEFT JOIN · GROUP BY · COUNT · NULL Handling</summary>

**Q:** Return every category and its product count, 0 for empty categories.

**A:** `categories LEFT JOIN products` with `COUNT(p.product_id)` grouped by category — COUNT needs no COALESCE since it returns 0 for empty groups.

**⚠️ Mistake:** —

**💡 Learning:** Default to LEFT JOIN for "all X with their Y count" even when today's data has no empty groups, and count the joined column, never `COUNT(*)`.

</details>

<details>
<summary><strong>Q36 · Suppliers and Number of Products</strong> — Easy — LEFT JOIN · GROUP BY · COUNT · NULL Handling</summary>

**Q:** Return every supplier and the number of products they supply, 0 for suppliers with none.

**A:** `suppliers LEFT JOIN products` with `COUNT(p.product_id)` grouped by supplier — structurally identical to Q35.

**⚠️ Mistake:** —

**💡 Learning:** The `LEFT JOIN + COUNT(joined_column)` template transfers unchanged across any "all entities with their count" report — recognising identical queries saves re-deriving logic.

</details>

<details>
<summary><strong>Q37 · Employees and Total Revenue Generated</strong> — Medium — LEFT JOIN (chained) · GROUP BY · SUM · COALESCE · ROUND/CAST · CONCAT</summary>

**Q:** Return every employee and total revenue generated, 0.00 for those with no orders.

**A:** `employees LEFT JOIN orders LEFT JOIN order_details`, `COALESCE(ROUND(SUM(...)::numeric,2),0)`, name via `CONCAT`, grouped by employee_id.

**⚠️ Mistake:** —

**💡 Learning:** SUM needs COALESCE for empty-group NULLs while COUNT doesn't; `GROUP BY primary_key` suffices when display columns are wrapped in an expression like CONCAT (which also handles NULL names, unlike `||`).

</details>

<details>
<summary><strong>Q38 · Shippers and Total Orders Handled</strong> — Easy — LEFT JOIN · GROUP BY · COUNT · NULL Handling</summary>

**Q:** Return every shipping company and total orders handled, 0 for shippers with none.

**A:** `shippers LEFT JOIN orders ON o.ship_via = s.shipper_id` with `COUNT(o.order_id)` grouped by shipper — note the differently-named join columns.

**⚠️ Mistake:** —

**💡 Learning:** Reuse the LEFT JOIN + `COUNT(joined_column)` template across table pairs, and always qualify join columns with aliases so the query stays unambiguous as it grows.

</details>

<details>
<summary><strong>Q39 · Categories and Total Revenue</strong> — Medium — LEFT JOIN (chained) · GROUP BY · SUM · COALESCE · ROUND/CAST</summary>

**Q:** Return every category and total revenue from its products, 0.00 for categories with no sales.

**A:** `categories LEFT JOIN products LEFT JOIN order_details` (products is the bridge), `COALESCE(ROUND(SUM(...)::numeric,2),0)`, grouped by category.

**⚠️ Mistake:** —

**💡 Learning:** Revenue-by-dimension reports usually need a bridge table (products) to reach order_details; every link must stay LEFT, and SUM always needs COALESCE for a zero default.

</details>

<details>
<summary><strong>Q40 · Customers and Average Order Value</strong> — Hard — CTE · LEFT JOIN (chained) · GROUP BY (two levels) · SUM · AVG · COALESCE · ROUND/CAST</summary>

**Q:** Return every customer and their average order value, 0.00 for no-order customers.

**A:** CTE sums line items to per-order totals (`GROUP BY order_id`), then outer query `customers LEFT JOIN orders LEFT JOIN cte` with `AVG(total_revenue)` grouped by customer.

**⚠️ Mistake:** First averaged line items directly (wrong grain); second attempt used a global SUM CTE with no `order_id` key to join on.

**💡 Learning:** "Average order value" is two-level aggregation — sum line items to order totals first, then average those per customer; always ask "what is the correct grain?" before any `AVG()`.

</details>

---

## 07 · RIGHT JOIN

<details>
<summary><strong>Q41 · Customers and Orders</strong> — Easy — RIGHT JOIN · NULL Handling</summary>

**Q:** Return every order with its customer's contact name, keeping orders even if no matching customer exists.

**A:** `customers c RIGHT JOIN orders o ON o.customer_id = c.customer_id` — the right table (`orders`) is preserved; unmatched orders show NULL `contact_name`.

**⚠️ Mistake:** —

**💡 Learning:** RIGHT JOIN and LEFT JOIN are mirror images — the right table is preserved completely; swap table order to rewrite one as the other. Useful for surfacing orphaned records.

</details>

<details>
<summary><strong>Q42 · Products and Suppliers</strong> — Easy — RIGHT JOIN · NULL Handling</summary>

**Q:** Return every product with its supplier name, preserving products even without a matching supplier.

**A:** `suppliers s RIGHT JOIN products p ON p.supplier_id = s.supplier_id` — products (right table) all appear; `supplier_name` is NULL for orphans.

**⚠️ Mistake:** —

**💡 Learning:** The "preserve right table, look up from left" pattern fits any child-with-nullable-parent report; every RIGHT JOIN is interchangeable with a LEFT JOIN by reversing table order.

</details>

<details>
<summary><strong>Q43 · Employees and Orders</strong> — Easy — RIGHT JOIN · NULL Handling · CONCAT</summary>

**Q:** Return every order with the handling employee's full name, preserving orders with no matching employee.

**A:** `employees e RIGHT JOIN orders o ON o.employee_id = e.employee_id`, display name via `CONCAT(e.first_name,' ',e.last_name)`.

**⚠️ Mistake:** —

**💡 Learning:** PostgreSQL `CONCAT()` treats NULL inputs as empty strings (all-NULL → a space), whereas `||` propagates NULL through the whole expression.

</details>

<details>
<summary><strong>Q44 · Products and Total Quantity Sold</strong> — Medium — RIGHT JOIN · GROUP BY · SUM · COALESCE</summary>

**Q:** Return every product with total units sold, showing 0 for products never ordered.

**A:** `order_details od RIGHT JOIN products p ...`, `COALESCE(SUM(od.quantity),0)`, `GROUP BY p.product_name, p.product_id`.

**⚠️ Mistake:** —

**💡 Learning:** `SUM()` returns NULL (not 0) for empty groups, so always wrap in `COALESCE`; `COUNT` never needs it. Avoid `ROUND()` on integer columns.

</details>

<details>
<summary><strong>Q45 · Customers and Total Revenue</strong> — Medium — RIGHT JOIN (chained) · GROUP BY · SUM · COALESCE · ROUND/CAST</summary>

**Q:** Return every customer with total discounted revenue, 0.00 when they have no orders.

**A:** Chain `order_details od RIGHT JOIN orders o RIGHT JOIN customers c`; `COALESCE(ROUND(SUM(qty*price*(1-disc))::numeric,2),0)`.

**⚠️ Mistake:** —

**💡 Learning:** In a chained RIGHT JOIN the preserved entity is the rightmost table in the final join; making any step INNER drops the rows you meant to keep. `::numeric` cast is required before two-arg `ROUND()`.

</details>

<details>
<summary><strong>Q46 · Employees and Total Orders</strong> — Medium — RIGHT JOIN · GROUP BY · COUNT DISTINCT · CONCAT</summary>

**Q:** Return every employee with their count of distinct orders handled, 0 for none.

**A:** `orders o RIGHT JOIN employees e ...`, `COUNT(DISTINCT o.order_id)`, `GROUP BY e.employee_id, e.first_name, e.last_name`.

**⚠️ Mistake:** —

**💡 Learning:** `COUNT` returns 0 for empty groups (no COALESCE), but `COUNT(*)` counts the NULL-padded row as 1; use `COUNT(DISTINCT o.order_id)` to also guard against row multiplication from later joins.

</details>

<details>
<summary><strong>Q47 · Categories and Products</strong> — Easy — RIGHT JOIN · NULL Handling</summary>

**Q:** Return every product with its category name, preserving uncategorised products.

**A:** `categories c RIGHT JOIN products p ON p.category_id = c.category_id` — products (right table) all appear; `category_name` NULL when unmatched.

**⚠️ Mistake:** —

**💡 Learning:** Structurally identical to Q42 — recognise the "preserve child, look up parent name" template across different table pairs instead of treating each query as new.

</details>

<details>
<summary><strong>Q48 · Suppliers and Total Revenue</strong> — Medium — RIGHT JOIN (chained) · GROUP BY · SUM · COALESCE · ROUND/CAST</summary>

**Q:** Return every supplier with total revenue from their products, 0.00 when none sold.

**A:** Chain `order_details od RIGHT JOIN products p RIGHT JOIN suppliers s`; `COALESCE(ROUND(SUM(...)::numeric,2),0)`, `GROUP BY s.company_name, s.supplier_id`.

**⚠️ Mistake:** —

**💡 Learning:** In a three-table RIGHT JOIN chain the preserved entity is the rightmost, and every intermediate join must be RIGHT (an INNER step drops never-ordered products so their suppliers vanish). `A→B→C` mirrors the LEFT chain `C→B→A`.

</details>

<details>
<summary><strong>Q49 · Customers and Average Order Value</strong> — Hard — CTE · RIGHT JOIN (chained) · two-level GROUP BY · AVG · COALESCE</summary>

**Q:** Return every customer's average order value (sum per order, then average per customer), 0.00 for no-order customers. RIGHT JOIN only.

**A:** CTE sums revenue per order (`order_details RIGHT JOIN orders`); outer query `order_totals ot RIGHT JOIN customers c`, `COALESCE(ROUND(AVG(ot.order_revenue)::numeric,2),0)`.

**⚠️ Mistake:** Original chain `customers RIGHT JOIN orders RIGHT JOIN order_details` preserved order_details, not customers, so no-order customers were dropped; also selected `contact_name` without grouping it.

**💡 Learning:** Reversing table order in a RIGHT JOIN chain changes which entity is preserved (must be rightmost in the final join); two-level aggregation is mandatory regardless of join direction.

</details>

<details>
<summary><strong>Q50 · Top Customer(s) by Revenue — Tie-Safe</strong> — Hard — CTE · RIGHT JOIN · CROSS JOIN · MAX · tie handling</summary>

**Q:** Return the customer(s) with the highest total revenue, returning all of them when tied.

**A:** CTE `revenue` per customer, CTE `max_rev` = `MAX(total_revenue)`, then `CROSS JOIN` the one-row max onto revenue with `WHERE r.total_revenue >= m.max_rev`.

**⚠️ Mistake:** —

**💡 Learning:** Tie-safe "top N" uses a `MAX()` comparison (or `RANK()=1`), never `LIMIT` (which silently drops ties). A CROSS JOIN against a guaranteed one-row CTE is a clean scalar-broadcast, not an accidental Cartesian product.

</details>

---

## 08 · FULL OUTER JOIN

<details>
<summary><strong>Q51 · Customers and Orders (FULL OUTER JOIN)</strong> — Medium — FULL OUTER JOIN · NULL Handling</summary>

**Q:** List the customer name and order ID for every customer AND every order, keeping customers with no orders and orders with no customer.

**A:** `FULL OUTER JOIN customers c ... orders o ON o.customer_id = c.customer_id`, selecting `c.contact_name, o.order_id`. Produces three row types: matched, left-only (order_id NULL), right-only (contact_name NULL).

**⚠️ Mistake:** —

**💡 Learning:** FULL OUTER JOIN is the only join that preserves unmatched rows from both tables at once; it is logically equivalent to `LEFT JOIN UNION RIGHT JOIN`.

</details>

<details>
<summary><strong>Q52 · Products and Categories (FULL OUTER JOIN)</strong> — Medium — FULL OUTER JOIN · NULL Handling</summary>

**Q:** Show every product and every category, including uncategorised products and empty categories.

**A:** `FULL OUTER JOIN products p ... categories c ON c.category_id = p.category_id`, selecting `p.product_name, c.category_name`. Uncategorised products get NULL category_name; empty categories get NULL product_name.

**⚠️ Mistake:** —

**💡 Learning:** FULL OUTER JOIN is the standard catalog-reconciliation tool, surfacing matched, left-only and right-only rows in one pass; `LEFT JOIN UNION RIGHT JOIN` reproduces it where native support is missing.

</details>

<details>
<summary><strong>Q53 · Employees and Orders (FULL OUTER JOIN)</strong> — Medium — FULL OUTER JOIN · NULL Handling · CONCAT</summary>

**Q:** List every employee and every order, keeping employees with no orders and orders with no assigned employee.

**A:** `FULL OUTER JOIN orders o ... employees e ON e.employee_id = o.employee_id`, with `CONCAT(e.first_name,' ',e.last_name)` for the name and `o.order_id`.

**⚠️ Mistake:** —

**💡 Learning:** FULL OUTER JOIN is symmetric — table order never changes the result (unlike LEFT/RIGHT); and `CONCAT(NULL,' ',NULL)` yields `' '`, not NULL, so use `NULLIF()` for a clean NULL.

</details>

<details>
<summary><strong>Q54 · Suppliers and Products (FULL OUTER JOIN)</strong> — Medium — FULL OUTER JOIN · NULL Handling</summary>

**Q:** Show every supplier and every product, including suppliers with no products and products with no supplier.

**A:** `FULL OUTER JOIN suppliers s ... products p ON p.supplier_id = s.supplier_id`, selecting `s.company_name, p.product_name`.

**⚠️ Mistake:** —

**💡 Learning:** When neither table may lose rows, FULL OUTER JOIN is the only correct choice; the two-table reconciliation template is identical across Q51–Q54 and chains naturally to three or more tables.

</details>

<details>
<summary><strong>Q55 · Customers and Total Orders (FULL OUTER JOIN)</strong> — Hard — FULL OUTER JOIN · GROUP BY · COUNT · NULL grouping</summary>

**Q:** Count orders per customer, including customers with zero orders and a row for orphaned orders.

**A:** `COUNT(o.order_id)` over `customers FULL OUTER JOIN orders`, `GROUP BY c.customer_id, c.contact_name`. COUNT(column) gives 0 for no-order customers; all orphaned orders collapse into one NULL group.

**⚠️ Mistake:** —

**💡 Learning:** Prefer `COUNT(column)` over `COUNT(*)` so NULL-padded rows count as 0, and remember GROUP BY collapses all NULLs into exactly one orphaned-record row.

</details>

<details>
<summary><strong>Q56 · Products and Total Revenue (FULL OUTER JOIN)</strong> — Hard — FULL OUTER JOIN · SUM · COALESCE · ::numeric · NULL grouping</summary>

**Q:** Total revenue per product, including never-sold products (0.00) and orphaned order lines referencing non-existent products.

**A:** `COALESCE(ROUND(SUM((od.unit_price*od.quantity*(1-od.discount))::numeric),2),0)` over `products FULL OUTER JOIN order_details ON od.product_id = p.product_id`, grouped by product.

**⚠️ Mistake:** —

**💡 Learning:** FULL OUTER JOIN gives all three row types; COALESCE turns SUM()'s NULL into 0.00 for never-sold products, and ::numeric is required for 2-arg ROUND().

</details>

<details>
<summary><strong>Q57 · Employees and Total Revenue</strong> — Medium — Chained FULL OUTER JOIN · COALESCE · CONCAT vs || · ::numeric</summary>

**Q:** Total revenue per employee across employees→orders→order_details, keeping zero-revenue employees and unassigned orders (true NULL name).

**A:** Chain FULL OUTER JOIN at every step; use `e.first_name || ' ' || e.last_name` (not CONCAT) so the unassigned row is a true NULL; `COALESCE(ROUND(SUM(...::numeric),2),0)`.

**⚠️ Mistake:** Used `CONCAT()` which turns the NULL employee into `' '` (a space), not the NULL the spec requires — fix with `||`.

**💡 Learning:** Keep the join type consistent at every step of a chain; use `||` (propagates NULL) not `CONCAT()` (NULL→empty string) when a missing entity must appear as a true NULL.

</details>

<details>
<summary><strong>Q58 · Customer Revenue Comparison (Advanced)</strong> — Hard — Chained FULL OUTER JOIN · CTE · Tie-safe Top-N · COALESCE</summary>

**Q:** Reconcile customers→orders→order_details revenue, then return the customer(s) with the single highest revenue, ties included.

**A:** CTE `rev` aggregates revenue with chained FULL OUTER JOIN and COALESCE, then outer query filters `WHERE total_revenue >= (SELECT MAX(total_revenue) FROM rev)`.

**⚠️ Mistake:** —

**💡 Learning:** The tie-safe top-N pattern (`>= (SELECT MAX(...))`) beats `LIMIT 1`, and it is only trustworthy when the reconciliation is unbiased (FULL OUTER JOIN) and COALESCE keeps every value non-NULL/comparable.

</details>

---

## 09 · SELF JOIN

<details>
<summary><strong>Q61 · Employees Without a Manager</strong> — Easy — SELF JOIN · LEFT JOIN · NULL anti-join</summary>

**Q:** Return the full name of every employee who has no manager (no `reports_to`).

**A:** LEFT JOIN `employees e` to `employees m` on `e.reports_to = m.employee_id`, then filter `WHERE m.employee_id IS NULL` — the robust anti-join on the joined table's PK.

**⚠️ Mistake:** —

**💡 Learning:** Filter on the joined table's PK (`WHERE joined.pk IS NULL`), not the FK — it also catches orphaned `reports_to` references.

</details>

<details>
<summary><strong>Q62 · Employees Who Are Managers</strong> — Medium — SELF JOIN · GROUP BY · HAVING · COUNT</summary>

**Q:** Return the full name of every employee who manages at least one other employee.

**A:** Join `e` (managed) to `m` (manager) on `e.reports_to = m.employee_id`, `GROUP BY m` and keep `HAVING COUNT(e.employee_id) > 0`; `DISTINCT + INNER JOIN` or `EXISTS` also work.

**⚠️ Mistake:** Counted the FK `COUNT(e.reports_to)` instead of the entity `COUNT(e.employee_id)` — correct result but imprecise intent.

**💡 Learning:** Count the entity (`COUNT(e.employee_id)`), not the FK column; GROUP BY+HAVING is the interview-favourite of the three valid approaches.

</details>

<details>
<summary><strong>Q63 · Employees Reporting to the Same Manager</strong> — Medium — SELF JOIN (triple alias) · INNER JOIN · dedup (id < id)</summary>

**Q:** Return unique pairs of employees who share the same manager, plus the manager's name.

**A:** Three aliases: `e1`/`e2` joined on `e1.reports_to = e2.reports_to`, and `m` joined on `m.employee_id = e1.reports_to`; `WHERE e1.employee_id < e2.employee_id` to dedup.

**⚠️ Mistake:** Showed `e1` as manager, then joined `m` on `e1.employee_id` instead of `e1.reports_to`.

**💡 Learning:** Join the manager alias on `m.employee_id = e1.reports_to` (who they report to), never `= e1.employee_id`; use a third alias when three roles come from one table.

</details>

<details>
<summary><strong>Q64 · Employees Having the Same Job Title</strong> — Easy — SELF JOIN · INNER JOIN · dedup (id < id)</summary>

**Q:** Return unique pairs of employees who share the same `title`, plus the title.

**A:** `JOIN employees e2 ON e1.employee_id < e2.employee_id AND e1.title = e2.title`; select `e1.title` directly.

**⚠️ Mistake:** Added a redundant third join just to read `title` when `e1.title` was already available.

**💡 Learning:** Only add another join/alias if the data isn't already reachable from an existing alias.

</details>

<details>
<summary><strong>Q65 · Employees Hired in the Same Year</strong> — Easy — SELF JOIN · EXTRACT · dedup (id < id)</summary>

**Q:** Return unique pairs of employees hired in the same year, plus the year.

**A:** `ON e1.employee_id < e2.employee_id AND EXTRACT(YEAR FROM e1.hire_date) = EXTRACT(YEAR FROM e2.hire_date)`.

**⚠️ Mistake:** —

**💡 Learning:** Compare `EXTRACT(YEAR FROM hire_date)`, not the raw date, to match at year granularity.

</details>

<details>
<summary><strong>Q66 · Customers from the Same Country</strong> — Easy — SELF JOIN · INNER JOIN · dedup (id < id)</summary>

**Q:** Return unique pairs of customers from the same country, plus the country.

**A:** `JOIN customers c2 ON c1.customer_id < c2.customer_id AND c1.country = c2.country`.

**⚠️ Mistake:** —

**💡 Learning:** The purest pair template — `t1.id < t2.id AND t1.common_column = t2.common_column`; `<` removes self-pairs and duplicates in one condition.

</details>

<details>
<summary><strong>Q67 · Customers from the Same City</strong> — Easy — SELF JOIN · INNER JOIN · dedup (id < id)</summary>

**Q:** Return unique pairs of customers from the same city, plus the city.

**A:** `ON c1.customer_id < c2.customer_id AND c1.city = c2.city`, selecting `c1.city`.

**⚠️ Mistake:** Join condition correct, but SELECT showed `c1.country` instead of `c1.city` (copy-paste from Q66).

**💡 Learning:** Verify every SELECT column answers the question, not just the join condition.

</details>

<details>
<summary><strong>Q68 · Products with the Same Supplier</strong> — Easy — SELF JOIN · INNER JOIN · dedup (id < id)</summary>

**Q:** Return unique pairs of products sharing the same `supplier_id`, plus that supplier ID.

**A:** `ON p1.product_id < p2.product_id AND p1.supplier_id = p2.supplier_id`.

**⚠️ Mistake:** Omitted the `p1.supplier_id = p2.supplier_id` condition → Cartesian product.

**💡 Learning:** `id < id` alone only deduplicates — always ask "what does *same* mean?" and add that equality, or you get a Cartesian product.

</details>

<details>
<summary><strong>Q69 · Products in the Same Category</strong> — Easy — SELF JOIN · LEFT JOIN (lookup) · dedup (id < id)</summary>

**Q:** Return unique pairs of products sharing the same `category_id`, plus the category name.

**A:** Self-join on `p1.product_id < p2.product_id AND p1.category_id = p2.category_id`, then `LEFT JOIN categories c ON c.category_id = p1.category_id` for the name.

**⚠️ Mistake:** Missing the `p1.category_id = p2.category_id` condition → Cartesian product.

**💡 Learning:** Add a lookup join only when the display value (the name) isn't already on the self-joined table.

</details>

<details>
<summary><strong>Q70 · Customers Sharing the Same Postal Code</strong> — Easy — SELF JOIN · INNER JOIN · dedup (id < id)</summary>

**Q:** Return unique pairs of customers sharing the same postal code, plus that postal code.

**A:** `ON c1.customer_id < c2.customer_id AND c1.postal_code = c2.postal_code`.

**⚠️ Mistake:** —

**💡 Learning:** `NULL = NULL` is never true in a join — rows with NULL match columns never pair; `<` is the universal dedup choice.

</details>

---

## 10 · CROSS JOIN

<details>
<summary><strong>Q71 · Employee–Category Combinations</strong> — Easy — CROSS JOIN · Cartesian product · No ON clause · CONCAT</summary>

**Q:** Return every employee name paired with every product category name (every employee × every category).

**A:** `SELECT CONCAT(e.first_name,' ',e.last_name) AS employee_name, c.category_name FROM employees e CROSS JOIN categories c;` → 9 × 8 = 72 rows.

**⚠️ Mistake:** Added `ON` clauses and joined through products/order_details/orders — turning it into an INNER JOIN chain of "employees who sold in that category."

**💡 Learning:** CROSS JOIN never has an `ON` clause — if you write `ON`, you are thinking in INNER JOIN terms; for "every X with every Y" only the two named tables are needed.

</details>

<details>
<summary><strong>Q72 · Product–Shipper Combinations</strong> — Easy — CROSS JOIN · Cartesian product · No ON clause</summary>

**Q:** Return every product name paired with every shipper company name.

**A:** `SELECT p.product_name, sh.company_name FROM products p CROSS JOIN shippers sh;` → 77 × 3 = 231 rows.

**⚠️ Mistake:** — (correct first attempt)

**💡 Learning:** For "every X with every Y", use CROSS JOIN on exactly the two required tables with no `ON` — and table order never changes the result set.

</details>

<details>
<summary><strong>Q73 · Supplier–Category Combinations</strong> — Easy — CROSS JOIN · Cartesian product · Column selection (company_name vs contact_name)</summary>

**Q:** Return every supplier name paired with every product category name.

**A:** `SELECT s.company_name AS supplier_name, c.category_name FROM suppliers s CROSS JOIN categories c;` → 29 × 8 = 232 rows.

**⚠️ Mistake:** Selected `s.contact_name` (the contact person) instead of `s.company_name` (the supplier entity).

**💡 Learning:** In Northwind, "Supplier Name" = `company_name` and "Supplier Contact" = `contact_name` — when in doubt, the company name identifies the entity.

</details>

<details>
<summary><strong>Q74 · Customer–Supplier Combinations</strong> — Easy — CROSS JOIN · Cartesian product · No ON clause</summary>

**Q:** Return every customer name paired with every supplier name (no FK relationship exists between the tables).

**A:** `SELECT cu.contact_name AS customer_name, s.company_name AS supplier_name FROM customers cu CROSS JOIN suppliers s;` → 91 × 29 = 2,639 rows.

**⚠️ Mistake:** — (correct first attempt)

**💡 Learning:** CROSS JOIN works between any two tables regardless of whether they share a foreign key — it is a pure combinatorial operation.

</details>

<details>
<summary><strong>Q75 · Employee–Shipper Combinations</strong> — Easy — CROSS JOIN · Cartesian product · No ON clause · CONCAT</summary>

**Q:** Return every employee name paired with every shipper company name.

**A:** `SELECT CONCAT(e.first_name,' ',e.last_name) AS employee_name, s.company_name FROM employees e CROSS JOIN shippers s;` → 9 × 3 = 27 rows.

**⚠️ Mistake:** — (correct first attempt)

**💡 Learning:** Table order in CROSS JOIN does not matter — `employees CROSS JOIN shippers` equals `shippers CROSS JOIN employees`; only the display order can differ.

</details>

<details>
<summary><strong>Q76 · Customer–Category Combinations</strong> — Easy — CROSS JOIN · Cartesian product · No ON clause</summary>

**Q:** Return every customer name paired with every product category name.

**A:** `SELECT cu.contact_name, c.category_name FROM customers cu CROSS JOIN categories c;` → 91 × 8 = 728 rows.

**⚠️ Mistake:** — (correct first attempt)

**💡 Learning:** The CROSS JOIN pattern is recognised instantly: two tables, no `ON`, N × M rows — resist joining through orders to "connect" the tables.

</details>

<details>
<summary><strong>Q77 · Product–Employee Combinations</strong> — Easy — CROSS JOIN · Cartesian product · No ON clause · CONCAT</summary>

**Q:** Return every product name paired with every employee name.

**A:** `SELECT p.product_name, CONCAT(e.first_name,' ',e.last_name) AS employee_name FROM employees e CROSS JOIN products p;` → 77 × 9 = 693 rows.

**⚠️ Mistake:** — (correct first attempt)

**💡 Learning:** CROSS JOIN is fully symmetric — table order affects only display order, never which rows are returned (unlike LEFT/RIGHT JOIN).

</details>

<details>
<summary><strong>Q78 · Supplier–Shipper Combinations</strong> — Easy — CROSS JOIN · Cartesian product · Column selection (company_name vs contact_name)</summary>

**Q:** Return every supplier name paired with every shipper name.

**A:** `SELECT s.company_name AS supplier_name, sh.company_name AS shipper_name FROM suppliers s CROSS JOIN shippers sh;` → 29 × 3 = 87 rows.

**⚠️ Mistake:** Submitted `s.contact_name` instead of `s.company_name` — "Supplier Name" means the company, not the contact person.

**💡 Learning:** "Supplier Name" = `company_name`; "Supplier Contact" = `contact_name` — always confirm which attribute the question requires before selecting.

</details>

---

## 11 · Set Operators

<details>
<summary><strong>Q79 · Customer and Supplier Contact Directory</strong> — Easy — UNION · Set Operators</summary>

**Q:** Build one deduplicated list of all customer and supplier contact names.

**A:** `SELECT contact_name FROM customers UNION SELECT contact_name FROM suppliers;` — UNION stacks rows and removes duplicates.

**⚠️ Mistake:** —

**💡 Learning:** UNION stacks rows (taller) from independent result sets; JOIN combines columns (wider) from related rows — know the two rules: same column count, compatible types.

</details>

<details>
<summary><strong>Q80 · Product and Category Name List</strong> — Easy — UNION · Set Operators</summary>

**Q:** Combine all product names and category names into one deduplicated column.

**A:** `SELECT product_name FROM products UNION SELECT category_name FROM categories;` — output column takes its name from the first SELECT.

**⚠️ Mistake:** —

**💡 Learning:** UNION is purely structural (matching column count + compatible types, not semantic similarity), and output labels always come from the first SELECT.

</details>

<details>
<summary><strong>Q81 · Company Name Directory</strong> — Easy — UNION (three-way) · Set Operators</summary>

**Q:** List every company name from customers, suppliers, and shippers in one deduplicated column.

**A:** Chain three SELECTs on `company_name` with UNION; deduplication applies across the entire combined result.

**⚠️ Mistake:** —

**💡 Learning:** UNION chains accept any number of SELECTs and deduplicate across the whole result (not adjacent pairs); keep the single `ORDER BY` at the very end.

</details>

<details>
<summary><strong>Q82 · Contact Directory with Type Label</strong> — Medium — UNION · Literal String Columns · CONCAT</summary>

**Q:** Combine customers and employees into one list with name, city, and a type label.

**A:** UNION two SELECTs, each adding a literal `'Customer'`/`'Employee'` column; use `CONCAT(first_name,' ',last_name)` for employees.

**⚠️ Mistake:** Wrote `'employee'` lowercase vs `'Customer'` title case — case-sensitive filters break silently.

**💡 Learning:** Literal label columns make a UNION directory self-describing, but capitalisation must be consistent across every branch since comparison is case-sensitive.

</details>

<details>
<summary><strong>Q83 · Master Contact Directory</strong> — Medium — UNION (three-way) · Literal Columns · CONCAT</summary>

**Q:** Build a Name/City/Entity_Type directory across customers, suppliers, and employees.

**A:** Three-way UNION, literal type label per branch, `CONCAT` for employee names.

**⚠️ Mistake:** `'employee'` lowercase in one branch while others were title case — silent downstream filtering bug.

**💡 Learning:** The three-way typed UNION is the master-directory template; literal labels must share consistent capitalisation across every branch.

</details>

<details>
<summary><strong>Q84 · Master Company Directory</strong> — Medium — UNION (three-way) · Literal Columns · Schema Awareness</summary>

**Q:** Combine company name, country, and type across customers, suppliers, and shippers.

**A:** Three-way UNION; `shippers` has no `country`, so substitute `'N/A'` to keep structural compatibility.

**⚠️ Mistake:** Aliased first column `Name` instead of required `Company_Name` — exact-output validation fails.

**💡 Learning:** Verify column availability in every source table before a multi-table UNION (use a placeholder for missing columns), and the first SELECT's aliases set the output column names.

</details>

<details>
<summary><strong>Q85 · Master Location Directory</strong> — Medium — UNION (three-way) · Deduplication</summary>

**Q:** List every unique city/country where there are customers, suppliers, or employees.

**A:** `SELECT city, country` from each table joined by `UNION` (not `UNION ALL`); both columns needed so same-named cities in different countries stay distinct.

**⚠️ Mistake:** —

**💡 Learning:** UNION deduplicates on the complete row, so UNION vs UNION ALL is a correctness choice — and adding an extra column (like a type label) to a "unique locations" query breaks the dedup.

</details>

<details>
<summary><strong>Q86 · Entity Record Count Summary</strong> — Hard — UNION ALL (in CTE) · CTE · GROUP BY · COUNT</summary>

**Q:** Report total record count per entity (customers, suppliers, employees) in one query.

**A:** CTE unions labelled rows with `UNION ALL`, then outer `GROUP BY Entity_Type` + `COUNT(*)`.

**⚠️ Mistake:** `'employee'` lowercase; also must use `UNION ALL` not `UNION` inside the CTE.

**💡 Learning:** "Standardise (UNION ALL in a CTE) then summarise (GROUP BY + COUNT)" — UNION would collapse identical label rows and undercount every entity to 1.

</details>

<details>
<summary><strong>Q92 · Countries with More Customers Than Employees and Suppliers</strong> — Hard — UNION ALL · Conditional Aggregation · HAVING</summary>

**Q:** Find countries where customers > employees + suppliers.

**A:** CTE with `UNION ALL` of labelled rows, `SUM(CASE...)` per entity, `HAVING total_customers > total_employees + total_suppliers`.

**⚠️ Mistake:** Wrong column aliases and missing `ORDER BY` — correct SQL still rejected by the platform.

**💡 Learning:** Aggregate filters go in `HAVING` with full `SUM(CASE...)` repeated (aliases not yet resolved); on a platform also match exact column names and a deterministic multi-column `ORDER BY`.

</details>

<details>
<summary><strong>Q93 · Countries with Balanced Business Entities</strong> — Advanced — UNION ALL · CTE · Conditional Aggregation · HAVING</summary>

**Q:** Find countries that have at least one employee, one supplier, and one customer.

**A:** UNION ALL into a CTE, `SUM(CASE...)` per entity, `HAVING` each count `!= 0`.

**⚠️ Mistake:** —

**💡 Learning:** Combine sources with UNION ALL, count each type via conditional aggregation, then use HAVING to require every per-entity count be non-zero — the pattern for "groups satisfying multiple presence conditions."

</details>

<details>
<summary><strong>Q96 · Countries with the Highest Customer Count Above the Overall Average</strong> — Expert — CTE · COUNT/AVG/MAX · CROSS JOIN · Multi-level Aggregation</summary>

**Q:** Return the country/countries with the maximum customer count among those above the overall average (tie-safe).

**A:** Count per country, then AVG and MAX over those counts in separate CTEs, `CROSS JOIN` the scalars, filter `total > avg AND total = max`.

**⚠️ Mistake:** —

**💡 Learning:** Aggregate-of-an-aggregate problems need staged CTEs (count per group, then AVG/MAX over counts); compare to MAX instead of `LIMIT 1` to stay tie-safe.

</details>

<details>
<summary><strong>Q97 · Countries with More Customers Than Their Entity Average</strong> — Expert — UNION ALL · CTE · Conditional Aggregation · Derived Metric</summary>

**Q:** Find countries where customers > the average of that country's own three entity counts.

**A:** UNION ALL + conditional aggregation for per-country counts, derive `(emp+cust+sup)/3.0` per country, filter `total_customers > entity_average`.

**⚠️ Mistake:** —

**💡 Learning:** Build per-country counts, derive the per-country average (divide by `3.0` for real division), then compare each country against its own benchmark — not a global one.

</details>

---

## 12 · Window Functions

<details>
<summary><strong>Q98 · Latest Order Per Customer</strong> — Easy — ROW_NUMBER · PARTITION BY · ORDER BY DESC · Top-1 per Group</summary>

**Q:** For every customer who has ordered, return exactly one row describing their latest order (latest `order_date`; if two orders share a date, the higher `order_id` wins).

**A:** 1. Number each customer's orders with `ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC, order_id DESC)`. 2. Keep only `rn = 1` in the outer query (window results cannot be filtered in the same `WHERE`). 3. Join `customers` for the company name and sort by `customer_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Top-1-per-group = `ROW_NUMBER() OVER (PARTITION BY group ORDER BY metric DESC, unique_id)` in a CTE, then filter `rn = 1` outside.

</details>

<details>
<summary><strong>Q99 · Rank Vs Dense Rank Product Prices</strong> — Easy — RANK · DENSE_RANK · PARTITION BY · Tie Handling</summary>

**Q:** For each product, show its price rank within its category using both `RANK()` and `DENSE_RANK()` (highest price = 1).

**A:** 1. Join `products` to `categories`. 2. Compute `RANK()` and `DENSE_RANK()` over the same window: `PARTITION BY category_id ORDER BY unit_price DESC`. 3. Sort by category, rank, then `product_id` as the tie-breaker.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** RANK skips numbers after ties, DENSE_RANK does not, ROW_NUMBER never ties. Pick based on how the question treats equal values.

</details>

<details>
<summary><strong>Q100 · Top 3 Products By Revenue Per Category</strong> — Medium — DENSE_RANK · PARTITION BY · GROUP BY · SUM</summary>

**Q:** For each category, return the top 3 revenue positions (using `DENSE_RANK`), where revenue = `unit_price * quantity * (1 - discount)` from `order_details`.

**A:** 1. CTE `product_revenue`: sum net revenue per product (with its `category_id`). 2. CTE `ranked`: `DENSE_RANK() OVER (PARTITION BY category_id ORDER BY revenue DESC)`. 3. Filter `revenue_rank <= 3`, join `categories` for the name, and round.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Top-N per group: aggregate, rank with `PARTITION BY`, then filter the rank in an outer query.

</details>

<details>
<summary><strong>Q101 · Running Total Of Monthly Revenue</strong> — Easy — SUM OVER · ROWS BETWEEN UNBOUNDED PRECEDING · DATE_TRUNC · CTE</summary>

**Q:** Return one row per order month with its revenue and the running total of revenue to date.

**A:** 1. CTE `monthly`: `DATE_TRUNC('month', order_date)` and sum net revenue per month. 2. Outer query: `SUM(revenue) OVER (ORDER BY order_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`. 3. Round both values and order by month.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Running total = `SUM(x) OVER (ORDER BY t ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)` over pre-aggregated rows.

</details>

<details>
<summary><strong>Q102 · Three Month Moving Average Revenue</strong> — Medium — AVG OVER · ROWS BETWEEN 2 PRECEDING · Named WINDOW · DATE_TRUNC</summary>

**Q:** Return each order month's revenue, the number of months in its trailing window, and the 3-month trailing moving average.

**A:** 1. CTE `monthly`: revenue per `DATE_TRUNC('month', order_date)`. 2. Define `WINDOW w AS (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)`. 3. Compute `AVG(revenue) OVER w` and `COUNT(*) OVER w`; round and order by month.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Moving averages use a bounded frame: `AVG(x) OVER (ORDER BY t ROWS BETWEEN n-1 PRECEDING AND CURRENT ROW)`.

</details>

<details>
<summary><strong>Q103 · Month Over Month Revenue Change</strong> — Medium — LAG · NULLIF · Percent Change · DATE_TRUNC</summary>

**Q:** For each order month, return revenue, previous month revenue (via `LAG`), absolute change, and percent change rounded to 2 dp.

**A:** 1. CTE `monthly`: revenue per month. 2. CTE `with_prev`: add `LAG(revenue) OVER (ORDER BY order_month)`. 3. Compute change and `100.0 * change / NULLIF(prev, 0)`; round and order by month.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `LAG()` compares a row with its predecessor without a self-join; guard percentage math with `NULLIF`.

</details>

<details>
<summary><strong>Q104 · Days Until Next Customer Order</strong> — Medium — LEAD · PARTITION BY · Date Arithmetic · Named WINDOW</summary>

**Q:** For each order, return the same customer's next order ID, its date, and the number of days between the two (NULL if there is no next order).

**A:** 1. Define `WINDOW w AS (PARTITION BY customer_id ORDER BY order_date, order_id)`. 2. Use `LEAD(order_id)` and `LEAD(order_date)` over `w`. 3. Subtract `order_date` from the lead date to get days (date − date = integer). 4. Order by customer, date, order_id.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `LEAD()` with `PARTITION BY entity ORDER BY time` gives 'next event' metrics per entity in one pass.

</details>

<details>
<summary><strong>Q105 · Customer Share Of Total Revenue</strong> — Medium — SUM() OVER () · Percent of Total · GROUP BY · CTE</summary>

**Q:** For each customer, return their net revenue, the company-wide total, and their share as a percentage (2 dp), largest first.

**A:** 1. CTE `customer_revenue`: net revenue per customer. 2. Outer query: `SUM(revenue) OVER ()` gives the grand total on every row. 3. Share = `100.0 * revenue / SUM(revenue) OVER ()`; round and order by share descending, then `customer_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `SUM(x) OVER ()` puts the grand total on every row, making percent-of-total a one-step calculation.

</details>

<details>
<summary><strong>Q106 · Customer Revenue Quartiles</strong> — Medium — NTILE · Bucketing · GROUP BY · CTE</summary>

**Q:** Assign every customer to a revenue quartile (1 = highest revenue) using `NTILE(4)`.

**A:** 1. CTE `customer_revenue`: net revenue per customer. 2. `NTILE(4) OVER (ORDER BY revenue DESC, customer_id)` to bucket customers. 3. Join `customers`; order by quartile, revenue descending, `customer_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `NTILE(n)` makes n equal-count buckets over an ordered set — always add a tie-breaker.

</details>

<details>
<summary><strong>Q107 · First And Latest Product Per Customer</strong> — Hard — FIRST_VALUE · LAST_VALUE · Window Frame · ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING</summary>

**Q:** For each customer, return the product on their earliest order line and the product on their latest order line (ordered by order date, then order ID, then product ID).

**A:** 1. Join orders, order lines and products. 2. Define a window per customer ordered by `order_date, order_id, product_id` with frame `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`. 3. Take `FIRST_VALUE(product_name)` and `LAST_VALUE(product_name)`. 4. Collapse to one row per customer with `DISTINCT`; join…

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `LAST_VALUE` needs `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` — the default frame stops at the current row.

</details>

<details>
<summary><strong>Q108 · Employee Revenue Percentile Rank</strong> — Hard — PERCENT_RANK · CUME_DIST · GROUP BY · CTE</summary>

**Q:** For each employee with orders, return total revenue, `PERCENT_RANK()` and `CUME_DIST()` (both ordered by revenue ascending, 4 dp).

**A:** 1. CTE `employee_revenue`: net revenue per employee. 2. Compute `PERCENT_RANK()` and `CUME_DIST()` over `ORDER BY revenue` (ascending, so higher = better). 3. Join employees, round, order by revenue descending then `employee_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `PERCENT_RANK` = relative rank from 0 to 1; `CUME_DIST` = share of rows at or below — know both formulas.

</details>

<details>
<summary><strong>Q109 · Average Gap Between Employee Orders</strong> — Hard — LAG · PARTITION BY · Date Arithmetic · AVG</summary>

**Q:** For each employee, compute the number of orders, the average and maximum days between consecutive orders, and the difference between their average gap and the average of all employees' averages.

**A:** 1. CTE `order_gaps`: `order_date - LAG(order_date) OVER (PARTITION BY employee_id ORDER BY order_date, order_id)`. 2. CTE `employee_gaps`: per employee `COUNT(*)`, `AVG(gap_days)`, `MAX(gap_days)`. 3. Outer query: `avg_gap_days - AVG(avg_gap_days) OVER ()`; join employees; order by `avg_gap_days`, `employee_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Compute row-level window values (LAG) in one CTE, aggregate in the next — window functions cannot be nested in aggregates.

</details>

---

## 13 · Date & Time

<details>
<summary><strong>Q110 · Orders Per Year And Month</strong> — Easy — EXTRACT · GROUP BY · COUNT · Integer Casting</summary>

**Q:** Return the number of orders placed per calendar year and month, with year and month as integers.

**A:** 1. Extract the year and month from `order_date` with `EXTRACT(...)::int`. 2. Group by both parts and `COUNT(*)` the orders. 3. Order by year, then month.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Period reports group on every part of the period key — year AND month — and cast `EXTRACT` to int for clean output.

</details>

<details>
<summary><strong>Q111 · Revenue By Quarter</strong> — Easy — EXTRACT(QUARTER) · JOIN · SUM · COUNT DISTINCT</summary>

**Q:** Return order count and net revenue (rounded to 2 decimals) per year and quarter.

**A:** 1. Join `orders` to `order_details` on `order_id`. 2. Extract year and quarter from `order_date`. 3. `SUM` the net line revenue and `COUNT(DISTINCT order_id)`. 4. Round revenue with `ROUND(...::numeric, 2)` and order by year, quarter.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Quarterly revenue = join to line items, group by year + `EXTRACT(QUARTER)`, `COUNT(DISTINCT order_id)`, and cast to numeric before rounding.

</details>

<details>
<summary><strong>Q112 · Late Shipments With Days Late</strong> — Easy — DATE Subtraction · NULL Filtering · Comparison</summary>

**Q:** Return all shipped orders where shipped_date > required_date, with the number of days late.

**A:** 1. Keep only orders with a non-NULL `shipped_date`. 2. Filter `shipped_date > required_date`. 3. Compute `shipped_date - required_date` as `days_late`. 4. Sort by `days_late DESC`, then `order_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** In PostgreSQL, `date - date` is an integer day count — the simplest way to measure lateness, after filtering out NULL ship dates.

</details>

<details>
<summary><strong>Q113 · Average Days To Ship Per Shipper</strong> — Medium — DATE Subtraction · AVG · MAX · JOIN</summary>

**Q:** Per shipper, return shipped order count, average and maximum days between order_date and shipped_date.

**A:** 1. Join `shippers` to `orders` on `ship_via = shipper_id`. 2. Filter `shipped_date IS NOT NULL`. 3. Aggregate `COUNT`, `AVG` and `MAX` of `shipped_date - order_date`. 4. Round the average and sort fastest first, tie-break on `shipper_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Lead-time metrics = `date - date` aggregated per group, with the NULL population excluded once in WHERE so every metric shares the same base.

</details>

<details>
<summary><strong>Q114 · Unshipped Orders Older Than 30 Days</strong> — Medium — NULL Filtering · DATE ± Integer · Fixed Reference Date · Boolean Expression</summary>

**Q:** Return unshipped orders with order_date more than 30 days before 1998-12-31, with days open and an overdue flag.

**A:** 1. Filter `shipped_date IS NULL`. 2. Keep rows where `order_date < DATE '1998-12-31' - 30`. 3. Compute `days_open` and a boolean `past_required_date`. 4. Sort oldest first (`days_open DESC`), tie-break on `order_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Aging reports need a fixed as-of date, `IS NULL` for open items, and `as_of - date` for integer days open.

</details>

<details>
<summary><strong>Q115 · Employee Age At Hire And Tenure</strong> — Medium — AGE() · EXTRACT from INTERVAL · DATE Subtraction · Fixed Reference Date</summary>

**Q:** Return each employee's age at hire, tenure in completed years and tenure in days as of 1998-12-31.

**A:** 1. `AGE(hire_date, birth_date)` gives an interval in years/months/days; extract YEAR for completed years. 2. `AGE(DATE '1998-12-31', hire_date)` for tenure years. 3. `DATE '1998-12-31' - hire_date` for tenure in days. 4. Sort youngest hire first, tie-break on `employee_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Use `AGE(later, earlier)` + `EXTRACT(YEAR ...)` for completed years and plain `date - date` for exact days.

</details>

<details>
<summary><strong>Q116 · Orders By Day Of Week</strong> — Medium — EXTRACT(ISODOW) · TO_CHAR · TRIM · JOIN</summary>

**Q:** Return order count and net revenue for each day of the week, ordered Monday through Sunday.

**A:** 1. Join `orders` to `order_details`. 2. Derive `EXTRACT(ISODOW ...)::int` and `TRIM(TO_CHAR(order_date, 'Day'))`. 3. Group by both; count distinct orders and sum net revenue. 4. Order by `day_number`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Group weekdays by a numeric `ISODOW` key for correct ordering, and display a trimmed `TO_CHAR` name alongside it.

</details>

<details>
<summary><strong>Q117 · Year Over Year Revenue Growth</strong> — Hard — CTE · LAG · Window Functions · NULLIF</summary>

**Q:** Return yearly net revenue, previous year's revenue and YoY growth % (all rounded to 2 decimals).

**A:** 1. CTE `yearly`: sum net revenue per `EXTRACT(YEAR ...)::int`. 2. Use `LAG(revenue) OVER (ORDER BY order_year)` for the prior year. 3. Growth % = `(revenue - prev) * 100.0 / NULLIF(prev, 0)`. 4. Round each output column and order by year.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Aggregate to one row per period, then `LAG` over the period order; compute growth on unrounded values with `NULLIF` on the divisor.

</details>

<details>
<summary><strong>Q118 · Customers Inactive In Last Six Months</strong> — Hard — LEFT JOIN · MAX · INTERVAL · NULLS FIRST</summary>

**Q:** Return customers whose most recent order is before 1998-06-30, or who have no orders, with last order date and days since then.

**A:** 1. CTE: LEFT JOIN customers to orders; take `MAX(order_date)` and `COUNT(o.order_id)` per customer. 2. Cutoff = `(DATE '1998-12-31' - INTERVAL '6 months')::date` = 1998-06-30. 3. Keep rows where last order is NULL or before the cutoff. 4. Order by `last_order_date NULLS FIRST`, tie-break on `customer_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Churn = aggregate to each customer's latest order via LEFT JOIN, then filter on that max — and keep the NULL never-ordered rows explicitly.

</details>

<details>
<summary><strong>Q119 · First Order Month Cohort Size</strong> — Hard — DATE_TRUNC · MIN · CTE · GROUP BY</summary>

**Q:** Return, per first-order year and month, the number of newly acquired customers and the cumulative total.

**A:** 1. CTE `first_orders`: per customer, `DATE_TRUNC('month', MIN(order_date))::date`. 2. Group by cohort month and `COUNT(*)` customers. 3. Running total with `SUM(COUNT(*)) OVER (ORDER BY cohort_month)`. 4. Split into integer year and month; order by both.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Cohorts start with one row per customer — `DATE_TRUNC('month', MIN(order_date))` — then count and window over those rows.

</details>

---

## 14 · String Functions

<details>
<summary><strong>Q120 · Employee Full Name And Initials</strong> — Easy — || Concatenation · CONCAT · UPPER · LOWER · LEFT</summary>

**Q:** Return each employee's full name, upper-case initials and lower-case last name.

**A:** 1. Concatenate `first_name || ' ' || last_name` for the full name. 2. Take `LEFT(..., 1)` of each name, concatenate and wrap in `UPPER()`. 3. Apply `LOWER(last_name)` and order by `employee_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `||` for NOT NULL inputs, `CONCAT`/`CONCAT_WS` when NULLs are possible; `LEFT`, `UPPER` and `LOWER` handle simple formatting.

</details>

<details>
<summary><strong>Q121 · Customers Matching Name Patterns</strong> — Easy — LIKE · ILIKE · Wildcards % and _ · OR</summary>

**Q:** Return customers whose company name starts with 'La' or contains 'market' in any case.

**A:** 1. Filter with `company_name LIKE 'La%'` OR `company_name ILIKE '%market%'`. 2. Label the matching rule with a `CASE` expression. 3. Order by `customer_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Anchor with `%` to choose starts-with vs contains, and reach for `ILIKE` whenever letter case should not matter.

</details>

<details>
<summary><strong>Q122 · Longest Product Names</strong> — Easy — LENGTH · CHAR_LENGTH · ORDER BY · LIMIT</summary>

**Q:** Return the 10 products with the longest names and their character counts.

**A:** 1. Compute `LENGTH(product_name)`. 2. Sort by length descending, then `product_id` to break ties. 3. Keep the first 10 rows with `LIMIT`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `LENGTH` counts characters; always pair a computed sort key with a unique tie-breaker before `LIMIT`.

</details>

<details>
<summary><strong>Q123 · Split Contact Name Into First And Last</strong> — Medium — SPLIT_PART · POSITION · SUBSTRING · LENGTH</summary>

**Q:** Split German customers' contact_name into first and last name using POSITION, SPLIT_PART and SUBSTRING.

**A:** 1. Find the first space with `POSITION(' ' IN contact_name)`. 2. `SPLIT_PART(contact_name, ' ', 1)` gives the first word. 3. `SUBSTRING(contact_name FROM space_pos + 1)` keeps the rest, including multi-word surnames. 4. Filter to Germany and order by `customer_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `SPLIT_PART` for a fixed field, `POSITION` + `SUBSTRING` for "everything after the first delimiter".

</details>

<details>
<summary><strong>Q124 · Normalize Postal Codes With Replace</strong> — Medium — REPLACE · UPPER · LENGTH · Regex Match ~</summary>

**Q:** Clean customer postal codes that contain spaces or hyphens and compare lengths.

**A:** 1. Keep rows where `postal_code ~ '[ -]'`. 2. Nest `REPLACE(REPLACE(postal_code, ' ', ''), '-', '')` and wrap in `UPPER`. 3. Compare lengths before and after, ordered by `customer_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `REPLACE` for literal substitutions (nest for several), `REGEXP_REPLACE ... 'g'` or `TRANSLATE` for character sets.

</details>

<details>
<summary><strong>Q125 · Product List Per Category With String Agg</strong> — Medium — STRING_AGG · ORDER BY inside aggregate · JOIN · GROUP BY · COUNT</summary>

**Q:** Return each category with its active product count and an alphabetical comma-separated product list.

**A:** 1. Join `categories` to `products` and keep `discontinued = false`. 2. Group by category. 3. `STRING_AGG(product_name, ', ' ORDER BY product_name)` builds the list; `COUNT(*)` counts. 4. Order by `category_name`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `STRING_AGG(col, sep ORDER BY col)` turns a group into a sorted delimited list — sort inside the aggregate.

</details>

<details>
<summary><strong>Q126 · Parse Category Description Keywords</strong> — Hard — SPLIT_PART · REPLACE · LENGTH · TRIM · Delimiter Counting</summary>

**Q:** Parse each category description into its first keyword, item count and cleaned last item.

**A:** 1. `SPLIT_PART(description, ',', 1)` gives the first keyword. 2. Count commas with `LENGTH(description) - LENGTH(REPLACE(description, ',', ''))`, then add 1. 3. Take the last comma field with `SPLIT_PART(description, ',', -1)`, `TRIM` it and strip a leading `and ` with `REGEXP_REPLACE`. 4. Order by `category_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Count delimiters with `LENGTH - LENGTH(REPLACE())`, pick fields with `SPLIT_PART` (negative index from the end) and clean with `TRIM`/anchored regex.

</details>

<details>
<summary><strong>Q127 · Customer Cities Per Country With Distinct String Agg</strong> — Hard — STRING_AGG DISTINCT · COUNT DISTINCT · HAVING · UPPER · LEFT</summary>

**Q:** For countries with 5+ customers, return a code, customer and city counts, and a distinct city list.

**A:** 1. Group customers by `country`. 2. `COUNT(*)` customers and `COUNT(DISTINCT city)` cities. 3. `STRING_AGG(DISTINCT city, ' | ' ORDER BY city)` for the list. 4. `HAVING COUNT(*) >= 5`; order by customer count descending, then country.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `STRING_AGG(DISTINCT x, sep ORDER BY x)` deduplicates a list; filter groups with `HAVING` and tie-break the outer sort.

</details>

---

## 15 · CASE & Conditional Logic

<details>
<summary><strong>Q128 · Product Price Bands</strong> — Easy — Searched CASE · WHEN Order · ELSE · Bucketing</summary>

**Q:** Label each product Budget (<20), Mid-range (<50) or Premium.

**A:** 1. Write a searched `CASE` with `WHEN unit_price < 20`, then `< 50`, then `ELSE`. 2. Order by `product_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Order `CASE` branches so each bound only needs one comparison; first match wins.

</details>

<details>
<summary><strong>Q129 · Product Count And Average Price Per Band</strong> — Easy — CASE in GROUP BY · COUNT · AVG · MIN · MAX</summary>

**Q:** Return product count and min/max/avg price per price band.

**A:** 1. Compute the band with `CASE`. 2. `GROUP BY` the band alias. 3. Aggregate `COUNT`, `MIN`, `MAX`, `AVG`. 4. Order by `min_price` so bands appear cheapest first.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Bucket with `CASE`, group by the bucket, then aggregate — the CASE becomes the grouping key.

</details>

<details>
<summary><strong>Q130 · Employee Shipping Status Counts</strong> — Medium — COUNT FILTER · SUM(CASE) · Conditional Aggregation · NULL Handling</summary>

**Q:** Per employee, count total, on-time, late and unshipped orders using FILTER and SUM(CASE).

**A:** 1. Join employees to orders. 2. Use `COUNT(*) FILTER (WHERE ...)` for on-time and late. 3. Use `SUM(CASE WHEN shipped_date IS NULL THEN 1 ELSE 0 END)` for unshipped (to show both styles). 4. Group by employee and order by `employee_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Conditional aggregation = one GROUP BY, many `COUNT(*) FILTER (WHERE ...)` / `SUM(CASE ...)` columns.

</details>

<details>
<summary><strong>Q131 · Pivot Category Revenue By Year</strong> — Medium — Pivot · SUM FILTER · EXTRACT · COALESCE · JOIN</summary>

**Q:** Pivot net revenue per category into 1996, 1997 and 1998 columns plus a total.

**A:** 1. Join categories → products → order_details → orders. 2. For each year, `SUM(net) FILTER (WHERE EXTRACT(YEAR FROM order_date) = yyyy)`. 3. `COALESCE(..., 0)` and round each column. 4. Group by category and order by `category_name`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Pivot = `GROUP BY` the row key + one `SUM(...) FILTER (WHERE col = value)` per output column.

</details>

<details>
<summary><strong>Q132 · Custom Country Sort Order With CASE</strong> — Medium — CASE in ORDER BY · Custom Sort · Tie-breakers</summary>

**Q:** Order Americas customers USA first, then Canada/Mexico, then others, with a CASE in ORDER BY.

**A:** 1. Filter to the five Americas countries. 2. Map country to a priority number with `CASE`. 3. Order by the priority, then `country`, then `company_name`, then `customer_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Custom sort = `ORDER BY CASE ... END` for the priority, then real columns down to a unique key.

</details>

<details>
<summary><strong>Q133 · Average Order Value With NULLIF And COALESCE</strong> — Medium — COALESCE · NULLIF · LEFT JOIN · Safe Division · COUNT DISTINCT</summary>

**Q:** For German customers, return order count, revenue (COALESCE 0) and average order value (NULLIF-safe).

**A:** 1. `LEFT JOIN` customers to orders and order_details so customers without orders stay. 2. `COUNT(DISTINCT o.order_id)` and `SUM` net revenue. 3. `COALESCE(SUM(...), 0)` for revenue; `SUM(...) / NULLIF(COUNT(DISTINCT ...), 0)` for the average. 4. Label with `CASE` and order by `customer_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `NULLIF(divisor, 0)` makes division safe; `COALESCE(agg, 0)` turns missing aggregates into zero — use each where its meaning fits.

</details>

<details>
<summary><strong>Q134 · Customer Value Segment Summary</strong> — Hard — CASE Segmentation · LEFT JOIN · COALESCE · CTE · CASE in ORDER BY · Window SUM</summary>

**Q:** Segment all customers by revenue (High/Medium/Low/Inactive) and summarise count, revenue and share per segment.

**A:** 1. CTE `cust_rev`: LEFT JOIN customers to orders/order_details and `COALESCE(SUM(...), 0)` per customer. 2. CTE `seg`: bucket revenue with `CASE` (Inactive when 0). 3. Group by segment; compute share with `SUM(SUM(revenue)) OVER ()`. 4. Order with a `CASE` mapping segments to 1–4.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Segment in a CTE (one row per entity, NULLs coalesced), aggregate per segment, and order segments with a `CASE`.

</details>

---

## 16 · DML & DDL

<details>
<summary><strong>Q135 · Insert New Shipper With Returning</strong> — Easy — INSERT · RETURNING · SERIAL Default · Multi-row VALUES</summary>

**Q:** Insert two shippers and return their generated ids with RETURNING.

**A:** 1. `INSERT INTO shippers (company_name, phone) VALUES (...), (...)` — omit the id. 2. Add `RETURNING shipper_id, company_name, phone`. 3. Wrap in a CTE and `SELECT ... ORDER BY shipper_id` so the output order is guaranteed.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Insert without the id, read generated values with `RETURNING`, and wrap in a CTE when you need ordered output.

</details>

<details>
<summary><strong>Q136 · Raise Prices For One Supplier</strong> — Easy — UPDATE · SET Expression · WHERE · RETURNING · ROUND</summary>

**Q:** Raise supplier 1's product prices by 5% and return the new prices.

**A:** 1. `UPDATE products SET unit_price = ROUND(unit_price * 1.05, 2)`. 2. Restrict with `WHERE supplier_id = 1`. 3. `RETURNING` the new price; wrap in a CTE and order by `product_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `UPDATE ... SET col = f(col) WHERE ... RETURNING` — always scope with `WHERE` and verify with `RETURNING`.

</details>

<details>
<summary><strong>Q137 · Update Prices Using A Join With FROM</strong> — Medium — UPDATE … FROM · Join Condition in WHERE · RETURNING · CTE</summary>

**Q:** Raise prices 10% for Seafood products using UPDATE ... FROM categories.

**A:** 1. `UPDATE products p SET ... FROM categories c`. 2. `WHERE c.category_id = p.category_id AND c.category_name = 'Seafood'`. 3. `RETURNING` columns from both tables; wrap in a CTE and order by `product_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `UPDATE target SET ... FROM other WHERE join_condition AND filter` — never list the target in `FROM` again.

</details>

<details>
<summary><strong>Q138 · Delete Small Order Lines With Returning</strong> — Medium — DELETE · RETURNING · CTE · Aggregating Deleted Rows</summary>

**Q:** Delete order lines with quantity <= 2 and return each deleted line with its value.

**A:** 1. `DELETE FROM order_details WHERE quantity <= 2 RETURNING *` inside a CTE. 2. Compute the line value in the outer `SELECT`. 3. Order by the primary key `(order_id, product_id)`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** `WITH d AS (DELETE ... RETURNING ...) SELECT ... FROM d` lets you audit, summarise or archive exactly what was removed.

</details>

<details>
<summary><strong>Q139 · Upsert Customers With On Conflict</strong> — Hard — INSERT … ON CONFLICT · DO UPDATE · EXCLUDED · RETURNING · xmax</summary>

**Q:** Upsert an existing and a new customer with ON CONFLICT and report inserted vs updated.

**A:** 1. `INSERT INTO customers (...) VALUES (...), (...)`. 2. `ON CONFLICT (customer_id) DO UPDATE SET city = EXCLUDED.city, postal_code = EXCLUDED.postal_code`. 3. `RETURNING ..., CASE WHEN xmax = 0 THEN 'inserted' ELSE 'updated' END`. 4. Wrap in a CTE and order by `customer_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Upsert = `INSERT ... ON CONFLICT (key) DO UPDATE SET col = EXCLUDED.col`, backed by a unique index.

</details>

<details>
<summary><strong>Q140 · Create Order And Lines With Chained CTE Inserts</strong> — Hard — Data-Modifying CTE · INSERT … SELECT · RETURNING · CROSS JOIN · Current Price Lookup</summary>

**Q:** Insert an order header and its lines in one statement via chained data-modifying CTEs.

**A:** 1. CTE `new_order`: `INSERT INTO orders ... RETURNING order_id`. 2. CTE `lines`: `INSERT INTO order_details SELECT new_order.order_id, p.product_id, p.unit_price, v.qty, 0 FROM new_order CROSS JOIN (VALUES ...) v JOIN products p ...  RETURNING *`. 3. Final `SELECT` joins `lines` to `products` for names and orders by `product_id`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Chain inserts with CTEs and pass generated keys through `RETURNING` — one atomic statement for header and lines.

</details>

<details>
<summary><strong>Q141 · Create Customer Revenue Summary Table As Select</strong> — Medium — CREATE TABLE AS · Aggregation · Primary Key via ALTER · Query the New Table</summary>

**Q:** Create a customer revenue summary table with CREATE TABLE AS, add a primary key and query it.

**A:** 1. `CREATE TABLE customer_revenue_summary AS SELECT ... GROUP BY customer_id`. 2. `ALTER TABLE ... ADD PRIMARY KEY (customer_id)`. 3. `SELECT` from the new table ordered by `revenue DESC, customer_id` with `LIMIT 10`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** CTAS snapshots a query into a table; add keys afterwards, and remember it never refreshes on its own.

</details>

<details>
<summary><strong>Q142 · Add Column And Check Constraint To Products</strong> — Hard — ALTER TABLE ADD COLUMN · CHECK Constraint · UPDATE with CASE · NOT NULL · pg_constraint</summary>

**Q:** Add and backfill a price_band column, enforce NOT NULL and CHECK constraints, and count products per band.

**A:** 1. `ALTER TABLE products ADD COLUMN price_band VARCHAR(10)`. 2. `UPDATE products SET price_band = CASE ... END` to backfill. 3. `ALTER COLUMN price_band SET NOT NULL` and add `CHECK (price_band IN (...))` and `CHECK (unit_price >= 0)`. 4. `SELECT` count and min price per band ordered by `min_price`.

**⚠️ Mistake:** — (new practice question, not attempted yet)

**💡 Learning:** Add column → backfill → enforce (`NOT NULL`, `CHECK`) — constraints are validated against existing rows when added.

</details>

---

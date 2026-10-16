# 🗂️ Flashcards — Northwind SQL Practice

A single-page revision deck for all **88 questions**. Each card shows the **question**, the
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
[11 Set Operators](#11--set-operators)

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


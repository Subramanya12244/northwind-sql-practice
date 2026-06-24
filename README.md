# Northwind SQL Practice

A structured collection of 29 SQL interview-style practice problems solved against the classic **Northwind** sample database, organized by concept and written for **PostgreSQL**.

Each question includes:
- A recruiter-friendly **problem statement** framed as a real business requirement
- A fully documented **SQL solution** with inline reasoning comments
- An explanation of **why** each join, aggregation, subquery, or CTE choice was made
- **Sample output**, **common mistakes**, and **interview follow-up questions**

This repo is intended as a portfolio artifact demonstrating SQL proficiency across aggregation, grouping, subqueries, CTEs, window functions, and outer joins — the core toolkit tested in most data analyst / data engineer SQL interviews.

---

## 🗂️ Repository Structure

```
northwind-sql-practice/
│
├── README.md
│
├── 01_Aggregations/                  → Q01–Q05
├── 02_GroupBy_Having/                → Q06–Q08
├── 03_Category_Product_Analytics/    → Q09–Q14
├── 04_Correlated_Subqueries/         → Q15–Q18
├── 05_CTE/                           → Q19–Q24
├── 06_Left_Join/                     → Q25–Q29
│
└── Assets/                           → (reserved for ER diagrams / schema images)
```

Each numbered folder contains a `.md` (documentation) and `.sql` (commented solution) file per question.

---

## 🧱 Schema Assumptions

All queries assume the standard Northwind table/column names:

| Table | Key Columns |
|---|---|
| `customers` | `customer_id`, `company_name` |
| `employees` | `employee_id`, `first_name`, `last_name` |
| `orders` | `order_id`, `customer_id`, `employee_id`, `order_date`, `ship_via` |
| `order_details` | `order_id`, `product_id`, `unit_price`, `quantity`, `discount` |
| `products` | `product_id`, `product_name`, `category_id` |
| `categories` | `category_id`, `category_name` |
| `shippers` | `shipper_id`, `company_name` |

**Revenue formula used throughout:**
```
revenue = unit_price * quantity * (1 - discount)
```
Note: `order_details.unit_price` (the price at time of sale) is used — not `products.unit_price`, which reflects the current catalog price and can drift from the historical transaction price.

---

## 📘 Question Index

### 01 — Aggregations & Revenue Analysis
| # | Question | Difficulty |
|---|---|---|
| [Q01](01_Aggregations/Q01_Product_Revenue.md) | Product Revenue | Easy |
| [Q02](01_Aggregations/Q02_Category_Revenue.md) | Category Revenue | Easy |
| [Q03](01_Aggregations/Q03_Top10_Customers_By_Revenue.md) | Top 10 Customers by Revenue | Easy |
| [Q04](01_Aggregations/Q04_Top5_Employees_By_Revenue.md) | Top 5 Employees by Revenue | Easy |
| [Q05](01_Aggregations/Q05_Top5_Customers_By_Order_Count.md) | Top 5 Customers by Number of Orders | Easy |

### 02 — GROUP BY & HAVING
| # | Question | Difficulty |
|---|---|---|
| [Q06](02_GroupBy_Having/Q06_Customers_Above_Average_Revenue.md) | Customers Above Average Revenue | Medium |
| [Q07](02_GroupBy_Having/Q07_Employees_Above_Average_Revenue.md) | Employees Above Average Revenue | Medium |
| [Q08](02_GroupBy_Having/Q08_Customers_Above_Average_Order_Count.md) | Customers Above Average Order Count | Medium |

### 03 — Category & Product Analytics
| # | Question | Difficulty |
|---|---|---|
| [Q09](03_Category_Product_Analytics/Q09_Top_Categories_By_Order_Count.md) | Top Categories by Number of Orders | Medium |
| [Q10](03_Category_Product_Analytics/Q10_Customers_Purchasing_From_Most_Categories.md) | Customers Purchasing from Most Categories | Medium |
| [Q11](03_Category_Product_Analytics/Q11_Revenue_By_Shipper.md) | Revenue by Shipper | Easy |
| [Q12](03_Category_Product_Analytics/Q12_Employees_By_Unique_Customers_Served.md) | Employees by Unique Customers Served | Easy |
| [Q13](03_Category_Product_Analytics/Q13_Products_Sold_Above_Category_Average_Quantity.md) | Products Sold Above Category Average Quantity | Hard |
| [Q14](03_Category_Product_Analytics/Q14_Highest_Revenue_Product_Per_Category.md) | Highest Revenue Product per Category (CTE + Window Function) | Hard |

### 04 — Correlated Subqueries
| # | Question | Difficulty |
|---|---|---|
| [Q15](04_Correlated_Subqueries/Q15_Customers_Above_Average_Orders_Correlated.md) | Customers Above Average Orders | Medium |
| [Q16](04_Correlated_Subqueries/Q16_Customers_Above_Average_Revenue_Correlated.md) | Customers Above Average Revenue | Medium |
| [Q17](04_Correlated_Subqueries/Q17_Employees_Above_Average_Revenue_Correlated.md) | Employees Above Average Revenue | Medium |
| [Q18](04_Correlated_Subqueries/Q18_Customer_Revenue_Above_Employee_Average.md) | Customer Revenue Above Employee Average | Hard |

### 05 — Common Table Expressions (CTEs)
| # | Question | Difficulty |
|---|---|---|
| [Q19](05_CTE/Q19_Customers_Above_Average_Revenue_CTE.md) | Customers Above Average Revenue Using CTE | Medium |
| [Q20](05_CTE/Q20_Top5_Customers_By_Revenue_CTE.md) | Top 5 Customers by Revenue Using CTE | Easy |
| [Q21](05_CTE/Q21_Employees_Above_Average_Revenue_Multiple_CTEs.md) | Employees Above Average Revenue Using Multiple CTEs | Medium |
| [Q22](05_CTE/Q22_Top_Employee_By_Revenue_3_CTEs.md) | Top Employee by Revenue Using 3 CTEs | Medium |
| [Q23](05_CTE/Q23_Best_Customer_Per_Employee.md) | Best Customer per Employee | Hard |
| [Q24](05_CTE/Q24_Highest_Revenue_Product_Per_Category_CTE.md) | Highest Revenue Product per Category | Hard |

### 06 — LEFT JOIN
| # | Question | Difficulty |
|---|---|---|
| [Q25](06_Left_Join/Q25_Customers_And_Order_Count.md) | Customers and Order Count | Medium |
| [Q26](06_Left_Join/Q26_Customers_And_Latest_Order_Date.md) | Customers and Latest Order Date | Medium |
| [Q27](06_Left_Join/Q27_Products_And_Total_Quantity_Sold.md) | Products and Total Quantity Sold | Medium |
| [Q28](06_Left_Join/Q28_Customers_With_No_Orders.md) | Customers with No Orders | Easy |
| [Q29](06_Left_Join/Q29_Products_Never_Ordered.md) | Products Never Ordered | Easy |

---

## 🎯 Key SQL Patterns Covered

| Pattern | Where It's Used |
|---|---|
| `LEFT JOIN ... WHERE x.col IS NULL` (anti-join) | Q28, Q29 |
| `COUNT(column)` vs `COUNT(*)` over outer joins | Q25 |
| `COALESCE` for NULL-to-zero defaults | Q27 |
| CTE + scalar subquery for "above average" comparisons | Q6–Q8, Q19–Q21 |
| Correlated subquery for "above this group's own average" | Q18 |
| `RANK()` with `PARTITION BY` for correct top-N-per-group tie handling | Q14, Q23, Q24 |
| Multi-CTE chaining for layered aggregation | Q13, Q22 |
| `JOIN ... ON` with inequality conditions | Q21 |

---

## 🧠 Why This Project

This repository was built to demonstrate not just *that* a query produces the right answer, but *why* a particular join type, aggregation strategy, or subquery pattern was the correct technical choice — the kind of reasoning expected in real SQL technical interviews. Each question pairs a working solution with the underlying decision-making, common pitfalls, and the follow-up questions an interviewer is likely to ask next.

---

## 🛠️ How to Use

1. Load the Northwind sample database into a local PostgreSQL instance.
2. Open any `.sql` file directly — each one is self-contained and includes a full header comment explaining the business context and approach.
3. Read the matching `.md` file for the full breakdown: problem framing, reasoning, sample output, and interview discussion.

---

## 📄 License

Free to use and adapt for personal learning, portfolio, or interview-preparation purposes.

# Olist E-commerce SQL Analysis

## Project Overview

This project analyzes the Brazilian Olist e-commerce dataset using SQL.

The goal of the analysis is to explore customer behavior, sales performance,
product categories, order values, and revenue trends.

The project demonstrates practical SQL skills used in data analysis, including
joins, aggregations, CTEs, subqueries, window functions, customer segmentation,
and anomaly detection.

## Dataset

The project uses the Brazilian E-Commerce Public Dataset by Olist.

The dataset contains information about:

- customers
- orders
- payments
- products
- sellers
- order items
- product categories
- reviews
- geolocation

The CSV files were imported into a SQLite database for analysis.

## Tools

- SQL
- SQLite
- VS Code
- Python for database creation
- Git / GitHub

## Project Structure

```text
olist-ecommerce-sql-analysis/
│
├── data/
│   └── olist.db
│
├── sql/
│   ├── 01_data_exploration.sql
│   ├── 02_orders_revenue_analysis.sql
│   ├── 03_customer_analysis.sql
│   ├── 04_product_analysis.sql
│   └── 05_advanced_analysis.sql
│
├── scripts/
│   └── create_database.py
│
├── images/
│
└── README.md
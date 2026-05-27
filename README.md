# SQL-journal-risk-analytics
Enterprise-style SQL project simulating journal-entry extraction, transformation, and FX translation workflows in a multi-entity financial reporting environment.
This project was designed to demonstrate practical SQL skills commonly used in:
* ERP financial systems
* Finance transformation
* Audit analytics
* Financial data engineering
* Multi-currency reporting environments

## Key Features:
* Oracle-style ERP relational table structure
* Journal line and journal header population building
* Multi-table SQL joins using relational keys
* Production-style data cleansing and transformation
* Standardized journal population creation
* Financial statement account classification
* Derived debit/credit net calculations
* Multi-entity and multi-currency support
* FX translation to USD using real market FX data
* Month-end and monthly-average FX methodology

## ERP Tables Simulated:
The project includes simplified ERP-style financial tables:
* GL_JE_LINES
* GL_JE_HEADERS
* GL_JE_BATCHES
* GL_JE_CODE_COMBINATIONS
* GL_BALANCES
* GL_LEDGERS
* FND_USER
The schema was intentionally designed to simulate realistic enterprise financial data relationships and SQL join logic.

## Journal Transformation Workflow:
Main transformation procedures include:
* relational joins across ERP tables
* standardized field renaming
* journal population cleansing
* business-rule filtering
* account classification logic
* derived financial calculations
* standardized production-style SQL CTE workflows

Examples:
* ACCOUNTED_DR - ACCOUNTED_CR → ACCOUNTED_NET
* ENTERED_DR - ENTERED_CR → ENTERED_NET
* CASE WHEN account mapping logic
* LEFT JOIN population preservation
* manual vs system journal tagging

## FX Translation:
The project also includes an enterprise-style FX translation workflow converting local-currency balances into USD.
FX rates were downloaded from publicly available market-data sources and standardized using SQL transformation logic.
Currencies currently included:
* EUR
* GBP
* JPY
* AUD
* BRL
Translation methodology:
* Balance Sheet accounts → Month-end FX rates
* P&L accounts → Monthly average FX rates









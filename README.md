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


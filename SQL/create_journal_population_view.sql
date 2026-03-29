/* ===================================================================================================================================
Script Name: create_journal_population_view.SQL
Purpose: Create a reusable line-level journal population object for downstream testing modules from Oracle-Style relational tables.

Downstream Use Cases
--------------------------------------------------------------------------------------------------------------------------------------
This view is intended to be used by later testing scripts, such as:
- completeness testing
- FX translation
- threshold/exception analysis
- high-risk sampling

Design Principles
--------------------------------------------------------------------------------------------------------------------------------------
1. Preserve GL_JE_LINES as the base population
2. Enrich with header, account, batch, user, and ledger attributes
3. Apply source-aware renaming for duplicate field names
4. Derive net amounts and control flags
5. Retain only posted, actual, in-scope, primary-ledger journals
====================================================================================================================================== */




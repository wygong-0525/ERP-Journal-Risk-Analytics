/* =========================================================================================
Script Name: Journal_Transformation.SQL
Purpose: Build an analysis-ready journal population from Oracle-Style relational tables

Key Objectives:
1. Preserve GL_JE_LINES as the base population.
2. Join header, account, batch, user, and ledger attributes
3. Rename overlapping fields for source clarity
4. Derive net amount, account grouping, and control flags
5. Filter to posted, actual, primary, in-scope journal lines only
===========================================================================================*/

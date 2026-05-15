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

CREATE VIEW JOURNAL_POPULATION AS 

WITH RAW_JOINS AS (
/* =====================================================================================================================================
NOTE:
  This layer performs relational row-level joins only.
  GL_JE_LINES is intentionally retained as the base population.
  LEFT JOIN is used so unmatched line records are not dropped during the enrichment.
========================================================================================================================================= */
  SELECT 
/* ==============CORE KEYS===============================*/
  L.JE_HEADER_ID,
  L.JE_LINE_NUM,
  L.CODE_COMBINATION_ID,
  H.JE_BATCH_ID,
  H.LEDGER_ID,
  H.CREATED_BY,

/* ==============PERIDS AND DATES========================*/
  L.PERIOD_NAME,
  L.EFFECTIVE_DATE,
  L.CREATION_DATE AS LINE_CREATION_DATE,

/* ==============SOURCE AWARE TEXT FIELDS================*/
  L.DESCIPRTION AS LINE_DESCRTPTION,
  H.DESCRIPTION AS HEADER_DESCRIPTION,
  B.DESCRIPTION AS BATCH_DESCRIPTION,

  H.NAME AS HEADER_NAME,
  B.NAME AS BATCH_NAME,
  LED.LEDER_NAME AS LEDHER_NAME,
  
















  



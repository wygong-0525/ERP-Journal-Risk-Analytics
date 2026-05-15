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

/* ==============PERIDS AND DATES=================================*/
  L.PERIOD_NAME,
  L.EFFECTIVE_DATE,
  L.CREATION_DATE AS LINE_CREATION_DATE,

/* ==============SOURCE AWARE TEXT FIELDS=========================*/
  L.DESCIPRTION AS LINE_DESCRTPTION,
  H.DESCRIPTION AS HEADER_DESCRIPTION,
  B.DESCRIPTION AS BATCH_DESCRIPTION,

  H.NAME AS HEADER_NAME,
  B.NAME AS BATCH_NAME,
  LED.LEDER_NAME AS LEDHER_NAME,
  
/* ==============CURRENCY FIELDS==================================*/
  L.CURRENCY_CODE AS LINE_CURRENCY_CODE,
  H.CURRENCY_CODE AS HEADER_CURRENCY_CODE,

/* ==============AMOUNT FIELDS WITH NULL HANDLING==================
  NOTE:
  COALESCE(VALUE,0) MEANS:
  - Use the field value as 0 if present.
  - otherwise replace null with 0.
  This prevents the downstream net calculation from returning NULL.
*/
  COALESCE(L.ENTERED_DR,0) AS ENTERED_DR,
  COALESCE(L.ENTERED_CR,0) AS ENTERED_CR,
  COALESCE(L.ACCOUNTED_DR,0) AS ACCOUNTED_DR,
  COALESCE(L.ACCOUNTED_CR,0) AS ACCOUNTED_CR,

/* ==============HEADER ATTRIBUTE==================================*/
  H.JE_SOURCE,
  H.STATUS,
  H.ACTUAL_FLAG,
  H.REVERSED_JE_HEADER_ID,

/* ==============CODE COMBINATION ATTRIBUTE========================*/
  CC.ACCOUNT_TYPE,
  SS.SUMMERY_FLAG,
  CC.SEGMENT1,
  CC.SEGMENT2,
  CC.SEGMENT3,
  CC.SEGMENT4,

/* ==============USER ATTRIBUTE=====================================*/ 
  U.USER_NAME,
  U.USER_DESCRIPTION,

/* ==============LEDGER ATTRIBUTE====================================*/  
  LED.DESCRIPTION AS LEDGER_DESCRIPTION,
  LED.LEDGER_CATEGORY_CODE

FROM GL_JE_LINES L
  
LEFT JOIN GL_JE_HEADER H
  ON L.JE_HEADER_ID = H.JE_HEADER_ID

LEFT JOIN GL_JE_CODE_COMBINATIONS CC
  ON L.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID

LEFT JOIN GL_JE_BATCH B
  ON H.JE_BATCH_ID = B.JE_BATCH_ID

LEFT JOIN FND_USER U
  ON H.CREATED_BY = U.USER_ID

LEFT JOIN GL_LEDGERS LED
  ON H.LEDGER_ID = LED.LEDGER_ID

),

STANDARDIZED AS (

  













  



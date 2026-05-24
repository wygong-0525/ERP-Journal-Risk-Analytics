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
/* ==============CORE KEYS========================================*/
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

/* ==============HEADER ATTRIBUTE===================================*/
  H.JE_SOURCE,
  H.STATUS,
  H.ACTUAL_FLAG,
  H.REVERSED_JE_HEADER_ID,

/* ==============CODE COMBINATION ATTRIBUTE=========================*/
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
/*------------------------------------------------------------------------------
  Note:
  This layer standardizes naming conventions, derives analytical fields, and adds
  data quality/control flags.
---------------------------------------------------------------------------------*/
  SELECT
  /* ==============CARRY-FORWARD KEYS============================================*/ 
  JE_HEADER_ID,
  JE_LINE_NUM,
  CODE_COMBINATION_ID,
  JE_BATCH_ID,
  LEDGER_ID,
  CREATED_BY,

  /*===============UNIQUE ROW KEY==================================================
    Combines JE header ID and line number for traceability.
  ================================================================================*/
  CAST(JE_HEADER_ID AS TEXT) ||" - "|| CAST(JE_LINE_NUM AS TEXT) AS JE_LINE_KEY,

  /* ==============PERIOD AND DATE================================================*/ 
  PERIOD_NAME,
  EFFECTIVE_DATE,
  LINE_CREATION_DATE,

  /* ==============BUSINESS-FREIDNLY SEGMENT RENAMING==============================*/ 
  SEGMENT1 AS COMPANY_CODE,
  SEGMENT2 AS COST_CENTRE_CODE,
  SEGMENT3 AS ACCOUNT_CODE,
  SEGMENT4 AS INTERCOMPANY_FLAG,

  /* ==============DESCRIPTION AND NAME============================================*/ 
  LINE_DESCRIPTION,
  HEADER_DESCRIPTION,
  BATCH_DESCRIPTION,
  HEADER_NAME,
  BATCH_NAME,
  LEDGER_NAME,

  /* ==============CURRENCY CODE===================================================*/
  LINE_CURRENCY_CODE,
  HEADER_CURRENCY_CODE,

  /* ==============RAW AMOUNT======================================================*/
  ENTERED_DR,
  ENTERED_CR,
  ACCOUNTED_DR,
  ACCOUNTED_CR,

  /* ==============NET AMOUNT======================================================*/
  (ENTERED_DR - ENTERED_CR) AS ENTERED_NET,
  (ACCOUNTED_DR - ACCOUNTED_CR) AS ACCOUNTED_NET,

  /* ==============DIRECTION INDICATORS=============================================*/
  CASE
  WHEN (ENTERED_DR - ENTERED_CR) > 0 THEN 'DEBIT'
  WHEN (ENTERED_DR - ENTERED_CR) < 0 THEN 'CREDIT'
  ELSE 'ZERO'
  END AS ENTERED_NET-DIRECTION,

  CASE
  WHEN (ACCOUNTED_DR - ACCOUNTED_CR) > 0 THEN 'DEBIT'
  WHEN (ACCOUNTED_DR - ACCOUNTED_CR) < 0 THEN 'CREDIT'
  ELSE 'ZERO'
  END AS ACCOUNTED_NET_DIRECTION,

  /* ==============ORIGINAL ACCOUNTING ATTRIBUTES===================================*/
  ACCOUNT_TYPE,
  SUMMARY_FLAG,
  JE_SOURCE,
  STATUS,
  ACTUAL_FLAG,
  REVERSED_JE_HEADER_ID,
  USER_NAME,
  USER_DESCRIPTION,
  LEDGER_DESCRIPTION,
  LEDGER_CATEGORY_CODE,

  /* ==============DERIVED ACCOUNTING GROUP===========================================
  NOTE:
  Native account type values are preserved, while BS/PL grouping is derived in the transformation layer.
  */
  CASE
  WHEN ACCOUNT_TYPE IN ('A', 'L', 'O') THEN 'BS'
  WHEN ACCOUNT_TYPE IN ('R', 'E') THEN 'PL'
  ELSE 'OTHER'
  END AS BS_PL_FLAG,

  /* ==============RETAINED EARNINGS FLAG===========================================
  Assumes account code 300000 represents retained earnings */
  CASE
  WHEN ACCOUNT_TYPE = 'O' AND SEGMENT3 = 300000 THEN 'Y'
  ELSE 'N'
  END AS RETAINED_EARNINGS_FLAG,

  /* ==============MANUAL JOURNAL INDICATOR========================================*/
  CASE
  WHEN JE_SOURCE IN ('MANUAL', 'SPREADSHEET') THEN 'Y'
  ELSE 'N'
  END AS MANUAL_JE_FLAG

  /* ==============SCOPE/CONTROL FLAG===============================================*/
  CASE
  WHEN STATUS = 'P' THEN 'Y'
  ELSE 'N'
  END AS POSTED_FLAG,

  CASE
  WHEN ACTUAL_FLAG = 'A' THEN 'Y'
  ELSE 'N'
  END AS ACTUAL_JE_FLAG,

  CASE
  WHEN PERIOD_NAME IN (
  'JAN-25','FEB-25','MAR-25','ARP-25','MAY-25','JUN-25','JUL-25','AUG-25','SEP-25','OCT-25',
  'NOV-25','DEC-25') 
  THEN 'Y'
  ELSE 'N'
  END AS PERIOD_SCOPE_FLAG,

  CASE
  WHEN LEDGER_CATEGORY_CODE = 'PRIMARY' THEN 'Y'
  ELSE 'N'
  END AS PRIMARY_LEDGER_FLAG,

FROM RAW_JOINED

),

FLIERED POPULATION AS (
  /* ------------------------------------------------------------------------------------------
  NOTE:
  This layer consolidates business scope rules into one final flag.
  Keeping flags before final filtering improves reviewability.
  ------------------------------------------------------------------------------------------*/
  SELECT
  *,
  CASE
  WHEN POSTED_FLAG = 'Y',
  AND ACTUAL_JE_FLAG = 'Y',
  AND PERIOD_SCOPE_FLAG = 'Y',
  AND PRIMARY_LEDGER_FLAG = 'Y',
  THEN 'Y'
  ELSE 'N'
  END AS POPULATION_SCOPE_FLAG

  FROM STANDARDIZED
)

/* ------------------------------------------------------------------------------------------
  FINAL OUTPUT:
  This is the reusable journal line-level population object.
  Downstream scripts can directly reference JOURNAL_POPULATION.
  ------------------------------------------------------------------------------------------*/
  
SELECT *
FROM FILTERED_POPULATION
WHERE POPULATION_SCOPE_FLAG = 'Y'
  

  












  



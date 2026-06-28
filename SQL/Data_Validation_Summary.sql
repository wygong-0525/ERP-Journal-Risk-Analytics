/* =============================================================================================================================================================
Script Name: Data_Validation_Summary.sql

Purpose:
Produce a data quality validation summary for the USD-translated journal population before the reconciliation testing.

Input:
USD_TRANSLATED_JOURNAL_POPULATION

Output:
DATA_VALIDATION_SUMMARY
============================================================================================================================================================= */

CREATE VIEW DATA_VALIDATION_SUMMARY AS

/* Test 1: Mandatory key fields should not be missing */

SELECT
  'MISSING_KEY_FIELD' AS VALIDATION_AREA,
  COUNT(*) AS EXCEPTION_COUNT,
  CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END AS VALIDATION_RESULT,
  'CHECK MISSING MANADATORY JOURNAL KEYS' AS VALIDATION_DESCRIPTION
FROM USD_TRANSLATED_JOURNAL_POPULATION
WHERE JE_HEADER_ID IS NULL
OR JE_LINE_NUM IS NULL
OR JE_LINE_KEY IS NULL
OR CODE_COMBINATION_ID IS NULL
OR COMPANY_CODE IS NULL
OR ACCOUNT_CODE IS NULL

UNION ALL

/* Test 2: Journal line key should be unique */

SELECT
  'DUPLICATE_JE_LINE_KEY',
  COUNT(*),
  CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END,
  'CHECK WHETHER EACH JE_LINE_KEY IS UNIQUE',
FROM (
  SELECT JE_LINE_KEY
  FROM USE_TRANSLATED_JOURNAL_POPULATION
  GROUP BY JE_LINE_KEY
  HAVING COUNT(*) > 1
) D

UNION ALL

/* TEST 3: Local/accounted journal should be balanced to zero. */

SELECT
'LOCAL_JOURNAL_BALANCED_TO_ZERO',
COUNT(*),
CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END,
'Check each journal balanced to zero in local/accounted currency'
FROM (
  SELECT JE_HEADER_ID
  FROM USD_TRANSLATED_JOURNAL_POPULATION
  GROUP BY JE_HEADER_ID
  HAVING ABS(ROUND(SUM(ACCOUNTED_NET))) > 0.01
  ) J

UNION ALL

/* TEST 4: FX translation should not have missing/invalid rates */
SELECT
'FX_TRANSLATION_EXCEPTION',
COUNT(*),
CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
'Check missing, zero, invalid, or unmapped FX records'
FROM USD_TRANSLATED_JOURNAL_POPULATION
WHERE FX_EXCEPTION_FLAG = 'Y'

UNION ALL

/* TEST 5: BS should use MONTH_END, PL should use MONTHLY_AVG */
SELECT
'FX_RATE_TYPE_VALIDATION',
COUNT(*),
CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
'Check BS lines use MONTH_END, and PL lines use MONTHLY_AVG.'
FROM USD_TRANSLATED_JOURNAL_POPULATION
WHERE LINE_CURRENCY_CODE <> 'USD'
AND (
  (BS_PL_FLAG = 'BS' AND APPLIED_RATE_TYPE <> 'MONTH_END')
OR(BS_PL_FLAG = 'PL' AND APPLIED_RATE_TYPE <> 'MONTHLY_AVG')
  )
)

SELECT *
FROM VALIDATION_TESTS















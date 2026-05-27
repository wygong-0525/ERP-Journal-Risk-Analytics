/* =================================================================================================================================
Script Name: FX_Translation_to_USD.sql

Purpose:
Translate journal line-level local currency amounts to USD.

Input:

1. Journal_Population
  - Clean journal line-level population created in the previous step.
  - LINE_CURRENCY_CODE is treated as the source local currency.

2. Raw FRED FX tables imported from CSV:
  - DEXUSUK: GBP/USD
  - DEXUSEU: EUR/USD
  - DEXJPUS: JPY/USD
  - DEXCAUS: CAD/USD
  - DEXBZUS: BRL/USD

Business Rules:
1. Balance sheet accounts use the MONTH_END rate.
2. Profit & Loss accounts use the MONTHLY_ACG rate.
3. USD lines use rate=1
4. Missing or invalid FX rates are flagged.
5. Translation is based on LINE_CURRENCY_CODE, not header currency.

Output:
USD_TRANSLATED_JOURNAL_POPULATION

================================================================================================================================= */

CREATE VIEW USD_TRANSLATED_JOURNAL_POPULATION AS

WITH FX_RAW_UNIONED AS (
  /* -------------------------------------------------------------------------------------------------------------------------------
  Step 1:
  Bring all raw FRED FX feeds into one common structure.

  Note:
  Each FRED file has a date column and a rate column.
  We manually assign FROM_CURRENCY and TO_CURRENCY here to ensure all feeds are treated consistently downstream.
  ------------------------------------------------------------------------------------------------------------------------------- */

SELECT
  observation_date AS RATE_DATE,
  'GBP' AS FROM_CURRENCY,
  'USD' AS TO_CURRENCY,
  DEXUSUK AS RAW_RATE,
  'DIRECT' AS QUOTE_METHOD,
  'DEXUSUK' AS SOURCE_SERIES
FROM DEXUSUK

UNION ALL

SELECT 
  observation_date AS RATE_DATE,
  'EUR' AS FROM_CURRENCY,
  'USD' AS TO_CURRENCY,
  DEXUSEU AS RAW_RATE,
  'DIRECT' AS QUOTE_METHOD,
  'DEXUSEU' AS SOURCE_SERIES
FROM DEXUSEU

UNION ALL

SELECT
  observation_date AS RATE_DATE,
  'JPY' AS FROM_CURRENCY,
  'USD' AS TO_CURRENCY,
  DEXJPUS AS RAW_RATE,
  'INVERSE' AS QUOTE_METHOD,
  'DEXJPUS' AS SOURCE_SERIES
FROM DEXJPUS

UNION ALL

SELECT
  observation_date AS RATE_DATE,
  'CAD' AS FROM_CURRENCY,
  'USD' AS TO_CURRENCY,
  DEXCAUS AS RAW_RATE,
  'INVERSE' AS QUOTE_METHOD,
  'DEXCAUS' AS SOURCE_SERIES
FROM DEXCAUS

UNION ALL

SELECT 
  observation_date AS RATE_DATE,
  'BRL' AS FROM_CURRENCY,
  'USD' AS TO_CURRENCY,
  DEXBZUS AS RAW_RATE,
  'INVERSE' AS QUOTE_METHOD,
  'DEXBZUS' AS SOURCE_SERIES
FROM DEXBZUS

),

FX_CLEANED AS (
  /* -------------------------------------------------------------------------------------------------------------------------------
  Step 2:
  Clean raw FX values and convert all rates into:

  USD amount for 1 unit of FROM_CURRENCY

  Direct:
  - GBP/EUR series are already USD per 1 foreign currency

  Inverse:
  - JPY/CAD/BRL series are quoted as local currency per 1 USD
  - Therefore, we use 1/rate to get USD per 1 local currency
  ------------------------------------------------------------------------------------------------------------------------------- */

SELECT
  RATE_DATE,
  FROM_CURRENCY,
  TO_CURRENCY,
  SOURCE_SERIES,
  QUOTE_METHOD,

  CASE 
  WHEN RAW_RATE IS NULL THEN NULL
  WHEN RAW_RATE = '.' THEN NULL
  ELSE CAST(RAW_RATE AS DECIMAL(18,8))
  END AS RAW_RATE_NUMERIC,

  CASE
  WHEN RAW_RATE IS NULL THEN 'INVALID'
  WHEN RAW_RATE = '.' THEN 'INVALID'
  WHEN CAST(RAW_RATE AS DECIMAL(18,8))=0 THEN 'INVALID'
  ELSE 'VALID'
  END AS RAW_RATE_STATUS

FROM FX_RAW_UNIONED

),

FX_USD_NORMALISED AS (
 
/* -------------------------------------------------------------------------------------------------------------------------------
  Step 3:
  Standardized all valid FX rates into USD conversion rates.
  This is the rate that will eventually be multiplied by the journal line amount.
  ------------------------------------------------------------------------------------------------------------------------------- */

SELECT
  RATE_DATE,
  FROM_CURRENCY,
  TO_CURRENCY,
  SOURCE_SERIES,

  CASE
  WHEN QUOTE_METHOD = 'DIRECT' THEN RAW_RATE_NUMERIC
  WHEN QUOTE_METHOD = 'INVERSE' THEN 1/RAW_RATE_NUMERIC
  ELSE NULL
  END AS USD_CONVERSION_RATE,

  CASE
  WHEN strftime('%m', RATE_DATE) = '01' THEN 'JAN-25'
  WHEN strftime('%m', RATE_DATE) = '02' THEN 'FEB-25'
  WHEN strftime('%m', RATE_DATE) = '03' THEN 'MAR-25'
  WHEN strftime('%m', RATE_DATE) = '04' THEN 'APR-25'
  WHEN strftime('%m', RATE_DATE) = '05' THEN 'MAY-25'
  WHEN strftime('%m', RATE_DATE) = '06' THEN 'JUN-25'
  WHEN strftime('%m', RATE_DATE) = '07' THEN 'JUL-25'
  WHEN strftime('%m', RATE_DATE) = '08' THEN 'AUG-25'
  WHEN strftime('%m', RATE_DATE) = '09' THEN 'SEP-25'
  WHEN strftime('%m', RATE_DATE) = '10' THEN 'OCT-25'
  WHEN strftime('%m', RATE_DATE) = '11' THEN 'NOV-25'
  WHEN strftime('%m', RATE_DATE) = '12' THEN 'DEC-25'
  END AS PERIOD_NAME

FROM FX_CLENED
  WHERE RAW_RATE_STATUS = 'VALID'
  AND RATE_DATE BETWEEN '2025-01-01' AND '2025-12-31'
  
),

MONTHLY_AVG_RATES AS (
  /* -------------------------------------------------------------------------------------------------------------------------------
  Step 4A:
  Generate monthly average FX rates.
  These will be used for profit and loss accounts because P&L represents activity across a period.
  ------------------------------------------------------------------------------------------------------------------------------- */
SELECT
  FROM_CURRENCY,
  TO_CURRENCY,
  PERIOD_NAME,
  'MONTHLY_AVG' AS RATE_TYPE,
  MAX(RATE_DATE) AS RATE_DATE,
  AVG(USD_CONVERSION_RATE) AS CONVERSION_RATE
  
FROM FX_USD_NORMALIZED
GROUP BY
  FROM_CURRENCY,
  TO_CURRENCY,
  PERIOD_NAME

),

MONTH_END_CANDIDATES AS (
  /* -------------------------------------------------------------------------------------------------------------------------------
  Step 4B:
  Rank daily FX rates within each currency and each period.
  The latest available business-day rate in each month will be selected as the month-end rate. 
  ------------------------------------------------------------------------------------------------------------------------------- */

SELECT
  FROM_CURRENCY,
  TO_CURRENCY,
  PERIOD_NAME,
  RATE_DATE,
  USD_CONVERSION_RATE,

  ROW_NUMBER() OVER(
  PARTITION BY FROM_CURRENCY, TO_CURRENCY, PERIOD_NAME
  ORDER BY RATE_DATE DESC
  ) AS MONTH_END_RANK

FROM FX_USD_NORMALIZED

),

MONTH_END_RATES AS (
  /* -------------------------------------------------------------------------------------------------------------------------------
  Step 4C:
  Generate month-end FX rates.
  These will be used for balance sheet accounts because BS balances represent a point-in-time position.
  ------------------------------------------------------------------------------------------------------------------------------- */

  SELECT
  FROM_CURRENCT,
  TO_CURRENCY,
  PERIOD_NAME,
  'MONTH_END' AS RATE_TYPE,
  RATE_DATE,
  USD_CONVERSION_RATE AS CONVERSION_RATE

  FROM MONTH_END_CANDIDATES
  WHERE MONTH_END_RANK = 1

),

FX_RATES_STANDARDISED AS (
  /* -------------------------------------------------------------------------------------------------------------------------------
  Step 5:
  Combine both FX rate types into one controlled FX reference layer.
  ------------------------------------------------------------------------------------------------------------------------------- */
SELECT * FROM MONTHLY_AVG_RATES
  UNION ALL
SELECT * FROM MONTH_END_RATES

),

JOURNAL_REQUIRED_RATE AS (
 /* -------------------------------------------------------------------------------------------------------------------------------
  Step 6:
  Determine which FX rate type each journal line needs.

  Important:
  - This is based on BS_PL_FLAG from JOURNAL_POPULATION.
  - It uses LINE_CURRENCY_CODE as the source currency.
  - Header currency is not used for translation.
  ------------------------------------------------------------------------------------------------------------------------------- */

SELECT
  JP.*,

  CASE 
  WHEN JP.LINE_CURRENCY_CODE = 'USD' THEN 'NO_RATE_REQUIRED'
  WHEN JP.BS_PL_FLAG = 'BS' THE 'MONTH_END'
  WHEN JP.BS_PL_FLAG = 'PL' THEN 'MONTHLY_AVG'
  ELSE 'UNMAPPED_ACCOUNT_CLASS'
  END AS REQUIRED_RATE_TYPE

FROM JOURNAL_POPULATION JP

),

JOURNAL_FX_ENRICHED AS (
  /* -------------------------------------------------------------------------------------------------------------------------------
  Step 7:
  Join each journal line to the appropriate FX rate.

  Join keys:
  - line local currency
  - USD target currency
  - period name
  - required rate type
  ------------------------------------------------------------------------------------------------------------------------------- */

SELECT
  JRR.*,

  FX.RATE_TYPE AS APPLIED_RATE_TYPE,
  FX.RATE_DATE AS APPLIED_RATE_DATE,
  FX.CONVERSION_RATE AS USD_CONVERSION_RATE,

  CASE 
  WHEN JRR.LINE_CURRENCY_CODE = 'USD' THEN 1
  ELSE FX.CONVERSION_RATE
  END AS EFFECTIVE_USD_RATE

FROM JOURNAL_REQUIRED_RATE JRR
  LEFT JOIN FX_RATE_STANDARDIZED FX
  ON JRR.LINE_CURRENCY_CODE = FX.FROM_CURRENCY
  AND FX.TO_CURRENCY = 'USD'
  AND JRR.PERIOND_NAME = FX.PERIOD_NAME
  AND JRR.REQUIRED_RATE_TYPE = FX.RATE_TYPE

),

TRANSLATED AS (
  /* -------------------------------------------------------------------------------------------------------------------------------
  Step 8:
  Apply FX translation to journal line amounts.
  The original line amount is not changed.
  New USD translated fields are added.
  ------------------------------------------------------------------------------------------------------------------------------- */

SELECT
  JFE.*,

  JFE.ENTERED_DR * JFE.EFFECTIVE_USD_RATE AS ENTERED_DR_USD,
  JFE.ENTERED_CR * JFE.EFFECTIVE_USD_RATE AS ENTERED_CR_USD,
  JFE.ENTERED_NET * JFE.EFFECTIVE_USD_RATE AS ENTERED_USD_NET,

  JFE.ACCOUNTED_DR * JFE.EFFECTIVE_USD_RATE AS ACCOUNTED_DR_USD,
  JFE.ACCOUNTED_CR * JFE.EFFECTIVE_USD_RATE AS ACCOUNTED_CR_USD,
  JFE.ACCOUNTED_NET * JFE.EFFECTIVE_USD_RATE AS ACCOUNTED_NET_USD,

  CASE
  WHEN JFE.LINE_CURRENCY_CODE = 'USD' THEN 'N'
  WHEN JFE.REQUIRED_RATE_TYPE = 'UNMAPPED_ACCOUNT_CLASS' THEN 'Y'
  WHEN JFE.USD_CONVERSION_RATE IS NULL THEN 'Y'
  WHEN JFE.USD_CONVERSION_RATE = 0 THEN 'Y'
  ELSE 'N'
  END AS FX_EXCEPTION_FLAG,

  CASE
  WHEN JFE.LINE_CURRENCY_CODE = 'USD'
  THEN 'NO TRANSLATION REQUIRED'
  WHEN JFE.REQUIRED_RATE_TYPE = 'UNMAPPED_ACCOUNT_CLASS'
  THEN 'ACCOUNT CLASS IS MAPPED TO BS OR PL'
  WHEN JFE.USD_CONVERSION_RATE IS NULL
  THEN 'MISSING FX RATE FOR CURRENCY/PERIOD/RATE TYPE'
  WHEN JFE.USD_CONVERSION_RATE = 0
  THEN 'ZERO FX RATE'
  ELSE 'FX TRANSLATED SUCCESSFULLY'
  END AS FX_TRANSLATION_STATUS

FROM JOURNAL_FX_ENRICHED JFE

)

SELECT *
FROM TRANSLATED
  



  

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

FX_USD_NORMALISED AS 
 
/* -------------------------------------------------------------------------------------------------------------------------------
  Step 3:
  Standardized all valid FX rates into USD conversion rates.
  This is the rate that will eventually be multiplied by the journal line amount.
  ------------------------------------------------------------------------------------------------------------------------------- */










  

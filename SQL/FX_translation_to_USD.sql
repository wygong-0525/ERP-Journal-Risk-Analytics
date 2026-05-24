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



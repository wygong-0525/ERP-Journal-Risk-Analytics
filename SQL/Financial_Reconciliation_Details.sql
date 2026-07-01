/* ================================================================================================================
Script Name: financial_reconciliation_detail.sql

Purpose:
Produce account-level reconciliation detail between journal movement and trial balance position in both local currency and
USD equivalent.

Inputs:
1. USD_TRANSLATED_JOURNAL_POPULATION
2. GL_BALANCES
3. GL_JE_CODE_COMBINATIONS
4. ENTITY_CURRENCY_MAPPING
5. FX_RATES_STANDARDIZED

INSERT INTO GL_LEDGERS (
  LEDGER_ID,
  LEDGER_NAME,
  DESCRIPTION,
  LEDGER_CATEGORY_CODE
)
VALUES
(1001, 'UK_PRIMARY', 'UK_PRIMARY_LEDGER', 'PRIMARY'),
(1002, 'EU_PRIMARY', 'EU_PRIMARY_LEDGER', 'PRIMARY');

INSERT INTO FND_USER (
    USER_ID,
    USER_NAME,
    USER_DESCRIPTION
)
VALUES
(101, 'FIN_USER_1', 'Finance user manual postings'),
(102, 'FIN_USER_2', 'Finance user recurring journals'),
(201, 'SYSTEM_USER', 'System generated journals'),
(301, 'UPLOAD_USER', 'Spreadsheet upload user');

INSERT INTO GL_JE_BATCHES (
    JE_BATCH_ID,
    NAME,
    DESCRIPTION
)
VALUES
(5001, 'JAN25_BATCH', 'January batch'),
(5002, 'FEB25_BATCH', 'February batch'),
(5003, 'MAR25_BATCH', 'March batch'),
(5004, 'APR25_BATCH', 'April batch'),
(5005, 'MAY25_BATCH', 'May batch'),
(5006, 'JUN25_BATCH', 'June batch'),
(5007, 'JUL25_BATCH', 'July batch'),
(5008, 'AUG25_BATCH', 'August batch'),
(5009, 'SEP25_BATCH', 'September batch'),
(5010, 'OCT25_BATCH', 'October batch'),
(5011, 'NOV25_BATCH', 'November batch'),
(5012, 'DEC25_BATCH', 'December batch');

INSERT INTO GL_JE_CODE_COMBINATIONS (
    CODE_COMBINATION_ID,
    ACCOUNT_TYPE,
    SUMMARY_FLAG,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4
)
VALUES
(10001, 'A', 'N', 101, 110, 100000, 0),   -- Cash
(10002, 'A', 'N', 101, 110, 110000, 0),   -- Accounts Receivable
(10003, 'L', 'N', 101, 110, 200000, 0),   -- Accounts Payable
(10004, 'O', 'N', 101, 110, 300000, 0),   -- Retained Earnings/Equity
(10005, 'R', 'N', 101, 110, 400000, 0),   -- Revenue
(10006, 'E', 'N', 101, 110, 500000, 0),   -- Salary Expense
(10007, 'E', 'N', 101, 110, 510000, 0),   -- Rent Expense
(10008, 'R', 'N', 101, 110, 520000, 0);   -- FX Gain/Loss/Other income

INSERT INTO GL_JE_HEADER (
    JE_HEADER_ID,
    LEDGER_ID,
    JE_SOURCE,
    NAME,
    CURRENCY_CODE,
    STATUS,
    ACTUAL_FLAG,
    CREATED_BY,
    JE_BATCH_ID,
    DESCRIPTION,
    REVERSED_JE_HEADER_ID
)
VALUES
(9001, 1001, 'Manual',      'JAN25_JE', 'GBP', 'P', 'A', 101, 5001, 'January revenue journal', NULL),
(9002, 1001, 'Spreadsheet', 'FEB25_JE', 'EUR', 'P', 'A', 301, 5002, 'February rent journal', NULL),
(9003, 1001, 'System',      'MAR25_JE', 'BRL', 'P', 'A', 201, 5003, 'March payroll journal', NULL),
(9004, 1001, 'Manual',      'APR25_JE', 'JPY', 'P', 'A', 102, 5004, 'April receivable journal', NULL),
(9005, 1001, 'Manual',      'MAY25_JE', 'CAD', 'P', 'A', 101, 5005, 'May revenue journal', NULL),
(9006, 1001, 'Spreadsheet', 'JUN25_JE', 'GBP', 'P', 'A', 301, 5006, 'June rent journal', NULL),
(9007, 1001, 'System',      'JUL25_JE', 'EUR', 'P', 'A', 201, 5007, 'July payroll journal', NULL),
(9008, 1001, 'Manual',      'AUG25_JE', 'BRL', 'P', 'A', 102, 5008, 'August receivable journal', NULL),
(9009, 1001, 'Manual',      'SEP25_JE', 'JPY', 'P', 'A', 101, 5009, 'September revenue journal', NULL),
(9010, 1001, 'Spreadsheet', 'OCT25_JE', 'CAD', 'P', 'A', 301, 5010, 'October rent journal', NULL),
(9011, 1001, 'System',      'NOV25_JE', 'GBP', 'P', 'A', 201, 5011, 'November payroll journal', NULL),
(9012, 1001, 'Manual',      'DEC25_JE', 'EUR', 'P', 'A', 102, 5012, 'December receivable journal', NULL);

INSERT INTO GL_JE_LINES (
    JE_HEADER_ID,
    JE_LINE_NUM,
    CODE_COMBINATION_ID,
    ENTERED_DR,
    ENTERED_CR,
    ACCOUNTED_DR,
    ACCOUNTED_CR,
    CURRENCY_CODE,
    DESCRIPTION,
    PERIOD_NAME,
    EFFECTIVE_DATE,
    CREATION_DATE
)
VALUES
(9001, 1, 10001, 1000.00, 0.00, 1250.00, 0.00, 'GBP', 'Cash receipt', 'JAN25', '2025-01-31', '2025-01-31'),
(9001, 2, 10005, 0.00, 1000.00, 0.00, 1250.00, 'GBP', 'Revenue recognition', 'JAN25', '2025-01-31', '2025-01-31'),

(9002, 1, 10007, 300.00, 0.00, 375.00, 0.00, 'EUR', 'Rent expense', 'FEB25', '2025-02-28', '2025-02-28'),
(9002, 2, 10003, 0.00, 300.00, 0.00, 375.00, 'EUR', 'Accrued payable', 'FEB25', '2025-02-28', '2025-02-28'),

(9003, 1, 10006, 500.00, 0.00, 625.00, 0.00, 'BRL', 'Salary expense', 'MAR25', '2025-03-31', '2025-03-31'),
(9003, 2, 10003, 0.00, 500.00, 0.00, 625.00, 'BRL', 'Payroll payable', 'MAR25', '2025-03-31', '2025-03-31'),

(9004, 1, 10002, 800.00, 0.00, 1000.00, 0.00, 'JPY', 'Accounts receivable', 'APR25', '2025-04-30', '2025-04-30'),
(9004, 2, 10005, 0.00, 800.00, 0.00, 1000.00, 'JPY', 'Revenue posting', 'APR25', '2025-04-30', '2025-04-30'),

(9005, 1, 10001, 1200.00, 0.00, 1500.00, 0.00, 'CAD', 'Cash receipt', 'MAY25', '2025-05-31', '2025-05-31'),
(9005, 2, 10005, 0.00, 1200.00, 0.00, 1500.00, 'CAD', 'Revenue recognition', 'MAY25', '2025-05-31', '2025-05-31'),

(9006, 1, 10007, 350.00, 0.00, 437.50, 0.00, 'GBP', 'Rent expense', 'JUN25', '2025-06-30', '2025-06-30'),
(9006, 2, 10003, 0.00, 350.00, 0.00, 437.50, 'GBP', 'Accrued payable', 'JUN25', '2025-06-30', '2025-06-30'),

(9007, 1, 10006, 550.00, 0.00, 687.50, 0.00, 'EUR', 'Salary expense', 'JUL25', '2025-07-31', '2025-07-31'),
(9007, 2, 10003, 0.00, 550.00, 0.00, 687.50, 'EUR', 'Payroll payable', 'JUL25', '2025-07-31', '2025-07-31'),

(9008, 1, 10002, 900.00, 0.00, 1125.00, 0.00, 'BRL', 'Accounts receivable', 'AUG25', '2025-08-31', '2025-08-31'),
(9008, 2, 10005, 0.00, 900.00, 0.00, 1125.00, 'BRL', 'Revenue posting', 'AUG25', '2025-08-31', '2025-08-31'),

(9009, 1, 10001, 1100.00, 0.00, 1375.00, 0.00, 'JPY', 'Cash receipt', 'SEP25', '2025-09-30', '2025-09-30'),
(9009, 2, 10005, 0.00, 1100.00, 0.00, 1375.00, 'JPY', 'Revenue recognition', 'SEP25', '2025-09-30', '2025-09-30'),

(9010, 1, 10007, 320.00, 0.00, 400.00, 0.00, 'CAD', 'Rent expense', 'OCT25', '2025-10-31', '2025-10-31'),
(9010, 2, 10003, 0.00, 320.00, 0.00, 400.00, 'CAD', 'Accrued payable', 'OCT25', '2025-10-31', '2025-10-31'),

(9011, 1, 10006, 600.00, 0.00, 750.00, 0.00, 'GBP', 'Salary expense', 'NOV25', '2025-11-30', '2025-11-30'),
(9011, 2, 10003, 0.00, 600.00, 0.00, 750.00, 'GBP', 'Payroll payable', 'NOV25', '2025-11-30', '2025-11-30'),

(9012, 1, 10002, 1000.00, 0.00, 1250.00, 0.00, 'EUR', 'Accounts receivable', 'DEC25', '2025-12-31', '2025-12-31'),
(9012, 2, 10005, 0.00, 1000.00, 0.00, 1250.00, 'EUR', 'Revenue posting', 'DEC25', '2025-12-31', '2025-12-31');

INSERT INTO GL_BALANCES (
    LEDGER_ID,
    CODE_COMBINATION_ID,
    CURRENCY_CODE,
    PERIOD_NAME,
    PERIOD_NET_DR,
    PERIOD_NET_CR,
    BEGIN_BALANCE_DR,
    BEGIN_BALANCE_CR
)
VALUES
-- Cash (Asset)
(1001, 10001, 'GBP', 'DEC-25', 3300.00, 0.00, 2000.00, 0.00),
-- Accounts Receivable (Asset)
(1001, 10002, 'GBP', 'DEC-25', 2700.00, 0.00, 1500.00, 0.00),
-- Accounts Payable (Liability)
(1001, 10003, 'GBP', 'DEC-25', 0.00, 2620.00, 0.00, 1000.00),
-- Retained Earnings (Equity)
(1001, 10004, 'GBP', 'DEC-25', 0.00, 2000.00, 0.00, 5000.00),
-- Revenue
(1001, 10005, 'GBP', 'DEC-25', 0.00, 6000.00, 0.00, 0.00),
-- Salary Expense
(1001, 10006, 'GBP', 'DEC-25', 1650.00, 0.00, 0.00, 0.00),
-- Rent Expense
(1001, 10007, 'GBP', 'DEC-25', 970.00, 0.00, 0.00, 0.00),
-- FX Gain/Loss (Revenue type)
(1001, 10008, 'GBP', 'DEC-25', 0.00, 200.00, 0.00, 0.00);







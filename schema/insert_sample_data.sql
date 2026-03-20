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
(10004, 'O', 'N', 101, 110, 300000, 0),   -- Retained Earnings / Equity
(10005, 'R', 'N', 101, 110, 400000, 0),   -- Revenue
(10006, 'E', 'N', 101, 110, 500000, 0),   -- Salary Expense
(10007, 'E', 'N', 101, 110, 510000, 0),   -- Rent Expense
(10008, 'R', 'N', 101, 110, 520000, 0);   -- FX Gain/Loss / Other income













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
(5001, 'JAN25_MANUAL_BATCH', 'January manual adjustment batch'),
(5002, 'JAN25_UPLOAD_BATCH', 'January spreadsheet upload batch'),
(5003, 'FEB25_SYSTEM_BATCH', 'February system-generated batch');

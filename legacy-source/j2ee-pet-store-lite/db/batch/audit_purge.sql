-- PSL_AUDIT_PURGE: delete sign-on audit events older than 90 days.
-- Runs only after PSL_AUDIT_EXTRACT so every row has been extracted first.
AUTOCOMMIT OFF;

DELETE FROM signon_audit
 WHERE event_ts < {fn TIMESTAMPADD(SQL_TSI_DAY, -90, CAST(CURRENT_DATE AS TIMESTAMP))};

COMMIT;

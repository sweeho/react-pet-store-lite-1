-- PSL_AUDIT_EXTRACT: export yesterday's sign-on audit events for the
-- security team. Output: /var/petstore/extract/signon_audit_extract.csv
-- (the script renames it to signon_audit_YYYYMMDD.csv).
CALL SYSCS_UTIL.SYSCS_EXPORT_QUERY(
  'SELECT audit_id, username, event_type, event_ts, remote_addr
     FROM signon_audit
    WHERE event_ts >= {fn TIMESTAMPADD(SQL_TSI_DAY, -1, CAST(CURRENT_DATE AS TIMESTAMP))}
      AND event_ts <  CAST(CURRENT_DATE AS TIMESTAMP)
    ORDER BY audit_id',
  '/var/petstore/extract/signon_audit_extract.csv', ',', '"', 'UTF-8');

-- PSL_SIGNON_REPORT: daily sign-on statistics for yesterday.
SELECT event_type, COUNT(*) AS events, COUNT(DISTINCT username) AS users
  FROM signon_audit
 WHERE event_ts >= {fn TIMESTAMPADD(SQL_TSI_DAY, -1, CAST(CURRENT_DATE AS TIMESTAMP))}
   AND event_ts <  CAST(CURRENT_DATE AS TIMESTAMP)
 GROUP BY event_type
 ORDER BY event_type;

SELECT COUNT(*) AS locked_accounts FROM signon WHERE locked = 'Y';

SELECT role, COUNT(*) AS accounts FROM signon GROUP BY role;

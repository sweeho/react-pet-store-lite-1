-- PSL_ACCT_UNLOCK: unlock sign-on accounts locked for more than 30 minutes.
-- Business rule: 3 failed sign-ons in a row lock an account (UserDAO).
-- A lock is cleared automatically 30 minutes after it was set.
AUTOCOMMIT OFF;

INSERT INTO signon_audit (username, event_type, event_ts, remote_addr)
  SELECT username, 'ACCOUNT_UNLOCKED', CURRENT_TIMESTAMP, 'batch:PSL_ACCT_UNLOCK'
    FROM signon
   WHERE locked = 'Y'
     AND locked_ts < {fn TIMESTAMPADD(SQL_TSI_MINUTE, -30, CURRENT_TIMESTAMP)};

UPDATE signon
   SET locked = 'N', failed_attempts = 0, locked_ts = NULL
 WHERE locked = 'Y'
   AND locked_ts < {fn TIMESTAMPADD(SQL_TSI_MINUTE, -30, CURRENT_TIMESTAMP)};

COMMIT;

# Design notes: sign-on-audit (legacy implementation)

These notes record how the legacy Java Pet Store Lite implements the sign-on audit trail.
They describe the legacy system only. The visible contract of the My Account page is in
`specs/sign-on-audit/spec.md`; nothing here replaces it.

## Sources read

- IR pass files with `capability_key: sign-on-audit` (112 pass records, 103 distinct
  module/record pairs) across: `inventory/ddl-export-default-001..003`, `db/schema`,
  `db/batch`, `batch`, `scheduler/control-m`, `conf`, `Dockerfile`, `docs/guides`,
  `src/main/java/.../signon`, `src/main/java/.../waf`, `src/main/webapp`,
  `src/main/webapp/populate`, `data/seed`, `data/interface`, `data/migration`,
  `data/generate_history.py`, `vortex/samples`.
- Legacy source checked directly: `db/schema/petstore_derby.sql:84-99`,
  `db/schema/petstore_oracle.sql:84-110`, `signon/dao/UserDAO.java:83-264`,
  `signon/web/AccountHelper.java:51-69`, `signon/web/SignOffServlet.java:56-72`,
  `webapp/account.jsp`, `WEB-INF/screendefinitions_en_US.xml:90-96`,
  `WEB-INF/signon-config.xml:27-28`, `db/batch/{acct_unlock,audit_extract,audit_purge,signon_report}.sql`,
  `batch/psl_{audit_extract,signon_report,audit_purge}.sh`,
  `scheduler/control-m/PSL_PETSTORE.xml:20-60`, `webapp/populate/PopulateSQL.xml:170-190,348-368`,
  `docs/guides/admin-guide.html:50-66`, `docs/guides/user-guide.html:130-148`.

## Storage

- Table `SIGNON_AUDIT(audit_id, username varchar(25) NOT NULL, event_type varchar(20) NOT NULL,
event_ts timestamp NOT NULL, remote_addr varchar(45) NULL)`, primary key `audit_id`, CHECK
  `ck_signon_audit_event` holding the seven event codes. Identical in both dialects.
- Id generation differs by DDL: Derby uses `generated always as identity`; the Oracle schema
  script uses sequence `signon_audit_seq` plus trigger `trg_signon_audit_id`; the Oracle block of
  `PopulateSQL.xml` creates `audit_id number(19) NOT NULL` with no generator. Every insert omits
  `audit_id`, so an Oracle database built by populate would refuse every audit write. Recorded
  as disputed (`SOA-RULE-0001`, `SAUD-BR-0002`); which DDL built production Oracle is unknown.
- No foreign key from `username` to `SIGNON`, which is why failures for unknown names are stored.
- Indexes `idx_signon_audit_user_ts(username, event_ts)` (My Account query) and
  `idx_signon_audit_ts(event_ts)` (extract, report and purge range predicates).

## Writers

- `UserDAO.audit()` is the only runtime writer. It inserts `(username, event_type, event_ts,
remote_addr)` with `event_ts` taken from the application server clock
  (`new Timestamp(System.currentTimeMillis())`) and `remote_addr` from
  `request.getRemoteAddr()`.
- Call sites: `authenticate` writes SIGNON_FAIL for unknown names (line 118), SIGNON_LOCKED when
  the account is locked (128, checked before the password), SIGNON_OK (138), SIGNON_FAIL then
  ACCOUNT_LOCKED on the locking failure (150, 152); `createUser` writes USER_CREATED (188);
  `recordSignOff` writes SIGNOFF (218), called by `SignOffServlet` only when the session holds a
  signed-on user name. An audit failure on sign-off is caught and only logged to stderr; the
  sign-off still completes.
- `db/batch/acct_unlock.sql` (job PSL_ACCT_UNLOCK, every 15 minutes) inserts ACCOUNT_UNLOCKED with
  `CURRENT_TIMESTAMP` (database clock) and `remote_addr = 'batch:PSL_ACCT_UNLOCK'`, then clears
  the lock, both under one `COMMIT`. The insert and the update repeat the same predicate
  (`locked_ts` older than 30 minutes) against `CURRENT_TIMESTAMP`, evaluated separately.
- Manual unlock procedure in `admin-guide.html:63-65` inserts ACCOUNT_UNLOCKED with
  `remote_addr = 'admin'`. Not code; an operator runbook step.
- `PopulateSQL.xml` insert uses `current_timestamp` (database clock) for seeded rows.
- `UserDAO` has no constant for ACCOUNT_UNLOCKED; only the batch and manual paths write it.

The runtime writer uses the application clock and the batch writers use the database clock. On
a single host these agree; the rebuild should note that the extract and purge windows are
computed on the database clock.

## My Account page

- Screen `account` in `screendefinitions_en_US.xml:90-96`: title "My Account", body `/account.jsp`
  on the shared banner/sidebar/footer template. Protected by `signon-config.xml:27-28`
  (`account.screen`); the sign-on filter shows the Sign In page to an anonymous visitor.
- `account.jsp` instantiates `AccountHelper` in request scope, sets `userName` from the session
  attribute `j_signon_username`, and reads `role` (`UserDAO.getRole`) and `recentActivity`
  (`UserDAO.getRecentActivity(userName, 10)`).
- `SELECT_AUDIT`: `select event_type, event_ts, remote_addr from signon_audit where username = ?
order by event_ts desc, audit_id desc`; the loop stops after 10 rows (no SQL row limit).
  `event_type` is trimmed.
- Time is rendered with `fmt:formatDate pattern="yyyy-MM-dd HH:mm:ss"`, server default time zone.
  Event codes are displayed raw; the meaning of each code is documented only in the user guide
  table (`user-guide.html:137-146`).
- The four screen records come from four modules describing this one page
  (`waf` AUDT-SCR-0001; `docs/guides` AUD-SCR-0001/SOA-SCR-0001; `signon` AUD-REQ-0002/
  AUDIT-SCR-0003; `webapp` AUD-SCR-0001/SOA-SCR-0001). The spec splits them into page access,
  identity display, activity selection and activity row format.

## Batch chain (Control-M `PSL_PETSTORE.xml`)

| Job               | When                           | In-condition         | Effect                                                                                                                      |
| ----------------- | ------------------------------ | -------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| PSL_DB_BACKUP     | daily                          | -                    | sets PSL_DB_BACKUP-OK; failure mails ops (urgent)                                                                           |
| PSL_AUDIT_EXTRACT | daily from 01:30, MAXRERUN=1   | PSL_DB_BACKUP-OK     | consumes backup-OK, sets PSL_AUDIT_EXTRACT-OK; failure mails `psl-security` (regular): "Sign-on audit extract not produced" |
| PSL_SIGNON_REPORT | daily from 01:45               | PSL_AUDIT_EXTRACT-OK | writes report                                                                                                               |
| PSL_AUDIT_PURGE   | Sunday (WEEKDAYS=0) from 02:00 | PSL_AUDIT_EXTRACT-OK | consumes extract-OK, deletes                                                                                                |

- Extract: `audit_extract.sql` calls `SYSCS_UTIL.SYSCS_EXPORT_QUERY` for
  `event_ts >= CURRENT_DATE - 1 day AND event_ts < CURRENT_DATE ORDER BY audit_id` with `,`
  delimiter, `"` quoting, UTF-8, to `/var/petstore/extract/signon_audit_extract.csv`.
  `psl_audit_extract.sh` removes any stale export, runs it, renames to
  `signon_audit_$(date -d yesterday +%Y%m%d).csv` and appends `TRAILER,$DAY,$(wc -l)`. The day is
  computed by the shell and the window by the database; both use "yesterday" of the same host.
  The extract directory comes from `PSL_EXTRACT_DIR` (`conf/env.sh`; created in the `Dockerfile`).
  Timestamp text (`2026-10-29 09:23:47.0`) is Derby's export rendering, seen in
  `data/interface/signon_audit_20261029.csv`.
- Report: `signon_report.sql` emits three result sets (per event type: count and distinct users
  for yesterday; `COUNT(*)` of `locked='Y'` now; accounts per role now). The file is raw `ij`
  output redirected by `psl_signon_report.sh`; there is no further formatting.
- Purge: `audit_purge.sql` deletes `event_ts < CURRENT_DATE - 90 days` and commits once.
  Retention 90 is `batch.audit.retentionDays` in `conf/petstore.properties:36` and
  `PSL_AUDIT_RETENTION_DAYS` in `conf/env.sh:11`, but the SQL hard-codes `-90`; the setting is only
  logged.

## Evidence quality and open points

- Approved: `AUD-ENT-0001` (SWHR5-R-0010), `AUDIT-BR-0007` (SWHR5-R-0011), `AUDIT-INT-0004`
  (SWHR5-R-0012). `AUD-ENT-0001` exists in five modules with different wording; the approved
  requirement is written from the `signon` module record, which the DDL and DAO SQL back. The
  other variants carry field lists that agree with it, plus the batch origin marker, which the spec
  states separately as a draft.
- Empty-day extract (trailer with count 0) is inferred from the script; no sample of an empty day
  exists (`SIGNON-AUDIT-RULE-0002`, low).
- Extract time zone and fractional-seconds format rest on one sample file (`SOA-INT-0006`, low).
- The control-m rerun (MAXRERUN=1) and the alert are from scheduler config only; no run history
  was read.
- Sample data (`vortex/samples`, `data/seed`, `data/migration`) show 1,686 events over
  2026-08-01..2026-10-29 with contiguous ids; counts describe the extract, not behaviour.

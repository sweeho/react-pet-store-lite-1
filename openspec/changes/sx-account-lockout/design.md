## Context

How the legacy J2EE Pet Store Lite implements account lockout. Notes only; the target design is drafted later by the Architect once the Product Requirement is approved.

### Where each rule lives in the legacy tree

All paths are under `legacy-source/j2ee-pet-store-lite/`.

| Concern                | Legacy location                                                                                                                                                                        |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Threshold of 3         | `src/main/java/com/sun/j2ee/blueprints/signon/dao/UserDAO.java:69` (`MAX_FAILED_ATTEMPTS = 3`, hard-coded)                                                                             |
| Count, lock, refusal   | `UserDAO.authenticate`, lines 105-160                                                                                                                                                  |
| Locked outcome routing | `signon/web/SignOnFilter.java:78` (`LOCKED_PAGE = "signon_locked.screen"`) and lines 221-223 (redirect)                                                                                |
| Locked page            | `src/main/webapp/signon_locked.jsp:5-9`; screen `signon_locked` in `src/main/webapp/WEB-INF/screendefinitions_en_US.xml:69-75`                                                         |
| Schema                 | `db/schema/petstore_derby.sql:69-81` (`signon.failed_attempts`, `locked char(1) default 'N' not null`, `ck_signon_locked check (locked in ('Y','N'))`, `locked_ts timestamp` nullable) |
| Unlock SQL             | `db/batch/acct_unlock.sql:6-17`                                                                                                                                                        |
| Unlock wrapper         | `batch/psl_acct_unlock.sh`                                                                                                                                                             |
| Schedule               | `scheduler/control-m/PSL_PETSTORE.xml:78-84` (job `PSL_ACCT_UNLOCK`, cyclic interval 15M, 0000-2359, all weekdays)                                                                     |
| Configuration          | `conf/petstore.properties:15-16` (`signon.maxFailedAttempts=3`, `signon.unlockAfterMinutes=30`)                                                                                        |
| Documents              | Admin Guide PSL-AG-01 §2 rules R1-R5 and §2.1; User Guide PSL-UG-01 §5.3 and §6; Operations Runbook PSL-RB-01 §2 and §3.6                                                              |

### Sign-in path (`UserDAO.authenticate`)

1. Select the `signon` row by exact user name. No row: write `SIGNON_FAIL` against the typed name and return `SIGNON_INVALID`. No account counter is touched.
2. `locked = 'Y'`: write `SIGNON_LOCKED` and return `SIGNON_LOCKED`. The lock is checked before the password, so the correct password does not help and the counter is not changed.
3. Password matches (`String.equals`, so a blank password is simply wrong): `failed_attempts = 0`, `last_signon = now`, write `SIGNON_OK`.
4. Otherwise `failed_attempts++`; when it is `>= 3`, set `locked='Y'`, `locked_ts=now`. Write `SIGNON_FAIL`, then, when locked, `ACCOUNT_LOCKED`, and return `SIGNON_LOCKED` so the locking attempt itself lands on the locked page.

The two audit inserts use separate calls to `audit()` on one connection; the code gives both the time of the attempt, but `data/generate_history.py:86-88` and the interface sample extract place `ACCOUNT_LOCKED` about 20 seconds later. That is the dispute carried on LOCK-BR-0008.

The unlock path does not reset the counter in Java; only the batch SQL and the documented manual SQL do.

### Unlock batch (`acct_unlock.sql`)

Runs with `AUTOCOMMIT OFF`: one `INSERT ... SELECT` writes `ACCOUNT_UNLOCKED` with `remote_addr = 'batch:PSL_ACCT_UNLOCK'` for every `locked='Y' AND locked_ts < now - 30 minutes`, then one `UPDATE` sets `locked='N', failed_attempts=0, locked_ts=NULL` with the same predicate, then `COMMIT`. Consequences:

- The comparison is strict `<`, so a lock exactly 30 minutes old waits for the next run; the effective lock lasts more than 30 and up to about 45 minutes.
- A row with `locked='Y'` and `locked_ts IS NULL` never matches and is never released automatically. Nothing in the schema forbids that state. Whether it occurs in production is open.
- Each statement evaluates `CURRENT_TIMESTAMP` separately; a lock crossing the 30-minute line between the two statements could in principle get an audit row without a release or the reverse. Not observed; noted only.

### Configuration not read

`conf/petstore.properties` declares `signon.maxFailedAttempts=3` and `signon.unlockAfterMinutes=30` with the comment "must match UserDAO and CreateUserServlet". The Java threshold is a literal constant and the SQL threshold is a literal `-30`; neither reads the property. Changing the property changes nothing.

### Manual unlock

Admin Guide §2.1 states there is no unlock screen and gives operators SQL that clears the lock and counter for one user and inserts `ACCOUNT_UNLOCKED` with `remote_addr = 'admin'`. An on-demand run of `PSL_ACCT_UNLOCK` applies the same 30-minute threshold, so it cannot release a recent lock.

### Account Locked page (legacy rendering)

Rendered by `signon_locked.jsp` inside the shared template (banner, sidebar, footer) as screen `signon_locked`, reached by an HTTP redirect from the sign-on filter. The copy hard-codes "3" and "30 minutes"; it does not mention the up-to-45-minute delay that the User Guide warns about. The catalog link targets `main.screen`.

### Record consolidation

The extraction produced the same rules from many modules under colliding keys. The spec writes one requirement per behaviour; corroborating records are:

- Count and reset: signon `LOCK-BR-0001` (a and b); also docs/guides `LOCK-BR-0001`, `AL-BR-0001`, `LOCKOUT`/samples `LOCK-BR-0003`, `ACCTLOCK-BR-0002`, `LOCK-RULE-0002`.
- Lock at 3: `AL-BR-0001`; also signon `LOCK-BR-0002`, conf `ACCOUNT-LOCKOUT-BR-0001`, webapp `LOCK-RUL-0001` / `AL-BR-0002`, seed, migration and samples records.
- Refusal while locked: signon `LOCK-BR-0003`; also docs/guides `LOCK-BR-0002`/`LOCK-BR-0003`, `AL-BR-0002`, `ACCTLOCK-BR-0003`, `LOCK-RULE-0003`, `LOCKOUT-BR-0002`.
- Scheduled unlock: `LOCK-WF-0004`; also `AL-WF-0001`, `LOCK-WF-0001`, batch, db/batch, scheduler, seed, migration and samples records.
- No unlock screen / manual unlock: `LOCK-BR-0005` and `LOCK-REQ-0002`; also `LOCK-REQ-0005`, `AL-REQ-0001`, docs/guides `LOCK-REQ-0001`.
- Lock state: `LOCK-ENT-0001`, `ALK-ENT-0001`, `AL-ENT-0001`, `AL-RULE-0001`, `ALCK-ENT-0001`.
- Role-independence: `LOCK-RULE-0005`, migration `LOCK-BR-0004`, seed `LOCK-BR-0004`, `ACCTLOCK-BR-0005`.
- Screens: `LOCK-SCR-0001` (webapp a, waf b), `AL-SCR-0001`, `LOCK-SCR-0006`.

## Goals / Non-Goals

Goals: record where and how the legacy application enforces lockout so the rebuild can match it. Non-goals: the credential check itself and the audit trail's retention and extract, which belong to other capabilities.

## Risks / Trade-offs

- LOCK-BR-0008 (audit timing) is disputed between code and sample data; an external consumer may depend on either.
- Locked-without-time accounts are never auto-released in legacy; the rebuild needs a decision.
- Several samples-derived records (`ACCTLOCK-BR-0004`, `LOCK-RULE-0004`) say "at least 30 minutes"; the SQL is strictly more than 30. The code is authoritative.

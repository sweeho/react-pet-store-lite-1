# Design notes: batch-operations (legacy implementation)

These notes record how the legacy Petstore Lite application implements its batch operations. They describe the system being replaced, not the one replacing it. All paths are under `legacy-source/j2ee-pet-store-lite/`.

## User interface

No screen records were extracted for this capability; its user interface is unspecified. The jobs are run by the scheduler or by an operator from a shell, and their only outputs are files, exit codes, log lines and mail.

## Components

| Concern                               | Legacy location                                                                                                                                |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Schedule, chaining, reruns, alerts    | `scheduler/control-m/PSL_PETSTORE.xml` (Control-M export, folders `PSL_PETSTORE_DAILY` and `PSL_PETSTORE_CYCLIC`)                              |
| Job wrappers                          | `batch/psl_db_backup.sh`, `psl_audit_extract.sh`, `psl_signon_report.sh`, `psl_audit_purge.sh`, `psl_catalog_check.sh`, `psl_acct_unlock.sh`   |
| Shared environment and helpers        | `conf/env.sh` (`psl_ij`, `psl_log`, folder defaults, DB URL)                                                                                   |
| Declared settings (not actually read) | `conf/petstore.properties`                                                                                                                     |
| SQL run by the jobs                   | `db/batch/*.sql`, executed with Derby `ij` over the network client                                                                             |
| Packaging                             | `Dockerfile` (Tomcat 9, Derby network server on 0.0.0.0:1527, `/var/petstore/{db,backup,extract,log}`), `pom.xml` (Derby jars at server level) |
| Operator documentation                | `docs/guides/operations-runbook.html` (sections 2 to 4), administrator guide                                                                   |

## Schedule (Control-M)

| Job               | Start                        | Days                      | In-condition           | Out-condition                                              | Rerun                                      | On failure                                                                 |
| ----------------- | ---------------------------- | ------------------------- | ---------------------- | ---------------------------------------------------------- | ------------------------------------------ | -------------------------------------------------------------------------- |
| PSL_DB_BACKUP     | 01:00                        | ALL (+ `DAYSCAL=PSL_CAL`) | none                   | `PSL_DB_BACKUP-OK` +                                       | `MAXRERUN=2`, `INTERVAL=10M`, `CRITICAL=1` | urgent mail to psl-ops, "Petstore DB backup failed, audit extract is held" |
| PSL_AUDIT_EXTRACT | 01:30                        | ALL                       | `PSL_DB_BACKUP-OK`     | consumes `PSL_DB_BACKUP-OK`, sets `PSL_AUDIT_EXTRACT-OK`   | `MAXRERUN=1`, no interval                  | regular mail to psl-security, "Sign-on audit extract not produced"         |
| PSL_SIGNON_REPORT | 01:45                        | ALL                       | `PSL_AUDIT_EXTRACT-OK` | `PSL_SIGNON_REPORT-OK`                                     | none                                       | none                                                                       |
| PSL_AUDIT_PURGE   | 02:00                        | Sunday (`WEEKDAYS=0`)     | `PSL_AUDIT_EXTRACT-OK` | consumes `PSL_AUDIT_EXTRACT-OK`, sets `PSL_AUDIT_PURGE-OK` | none                                       | none                                                                       |
| PSL_CATALOG_CHECK | 06:00                        | ALL                       | none                   | `PSL_CATALOG_CHECK-OK`                                     | none, `CRITICAL=1`                         | urgent mail to psl-catalog on `COMPSTAT=4` only                            |
| PSL_ACCT_UNLOCK   | every 15 min, 00:00 to 23:59 | ALL                       | none                   | none                                                       | none                                       | none                                                                       |

The same order is restated in each script header and in runbook section 2 (table and diagram).

## Shared helpers (`conf/env.sh`)

- `psl_ij <script.sql>` runs `org.apache.derby.tools.ij` with the derbytools and derbyclient 10.14.2.0 jars from `$DERBY_LIB` (default `/usr/local/tomcat/lib`) against `jdbc:derby://localhost:1527//var/petstore/db/PetStoreDB` as `estoreuser`. It echoes the output and returns 1 only when an output line starts with `ERROR`; the java exit status is ignored.
- `psl_log <msg>` appends `YYYY-MM-DD HH:MM:SS [<PSL_JOB>] <msg>` to `$PSL_LOG_DIR/batch.log` and to stdout. Each wrapper logs `start` and `end OK ...` or `FAILED: ...`.
- Folder defaults, each overridable from the environment: `PSL_HOME=/opt/petstore`, `PSL_LOG_DIR=/var/petstore/log`, `PSL_BACKUP_DIR=/var/petstore/backup`, `PSL_EXTRACT_DIR=/var/petstore/extract`, `PSL_STORE_URL=http://localhost:8080/petstore`. `PSL_BACKUP_KEEP_DAYS=7` and `PSL_AUDIT_RETENTION_DAYS=90` are literals.
- Wrappers map a non-zero `psl_ij` to `exit 8`. `psl_catalog_check.sh` exits 4 when C1 to C4 rows appear and 8 when its Populate request fails.

## Backup (`psl_db_backup.sh`, `db_backup.sql`)

1. Removes any stale `$PSL_BACKUP_DIR/PetStoreDB`.
2. `CALL SYSCS_UTIL.SYSCS_BACKUP_DATABASE('/var/petstore/backup')`: an online backup; the store stays open.
3. Removes `PetStoreDB_<today>` if present and moves the new backup to `PetStoreDB_YYYYMMDD` (shell `date`).
4. `find $PSL_BACKUP_DIR -maxdepth 1 -name 'PetStoreDB_*' -mtime +7 -exec rm -rf` deletes old backups.

Restore (runbook 4.1) is manual: stop Tomcat, move `/var/petstore/db/PetStoreDB` aside, copy a dated backup into its place, start Tomcat.

## Audit extract day window

The extract and the report cover "yesterday" computed at run time: the SQL uses the database's `CURRENT_DATE` and the file name uses the shell's `date -d yesterday`. A rerun on the same day overwrites the day's file. Re-extracting an older day means editing `audit_extract.sql` dates by hand (runbook 4.2).

## Open questions and disputes (for the SME)

- **Q1 Backup retention.** The scheduler description, runbook 3.1 and settings say "older than 7 days are deleted". `find -mtime +7` matches only folders 8 or more whole days old, so about 8 (sometimes 9) dated backups remain. Recorded as `conflicting-sources` / `contradicts-docs`. The spec states the 7-day setting and gives scenarios only for ages outside the 7-to-8-day band.
- **Q2 Extract rerun.** `MAXRERUN=1` has no `INTERVAL`; whether Control-M reruns it automatically or this only caps manual reruns is not settled by the export.
- **Q3 `PSL_CAL`.** The backup carries `DAYSCAL=PSL_CAL`, which is not defined in the tree. If it excludes days, the whole dependent chain skips them.
- **Q4 Settings authority.** `petstore.properties` claims to be read by `env.sh`; it is not. The SQL hard-codes 90 days, 30 minutes and the `/var/petstore` backup and extract paths again.
- **Q5 Extract gap.** An extract held past midnight, or rerun on a later day, exports the day before the actual run; the held day is never exported automatically.
- **Q6 Trigger and persistence in production.** The image starts no scheduler and declares no `VOLUME`; how Control-M reaches the container and where `/var/petstore` persists is not stated.

## Suspected legacy defects (confirm behaviour; correctness is the Business Owner's decision)

- **SD1** `psl_ij` ignores the process exit status. A failure that does not print a line starting `ERROR` (JVM not found, missing jar: `Error: Could not find or load main class`) is reported as success by every job.
- **SD2** The backup and extract SQL write to fixed `/var/petstore/...` paths while the wrappers rename and prune in the overridable folders, and the `mv` results are unchecked. With an overridden folder the job logs `end OK` for a file that does not exist. The runbook says exit 8 covers file errors; no script checks a file step.
- **SD3** The catalog check does not check `psl_ij`'s status. With the database down it prints neither pattern it looks for, logs `end OK` and exits 0.
- **SD4** Alerts exist only for backup failure, extract failure and catalog check code 4. Catalog check code 8, the report, the purge and the unlock fail silently; a cyclic unlock that ends NOTOK normally stops cycling.
- **SD5** On Sunday the purge consumes `PSL_AUDIT_EXTRACT-OK`. If the extract finishes after 02:00 and the purge completes before the report is submitted, that day's report never runs and nobody is told.
- **SD6** A failed backup holds the extract, so the security team's own failure mail never fires; they learn of a missing file only by its absence.
- **SD7** The purge logs `retention=${PSL_AUDIT_RETENTION_DAYS}d` but deletes on a hard-coded 90.
- **SD8** The live database and its backups share the container filesystem with no volume, so losing the container loses both.
- **SD9** The DB URL in `env.sh` carries the password and is passed as `-D`, visible in the process list; the listener binds 0.0.0.0:1527.
- **SD10** `pom.xml` sets `derby.version` but `env.sh` names jars with the literal `10.14.2.0`; a version bump alone breaks every job with exit 8.
- **SD11** When catalog tables are missing, the catalog check calls the first-load endpoint, which drops and recreates every table, including accounts and sign-on audit, with no backup first. (Recorded under the catalog capability; noted here because the trigger is a batch job.)

## Other notes

- Nothing in the tree removes old extract or report files, or rotates `batch.log` and the per-job logs.
- The store database is a single Derby database at `/var/petstore/db/PetStoreDB` (created if missing), reached by the web tier through a JNDI pool of at most 20 connections with a 10-second wait (`src/main/webapp`, record BO-INT-0001, medium confidence).

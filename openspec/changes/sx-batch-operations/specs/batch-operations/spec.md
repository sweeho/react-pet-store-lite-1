## ADDED Requirements

### Requirement: Nightly job chain order

The system SHALL run the nightly jobs in this order: the database backup daily from 01:00; the sign-on audit extract daily from 01:30, only after that day's backup has succeeded; the sign-on statistics report daily from 01:45 and the sign-on audit purge on Sundays from 02:00, each only after that day's audit extract has succeeded.

#### Scenario: Normal weekday night

- **GIVEN** a Tuesday on which the backup succeeds at 01:10 and the audit extract succeeds at 01:35
- **WHEN** the chain runs
- **THEN** the extract starts no earlier than 01:30 and after the backup succeeded, the sign-on report starts no earlier than 01:45, and the audit purge does not run

#### Scenario: Sunday night

- **GIVEN** a Sunday on which the backup and the audit extract have succeeded
- **WHEN** the chain runs
- **THEN** the sign-on report starts no earlier than 01:45 and the audit purge starts no earlier than 02:00

#### Scenario: Extract not yet succeeded

- **GIVEN** the audit extract for the day has not succeeded
- **WHEN** 01:45 arrives
- **THEN** the sign-on report MUST NOT start

### Requirement: Jobs independent of the nightly chain

The system SHALL run the catalog integrity check daily at 06:00 and the account unlock every 15 minutes from 00:00 to 23:59, and neither job SHALL wait on any job of the nightly chain.

#### Scenario: Backup failed but catalog check runs

- **GIVEN** the nightly backup has failed and the audit extract is held
- **WHEN** 06:00 arrives
- **THEN** the catalog integrity check starts

#### Scenario: Unlock cadence

- **GIVEN** any day
- **WHEN** the account unlock schedule is evaluated
- **THEN** the unlock runs at 15-minute intervals between 00:00 and 23:59 regardless of the nightly chain's state

### Requirement: Daily online database backup

The system SHALL take a backup of the whole store database every day without stopping the store, and SHALL keep it as a backup named with the run date in the form PetStoreDB_YYYYMMDD; a second backup taken on the same date SHALL replace the earlier backup of that date.

#### Scenario: First backup of the day

- **GIVEN** the store is open and serving customers on 2026-11-02
- **WHEN** the backup runs
- **THEN** the store stays available and a backup named PetStoreDB_20261102 exists

#### Scenario: Backup rerun on the same date

- **GIVEN** a backup named PetStoreDB_20261102 already exists
- **WHEN** the backup runs again on 2026-11-02
- **THEN** exactly one PetStoreDB_20261102 backup exists and it holds the newer copy

### Requirement: Backup retention

After each successful backup the system SHALL delete dated backups older than the 7-day backup retention setting, and SHALL NOT delete any backup when the backup run failed.

#### Scenario: Old backup removed

- **GIVEN** a dated backup whose age is 9 whole days
- **WHEN** a backup run succeeds
- **THEN** that backup is deleted

#### Scenario: Recent backup kept

- **GIVEN** a dated backup taken 5 days ago
- **WHEN** a backup run succeeds
- **THEN** that backup is kept

#### Scenario: Failed run deletes nothing

- **GIVEN** dated backups of every age from 1 to 10 days
- **WHEN** the backup run fails
- **THEN** no dated backup is deleted

### Requirement: Failed backup holds the dependent chain

When the nightly backup has not succeeded for the run date, the system SHALL NOT start that day's audit extract, sign-on report or audit purge, and SHALL send an urgent mail to the operations team stating that the backup failed and the audit extract is held.

#### Scenario: Backup fails after all reruns

- **GIVEN** the backup fails and its automatic reruns also fail
- **WHEN** the audit extract's 01:30 start time arrives
- **THEN** the audit extract, the sign-on report and the audit purge do not run, and operations receive an urgent mail saying the backup failed and the audit extract is held

#### Scenario: Backup succeeds on a rerun

- **GIVEN** the 01:00 backup fails and its first rerun succeeds
- **WHEN** the rerun completes
- **THEN** the audit extract becomes eligible to start

### Requirement: Automatic retry limits

The system SHALL rerun a failed database backup automatically up to 2 more times, 10 minutes apart, and SHALL rerun a failed audit extract at most once; the sign-on report, the audit purge, the catalog integrity check and the account unlock SHALL NOT be rerun automatically.

#### Scenario: Backup keeps failing

- **GIVEN** the 01:00 backup run fails
- **WHEN** each rerun also fails
- **THEN** the backup is run at most 3 times in total, with 10 minutes between a failure and the next run

#### Scenario: Extract rerun cap

- **GIVEN** the audit extract fails and its one rerun also fails
- **WHEN** the rerun ends
- **THEN** no further automatic run of the extract is made for that day

#### Scenario: Report not retried

- **GIVEN** the sign-on report fails
- **WHEN** the failure is recorded
- **THEN** the report is not rerun automatically

### Requirement: Batch job exit codes

Every batch job SHALL end with exit code 0 when it succeeded, 4 only when the catalog integrity check found catalog data breaking a rule, and 8 when a database step, the sample-data load request or a file step failed.

#### Scenario: Successful job

- **GIVEN** the audit purge completes its database step without error
- **WHEN** the job ends
- **THEN** its exit code is 0

#### Scenario: Catalog rule broken

- **GIVEN** the catalog integrity check finds an item breaking a catalog rule
- **WHEN** the job ends
- **THEN** its exit code is 4

#### Scenario: Database step fails

- **GIVEN** the database cannot be reached when the backup runs
- **WHEN** the job ends
- **THEN** its exit code is 8

### Requirement: Database step failure detection

A batch job SHALL treat a database script step as failed when the database tool's output contains a line beginning with "ERROR", and as succeeded otherwise.

#### Scenario: Error line reported

- **GIVEN** a database step whose tool output contains a line beginning with "ERROR"
- **WHEN** the step ends
- **THEN** the job treats the step as failed and ends with exit code 8

#### Scenario: No error line

- **GIVEN** a database step whose tool output contains no line beginning with "ERROR"
- **WHEN** the step ends
- **THEN** the job treats the step as succeeded

### Requirement: Shared batch log

Every batch job SHALL append a line to a shared batch log when it starts and when it ends, each line carrying a timestamp in the form YYYY-MM-DD HH:MM:SS and the job name, and the end line SHALL state OK or FAILED with a reason. The account unlock, the audit purge and the catalog integrity check SHALL also keep their own detail logs.

#### Scenario: Successful run logged

- **GIVEN** the backup job runs and succeeds
- **WHEN** it ends
- **THEN** the shared batch log holds a start line and an end OK line, both time-stamped and naming the backup job

#### Scenario: Failed run logged

- **GIVEN** the audit extract's database step fails
- **WHEN** the job ends
- **THEN** the shared batch log holds a time-stamped FAILED line naming the extract job and the failed step

### Requirement: Batch failure alerts

The system SHALL send mail on these batch outcomes only: a failed database backup (urgent, to the operations team); a failed audit extract (regular urgency, to the security team, stating the sign-on audit extract was not produced); and a catalog integrity check ending with code 4 (urgent, to the catalog team, pointing at the catalog check log). A failure of the sign-on report, the audit purge or the account unlock, and a catalog check ending with any code other than 4, SHALL raise no mail.

#### Scenario: Extract failure alert

- **GIVEN** the audit extract fails
- **WHEN** the failure is recorded
- **THEN** the security team receives a regular-urgency mail saying the sign-on audit extract was not produced

#### Scenario: Catalog rule alert

- **GIVEN** the catalog integrity check ends with code 4
- **WHEN** the failure is recorded
- **THEN** the catalog team receives an urgent mail pointing at the catalog check log

#### Scenario: Catalog check ends with code 8

- **GIVEN** the catalog integrity check ends with code 8
- **WHEN** the failure is recorded
- **THEN** no mail is sent

#### Scenario: Purge failure

- **GIVEN** the Sunday audit purge fails
- **WHEN** the failure is recorded
- **THEN** no mail is sent

### Requirement: Rerun after a failed job

An operator SHALL be able to rerun any batch job on demand once the cause of a code 4 or code 8 ending has been fixed.

#### Scenario: Rerun after database outage

- **GIVEN** the sign-on report ended with code 8 because the database was unreachable
- **WHEN** the database is reachable again and the operator reruns the report
- **THEN** the report runs and ends with code 0

### Requirement: Audit extract day window

The sign-on audit extract and the sign-on report SHALL cover the calendar day before the day the job runs; a rerun on the same day SHALL overwrite that day's output file; extracting any older day SHALL require a manual run with the dates changed.

#### Scenario: Normal extract

- **GIVEN** the extract runs on 2026-11-02
- **WHEN** it completes
- **THEN** it covers sign-on events of 2026-11-01 and its file is named for 20261101

#### Scenario: Same-day rerun

- **GIVEN** the extract for 2026-11-01 was produced on 2026-11-02
- **WHEN** the extract is rerun on 2026-11-02
- **THEN** the 20261101 file is replaced

#### Scenario: Held past midnight

- **GIVEN** the extract scheduled for the night of 2026-11-02 is held and only runs on 2026-11-03
- **WHEN** it completes
- **THEN** it covers 2026-11-02, and 2026-11-01 is extracted only if an operator runs it by hand with changed dates

### Requirement: Batch output locations

The batch jobs SHALL write backups to /var/petstore/backup, extract and report files to /var/petstore/extract and job logs to /var/petstore/log by default, and SHALL allow each of these locations, the batch installation home and the store address to be overridden by the operating environment.

#### Scenario: Defaults

- **GIVEN** no location is overridden
- **WHEN** the backup and the extract run
- **THEN** the backup is written under /var/petstore/backup, the extract under /var/petstore/extract and the log lines under /var/petstore/log

#### Scenario: Override

- **GIVEN** the operating environment sets a different log location
- **WHEN** a batch job runs
- **THEN** its log lines are written to that location

### Requirement: Batch access to the live store database

The batch jobs SHALL read and write the same live store database the store uses, through a network database listener on the local host at port 1527, as the store's application user, without stopping the store; a batch job SHALL fail with exit code 8 when the store, and with it the listener, is not running.

#### Scenario: Store running

- **GIVEN** the store is running
- **WHEN** the account unlock runs
- **THEN** it updates the same accounts the store reads, while the store stays available

#### Scenario: Store not running

- **GIVEN** the store application is stopped
- **WHEN** a batch job starts its database step
- **THEN** the job cannot reach the database and ends with exit code 8

### Requirement: Batch access to the store over HTTP

The batch jobs SHALL reach the running store over HTTP at the configured store address, defaulting to http://localhost:8080/petstore.

#### Scenario: Sample-data load request

- **GIVEN** the store address is not overridden
- **WHEN** the catalog integrity check requests a sample-data load
- **THEN** the request is sent to http://localhost:8080/petstore

### Requirement: Batch packaging with the store

The system SHALL deploy every batch job, its SQL, its settings and the database client and command-line tools the jobs need in the same deployable unit as the store, with every batch job executable on demand inside that unit; a job SHALL fail when those database tools are absent or not at the version the batch environment expects.

#### Scenario: On-demand run inside the deployed unit

- **GIVEN** a freshly deployed store
- **WHEN** an operator runs the backup job by hand inside the deployed unit
- **THEN** the job runs without any further installation

#### Scenario: Tool version mismatch

- **GIVEN** the database tools installed are a different version from the one the batch environment names
- **WHEN** any batch job runs its database step
- **THEN** the job fails

### Requirement: Persistent working areas

The system SHALL provide four working areas at start-up, kept apart from each other: one for the live database files, one for database backups, one for extract and report files and one for job logs.

#### Scenario: Fresh start

- **GIVEN** a newly started store
- **WHEN** the first backup, extract and log write happen
- **THEN** each writes into its own existing working area and none writes into the live database area

### Requirement: Restore from a dated backup

Operations SHALL be able to restore the store database from a dated backup by stopping the store, moving the current database aside, copying the chosen dated backup into its place and starting the store again.

#### Scenario: Restore of the previous night's backup

- **GIVEN** a dated backup PetStoreDB_20261101 exists
- **WHEN** an operator stops the store, moves the current database aside, copies that backup into the database location and starts the store
- **THEN** the store serves the data as it was at the time of that backup

### Requirement: Single store database and connection pool

The system SHALL keep its catalog, accounts and sign-on history in a single database, created if missing at start-up, and the store SHALL reach it through a pool of at most 20 connections that waits at most 10 seconds for a free connection.

#### Scenario: Pool exhausted

- **GIVEN** all 20 pooled connections are in use
- **WHEN** a further request needs a connection and none is freed within 10 seconds
- **THEN** that request fails to obtain a connection

#### Scenario: Missing database

- **GIVEN** no store database exists at the database location
- **WHEN** the store starts
- **THEN** the database is created

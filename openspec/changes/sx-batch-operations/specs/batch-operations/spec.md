## ADDED Requirements

### Requirement: Nightly job chain order

ID: SWHR5-R-0272
Recovered from: BATCH-WF-0001
The system SHALL run the nightly job chain in this order: the database backup daily from 01:00; the sign-on audit extract daily from 01:30, only after that day's backup has succeeded; the sign-on statistics report daily from 01:45, only after that day's extract has succeeded; and the sign-on audit purge on Sundays from 02:00, only after that day's extract has succeeded.

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

ID: SWHR5-R-0263
Recovered from: BAT-WF-0001
The system SHALL run the catalog integrity check daily at 06:00 and the account unlock every 15 minutes, and neither job SHALL wait on any job of the nightly chain.

#### Scenario: Backup failed but catalog check runs

- **GIVEN** the nightly backup has failed and the audit extract is held
- **WHEN** 06:00 arrives
- **THEN** the catalog integrity check starts

#### Scenario: Unlock cadence

- **GIVEN** any day, whatever the state of the nightly chain
- **WHEN** the account unlock schedule is evaluated
- **THEN** the unlock runs at 15-minute intervals

### Requirement: Failed backup holds the dependent chain

ID: SWHR5-R-0264
Recovered from: BAT-WF-0003
The system SHALL hold the audit extract, the sign-on report and the audit purge for a night on which the database backup has not succeeded, and SHALL release the audit extract once a backup succeeds for that night.

#### Scenario: Backup fails after all reruns

- **GIVEN** the backup fails and its automatic reruns also fail
- **WHEN** the audit extract's 01:30 start time arrives
- **THEN** the audit extract, the sign-on report and the audit purge do not run

#### Scenario: Backup succeeds on a rerun

- **GIVEN** the 01:00 backup fails and its first rerun succeeds
- **WHEN** the rerun completes
- **THEN** the audit extract becomes eligible to start

### Requirement: Job start and end log lines

ID: SWHR5-R-0046
Recovered from: BO-WF-0001
Each scheduled job SHALL write one line to the batch job log when it starts and one line when it ends.

#### Scenario: Successful run logged

- **GIVEN** the backup job runs and succeeds
- **WHEN** it ends
- **THEN** the batch job log holds exactly one start line and one end line for that run

#### Scenario: Failed run logged

- **GIVEN** the audit extract's database step fails
- **WHEN** the job ends
- **THEN** the batch job log holds a start line and an end line for that run, the end line stating the failure

### Requirement: Audit extract failure handling

ID: SWHR5-R-0111
Recovered from: BATCH-OPERATIONS-WF-0001
The system SHALL run the sign-on audit extract daily from 01:30 only after that day's database backup has succeeded; when the export fails the job SHALL end with exit code 8 and the security team SHALL be notified by mail that the extract was not produced, and the daily sign-on report and the Sunday audit purge SHALL NOT start until the extract has succeeded.

#### Scenario: Export fails

- **GIVEN** that day's backup has succeeded and the extract's export step fails
- **WHEN** the extract job ends
- **THEN** its exit code is 8, the security team receives a mail saying the sign-on audit extract was not produced, and neither the sign-on report nor the audit purge starts

### Requirement: Daily online dated backup

ID: SWHR5-R-0267
Recovered from: BAT-BR-0001
The system SHALL take a full online backup of the store database every day from 01:00 without stopping the store, and SHALL keep it under a name formed from the backup date, PetStoreDB_YYYYMMDD; when a backup for the same date already exists, a backup run that day SHALL replace it.

#### Scenario: First backup of the day

- **GIVEN** the store is open and serving customers on 2026-11-02
- **WHEN** the backup runs
- **THEN** the store stays available and a backup named PetStoreDB_20261102 exists

#### Scenario: Backup rerun on the same date

- **GIVEN** a backup named PetStoreDB_20261102 already exists
- **WHEN** the backup runs again on 2026-11-02
- **THEN** exactly one PetStoreDB_20261102 backup exists and it holds the newer copy

### Requirement: Backup age counting for deletion

ID: SWHR5-R-0262
Recovered from: BAT-BR-0002
After each successful backup the system SHALL delete dated backups whose age, counted in whole days, is more than 7, which keeps today's backup and about the 7 previous daily backups.

#### Scenario: Backup aged 9 whole days

- **GIVEN** a dated backup whose age is 9 whole days
- **WHEN** a backup run succeeds
- **THEN** that backup is deleted

#### Scenario: Backup aged 5 whole days

- **GIVEN** a dated backup whose age is 5 whole days
- **WHEN** a backup run succeeds
- **THEN** that backup is kept

### Requirement: Seven-day backup retention

ID: SWHR5-R-0170
Recovered from: BATCH-BR-0001
The system SHALL keep each daily database backup for at least 7 days and SHALL delete older ones after a successful backup.

#### Scenario: A week of backups is available

- **GIVEN** the backup has succeeded every night for the last 10 nights
- **WHEN** an operator lists the dated backups after tonight's backup
- **THEN** a backup exists for each of the last 7 dates

### Requirement: Backup deletion only after a successful run

ID: SWHR5-R-0265
Recovered from: BATCH-BR-0004
The system SHALL delete dated database backups older than 7 days only at the end of a successful backup run, and a failed backup run SHALL NOT delete any dated backup.

#### Scenario: Failed run deletes nothing

- **GIVEN** dated backups of every age from 1 to 10 days
- **WHEN** the backup run fails
- **THEN** no dated backup is deleted

#### Scenario: Successful run prunes

- **GIVEN** dated backups of every age from 1 to 10 days
- **WHEN** the backup run succeeds
- **THEN** the backups aged 9 and 10 days are deleted

### Requirement: Batch job exit codes

ID: SWHR5-R-0039
Recovered from: BAT-BR-0004
Each batch run SHALL end with exit code 0 on success, exit code 8 on a database or file error, and exit code 4 only when the catalog integrity check finds bad catalog data.

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

### Requirement: Automatic retry limits

ID: SWHR5-R-0040
Recovered from: BAT-BR-0005
The system SHALL retry a failed nightly backup automatically up to 2 more times, 10 minutes apart, and SHALL retry a failed audit extract automatically once; other batch jobs SHALL NOT be retried automatically.

#### Scenario: Backup keeps failing

- **GIVEN** the 01:00 backup run fails
- **WHEN** each rerun also fails
- **THEN** the backup is run at most 3 times in total, with 10 minutes between a failure and the next run

#### Scenario: Extract retry cap

- **GIVEN** the audit extract fails and its one retry also fails
- **WHEN** the retry ends
- **THEN** no further automatic run of the extract is made for that day

#### Scenario: Report not retried

- **GIVEN** the sign-on report fails
- **WHEN** the failure is recorded
- **THEN** the report is not rerun automatically

### Requirement: Batch failure alerts

ID: SWHR5-R-0266
Recovered from: BATCH-REQ-0005
The system SHALL alert by mail on these batch failures only: a failed database backup (urgent, to the operations team, stating the backup failed and the audit extract is held); a failed sign-on audit extract (regular urgency, to the security team); and a catalog integrity check ending with code 4 (urgent, to the catalog team). A failure of the sign-on report, the audit purge or the account unlock, and a catalog check ending with any code other than 4, SHALL raise no mail.

#### Scenario: Backup failure alert

- **GIVEN** the backup fails
- **WHEN** the failure is recorded
- **THEN** the operations team receives an urgent mail saying the backup failed and the audit extract is held

#### Scenario: Catalog rule alert

- **GIVEN** the catalog integrity check ends with code 4
- **WHEN** the failure is recorded
- **THEN** the catalog team receives an urgent mail

#### Scenario: Catalog check ends with code 8

- **GIVEN** the catalog integrity check ends with code 8
- **WHEN** the failure is recorded
- **THEN** no mail is sent

#### Scenario: Purge failure

- **GIVEN** the Sunday audit purge fails
- **WHEN** the failure is recorded
- **THEN** no mail is sent

### Requirement: Database step failure detection

ID: SWHR5-R-0271
Recovered from: BATCH-REQ-0004
A batch job SHALL treat a database error line reported by the database tool, a line beginning with "ERROR", as a failure of that database step, SHALL end with exit code 8 when a database step fails, and SHALL treat a step whose tool output contains no such line as succeeded.

#### Scenario: Error line reported

- **GIVEN** a database step whose tool output contains a line beginning with "ERROR"
- **WHEN** the step ends
- **THEN** the job treats the step as failed and ends with exit code 8

#### Scenario: No error line

- **GIVEN** a database step whose tool output contains no line beginning with "ERROR"
- **WHEN** the step ends
- **THEN** the job treats the step as succeeded

### Requirement: Batch output locations and shared log

ID: SWHR5-R-0269
Recovered from: BATCH-REQ-0001
The batch jobs SHALL write backups to /var/petstore/backup, extract files to /var/petstore/extract and logs to /var/petstore/log by default, each location overridable by the operator's environment, and SHALL append every job log line, prefixed with a date-time stamp in the form YYYY-MM-DD HH:MM:SS and the job name, to a shared batch log.

#### Scenario: Defaults

- **GIVEN** no location is overridden
- **WHEN** the backup and the extract run
- **THEN** the backup is written under /var/petstore/backup, the extract under /var/petstore/extract and the log lines under /var/petstore/log

#### Scenario: Override

- **GIVEN** the operator's environment sets a different log location
- **WHEN** a batch job runs
- **THEN** its log lines are written to the shared batch log in that location

#### Scenario: Log line format

- **GIVEN** the audit purge starts at 02:00:05 on 2026-11-01
- **WHEN** it writes its start line
- **THEN** the shared batch log line begins with 2026-11-01 02:00:05 and names the purge job

### Requirement: Separate working areas

ID: SWHR5-R-0270
Recovered from: BATCH-REQ-0002
The system SHALL provide, existing at start-up, separate working areas for database backups, for extract files and for job logs, and SHALL keep the live database files in a fourth area apart from them.

#### Scenario: Fresh start

- **GIVEN** a newly started store
- **WHEN** the first backup, extract and log write happen
- **THEN** each writes into its own already existing working area and none writes into the live database area

### Requirement: Batch packaging with the store

ID: SWHR5-R-0042
Recovered from: BATCH-REQ-0003
The system SHALL install every batch job, its SQL and its settings together with the store in one deployable unit, with every batch job runnable on demand inside that unit.

#### Scenario: On-demand run inside the deployed unit

- **GIVEN** a freshly deployed store
- **WHEN** an operator runs the backup job by hand inside the deployed unit
- **THEN** the job runs without any further installation

### Requirement: Audit extract day window

ID: SWHR5-R-0043
Recovered from: BATCH-REQ-0006
The sign-on audit extract and the sign-on report SHALL always cover the calendar day before the run date; a rerun on the same day SHALL overwrite that day's file; re-extracting an older day SHALL require running the export by hand with changed dates.

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
- **THEN** it covers 2026-11-02, and 2026-11-01 is extracted only if an operator runs the export by hand with changed dates

### Requirement: Batch access to the live store

ID: SWHR5-R-0268
Recovered from: BATCH-INT-0001
The system SHALL keep the store database running inside the store's own process and SHALL at the same time accept network database connections on port 1527, so that the batch jobs, running as separate processes, read and write the same live database the store uses; the batch jobs SHALL reach the database through that listener on the local host and the running store over HTTP at the configured store address, defaulting to http://localhost:8080/petstore.

#### Scenario: Store running

- **GIVEN** the store is running
- **WHEN** the account unlock runs
- **THEN** it updates through port 1527 the same accounts the store reads, while the store stays available

#### Scenario: Store address default

- **GIVEN** the store address is not overridden
- **WHEN** a batch job sends a request to the store
- **THEN** the request is sent to http://localhost:8080/petstore

#### Scenario: Store not running

- **GIVEN** the store is stopped, and with it the database listener
- **WHEN** a batch job starts its database step
- **THEN** the job cannot reach the database and fails

### Requirement: Store restorable from a dated backup

ID: SWHR5-R-0041
Recovered from: BAT-REQ-0001
Restoring the store SHALL be possible by stopping the application, setting the current database aside, copying a dated backup in its place and restarting.

#### Scenario: Restored data matches the backup

- **GIVEN** a dated backup PetStoreDB_20261101 and a live database changed since that backup
- **WHEN** the store is restored from that backup and restarted
- **THEN** the store serves the data as it was at the time of that backup

### Requirement: Operator restore procedure

ID: SWHR5-R-0045
Recovered from: BO-REQ-0002
Operations SHALL be able to restore the store database from a dated backup by stopping the application, moving the current database aside, copying the chosen backup into its place and restarting the application.

#### Scenario: Restore of the previous night's backup

- **GIVEN** a dated backup PetStoreDB_20261101 exists
- **WHEN** an operator stops the store, moves the current database aside, copies that backup into the database location and starts the store
- **THEN** the store starts and the database that was moved aside is still available to the operator

### Requirement: Single store database and connection pool

ID: SWHR5-R-0044
Recovered from: BO-INT-0001
The system SHALL keep its catalog, accounts and sign-on history in a single database, created if missing, and the store SHALL reach it through a connection pool of at most 20 connections that waits at most 10 seconds for a free connection.

#### Scenario: Pool exhausted

- **GIVEN** all 20 pooled connections are in use
- **WHEN** a further request needs a connection and none is freed within 10 seconds
- **THEN** that request fails to obtain a connection

#### Scenario: Missing database

- **GIVEN** no store database exists at the database location
- **WHEN** the store starts
- **THEN** the database is created

## 1. Scheduling and chaining

- [ ] 1.1 Define the nightly chain: backup 01:00, audit extract 01:30, sign-on report 01:45, Sunday audit purge 02:00
- [ ] 1.2 Gate the audit extract on that day's successful backup
- [ ] 1.3 Gate the sign-on report and the Sunday purge on that day's successful extract
- [ ] 1.4 Schedule the 06:00 catalog integrity check independently of the chain
- [ ] 1.5 Schedule the account unlock every 15 minutes from 00:00 to 23:59 independently of the chain
- [ ] 1.6 Resolve with operations whether the PSL_CAL calendar excludes any backup days

## 2. Retry policy

- [ ] 2.1 Rerun a failed backup up to 2 more times, 10 minutes apart
- [ ] 2.2 Cap the audit extract at one rerun and confirm whether that rerun is automatic
- [ ] 2.3 Ensure the report, purge, catalog check and unlock are never rerun automatically

## 3. Database backup

- [ ] 3.1 Take an online backup of the whole store database without stopping the store
- [ ] 3.2 Name the backup PetStoreDB_YYYYMMDD and replace an existing backup of the same date
- [ ] 3.3 Delete dated backups older than the 7-day retention only after a successful backup
- [ ] 3.4 Settle with the SME whether retention means 7 days or about 8 copies and test the boundary
- [ ] 3.5 Document and test the manual restore-from-backup procedure

## 4. Job outcome contract

- [ ] 4.1 Implement exit codes 0 (success), 4 (catalog rule broken) and 8 (database, load request or file failure)
- [ ] 4.2 Treat a database step as failed when its tool reports a line beginning with "ERROR"
- [ ] 4.3 Decide with the Business Owner whether a non-zero tool exit status without an ERROR line must also fail the step
- [ ] 4.4 Decide with the Business Owner whether unchecked file steps (rename, line count) must end with code 8

## 5. Logging

- [ ] 5.1 Append a time-stamped start line naming the job to the shared batch log
- [ ] 5.2 Append a time-stamped end line stating OK or FAILED with a reason

## 6. Alerting

- [ ] 6.1 Send an urgent mail to operations when the backup fails, stating the extract is held
- [ ] 6.2 Send a regular mail to security when the audit extract fails
- [ ] 6.3 Send an urgent mail to the catalog team when the catalog check ends with code 4
- [ ] 6.4 Confirm with the Business Owner that report, purge, unlock and catalog-check code 8 failures stay silent

## 7. Audit extract window

- [ ] 7.1 Cover the calendar day before the run date in the extract and the report
- [ ] 7.2 Overwrite the day's output on a same-day rerun
- [ ] 7.3 Provide the manual path for extracting an older day
- [ ] 7.4 Decide with the SME whether a held extract must still cover its scheduled day and which clock defines the day

## 8. Environment and packaging

- [ ] 8.1 Default the backup, extract and log locations under /var/petstore and allow environment overrides
- [ ] 8.2 Allow the batch home and the store address to be overridden, defaulting to http://localhost:8080/petstore
- [ ] 8.3 Give the batch jobs access to the live database through the local network listener on port 1527
- [ ] 8.4 Package the jobs, SQL, settings and database tools with the store so each job runs on demand
- [ ] 8.5 Provision separate working areas for database files, backups, extracts and logs at start-up
- [ ] 8.6 Configure the store's database pool with at most 20 connections and a 10-second wait
- [ ] 8.7 Confirm with operations how jobs are triggered in production and where the working areas persist

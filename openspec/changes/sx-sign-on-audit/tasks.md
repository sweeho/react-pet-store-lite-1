## 1. Audit data model

- [ ] 1.1 Define the sign-on audit entry with event number, user name (25), event type, event time and client address (45, optional)
- [ ] 1.2 Generate the event number automatically and ascending on insert, never supplied by the writer
- [ ] 1.3 Restrict event type to the seven codes and refuse any other value
- [ ] 1.4 Keep user name free of any account reference so unknown names can be recorded
- [ ] 1.5 Add an index on (user name, event time) and an index on event time
- [ ] 1.6 Make the audit log append-only outside the retention purge

## 2. Event writers

- [ ] 2.1 Provide one audit write function taking user name as typed, event type and client address
- [ ] 2.2 Record SIGNON_OK on successful sign-in
- [ ] 2.3 Record SIGNON_FAIL on wrong password and on an unknown user name
- [ ] 2.4 Record SIGNON_LOCKED on any sign-in attempt to a locked account
- [ ] 2.5 Record SIGNON_FAIL then ACCOUNT_LOCKED on the failure that locks the account
- [ ] 2.6 Record USER_CREATED when an account is created
- [ ] 2.7 Record SIGNOFF only on explicit sign-out by a signed-in user
- [ ] 2.8 Record ACCOUNT_UNLOCKED with origin batch:PSL_ACCT_UNLOCK in the same transaction as the automatic unlock

## 3. My Account page

- [ ] 3.1 Add the My Account page on the shared layout, restricted to signed-in users
- [ ] 3.2 Show the Sign In page to a visitor who is not signed in
- [ ] 3.3 Display the user name and the account role
- [ ] 3.4 Query the user's 10 newest audit events ordered by event time then event number, descending
- [ ] 3.5 Render each row with When (yyyy-MM-dd HH:mm:ss), Event code and From
- [ ] 3.6 Render the empty list state and the "Showing your 10 most recent events." note

## 4. Daily audit extract

- [ ] 4.1 Select the previous calendar day's events in ascending event-number order
- [ ] 4.2 Write five quoted/unquoted comma-separated fields per line, UTF-8, no header
- [ ] 4.3 Format the event time as YYYY-MM-DD HH:MM:SS with fractional seconds in server local time
- [ ] 4.4 Name the file signon_audit_YYYYMMDD.csv in the extract directory, replacing any existing file
- [ ] 4.5 Append the TRAILER,YYYYMMDD,count line, including the zero-event case
- [ ] 4.6 Schedule the extract daily from 01:30 after a successful backup, with one rerun on failure
- [ ] 4.7 Alert the security team when the extract fails and hold the report and purge

## 5. Daily sign-on report

- [ ] 5.1 Count the previous day's events and distinct users per event type, ordered by event type
- [ ] 5.2 Add the locked-account count and accounts per role as a run-time snapshot
- [ ] 5.3 Write signon_report_YYYYMMDD.txt daily from 01:45 after a successful extract

## 6. Retention purge

- [ ] 6.1 Delete events earlier than 00:00 of the day 90 days before the run date in one transaction
- [ ] 6.2 Schedule the purge on Sundays from 02:00, only after that day's extract succeeded

## 7. Verification

- [ ] 7.1 Test each sign-on outcome writes the expected event sequence
- [ ] 7.2 Test extract window boundaries, line format and trailer against the 2026-10-29 sample file
- [ ] 7.3 Test the purge cutoff on both sides of midnight 90 days back
- [ ] 7.4 Test My Account ordering, limit, tie-break and empty state

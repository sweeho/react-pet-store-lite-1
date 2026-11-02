## ADDED Requirements

### Requirement: Sign-on audit event record

ID: SWHR5-R-0010
Recovered from: AUD-ENT-0001
The system SHALL keep an append-only sign-on audit log in which each entry has a unique identifier, the user name (at most 25 characters, required), the event type (one of SIGNON_OK, SIGNON_FAIL, SIGNON_LOCKED, ACCOUNT_LOCKED, SIGNOFF, USER_CREATED, ACCOUNT_UNLOCKED; required), the event time (required) and the client address (up to 45 characters, optional).

#### Scenario: Event recorded with every field
ID: SWHR5-R-0010.01

- **GIVEN** user j2ee signs in successfully from client address 10.0.0.5
- **WHEN** the audit entry is written
- **THEN** the log holds a new entry with a unique identifier, user name j2ee, event type SIGNON_OK, the event time and client address 10.0.0.5

#### Scenario: Event recorded without a client address
ID: SWHR5-R-0010.02

- **GIVEN** an audit event whose client address is not known
- **WHEN** the entry is written
- **THEN** the entry is stored with an empty client address

#### Scenario: Entry missing a mandatory field
ID: SWHR5-R-0010.03

- **GIVEN** an audit entry with no user name, no event type or no event time
- **WHEN** it is written
- **THEN** the write is refused and no entry is stored

#### Scenario: Recorded entries are never changed
ID: SWHR5-R-0010.04

- **GIVEN** an audit entry has been recorded
- **WHEN** any later sign-on activity happens for the same user
- **THEN** the existing entry is unchanged; entries are removed only by the retention purge

### Requirement: Weekly audit purge after extract

ID: SWHR5-R-0011
Recovered from: AUDIT-BR-0007
The system SHALL, on Sundays at 02:00 and only after that day's audit extract has succeeded, delete audit events older than 90 days.

#### Scenario: Sunday purge after a successful extract
ID: SWHR5-R-0011.01

- **GIVEN** it is Sunday 02:00 and that day's audit extract has completed successfully
- **WHEN** the purge runs
- **THEN** every audit event older than 90 days is deleted

#### Scenario: Sunday extract failed
ID: SWHR5-R-0011.02

- **GIVEN** it is Sunday and that day's audit extract did not complete successfully
- **WHEN** 02:00 passes
- **THEN** no purge runs that week and no audit event is deleted

#### Scenario: Not a Sunday
ID: SWHR5-R-0011.03

- **GIVEN** it is Wednesday and the audit extract has succeeded
- **WHEN** the day's batch runs
- **THEN** no audit event is deleted

### Requirement: Daily sign-on audit extract file

ID: SWHR5-R-0012
Recovered from: AUDIT-INT-0004
The system SHALL, every day at 01:30 after a successful backup, export the previous day's audit events (00:00 to 24:00) ordered by event number to a comma-separated file named signon_audit_YYYYMMDD.csv for the security team, with columns audit_id, username, event_type, event_ts, remote_addr, no header row, and a final trailer line 'TRAILER,YYYYMMDD,<row count>' where the count excludes the trailer.

#### Scenario: Extract of a day with events
ID: SWHR5-R-0012.01

- **GIVEN** 28 audit events timestamped on 2026-10-29 and the backup of 2026-10-30 has succeeded
- **WHEN** the extract runs at 01:30 on 2026-10-30
- **THEN** a file signon_audit_20261029.csv is written with 28 event lines in ascending event-number order, each carrying audit_id, username, event_type, event_ts and remote_addr, with no header row, followed by the line TRAILER,20261029,28

#### Scenario: Events outside the previous day are excluded
ID: SWHR5-R-0012.02

- **GIVEN** an event at 2026-10-28 23:59:59 and an event at 2026-10-30 00:00:00
- **WHEN** the extract for 2026-10-29 runs
- **THEN** neither event appears in signon_audit_20261029.csv

#### Scenario: Backup not successful
ID: SWHR5-R-0012.03

- **GIVEN** the day's database backup has not completed successfully
- **WHEN** 01:30 passes
- **THEN** the extract does not run

### Requirement: Closed set of audit event types

ID: SWHR5-R-0138
Recovered from: AUDIT-BR-0001
The system SHALL accept only these sign-on event types: SIGNON_OK, SIGNON_FAIL, SIGNON_LOCKED, ACCOUNT_LOCKED, SIGNOFF, USER_CREATED and ACCOUNT_UNLOCKED, and SHALL refuse to record any other event type.

#### Scenario: Unknown event type refused
ID: SWHR5-R-0138.01

- **GIVEN** an audit write with event type PASSWORD_RESET
- **WHEN** the event is recorded
- **THEN** the write is refused and no entry is stored

#### Scenario: Listed event type accepted
ID: SWHR5-R-0138.02

- **GIVEN** an audit write with event type SIGNON_LOCKED
- **WHEN** the event is recorded
- **THEN** the entry is stored

### Requirement: Mandatory audit fields and accepted event types

ID: SWHR5-R-0252
Recovered from: SOA-ENT-0001
The system SHALL record each sign-on event with a unique event identifier, the user name (at most 25 characters, required), the event type (required), the event time (required) and the client network address (optional, at most 45 characters). The event type SHALL be one of SIGNON_OK, SIGNON_FAIL, SIGNON_LOCKED, ACCOUNT_LOCKED, SIGNOFF, USER_CREATED or ACCOUNT_UNLOCKED, and any other value SHALL be rejected.

#### Scenario: Event without an event time
ID: SWHR5-R-0252.01

- **GIVEN** an audit write with user name j2ee, event type SIGNON_OK and no event time
- **WHEN** the event is recorded
- **THEN** the write is rejected and no entry is stored

#### Scenario: Event without a client address
ID: SWHR5-R-0252.02

- **GIVEN** an audit write for j2ee with event type SIGNOFF and no client address
- **WHEN** the event is recorded
- **THEN** the entry is stored with an empty client address

### Requirement: Audit field lengths

ID: SWHR5-R-0236
Recovered from: SAUD-ENT-0001
The system SHALL record each sign-on audit event with the user name (mandatory, at most 25 characters), an event type, the event time (mandatory) and optionally the client network address (at most 45 characters), and SHALL accept only these event types: SIGNON_OK, SIGNON_FAIL, SIGNON_LOCKED, ACCOUNT_LOCKED, SIGNOFF, USER_CREATED, ACCOUNT_UNLOCKED.

#### Scenario: User name of 25 characters
ID: SWHR5-R-0236.01

- **GIVEN** a user name of exactly 25 characters
- **WHEN** an audit event is recorded for it
- **THEN** the entry is stored with the full user name

#### Scenario: User name longer than 25 characters
ID: SWHR5-R-0236.02

- **GIVEN** a user name of 26 characters
- **WHEN** an audit event is recorded for it
- **THEN** the write is refused

#### Scenario: Client address of 45 characters
ID: SWHR5-R-0236.03

- **GIVEN** a client address of exactly 45 characters
- **WHEN** an audit event is recorded with it
- **THEN** the entry is stored with the full client address

### Requirement: Audit event time and origin

ID: SWHR5-R-0234
Recovered from: AUDIT-ENT-0001
The system SHALL record each sign-on audit event with the user name, an event type from the closed set SIGNON_OK, SIGNON_FAIL, SIGNON_LOCKED, ACCOUNT_LOCKED, ACCOUNT_UNLOCKED, SIGNOFF, USER_CREATED, the event time to the second, and the originating address: the client network address for an event caused by a user, or the label "batch:" followed by the job name for an event caused by a scheduled job.

#### Scenario: User-caused event
ID: SWHR5-R-0234.01

- **GIVEN** user j2ee signs in from 10.0.0.5 at 2026-10-29 09:23:47
- **WHEN** the event is recorded
- **THEN** the entry carries event time 2026-10-29 09:23:47 and origin 10.0.0.5

#### Scenario: Job-caused event
ID: SWHR5-R-0234.02

- **GIVEN** the scheduled unlock job PSL_ACCT_UNLOCK releases account j2ee
- **WHEN** the event is recorded
- **THEN** the entry carries origin batch:PSL_ACCT_UNLOCK

### Requirement: System-assigned ascending event number

ID: SWHR5-R-0232
Recovered from: AUDIT-BR-0002
The system SHALL assign each sign-on event a system-generated event number that is unique and increases with each event recorded.

#### Scenario: Two events recorded in sequence
ID: SWHR5-R-0232.01

- **GIVEN** an audit event has been recorded with event number 1685
- **WHEN** the next audit event is recorded
- **THEN** it receives an event number greater than 1685

### Requirement: Event identifier generated on recording

ID: SWHR5-R-0220
Recovered from: SAUD-BR-0002
The system SHALL give every sign-on audit event a unique identifier generated automatically when the event is recorded.

#### Scenario: Two events at the same time
ID: SWHR5-R-0220.01

- **GIVEN** two audit events recorded with the same event time
- **WHEN** both are stored
- **THEN** each has its own identifier and the identifiers differ

### Requirement: Caller never supplies the event identifier

ID: SWHR5-R-0221
Recovered from: SOA-RULE-0001
The system SHALL assign each sign-on audit event a unique identifier automatically, so that recording an event never requires the caller to supply one.

#### Scenario: Event recorded without an identifier
ID: SWHR5-R-0221.01

- **GIVEN** an audit write carrying user name, event type, event time and client address but no identifier
- **WHEN** the event is recorded
- **THEN** the entry is stored and carries a system-assigned identifier

### Requirement: Events recorded against the user name as typed

ID: SWHR5-R-0233
Recovered from: AUDIT-BR-0003
The system SHALL record sign-on events against the user name as typed, without requiring that an account with that name exists.

#### Scenario: Sign-in with an unknown user name
ID: SWHR5-R-0233.01

- **GIVEN** no account named ghost exists
- **WHEN** a sign-in is attempted with user name ghost and it fails
- **THEN** a SIGNON_FAIL event is recorded under user name ghost

### Requirement: Audit user name need not match an account

ID: SWHR5-R-0235
Recovered from: SA-BR-0003
The system SHALL record sign-on events against the user name as typed, without requiring that an account with that name exists.

#### Scenario: User name differing only by case
ID: SWHR5-R-0235.01

- **GIVEN** an account named j2ee exists and no account named J2EE exists
- **WHEN** a sign-in is attempted with user name J2EE
- **THEN** a SIGNON_FAIL event is recorded under user name J2EE

#### Scenario: Events kept after the account is gone
ID: SWHR5-R-0235.02

- **GIVEN** audit events recorded for user name olduser and no account olduser exists any longer
- **WHEN** the audit log is read
- **THEN** the events for olduser are still present

### Requirement: Sign-on outcomes are audited

ID: SWHR5-R-0231
Recovered from: AUD-REQ-0001
The system SHALL write an audit event, with the user name, event type, date and time, and client network address, for each of: successful sign-on (SIGNON_OK), failed sign-on (SIGNON_FAIL), account locked by this failure (ACCOUNT_LOCKED), sign-on attempted while locked (SIGNON_LOCKED), sign-off (SIGNOFF) and account created (USER_CREATED).

#### Scenario: Successful sign-in
ID: SWHR5-R-0231.01

- **GIVEN** an unlocked account j2ee with password j2ee
- **WHEN** j2ee signs in with the correct password from 10.0.0.5
- **THEN** one SIGNON_OK event is recorded for j2ee with address 10.0.0.5

#### Scenario: Wrong password
ID: SWHR5-R-0231.02

- **GIVEN** an unlocked account j2ee with no earlier failures
- **WHEN** a sign-in for j2ee is submitted with a wrong password
- **THEN** one SIGNON_FAIL event is recorded for j2ee

#### Scenario: Sign-in attempt on a locked account
ID: SWHR5-R-0231.03

- **GIVEN** the account j2ee is locked
- **WHEN** a sign-in is attempted for j2ee, with any password
- **THEN** one SIGNON_LOCKED event is recorded for j2ee

### Requirement: Every audited activity and its event type

ID: SWHR5-R-0139
Recovered from: AUDIT-REQ-0001
The system SHALL record every successful sign-in, failed sign-in, sign-in to a locked account, account lock, account unlock, sign-out and account creation as an audit event with the user name, event type, time and client address, using only the event types SIGNON_OK, SIGNON_FAIL, SIGNON_LOCKED, ACCOUNT_LOCKED, ACCOUNT_UNLOCKED, SIGNOFF and USER_CREATED.

#### Scenario: Activity mapped to its event type
ID: SWHR5-R-0139.01

- **GIVEN** each of the seven activities occurs once for user j2ee
- **WHEN** the audit log for j2ee is read
- **THEN** it holds exactly one event of each of SIGNON_OK, SIGNON_FAIL, SIGNON_LOCKED, ACCOUNT_LOCKED, ACCOUNT_UNLOCKED, SIGNOFF and USER_CREATED

### Requirement: Locking attempt writes two events

ID: SWHR5-R-0228
Recovered from: AUD-BR-0001
GIVEN an account has 2 consecutive failed sign-ons, WHEN a third wrong password is submitted, THEN the system SHALL record two events for that attempt: a failed sign-on (SIGNON_FAIL) followed by an account-locked event (ACCOUNT_LOCKED).

#### Scenario: Third wrong password in a row
ID: SWHR5-R-0228.01

- **GIVEN** an account with 2 consecutive failed sign-ons
- **WHEN** a third wrong password is submitted
- **THEN** a SIGNON_FAIL event is recorded followed by an ACCOUNT_LOCKED event, the second with the higher event number

### Requirement: Account creation is audited

ID: SWHR5-R-0244
Recovered from: AUD-RULE-0001
The system SHALL record a USER_CREATED audit event when an account is created, timestamped with the account's creation time.

#### Scenario: New account created
ID: SWHR5-R-0244.01

- **GIVEN** a visitor creates the account newbie at 2026-10-29 14:02:11
- **WHEN** the account is stored
- **THEN** a USER_CREATED event is recorded for newbie with event time 2026-10-29 14:02:11

### Requirement: Sign-off is audited on explicit sign-out

ID: SWHR5-R-0222
Recovered from: AUD-RULE-0002
The system SHALL record a SIGNOFF audit event when a user signs out explicitly. A session that ends without an explicit sign-out SHALL leave no SIGNOFF event.

#### Scenario: Explicit sign-out
ID: SWHR5-R-0222.01

- **GIVEN** user j2ee is signed in
- **WHEN** j2ee signs out
- **THEN** one SIGNOFF event is recorded for j2ee with the client address

#### Scenario: Session times out
ID: SWHR5-R-0222.02

- **GIVEN** user j2ee is signed in
- **WHEN** the session expires after inactivity without a sign-out
- **THEN** no SIGNOFF event is recorded

### Requirement: No sign-off event without explicit sign-out

ID: SWHR5-R-0225
Recovered from: SIGNONAUD-BR-0003
The system SHALL record a sign-off event only when the user explicitly signs out. A session that ends any other way (timeout, browser closed) SHALL leave no sign-off event.

#### Scenario: Browser closed
ID: SWHR5-R-0225.01

- **GIVEN** user j2ee is signed in
- **WHEN** the browser is closed without signing out
- **THEN** no SIGNOFF event is recorded for j2ee

### Requirement: Automatic unlock is audited

ID: SWHR5-R-0240
Recovered from: AUD-BR-0004
WHEN the automatic unlock releases an account THEN the system SHALL record an ACCOUNT_UNLOCKED audit event for that user name with the time of the unlock and the client address "batch:PSL_ACCT_UNLOCK", committed in the same transaction as the unlock.

#### Scenario: Two accounts released by one run
ID: SWHR5-R-0240.01

- **GIVEN** two accounts locked more than 30 minutes ago
- **WHEN** the unlock run executes
- **THEN** both accounts are unlocked and one ACCOUNT_UNLOCKED event per account is recorded with client address batch:PSL_ACCT_UNLOCK

#### Scenario: Unlock run fails before commit
ID: SWHR5-R-0240.02

- **GIVEN** the unlock run fails before it commits
- **WHEN** the failure occurs
- **THEN** no account is unlocked and no ACCOUNT_UNLOCKED event is recorded

### Requirement: Client-address field content

ID: SWHR5-R-0238
Recovered from: SOA-BR-0005
The system SHALL fill the client-address field of an audit record with the network address of the client that made the request, and, for an unlock made by the scheduled unlock job, with the literal value batch:PSL_ACCT_UNLOCK. The field MAY be empty, and SHALL hold at most 45 characters.

#### Scenario: Address of an IPv6 client
ID: SWHR5-R-0238.01

- **GIVEN** a sign-in from client address 2001:db8::1
- **WHEN** the event is recorded
- **THEN** the client-address field holds 2001:db8::1

### Requirement: Sign-on audit retention of 90 days

ID: SWHR5-R-0251
Recovered from: SIGNONAUDIT-BR-0002
The system SHALL keep sign-on audit events for 90 days and remove older events.

#### Scenario: Recent event kept
ID: SWHR5-R-0251.01

- **GIVEN** an audit event 30 days old
- **WHEN** the purge runs
- **THEN** the event is kept

#### Scenario: Old event removed
ID: SWHR5-R-0251.02

- **GIVEN** an audit event 120 days old
- **WHEN** the purge runs
- **THEN** the event is removed

### Requirement: Retained history no older than 90 days

ID: SWHR5-R-0224
Recovered from: SIGNONAUD-BR-0002
The system SHALL keep sign-on audit events for about 90 days. GIVEN the export of 2026-10-29 WHEN the oldest retained event is inspected THEN it SHALL be no older than 90 days.

#### Scenario: Oldest event in the 2026-10-29 export
ID: SWHR5-R-0224.01

- **GIVEN** the audit history exported on 2026-10-29
- **WHEN** the oldest retained event is inspected
- **THEN** its event time is no older than 90 days before 2026-10-29

### Requirement: Daily extract and 90-day purge

ID: SWHR5-R-0227
Recovered from: SOA-RULE-0002
The system SHALL extract the sign-on audit log daily and SHALL purge audit events older than 90 days.

#### Scenario: Purged event was extracted first
ID: SWHR5-R-0227.01

- **GIVEN** an audit event recorded 91 days ago
- **WHEN** it is purged
- **THEN** it was included in the daily extract file for the day it was recorded

### Requirement: Weekly purge cutoff

ID: SWHR5-R-0229
Recovered from: AUD-BR-0003
The system SHALL, once a week on Sunday and only after that day's audit extract has succeeded, permanently delete every sign-on audit event whose timestamp is before midnight at the start of the day 90 days before the run date.

#### Scenario: Events on either side of the cutoff
ID: SWHR5-R-0229.01

- **GIVEN** the purge runs on Sunday 2026-11-01, an event at 2026-08-02 23:59:59 and an event at 2026-08-03 00:00:00
- **WHEN** the purge completes
- **THEN** the 2026-08-02 event is deleted and the 2026-08-03 event is kept

### Requirement: Purge waits for the Sunday extract

ID: SWHR5-R-0242
Recovered from: AUD-BR-0005
The system SHALL delete sign-on audit events whose time is before 00:00 on the day 90 days before the run date, once a week on Sunday, and only after that day's audit extract has completed successfully.

#### Scenario: Extract still running at 02:00
ID: SWHR5-R-0242.01

- **GIVEN** it is Sunday 02:00 and that day's audit extract has not yet completed
- **WHEN** the extract later completes successfully
- **THEN** the purge runs after it, not before

#### Scenario: Events up to about 97 days old between purges
ID: SWHR5-R-0242.02

- **GIVEN** the purge runs only on Sundays
- **WHEN** the audit log is read on the Saturday before the next purge
- **THEN** events up to about 97 days old MAY still be present

### Requirement: Extract file content and encoding

ID: SWHR5-R-0230
Recovered from: AUD-INT-0001
The system SHALL produce, once a day, a file of all sign-on audit events whose event time falls on the previous calendar day (from 00:00 inclusive to 00:00 of the run day exclusive), one event per line in ascending event-number order, with the five fields event number, user name, event type, event time and client address, comma-separated, text fields enclosed in double quotes, UTF-8 encoded, with no header row, named signon_audit_YYYYMMDD.csv where YYYYMMDD is the day covered.

#### Scenario: Event at midnight of the run day
ID: SWHR5-R-0230.01

- **GIVEN** an event at 2026-10-29 00:00:00 and an event at 2026-10-30 00:00:00
- **WHEN** the extract runs on 2026-10-30
- **THEN** signon_audit_20261029.csv contains the 2026-10-29 00:00:00 event and not the 2026-10-30 00:00:00 event

#### Scenario: User name with a non-ASCII character
ID: SWHR5-R-0230.02

- **GIVEN** an event for user name josé on the previous day
- **WHEN** the extract runs
- **THEN** the user name is written UTF-8 encoded inside double quotes

### Requirement: Extract trailer count

ID: SWHR5-R-0103
Recovered from: AUD-INT-0002
The system SHALL end each daily sign-on audit extract file with a trailer line "TRAILER,<YYYYMMDD>,<n>" where YYYYMMDD is the day covered and n is the number of event lines in the file, not counting the trailer itself. GIVEN a day with no audit events WHEN the extract runs THEN the file SHALL contain only the trailer line with a count of 0.

#### Scenario: Day with 28 events
ID: SWHR5-R-0103.01

- **GIVEN** 28 audit events on 2026-10-29
- **WHEN** the extract runs on 2026-10-30
- **THEN** the last line of signon_audit_20261029.csv is TRAILER,20261029,28

### Requirement: Extract trailer line

ID: SWHR5-R-0237
Recovered from: SIGNON-AUDIT-INT-0003
The system SHALL end the extract file with a single trailer line of the form TRAILER,YYYYMMDD,<count>, where YYYYMMDD is the extracted day and <count> is the number of event lines in the file, excluding the trailer itself.

#### Scenario: Only one trailer
ID: SWHR5-R-0237.01

- **GIVEN** an extract file for 2026-10-29 with 5 event lines
- **WHEN** the file is read
- **THEN** it holds exactly one line starting with TRAILER, and it is the last line, reading TRAILER,20261029,5

### Requirement: Extract of an empty day

ID: SWHR5-R-0223
Recovered from: SIGNON-AUDIT-RULE-0002
GIVEN no sign-on audit events occurred on the extracted day WHEN the extract runs THEN the system SHALL still produce the dated file, containing only the trailer line with a count of 0.

#### Scenario: Day with no audit events
ID: SWHR5-R-0223.01

- **GIVEN** no audit events are timestamped on 2026-10-29
- **WHEN** the extract for that day runs
- **THEN** signon_audit_20261029.csv is produced containing only the line TRAILER,20261029,0

### Requirement: One extract file per day

ID: SWHR5-R-0245
Recovered from: AUDIT-INT-0003
The system SHALL produce, for each day, a file of that day's sign-on audit events containing exactly the stored events for that day in event-number order, without a header, with a trailer line carrying the date and the row count.

#### Scenario: Extract matches the stored events
ID: SWHR5-R-0245.01

- **GIVEN** the audit log holds 31 events dated 2026-10-28
- **WHEN** the file for 2026-10-28 is produced
- **THEN** it contains exactly those 31 events in ascending event-number order and the trailer TRAILER,20261028,31

### Requirement: Extract line format

ID: SWHR5-R-0249
Recovered from: SIGNON-AUDIT-INT-0002
The system SHALL write each audit event in the extract as one line of five comma-separated fields in this order: event number, user name as typed, event type, event time, client address; text fields SHALL be enclosed in double quotes and the event number SHALL be unquoted; the file SHALL have no header row and SHALL be UTF-8 encoded; the event time SHALL be written as YYYY-MM-DD HH:MM:SS followed by a fractional-seconds part.

#### Scenario: One event line
ID: SWHR5-R-0249.01

- **GIVEN** event 1660 is a SIGNON_OK for j2ee at 2026-10-29 09:23:47 from 10.0.0.5
- **WHEN** it is written to the extract
- **THEN** the line reads 1660,"j2ee","SIGNON_OK","2026-10-29 09:23:47.0","10.0.0.5"

### Requirement: Extract event time and user name representation

ID: SWHR5-R-0226
Recovered from: SOA-INT-0006
The system SHALL write the event time in the extract file as YYYY-MM-DD HH:MM:SS followed by a fractional-seconds part (for example 2026-10-29 09:23:47.0), in the server's local time, and the user name exactly as it was typed at sign-in.

#### Scenario: Mixed-case user name
ID: SWHR5-R-0226.01

- **GIVEN** a failed sign-in typed as J2EE at 09:23:47 server local time on 2026-10-29
- **WHEN** the event is written to the extract
- **THEN** the user name field is "J2EE" and the event time field is "2026-10-29 09:23:47.0"

### Requirement: Extract event type and client address values

ID: SWHR5-R-0250
Recovered from: SIGNON-AUDIT-INT-0004
The system SHALL restrict the event type field of the extract to the values SIGNON_OK, SIGNON_FAIL, SIGNON_LOCKED, ACCOUNT_LOCKED, ACCOUNT_UNLOCKED, SIGNOFF and USER_CREATED, and SHALL write the client address field as the requesting client's address, or as the literal "batch:PSL_ACCT_UNLOCK" for events written by the automatic unlock job; the client address MAY be empty.

#### Scenario: Automatic unlock in the extract
ID: SWHR5-R-0250.01

- **GIVEN** an ACCOUNT_UNLOCKED event written by the automatic unlock job on the extracted day
- **WHEN** it is written to the extract
- **THEN** its client address field is "batch:PSL_ACCT_UNLOCK"

#### Scenario: Event with no client address
ID: SWHR5-R-0250.02

- **GIVEN** an event with no client address on the extracted day
- **WHEN** it is written to the extract
- **THEN** its client address field is empty

### Requirement: Dedicated extract location

ID: SWHR5-R-0248
Recovered from: SIGNON-AUDIT-INT-0001
The system SHALL provide a fixed, dedicated location to which the daily sign-on audit extract file is written for collection by its consumer.

#### Scenario: Extract written to the dedicated location
ID: SWHR5-R-0248.01

- **GIVEN** the daily extract has run
- **WHEN** the consumer collects the file
- **THEN** signon_audit_YYYYMMDD.csv is found in the fixed extract location and nowhere else

### Requirement: Extract always covers the previous day

ID: SWHR5-R-0246
Recovered from: AUDIT-REQ-0005
The system SHALL always extract the day before the run date; re-extracting an older day SHALL be done by running the export query by hand with changed dates.

#### Scenario: Extract run late
ID: SWHR5-R-0246.01

- **GIVEN** the extract for 2026-10-29 was not produced
- **WHEN** the extract runs on 2026-10-31
- **THEN** it produces signon_audit_20261030.csv and 2026-10-29 is not extracted

### Requirement: Extract rerun replaces the file

ID: SWHR5-R-0105
Recovered from: SIGNON-AUDIT-RULE-0001
GIVEN the extract job is run (or rerun) on a given date WHEN it completes THEN it SHALL always cover the day before that run date and SHALL replace any file of the same name; an older day SHALL only be re-extracted by running the export query manually with the dates changed.

#### Scenario: Extract rerun on the same day
ID: SWHR5-R-0105.01

- **GIVEN** signon_audit_20261029.csv already exists
- **WHEN** the extract is rerun on 2026-10-30
- **THEN** signon_audit_20261029.csv is replaced with a fresh extract of 2026-10-29 and only one trailer line is present

### Requirement: Extract failure alert

ID: SWHR5-R-0241
Recovered from: AUDIT-REQ-0002
GIVEN the daily sign-on audit extract ends in failure, THEN the system SHALL send a regular-urgency e-mail to the security team stating that the sign-on audit extract was not produced, AND the sign-on report and the audit purge SHALL NOT run for that day.

#### Scenario: Extract fails
ID: SWHR5-R-0241.01

- **GIVEN** the audit extract ends in failure on Sunday
- **WHEN** the failure is reported
- **THEN** the security team receives a regular-urgency e-mail that the sign-on audit extract was not produced, and neither the sign-on report nor the purge runs that day

### Requirement: Daily report per event type

ID: SWHR5-R-0101
Recovered from: AUD-BR-0006
The system SHALL produce a daily sign-on report named signon_report_YYYYMMDD.txt that lists, for each event type that occurred on the previous calendar day, the number of events and the number of distinct user names, sorted by event type. Event types with no events that day SHALL be absent from the list rather than shown as zero.

#### Scenario: Report for a day with two event types
ID: SWHR5-R-0101.01

- **GIVEN** on 2026-10-29 there were 12 SIGNON_OK events by 9 users and 3 SIGNON_FAIL events by 2 users
- **WHEN** the report runs on 2026-10-30
- **THEN** signon_report_20261029.txt lists SIGNON_FAIL 3 events 2 users, then SIGNON_OK 12 events 9 users, and no other event type

### Requirement: Report locked-account and role figures are a run-time snapshot

ID: SWHR5-R-0102
Recovered from: AUD-BR-0007
The daily sign-on report SHALL also state the number of accounts locked at the moment the report runs and the number of accounts per role (CUSTOMER, ADMIN) at that moment. These two figures SHALL be a snapshot at run time, not values for the previous day.

#### Scenario: Account locked and unlocked on the previous day
ID: SWHR5-R-0102.01

- **GIVEN** one account was locked and unlocked again on 2026-10-29 and no account is locked at 01:45 on 2026-10-30
- **WHEN** the report runs
- **THEN** it states 0 locked accounts and the current number of CUSTOMER and ADMIN accounts

### Requirement: Report file covers the previous calendar day

ID: SWHR5-R-0136
Recovered from: AUD-INT-0003
The system SHALL produce, once a day after the audit extract has succeeded, a sign-on statistics report for the previous calendar day containing: for each event type that occurred, the number of events and the number of distinct user names, ordered by event type; the number of accounts locked at the time the report runs; and the number of accounts per role. The report SHALL be written as signon_report_YYYYMMDD.txt where YYYYMMDD is the day covered.

#### Scenario: Report file name
ID: SWHR5-R-0136.01

- **GIVEN** the audit extract succeeded on 2026-10-30
- **WHEN** the report runs that day
- **THEN** the report is written as signon_report_20261029.txt

### Requirement: Daily report content

ID: SWHR5-R-0247
Recovered from: AUDIT-REQ-0006
The system SHALL, every day at 01:45 after a successful audit extract, write a report signon_report_YYYYMMDD.txt with the previous day's count per event type, the number of locked accounts and the number of accounts per role.

#### Scenario: Report holds the three figures
ID: SWHR5-R-0247.01

- **GIVEN** the extract succeeded on 2026-10-30
- **WHEN** the report runs at 01:45
- **THEN** signon_report_20261029.txt holds the per-event-type counts for 2026-10-29, the locked-account count and the account count per role

### Requirement: Report scheduled after the extract

ID: SWHR5-R-0140
Recovered from: AUDIT-REQ-0003
The system SHALL produce the daily sign-on statistics report every day no earlier than 01:45, and only after that day's sign-on audit extract has completed successfully.

#### Scenario: Extract not successful
ID: SWHR5-R-0140.01

- **GIVEN** that day's audit extract did not succeed
- **WHEN** 01:45 passes
- **THEN** no report is written

#### Scenario: Extract finishes after 01:45
ID: SWHR5-R-0140.02

- **GIVEN** that day's audit extract completes successfully at 01:52
- **WHEN** the report becomes eligible
- **THEN** the report runs after 01:52

### Requirement: Audit retrieval by time range

ID: SWHR5-R-0219
Recovered from: SAUD-REQ-0001
The system SHALL support selecting sign-on audit events by event time range without scanning the whole audit history, because the daily extract, the daily report and the 90-day purge all select on event time.

#### Scenario: One day selected from 90 days of history
ID: SWHR5-R-0219.01

- **GIVEN** an audit log holding 90 days of events for all users
- **WHEN** one day's events are requested
- **THEN** only events in that time range are read

### Requirement: Audit retrieval by user in time order

ID: SWHR5-R-0106
Recovered from: SOA-REQ-0001
The system SHALL support retrieving a given user's sign-on events in time order without scanning the whole audit trail.

#### Scenario: One user's recent events
ID: SWHR5-R-0106.01

- **GIVEN** an audit log holding 90 days of events for all users
- **WHEN** one user's events are requested newest first
- **THEN** only that user's events are read, in event-time order

### Requirement: My Account page

ID: SWHR5-R-0104
Recovered from: AUDT-SCR-0001
The system SHALL provide a My Account page, titled "My Account", on the shared layout, reachable from the Account link in the banner.

#### Scenario: Signed-in user opens My Account
ID: SWHR5-R-0104.01

- **GIVEN** user j2ee is signed in
- **WHEN** j2ee clicks Account in the banner
- **THEN** the My Account page is displayed with the title "My Account" inside the shared banner, sidebar and footer

### Requirement: My Account sign-in gate and identity display

ID: SWHR5-R-0239
Recovered from: SOA-SCR-0001
The My Account page SHALL show the signed-in user's user name, labelled "User Name", and role, labelled "Role", above their 10 most recent audit events, newest first. GIVEN the user is not signed in WHEN they open Account THEN the Sign In page SHALL be shown first.

#### Scenario: Customer views identity
ID: SWHR5-R-0239.01

- **GIVEN** user j2ee with role CUSTOMER is signed in
- **WHEN** My Account is displayed
- **THEN** it shows User Name j2ee and Role CUSTOMER

#### Scenario: Visitor who is not signed in opens My Account
ID: SWHR5-R-0239.02

- **GIVEN** no user is signed in
- **WHEN** the visitor clicks Account
- **THEN** the Sign In page is displayed instead of My Account, and My Account is shown after a successful sign-in

### Requirement: My Account recent activity selection

ID: SWHR5-R-0243
Recovered from: AUD-REQ-0002
The My Account page SHALL show the signed-on user's name, role and their 10 most recent audit events, newest first (events with the same time ordered by most recently recorded first), each with event type, date and time, and client address. Only events recorded under that user's name SHALL be listed.

#### Scenario: User with more than 10 events
ID: SWHR5-R-0243.01

- **GIVEN** user j2ee has 25 audit events
- **WHEN** My Account is displayed
- **THEN** exactly the 10 newest events are listed, newest at the top

#### Scenario: Two events with the same time
ID: SWHR5-R-0243.02

- **GIVEN** a SIGNON_FAIL and an ACCOUNT_LOCKED event for j2ee with the same event time, ACCOUNT_LOCKED recorded second
- **WHEN** My Account is displayed
- **THEN** ACCOUNT_LOCKED is listed above SIGNON_FAIL

#### Scenario: Other users' events not shown
ID: SWHR5-R-0243.03

- **GIVEN** user j2ee is signed in and user ghost has audit events
- **WHEN** My Account is displayed
- **THEN** none of ghost's events are listed

### Requirement: My Account recent activity rows

ID: SWHR5-R-0137
Recovered from: AUD-SCR-0001
The system SHALL show a signed-in user a My Account page with their user name, their role and their 10 most recent sign-on events, newest first, under the heading "Recent Sign-in Activity", each row with the time as yyyy-MM-dd HH:mm:ss (column "When"), the event type code (column "Event") and the client address it came from (column "From"); the list SHALL be followed by the note "Showing your 10 most recent events." When the user has no audit events the column headings and the note SHALL be shown with no rows.

#### Scenario: Row content
ID: SWHR5-R-0137.01

- **GIVEN** j2ee's newest event is SIGNON_OK at 2026-10-29 09:23:47 from 10.0.0.5
- **WHEN** My Account is displayed
- **THEN** the first row shows When 2026-10-29 09:23:47, Event SIGNON_OK and From 10.0.0.5

#### Scenario: Unlock performed by the automatic run
ID: SWHR5-R-0137.02

- **GIVEN** j2ee's newest event is an ACCOUNT_UNLOCKED written by the automatic unlock run
- **WHEN** My Account is displayed
- **THEN** the first row shows Event ACCOUNT_UNLOCKED and From batch:PSL_ACCT_UNLOCK

#### Scenario: User with no events
ID: SWHR5-R-0137.03

- **GIVEN** a signed-in user with no audit events
- **WHEN** My Account is displayed
- **THEN** the When, Event and From headings and the note "Showing your 10 most recent events." are shown with no rows

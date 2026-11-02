## ADDED Requirements

### Requirement: Sign-on audit event record

ID: SWHR5-R-0010
Recovered from: AUD-ENT-0001
The system SHALL keep an append-only sign-on audit log in which each entry has a unique identifier, the user name (at most 25 characters, required), the event type (one of SIGNON_OK, SIGNON_FAIL, SIGNON_LOCKED, ACCOUNT_LOCKED, SIGNOFF, USER_CREATED, ACCOUNT_UNLOCKED; required), the event time (required) and the client address (up to 45 characters, optional).

#### Scenario: Event recorded with every field

- **GIVEN** user j2ee signs in successfully from client address 10.0.0.5
- **WHEN** the audit entry is written
- **THEN** the log holds a new entry with a unique identifier, user name j2ee, event type SIGNON_OK, the event time and client address 10.0.0.5

#### Scenario: Event recorded without a client address

- **GIVEN** an audit event whose client address is not known
- **WHEN** the entry is written
- **THEN** the entry is stored with an empty client address

#### Scenario: Entry missing a mandatory field

- **GIVEN** an audit entry with no user name, no event type or no event time
- **WHEN** it is written
- **THEN** the write is refused and no entry is stored

#### Scenario: Recorded entries are never changed

- **GIVEN** an audit entry has been recorded
- **WHEN** any later sign-on activity happens for the same user
- **THEN** the existing entry is unchanged; entries are removed only by the retention purge

### Requirement: Weekly audit purge after extract

ID: SWHR5-R-0011
Recovered from: AUDIT-BR-0007
The system SHALL, on Sundays at 02:00 and only after that day's audit extract has succeeded, delete audit events older than 90 days.

#### Scenario: Sunday purge after a successful extract

- **GIVEN** it is Sunday 02:00 and that day's audit extract has completed successfully
- **WHEN** the purge runs
- **THEN** every audit event older than 90 days is deleted

#### Scenario: Sunday extract failed

- **GIVEN** it is Sunday and that day's audit extract did not complete successfully
- **WHEN** 02:00 passes
- **THEN** no purge runs that week and no audit event is deleted

#### Scenario: Not a Sunday

- **GIVEN** it is Wednesday and the audit extract has succeeded
- **WHEN** the day's batch runs
- **THEN** no audit event is deleted

### Requirement: Daily sign-on audit extract file

ID: SWHR5-R-0012
Recovered from: AUDIT-INT-0004
The system SHALL, every day at 01:30 after a successful backup, export the previous day's audit events (00:00 to 24:00) ordered by event number to a comma-separated file named signon_audit_YYYYMMDD.csv for the security team, with columns audit_id, username, event_type, event_ts, remote_addr, no header row, and a final trailer line 'TRAILER,YYYYMMDD,<row count>' where the count excludes the trailer.

#### Scenario: Extract of a day with events

- **GIVEN** 28 audit events timestamped on 2026-10-29 and the backup of 2026-10-30 has succeeded
- **WHEN** the extract runs at 01:30 on 2026-10-30
- **THEN** a file signon_audit_20261029.csv is written with 28 event lines in ascending event-number order, each carrying audit_id, username, event_type, event_ts and remote_addr, with no header row, followed by the line TRAILER,20261029,28

#### Scenario: Events outside the previous day are excluded

- **GIVEN** an event at 2026-10-28 23:59:59 and an event at 2026-10-30 00:00:00
- **WHEN** the extract for 2026-10-29 runs
- **THEN** neither event appears in signon_audit_20261029.csv

#### Scenario: Backup not successful

- **GIVEN** the day's database backup has not completed successfully
- **WHEN** 01:30 passes
- **THEN** the extract does not run

### Requirement: Closed set of audit event types

The system SHALL accept an audit event type only from the closed set SIGNON_OK, SIGNON_FAIL, SIGNON_LOCKED, ACCOUNT_LOCKED, ACCOUNT_UNLOCKED, SIGNOFF and USER_CREATED, and SHALL refuse to record any other event type.

#### Scenario: Unknown event type refused

- **GIVEN** an audit write with event type PASSWORD_RESET
- **WHEN** the event is recorded
- **THEN** the write is refused and no entry is stored

### Requirement: System-assigned ascending event number

The system SHALL give every audit event a unique, system-assigned event number at the moment it is recorded, increasing with each event recorded, so that the writer of an event never supplies one; events with the same event time SHALL be ordered by this number.

#### Scenario: Two events recorded in sequence

- **GIVEN** an audit event has been recorded with event number 1685
- **WHEN** the next audit event is recorded without an event number
- **THEN** it receives an event number greater than 1685

### Requirement: Events recorded against the user name as typed

The system SHALL record sign-on audit events against the user name as typed, without requiring that an account with that name exists.

#### Scenario: Sign-in with an unknown user name

- **GIVEN** no account named ghost exists
- **WHEN** a sign-in is attempted with user name ghost
- **THEN** a SIGNON_FAIL event is recorded under user name ghost

#### Scenario: User name differing only by case

- **GIVEN** an account named j2ee exists and no account named J2EE exists
- **WHEN** a sign-in is attempted with user name J2EE
- **THEN** a SIGNON_FAIL event is recorded under user name J2EE

### Requirement: Sign-on outcomes are audited

The system SHALL write one audit event, holding the user name as typed, the event type, the time and the client network address, for each of: a successful sign-in (SIGNON_OK); a failed sign-in, including an unknown user name (SIGNON_FAIL); a sign-in attempt on a locked account (SIGNON_LOCKED); an account becoming locked (ACCOUNT_LOCKED); a sign-out by a signed-in user (SIGNOFF); and a new account (USER_CREATED).

#### Scenario: Successful sign-in

- **GIVEN** an unlocked account j2ee with password j2ee
- **WHEN** j2ee signs in with the correct password from 10.0.0.5
- **THEN** one SIGNON_OK event is recorded for j2ee with address 10.0.0.5

#### Scenario: Sign-in attempt on a locked account

- **GIVEN** the account j2ee is locked
- **WHEN** a sign-in is attempted for j2ee, with any password
- **THEN** one SIGNON_LOCKED event is recorded for j2ee

### Requirement: Locking attempt writes two events

WHEN a wrong password causes an account to lock, the system SHALL write two audit events for that one attempt, first a failed sign-in (SIGNON_FAIL) and then the lock (ACCOUNT_LOCKED).

#### Scenario: Third wrong password in a row

- **GIVEN** an account with 2 consecutive failed sign-ons
- **WHEN** a third wrong password is submitted
- **THEN** a SIGNON_FAIL event is recorded followed by an ACCOUNT_LOCKED event, the second with the higher event number

### Requirement: Account creation is audited

The system SHALL record a USER_CREATED audit event when an account is created, timestamped at the account's creation, before any other audit event for that account.

#### Scenario: New account created

- **GIVEN** a visitor creates the account newbie
- **WHEN** the account is stored
- **THEN** a USER_CREATED event is recorded for newbie and it is the earliest audit event for newbie

### Requirement: Sign-off is audited only on explicit sign-out

The system SHALL record a SIGNOFF event only when a signed-in user explicitly signs out. A session that ends any other way SHALL leave no SIGNOFF event.

#### Scenario: Explicit sign-out

- **GIVEN** user j2ee is signed in
- **WHEN** j2ee signs out
- **THEN** one SIGNOFF event is recorded for j2ee with the client address

#### Scenario: Session times out

- **GIVEN** user j2ee is signed in
- **WHEN** the session expires after inactivity without a sign-out
- **THEN** no SIGNOFF event is recorded

#### Scenario: Sign-out by a visitor who is not signed in

- **GIVEN** no user is signed in on the session
- **WHEN** the sign-out action is requested
- **THEN** no SIGNOFF event is recorded

### Requirement: Automatic unlock is audited

WHEN the automatic unlock run releases an account, the system SHALL record one ACCOUNT_UNLOCKED audit event for that user name, timestamped at the run, with the origin "batch:PSL_ACCT_UNLOCK" in place of a client address, and SHALL commit the audit events and the unlocks together as one unit of work.

#### Scenario: Two accounts released by one run

- **GIVEN** two accounts locked more than 30 minutes ago
- **WHEN** the unlock run executes
- **THEN** both accounts are unlocked and one ACCOUNT_UNLOCKED event per account is recorded with origin batch:PSL_ACCT_UNLOCK

#### Scenario: Unlock run fails part-way

- **GIVEN** the unlock run fails before it commits
- **WHEN** the failure occurs
- **THEN** no account is unlocked and no ACCOUNT_UNLOCKED event is recorded

### Requirement: Origin field content

The system SHALL fill the client-address field of an audit event with the network address of the client that made the request, and, for an unlock made by the automatic unlock run, with the literal value batch:PSL_ACCT_UNLOCK. The field MAY be empty and SHALL hold at most 45 characters.

#### Scenario: Address of an IPv6 client

- **GIVEN** a sign-in from client address 2001:db8::1
- **WHEN** the event is recorded
- **THEN** the client-address field holds 2001:db8::1

### Requirement: Extract file line format

The system SHALL write each audit event in the extract file as one line of exactly five comma-separated fields in the order event number, user name as typed, event type, event time, client address, with the event number unquoted and the four text fields enclosed in double quotes, UTF-8 encoded, with no header line; the event time SHALL be written as YYYY-MM-DD HH:MM:SS followed by a fractional-seconds part, in the server's local time.

#### Scenario: One event line

- **GIVEN** event 1660 is a SIGNON_OK for j2ee at 2026-10-29 09:23:47 from 10.0.0.5
- **WHEN** it is written to the extract
- **THEN** the line reads 1660,"j2ee","SIGNON_OK","2026-10-29 09:23:47.0","10.0.0.5"

### Requirement: Extract trailer line

The system SHALL end each extract file with a single trailer line TRAILER,<YYYYMMDD>,<count>, where YYYYMMDD is the day the file covers and count is the number of event lines in the file, excluding the trailer.

#### Scenario: Day with no audit events

- **GIVEN** no audit events are timestamped on 2026-10-29
- **WHEN** the extract for that day runs
- **THEN** signon_audit_20261029.csv is produced containing only the line TRAILER,20261029,0

### Requirement: Extract always covers the previous day

The automatic audit extract SHALL always cover the day before its run date and SHALL replace any existing file of the same name; the system SHALL provide no parameter to extract another day. An older day MAY be re-extracted only by running the export query by hand with changed dates.

#### Scenario: Extract rerun on the same day

- **GIVEN** signon_audit_20261029.csv already exists
- **WHEN** the extract is rerun on 2026-10-30
- **THEN** signon_audit_20261029.csv is replaced with a fresh extract of 2026-10-29

#### Scenario: Extract run late

- **GIVEN** the extract for 2026-10-29 was not produced
- **WHEN** the extract runs on 2026-10-31
- **THEN** it produces signon_audit_20261030.csv and 2026-10-29 is not extracted

### Requirement: Extract failure handling

The system SHALL rerun a failed audit extract once, and GIVEN the extract ends in failure THEN it SHALL send a regular-urgency alert to the security team stating that the sign-on audit extract was not produced, and the sign-on report and the audit purge SHALL NOT run for that day.

#### Scenario: Extract fails

- **GIVEN** the audit extract fails on its run and on its single rerun
- **WHEN** the failure is reported
- **THEN** the security team receives the alert "Sign-on audit extract not produced" and neither the sign-on report nor the purge runs that day

### Requirement: Daily sign-on statistics report

The system SHALL, every day no earlier than 01:45 and only after that day's audit extract has succeeded, write signon_report_YYYYMMDD.txt for the previous calendar day containing: for each event type that occurred that day, the number of events and the number of distinct user names, ordered by event type; the number of accounts locked at the moment the report runs; and the number of accounts per role at that moment. Event types with no events that day SHALL be absent rather than shown as zero.

#### Scenario: Report for a day with events

- **GIVEN** on 2026-10-29 there were 12 SIGNON_OK events by 9 users and 3 SIGNON_FAIL events by 2 users, and 1 account is locked when the report runs
- **WHEN** the report runs on 2026-10-30
- **THEN** signon_report_20261029.txt lists SIGNON_FAIL 3 events 2 users, then SIGNON_OK 12 events 9 users, no other event type, 1 locked account, and the account count per role

#### Scenario: Extract not successful

- **GIVEN** that day's audit extract did not succeed
- **WHEN** 01:45 passes
- **THEN** no report is written

### Requirement: Purge cutoff and atomicity

The system SHALL delete exactly those audit events whose event time is earlier than 00:00 at the start of the day 90 days before the purge run date, and SHALL commit the deletion as one unit of work.

#### Scenario: Events on either side of the cutoff

- **GIVEN** the purge runs on 2026-11-01, an event at 2026-08-02 23:59:59 and an event at 2026-08-03 00:00:00
- **WHEN** the purge completes
- **THEN** the 2026-08-02 event is deleted and the 2026-08-03 event is kept

#### Scenario: Retained age between purges

- **GIVEN** the purge runs only on Sundays
- **WHEN** the next purge is due
- **THEN** events up to about 97 days old may still be present

### Requirement: Audit retrieval by user and by time

The system SHALL retrieve one user's audit events in event-time order, and all users' audit events within an event-time range, without reading the whole audit log.

#### Scenario: Large audit log

- **GIVEN** an audit log holding 90 days of events for all users
- **WHEN** one user's recent events, or one day's events, are requested
- **THEN** only the matching events are read

### Requirement: My Account page access

The system SHALL provide a page titled "My Account" on the shared store layout, reachable from the Account link in the banner, and SHALL show it only to a signed-in user; a visitor who is not signed in SHALL be shown the Sign In page first.

#### Scenario: Signed-in user opens My Account

- **GIVEN** user j2ee is signed in
- **WHEN** j2ee clicks Account in the banner
- **THEN** the My Account page is displayed with the title "My Account" inside the shared banner, sidebar and footer

#### Scenario: Visitor who is not signed in opens My Account

- **GIVEN** no user is signed in
- **WHEN** the visitor clicks Account
- **THEN** the Sign In page is displayed instead of My Account

### Requirement: My Account identity display

The My Account page SHALL display the signed-in user's user name, labelled "User Name", and the role stored on that user's account, labelled "Role".

#### Scenario: Customer views identity

- **GIVEN** user j2ee with role CUSTOMER is signed in
- **WHEN** My Account is displayed
- **THEN** it shows User Name j2ee and Role CUSTOMER

### Requirement: My Account recent activity selection

The My Account page SHALL display, under the heading "Recent Sign-in Activity", the signed-in user's 10 most recent audit events, newest first, with events of the same time ordered by most recently recorded first, and only events recorded under that user's name.

#### Scenario: User with more than 10 events

- **GIVEN** user j2ee has 25 audit events
- **WHEN** My Account is displayed
- **THEN** exactly the 10 newest events are listed, newest at the top

#### Scenario: Two events with the same time

- **GIVEN** a SIGNON_FAIL and an ACCOUNT_LOCKED event for j2ee with the same event time, ACCOUNT_LOCKED recorded second
- **WHEN** My Account is displayed
- **THEN** ACCOUNT_LOCKED is listed above SIGNON_FAIL

### Requirement: My Account recent activity rows

Each row of the recent activity list SHALL show the event time as yyyy-MM-dd HH:mm:ss in the server's time zone with no zone shown (column "When"), the raw event type code (column "Event") and the client address or origin (column "From"); the list SHALL be followed by the note "Showing your 10 most recent events." When the user has no audit events the column headings and the note SHALL be shown with no rows.

#### Scenario: Row content

- **GIVEN** j2ee's newest event is SIGNON_OK at 2026-10-29 09:23:47 from 10.0.0.5
- **WHEN** My Account is displayed
- **THEN** the first row shows When 2026-10-29 09:23:47, Event SIGNON_OK and From 10.0.0.5

#### Scenario: Unlock performed by the automatic run

- **GIVEN** j2ee's newest event is an ACCOUNT_UNLOCKED written by the automatic unlock run
- **WHEN** My Account is displayed
- **THEN** the first row shows Event ACCOUNT_UNLOCKED and From batch:PSL_ACCT_UNLOCK

#### Scenario: User with no events

- **GIVEN** a signed-in user with no audit events
- **WHEN** My Account is displayed
- **THEN** the When, Event and From headings and the note "Showing your 10 most recent events." are shown with no rows

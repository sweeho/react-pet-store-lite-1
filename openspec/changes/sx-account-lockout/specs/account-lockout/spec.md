## ADDED Requirements

### Requirement: Consecutive failed sign-in count

ID: SWHR5-R-0003
Recovered from: LOCK-BR-0001
WHEN a sign-in with an existing, unlocked user name has a wrong password, the system SHALL add 1 to that account's count of consecutive failed sign-ins; WHEN a sign-in succeeds, the system SHALL reset the count to 0.

#### Scenario: Wrong password increments the count

- **GIVEN** an existing, unlocked account with 1 consecutive failed sign-in
- **WHEN** a sign-in is attempted for it with a wrong password
- **THEN** the account's consecutive failed sign-in count becomes 2 and a sign-in failure event is recorded

#### Scenario: Successful sign-in resets the count

- **GIVEN** an existing, unlocked account with 2 consecutive failed sign-ins
- **WHEN** a sign-in is attempted for it with the correct password
- **THEN** the sign-in succeeds and the account's consecutive failed sign-in count becomes 0

### Requirement: Lock on the third consecutive failure

ID: SWHR5-R-0145
Recovered from: LOCK-BR-0002
WHEN a wrong-password attempt brings an account's consecutive failed sign-in count to 3, the system SHALL lock the account, record the time of the lock, and SHALL show the Account Locked page for that same attempt instead of the sign-in error page.

#### Scenario: Third consecutive failure locks the account

- **GIVEN** an existing, unlocked account with 2 consecutive failed sign-ins
- **WHEN** a third sign-in is attempted with a wrong password
- **THEN** the account is locked, its failed count is 3, its lock time is the time of the attempt, and the Account Locked page is shown instead of the sign-in error page

### Requirement: Lock threshold of three consecutive failures

ID: SWHR5-R-0108
Recovered from: LOCK-RUL-0001
The system SHALL lock an account after 3 consecutive failed sign-in attempts, and MUST NOT lock it after fewer.

#### Scenario: Two consecutive failures do not lock

- **GIVEN** an existing, unlocked account with 1 consecutive failed sign-in
- **WHEN** a second sign-in is attempted with a wrong password
- **THEN** the account is not locked and the sign-in error page is shown

### Requirement: Lockout and automatic unlock policy

ID: SWHR5-R-0143
Recovered from: AL-RULE-0002
The system SHALL lock an account after 3 consecutive failed sign-ins, SHALL reset the consecutive-failure count to 0 on a successful sign-in or on unlock, and SHALL unlock a locked account automatically after 30 minutes.

#### Scenario: Count restarts after an unlock

- **GIVEN** an account that was locked with a failed count of 3 and has been automatically unlocked
- **WHEN** its failed count is read
- **THEN** the count is 0 and the account is not locked

### Requirement: Only consecutive failures count towards a lock

ID: SWHR5-R-0156
Recovered from: LOCK-RULE-0002
GIVEN an account with one or two consecutive failed sign-ins, WHEN the next sign-in succeeds, the system SHALL reset the failed-attempt count to zero, so that earlier failures do not count towards a lock.

#### Scenario: Failures interrupted by a success

- **GIVEN** an account with 2 consecutive failed sign-ins
- **WHEN** a sign-in succeeds and then two more sign-ins fail
- **THEN** the account's failed count is 2 and the account is not locked

### Requirement: Successful sign-in clears earlier failures

ID: SWHR5-R-0149
Recovered from: ACCTLOCK-BR-0002
The system SHALL reset an account's failed-attempt count when a sign-in succeeds, so only consecutive failures count toward a lock.

#### Scenario: One failure then success

- **GIVEN** an account with 1 failed sign-in
- **WHEN** the next sign-in succeeds
- **THEN** the account's failure count returns to 0

### Requirement: Unknown user names do not count towards a lock

ID: SWHR5-R-0155
Recovered from: LOCK-BR-0004
WHEN a sign-in uses a user name that matches no account, the system SHALL treat it as an ordinary failed sign-in, recording a sign-in failure event against the name as typed and showing the sign-in error page, and SHALL NOT count it towards locking any account.

#### Scenario: Sign-in with a non-existent user name

- **GIVEN** no account exists with the user name "ghost"
- **WHEN** a sign-in is attempted as "ghost" three times in a row
- **THEN** each attempt shows the sign-in error page and records a sign-in failure event for "ghost", and no account is locked

### Requirement: Locked account refuses every sign-in

ID: SWHR5-R-0004
Recovered from: LOCK-BR-0003
GIVEN an account is locked, WHEN anyone tries to sign in to it with any password, including the correct one, the system SHALL refuse the sign-in, show the Account Locked page, record a sign-in-while-locked event, and SHALL leave the failed sign-in count and the lock time unchanged.

#### Scenario: Correct password on a locked account

- **GIVEN** an account locked 5 minutes ago with a failed count of 3
- **WHEN** a sign-in is attempted for it with the correct password
- **THEN** the sign-in is refused, the Account Locked page is shown, a sign-in-while-locked event is recorded, and the failed count stays 3 and the lock time is unchanged

#### Scenario: Wrong password on a locked account

- **GIVEN** a locked account
- **WHEN** a sign-in is attempted for it with a wrong password
- **THEN** only a sign-in-while-locked event is recorded, no sign-in failure event is recorded, and the lock is not extended

### Requirement: Locked refusal leaves catalog browsing available

ID: SWHR5-R-0151
Recovered from: AL-BR-0002
GIVEN an account is locked, WHEN anyone tries to sign in to it, even with the right password, the system SHALL refuse the sign-in, show the Account Locked page, record a sign-in-while-locked event and leave the failed-attempt count unchanged, and the user SHALL still be able to browse the catalog.

#### Scenario: Browsing after a locked refusal

- **GIVEN** a sign-in to a locked account has just been refused
- **WHEN** the user opens a catalog category
- **THEN** the category is displayed without the user being signed in

### Requirement: Locked attempts are audited separately from failures

ID: SWHR5-R-0157
Recovered from: LOCK-RULE-0003
GIVEN a locked account, WHEN someone tries to sign in to it, the system SHALL refuse the attempt without signing the user in, and SHALL record it as a sign-in-while-locked audit event rather than as a failed sign-in.

#### Scenario: Audit entry for an attempt on a locked account

- **GIVEN** a locked account
- **WHEN** a sign-in is attempted for it
- **THEN** the audit trail gains one sign-in-while-locked event and no sign-in failure event, and no session is established

### Requirement: Attempts on a locked account do not extend the lock

ID: SWHR5-R-0150
Recovered from: ACCTLOCK-BR-0003
The system SHALL refuse a sign-in attempt on a locked account, record it as a distinct locked-account attempt (not as a failed attempt), and SHALL NOT extend the lock.

#### Scenario: Repeated attempts while locked

- **GIVEN** an account locked at 10:00:00
- **WHEN** sign-ins are attempted for it at 10:10 and 10:20
- **THEN** both are refused, its lock time stays 10:00:00, and it is released by the first unlock run more than 30 minutes after 10:00:00

### Requirement: Lockout applies to every role

ID: SWHR5-R-0146
Recovered from: LOCK-RULE-0005
The system SHALL apply the same three-failure lockout and the same automatic unlock to administrator accounts as to customer accounts.

#### Scenario: Administrator fails three times

- **GIVEN** an unlocked administrator account with 2 consecutive failed sign-ins
- **WHEN** a third sign-in is attempted with a wrong password
- **THEN** the administrator account is locked exactly as a customer account would be

### Requirement: Account lock state

ID: SWHR5-R-0148
Recovered from: LOCK-ENT-0001
The system SHALL keep, for every account, a mandatory count of consecutive failed sign-ins that starts at 0, a mandatory locked indicator that is either locked or not locked and starts as not locked, and an optional time at which the lock was set, which MUST be empty while the account is not locked.

#### Scenario: New account starts unlocked

- **GIVEN** no account exists with the user name "newcustomer"
- **WHEN** the account "newcustomer" is created
- **THEN** its failed count is 0, it is not locked and it has no lock time

### Requirement: Lock tracking for every sign-on account

ID: SWHR5-R-0154
Recovered from: ALCK-ENT-0001
The system SHALL track, for every sign-on account, a count of failed sign-on attempts starting at 0, a locked flag that is either locked or unlocked and starts unlocked, and the time the account was locked.

#### Scenario: Sample accounts loaded unlocked

- **GIVEN** an empty store
- **WHEN** the sample accounts are populated
- **THEN** every populated account has a failed count of 0, is unlocked and has no lock time

### Requirement: Lock state defaults

ID: SWHR5-R-0153
Recovered from: AL-RULE-0001
The system SHALL record for each account whether it is locked (yes or no, default no), the count of consecutive failed sign-ins (default 0), and the time it was locked.

#### Scenario: Account stored without lock values

- **GIVEN** an account is stored without a locked value or a failed count
- **WHEN** it is read back
- **THEN** it is not locked and its failed count is 0

### Requirement: Scheduled automatic unlock

ID: SWHR5-R-0006
Recovered from: LOCK-WF-0004
The system SHALL, every 15 minutes around the clock, unlock every account locked more than 30 minutes earlier, reset its failed attempts to 0, clear its lock time and record an account-unlocked event attributed to the unlock job rather than to a client address.

#### Scenario: Lock older than 30 minutes is released

- **GIVEN** an account locked at 14:30:06
- **WHEN** the unlock run executes at 15:15
- **THEN** the account is not locked, its failed count is 0, its lock time is empty, and an account-unlocked event attributed to the unlock job is recorded

#### Scenario: Lock younger than 30 minutes is kept

- **GIVEN** an account locked at 14:30:06
- **WHEN** the unlock run executes at 15:00 (lock 29 minutes 54 seconds old)
- **THEN** the account stays locked and no unlock event is recorded for it

### Requirement: Unlock check schedule

ID: SWHR5-R-0147
Recovered from: LOCK-REQ-0001
The system SHALL run the automatic account-unlock check every 15 minutes, all day from 00:00 to 23:59, every day, unlocking accounts whose lock is more than 30 minutes old.

#### Scenario: Weekend overnight run

- **GIVEN** an account locked at 02:00:00 on a Sunday
- **WHEN** the unlock check runs at 02:45 that Sunday
- **THEN** the account is unlocked

### Requirement: Automatic unlock clears lock state

ID: SWHR5-R-0152
Recovered from: AL-BR-0003
The system SHALL automatically unlock an account once its lock is more than 30 minutes old, clearing the lock time, resetting the failure count to 0 and recording an account-unlocked event.

#### Scenario: Lock exactly 30 minutes old

- **GIVEN** an account locked at 10:00:00 and unlock runs at 10:15, 10:30 and 10:45
- **WHEN** the 10:30 run evaluates it (lock exactly 30 minutes old)
- **THEN** it stays locked, and the 10:45 run unlocks it, clears its lock time, sets its failure count to 0 and records an account-unlocked event

### Requirement: Quarter-hour unlock job records its run time

ID: SWHR5-R-0144
Recovered from: LOCK-RULE-0004
The system SHALL automatically unlock a locked account with a scheduled job that runs every 15 minutes on the quarter hour, and each unlock SHALL be recorded as an account-unlocked audit event timestamped with the job's run time, after which the account's failed-attempt count SHALL restart from zero.

#### Scenario: Unlock event carries the run time

- **GIVEN** an account locked at 09:12:40
- **WHEN** the job runs at 09:45:00
- **THEN** the account is unlocked, its account-unlocked event is timestamped 09:45:00 and its failed count is 0

### Requirement: Unlock attributed to the job

ID: SWHR5-R-0142
Recovered from: ACCTLOCK-BR-0004
The system SHALL automatically unlock a locked account using a scheduled job that runs every 15 minutes on the quarter hour, once the lock is more than 30 minutes old, and each unlock SHALL be recorded as an account-unlocked event attributed to the job, not to a network address.

#### Scenario: Source of an automatic unlock event

- **GIVEN** an account locked more than 30 minutes ago
- **WHEN** the scheduled job unlocks it
- **THEN** the account-unlocked event names the unlock job as its source and carries no client address

### Requirement: No in-application unlock

ID: SWHR5-R-0005
Recovered from: LOCK-BR-0005
The web application SHALL NOT offer any way to unlock an account; a lock SHALL stay in force until it is cleared outside the application, by the scheduled unlock job or by a manual data change made by an administrator.

#### Scenario: Locked user looks for an unlock option

- **GIVEN** a locked account
- **WHEN** its user or an administrator uses the web application
- **THEN** no page or control is offered that unlocks the account

### Requirement: Early unlock by operations

ID: SWHR5-R-0013
Recovered from: LOCK-REQ-0002
An on-demand run of the automatic unlock SHALL release only accounts whose lock is more than 30 minutes old; releasing an account sooner SHALL require a manual data change by an administrator that clears the lock, resets the failed count and records an account-unlocked event attributed to the administrator.

#### Scenario: On-demand unlock run on a recent lock

- **GIVEN** an account locked 10 minutes ago
- **WHEN** operations run the unlock job on demand
- **THEN** the account stays locked

#### Scenario: Manual administrator unlock

- **GIVEN** an account locked 10 minutes ago
- **WHEN** an administrator applies the documented manual unlock
- **THEN** the account is not locked, its failed count is 0, its lock time is empty and an account-unlocked event attributed to "admin" is recorded

### Requirement: Operations unlock routes

ID: SWHR5-R-0029
Recovered from: AL-REQ-0001
The system SHALL provide no screen to unlock an account; an account SHALL be unlockable before the scheduled job only by operations running the unlock job on demand, which still only clears locks older than 30 minutes, or by a direct data change that clears the lock and failed count and records an account-unlocked event with source "admin".

#### Scenario: Direct data change by operations

- **GIVEN** an account locked 5 minutes ago with a failed count of 3
- **WHEN** operations apply the direct data change for it
- **THEN** the account is not locked, its failed count is 0 and an account-unlocked event with source "admin" is recorded

### Requirement: Manual unlock is audited with the admin source

ID: SWHR5-R-0030
Recovered from: LOCK-REQ-0005
The system SHALL offer no screen to unlock an account; an earlier unlock SHALL be done by operations, either by running the unlock job on demand, which only releases locks older than 30 minutes, or by a manual data update that clears the lock, resets the count and records an account-unlocked event with address "admin".

#### Scenario: Manual unlock leaves an audit record

- **GIVEN** a locked account released by a manual data update
- **WHEN** the audit trail for that user is read
- **THEN** it holds an account-unlocked event whose address is "admin"

### Requirement: Lock event timing in the sign-in audit trail

ID: SWHR5-R-0141
Recovered from: LOCK-BR-0008
GIVEN an account with two consecutive failed sign-ins, WHEN a third consecutive sign-in with a wrong password is made, the system SHALL record a sign-in failure event followed by an account-locked event for that user, both carrying the client address of the attempt. Whether the two events carry the same time or the account-locked event follows later is disputed between the code and the sample extract and MUST be settled before this is built.

#### Scenario: Audit events for the locking attempt

- **GIVEN** an account with two consecutive failed sign-ins
- **WHEN** a third sign-in with a wrong password is made from address 10.0.0.5
- **THEN** the audit trail holds a sign-in failure event and then an account-locked event for that user, both from 10.0.0.5

### Requirement: Account Locked page display

ID: SWHR5-R-0109
Recovered from: LOCK-SCR-0001
The system SHALL provide an Account Locked page, titled "Account Locked", on the store's shared page layout; it SHALL state that the account is locked after 3 failed sign-in attempts in a row, that locked accounts are unlocked automatically 30 minutes after the lock, and that the user should try again later or contact the store administrator, and it MUST offer a link to keep browsing the catalog.

#### Scenario: Page content is displayed

- **GIVEN** a sign-in has been refused because the account is locked
- **WHEN** the Account Locked page is displayed
- **THEN** it shows the title "Account Locked" within the shared layout, the statement that the account is locked after 3 failed sign-in attempts in a row, the statement that locks clear automatically 30 minutes after they are set, the advice to try later or contact the store administrator, and a "browsing the catalog" link

#### Scenario: Browse-catalog link is followed

- **GIVEN** the Account Locked page is displayed
- **WHEN** the user follows the "browsing the catalog" link
- **THEN** the catalog home page is shown and the user remains signed out

### Requirement: Account Locked page shown on a locked refusal

ID: SWHR5-R-0031
Recovered from: LOCK-SCR-0006
WHEN a sign-in is refused because the account is locked, whether by the attempt that locked it or by any attempt while it is locked, the system SHALL show the Account Locked page instead of the sign-in error page, and SHALL let the user keep browsing the catalog without signing in.

#### Scenario: Refused sign-in on a locked account

- **GIVEN** a locked account
- **WHEN** a sign-in is submitted for it
- **THEN** the Account Locked page is displayed and not the sign-in error page

#### Scenario: Ordinary failed sign-in

- **GIVEN** an unlocked account with 0 consecutive failed sign-ins
- **WHEN** a sign-in is submitted for it with a wrong password
- **THEN** the sign-in error page is displayed and not the Account Locked page

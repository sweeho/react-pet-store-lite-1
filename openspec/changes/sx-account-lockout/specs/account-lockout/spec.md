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

Recovered from: AL-BR-0001
WHEN a wrong-password attempt brings an account's consecutive failed sign-in count to 3, the system SHALL lock the account, record the time of the lock, record a sign-in failure event followed by an account-locked event, and SHALL refuse that same attempt as a locked-account refusal rather than as an ordinary failed sign-in.

#### Scenario: Third consecutive failure locks the account

- **GIVEN** an existing, unlocked account with 2 consecutive failed sign-ins
- **WHEN** a third sign-in is attempted with a wrong password
- **THEN** the account is locked, its failed count is 3, its lock time is the time of the attempt, a sign-in failure event and then an account-locked event are recorded, and the Account Locked page is shown instead of the sign-in error page

### Requirement: Blank password counts as a wrong password

Recovered from: LOCKOUT-BR-0003
The system SHALL treat a sign-in with a blank password on an existing, unlocked account as a wrong-password attempt: it SHALL show the sign-in error page, record a sign-in failure event and add 1 to the consecutive failed sign-in count.

#### Scenario: Blank password submitted

- **GIVEN** an existing, unlocked account with 0 consecutive failed sign-ins
- **WHEN** a sign-in is submitted for it with a blank password
- **THEN** the sign-in error page is shown, a sign-in failure event is recorded and the failed count becomes 1

### Requirement: Unknown user names do not count towards a lock

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

### Requirement: Lockout applies to every role

Recovered from: LOCK-RULE-0005
The system SHALL apply the same three-failure lockout and the same automatic unlock to administrator accounts as to customer accounts.

#### Scenario: Administrator fails three times

- **GIVEN** an unlocked administrator account with 2 consecutive failed sign-ins
- **WHEN** a third sign-in is attempted with a wrong password
- **THEN** the administrator account is locked exactly as a customer account would be

### Requirement: Account lock state

Recovered from: LOCK-ENT-0001
The system SHALL keep, for every account, a mandatory count of consecutive failed sign-ins that starts at 0, a mandatory locked indicator that is either locked or not locked and starts as not locked, and an optional time at which the lock was set, which MUST be empty while the account is not locked.

#### Scenario: New account starts unlocked

- **GIVEN** no account exists with the user name "newcustomer"
- **WHEN** the account "newcustomer" is created
- **THEN** its failed count is 0, it is not locked and it has no lock time

### Requirement: Lock state consistency

Recovered from: ACCTLOCK-BR-0001
The system SHALL keep an account's lock state consistent: an account is locked if and only if it has a lock time, and a locked account SHALL carry a failed sign-in count of 3; an account that is locked when its data is migrated SHALL keep its lock time so the automatic unlock still applies 30 minutes after it.

#### Scenario: Locked account migrated at cut-over

- **GIVEN** an account locked 10 minutes before cut-over
- **WHEN** its data is migrated
- **THEN** it remains locked with its original lock time and is released by the first unlock run more than 30 minutes after that time

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

### Requirement: Unlock threshold is strictly more than 30 minutes

Recovered from: LOCK-RULE-0001
The system SHALL release a lock only when it is strictly more than 30 minutes old at the time of the unlock run, so that a lock is cleared no earlier than 30 and no later than about 45 minutes after it was set.

#### Scenario: Lock exactly 30 minutes old

- **GIVEN** an account locked at 10:00:00 and unlock runs at 10:15, 10:30 and 10:45
- **WHEN** the 10:30 run evaluates it (lock exactly 30 minutes old)
- **THEN** it stays locked, and it is unlocked by the 10:45 run

### Requirement: Unlock is recorded atomically with the release

Recovered from: LOCK-BR-0002
The system SHALL record exactly one account-unlocked event per account it unlocks automatically, carrying the unlock time, and the event and the release MUST be committed together.

#### Scenario: Two accounts released in one run

- **GIVEN** two accounts locked more than 30 minutes ago
- **WHEN** the unlock run executes
- **THEN** both accounts are released and exactly one account-unlocked event is recorded for each

### Requirement: Locked account with no lock time

Recovered from: LOCK-BR-0003 (j2ee-pet-store-lite/db/batch)
GIVEN an account marked locked that has no recorded lock time, WHEN the automatic unlock runs, the system SHALL leave the account locked and SHALL record no unlock event for it.

#### Scenario: Lock flag set without a lock time

- **GIVEN** an account marked locked whose lock time is empty
- **WHEN** the unlock run executes
- **THEN** the account stays locked and no account-unlocked event is recorded for it

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

### Requirement: Lock event timing in the sign-in audit trail

Recovered from: LOCK-BR-0008
GIVEN an account with two consecutive failed sign-ins, WHEN a third consecutive sign-in with a wrong password is made, the system SHALL record a sign-in failure event followed by an account-locked event for that user, both carrying the client address of the attempt. Whether the two events carry the same time or the account-locked event follows later is disputed between the code and the sample extract and MUST be settled before this is built.

#### Scenario: Audit events for the locking attempt

- **GIVEN** an account with two consecutive failed sign-ins
- **WHEN** a third sign-in with a wrong password is made from address 10.0.0.5
- **THEN** the audit trail holds a sign-in failure event and then an account-locked event for that user, both from 10.0.0.5

### Requirement: Account Locked page display

Recovered from: LOCK-SCR-0001
The Account Locked page SHALL be titled "Account Locked" on the store's shared page layout and SHALL state that the account is locked after 3 failed sign-in attempts in a row, that locked accounts are unlocked automatically 30 minutes after the lock, that the user should try again later or contact the store administrator, and it MUST offer a link to keep browsing the catalog.

#### Scenario: Page content is displayed

- **GIVEN** a sign-in has been refused because the account is locked
- **WHEN** the Account Locked page is displayed
- **THEN** it shows the title "Account Locked", the statement that the account is locked after 3 failed sign-in attempts in a row, the statement that locks clear automatically 30 minutes after they are set, the advice to try later or contact the store administrator, and a "browsing the catalog" link

#### Scenario: Browse-catalog link is followed

- **GIVEN** the Account Locked page is displayed
- **WHEN** the user follows the "browsing the catalog" link
- **THEN** the catalog home page is shown and the user remains signed out

### Requirement: Account Locked page shown on a locked refusal

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

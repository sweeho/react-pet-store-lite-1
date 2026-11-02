## ADDED Requirements

### Requirement: Credential check

ID: SWHR5-R-0309
Recovered from: SIGN-REQ-0001
The system SHALL accept a sign-in only when an account with exactly the submitted user name exists, the account is not locked, and the submitted password is exactly equal to the stored password; user names and passwords SHALL be compared case-sensitively.

#### Scenario: Correct credentials on an unlocked account

- **GIVEN** an unlocked account "j2ee" whose stored password is "j2ee"
- **WHEN** a sign-in is submitted with user name "j2ee" and password "j2ee"
- **THEN** the sign-in is accepted

#### Scenario: Correct password on a locked account

- **GIVEN** a locked account "alice" whose stored password is "secret"
- **WHEN** a sign-in is submitted with user name "alice" and password "secret"
- **THEN** the sign-in is refused

### Requirement: Case-sensitive match of user name and password

ID: SWHR5-R-0312
Recovered from: SIGNON-REQ-0001
The system SHALL accept a sign-in only when an account with exactly the entered user name exists, the account is not locked, and the entered password is exactly equal to the stored password, comparing both the user name and the password case-sensitively.

#### Scenario: Password differs only in letter case

- **GIVEN** an unlocked account "j2ee" whose stored password is "j2ee"
- **WHEN** a sign-in is submitted with user name "j2ee" and password "J2EE"
- **THEN** the sign-in is refused

#### Scenario: User name differs only in letter case

- **GIVEN** an account "j2ee" exists and no account "J2EE" exists
- **WHEN** a sign-in is submitted with user name "J2EE" and the correct password of "j2ee"
- **THEN** the sign-in is refused

### Requirement: Sign-in outcome routing

ID: SWHR5-R-0308
Recovered from: SIGN-BR-0001
A sign-in SHALL succeed only when the user exists, is not locked and the password matches exactly; on success the user SHALL be returned to the page they were trying to open, or to the home page; on failure a "Sign-in Error" page with a try-again link SHALL be shown.

#### Scenario: Successful sign-in with no page requested

- **GIVEN** an unlocked account "alice" and a visitor who opened the Sign In page directly
- **WHEN** the visitor signs in as "alice" with the correct password
- **THEN** the home page is shown

#### Scenario: Failed sign-in

- **GIVEN** an unlocked account "alice"
- **WHEN** a sign-in is submitted for "alice" with a wrong password that does not lock the account
- **THEN** the "Sign-in Error" page is shown with a try-again link

### Requirement: Sign-in acceptance rule

ID: SWHR5-R-0314
Recovered from: SIGNON-BR-0001
The system SHALL accept a sign-in only when the user exists, is not locked and the password matches the stored password exactly.

#### Scenario: Unknown user

- **GIVEN** no account named "nobody" exists
- **WHEN** a sign-in is submitted for "nobody"
- **THEN** the sign-in is refused

#### Scenario: All three conditions hold

- **GIVEN** an unlocked account "alice" whose stored password is "secret"
- **WHEN** a sign-in is submitted for "alice" with password "secret"
- **THEN** the sign-in is accepted

### Requirement: Sign-in acceptance with try-again on wrong credentials

ID: SWHR5-R-0313
Recovered from: SO-BR-0001
The system SHALL accept a sign-in only when the user name exists, the account is not locked and the password matches exactly. GIVEN the user name or password is wrong THEN the system SHALL show the Sign-in Error page with a "try again" link.

#### Scenario: Wrong user name

- **GIVEN** no account named "nobody" exists
- **WHEN** a sign-in is submitted for "nobody"
- **THEN** the Sign-in Error page is shown with a "try again" link

### Requirement: Passwords compared as entered

ID: SWHR5-R-0310
Recovered from: SIGNON-BR-0007
The system SHALL store account passwords exactly as entered, without hashing, and SHALL compare them as entered at sign-in.

#### Scenario: Entered password matches the stored text

- **GIVEN** an unlocked account "alice" created with the password "Pa55word"
- **WHEN** a sign-in is submitted for "alice" with the password "Pa55word"
- **THEN** the sign-in is accepted

### Requirement: Passwords stored in readable form

ID: SWHR5-R-0211
Recovered from: SIGNON-BR-0004
The system SHALL store account passwords exactly as entered, in readable form.

#### Scenario: Stored password is the entered text

- **GIVEN** an account created with the password "Pa55word"
- **WHEN** the account record is read
- **THEN** its stored password is "Pa55word"

### Requirement: One account per case-sensitive user name

ID: SWHR5-R-0311
Recovered from: SIGNON-ENT-0001
The system SHALL keep one sign-on account per unique, case-sensitive user name, holding the password, a role, a count of consecutive failed sign-ins, a locked flag, the time the lock was set, the time of the last successful sign-in and the time the account was created.

#### Scenario: User names differing only in case are different accounts

- **GIVEN** an account "alice" exists
- **WHEN** the accounts are looked up by the user name "Alice"
- **THEN** no account is found

### Requirement: Account record

ID: SWHR5-R-0210
Recovered from: SIGN-ENT-0001
The system SHALL keep one account record per user name, holding: user name (unique, at most 25 characters), password (at most 25 characters), role (CUSTOMER or ADMIN, default CUSTOMER), count of consecutive failed sign-ins (default 0), locked flag (Y or N, default N), time the lock was set, time of the last successful sign-in, and time the account was created.

#### Scenario: Defaults on a new account

- **GIVEN** an account "alice" is created with only a user name and password
- **WHEN** the account record is read
- **THEN** its role is CUSTOMER, its failed sign-in count is 0, its locked flag is N and its creation time is set

#### Scenario: Duplicate user name

- **GIVEN** an account "alice" exists
- **WHEN** a second account "alice" is stored
- **THEN** the store refuses it

### Requirement: Successful sign-in resets the failure count

ID: SWHR5-R-0315
Recovered from: SIGNON-BR-0002
The system SHALL reset the consecutive failed sign-in count to zero on a successful sign-in and SHALL store the time of that sign-in as the account's last sign-in.

#### Scenario: Sign-in after earlier failures

- **GIVEN** an unlocked account "alice" with 2 consecutive failed sign-ins
- **WHEN** "alice" signs in with the correct password at 2024-03-05 10:15
- **THEN** the account's failed sign-in count is 0 and its last sign-in time is 2024-03-05 10:15

### Requirement: Existing user names containing a full stop

ID: SWHR5-R-0212
Recovered from: SIGNON-BR-0003
The system SHALL hold, and SHALL allow sign-in for, existing accounts whose user names contain ".", which the self-registration rule does not permit.

#### Scenario: Migrated account with a dotted user name

- **GIVEN** a migrated, unlocked account "al.khan" with a known password
- **WHEN** a sign-in is submitted for "al.khan" with that password
- **THEN** the sign-in is accepted

### Requirement: Last successful sign-in time recorded

ID: SWHR5-R-0093
Recovered from: SIGN-REQ-0002
The system SHALL record the date and time of the last successful sign-in on the account whenever a sign-in succeeds.

#### Scenario: First successful sign-in

- **GIVEN** an account "alice" that has never signed in
- **WHEN** "alice" signs in successfully at 2024-02-01 08:30
- **THEN** the account's last sign-in time is 2024-02-01 08:30

#### Scenario: Refused sign-in leaves the time unchanged

- **GIVEN** an account "alice" whose last sign-in time is 2024-02-01 08:30
- **WHEN** a sign-in for "alice" is refused
- **THEN** the account's last sign-in time is still 2024-02-01 08:30

### Requirement: Last sign-in time equals the most recent successful sign-in

ID: SWHR5-R-0094
Recovered from: SIGN-RULE-0001
The system SHALL set an account's last sign-in time to the time of its most recent successful sign-in.

#### Scenario: Several sign-ins

- **GIVEN** an account "alice" that signed in successfully at 2024-03-01 09:00 and again at 2024-03-05 10:15
- **WHEN** the account record is read
- **THEN** its last sign-in time is 2024-03-05 10:15

### Requirement: Sign out ends the session and records the sign-off

ID: SWHR5-R-0098
Recovered from: SIGNON-REQ-0006
WHEN a signed-in user chooses Sign out THEN the system SHALL end the session, record a sign-off event and show the "You are signed out" page.

#### Scenario: Signed-in user chooses Sign out

- **GIVEN** a visitor signed in as "alice"
- **WHEN** the visitor chooses Sign out
- **THEN** the session ends, a sign-off event is recorded for "alice" and the "You are signed out" page is shown

### Requirement: Sign out

ID: SWHR5-R-0009
Recovered from: SIGNON-REQ-0005
WHEN a user signs out, the system SHALL record the sign-out against the signed-in user name (if any), end the user's session, and show the "You are signed out" page. Signing out without a session or without a signed-in user SHALL still show that page.

#### Scenario: Signed-in user signs out

- **GIVEN** a visitor signed in as "alice"
- **WHEN** the visitor chooses Sign out
- **THEN** a sign-off event is recorded for "alice", the session ends and the "You are signed out" page is shown

#### Scenario: Sign out with no signed-in user

- **GIVEN** a visitor who is not signed in
- **WHEN** the sign-out address is requested
- **THEN** the "You are signed out" page is shown and no sign-off event is recorded

### Requirement: Sign-off by link or form submission

ID: SWHR5-R-0218
Recovered from: SIGN-REQ-0007
WHEN the user signs off, THEN the system SHALL record a sign-off event for the signed-in user name (if any), end the session, and show the signed-out page. WHEN there is no session, THEN the system SHALL show the signed-out page without recording anything. Sign-off SHALL be accepted both by following a page link and by form submission.

#### Scenario: Sign out by form submission

- **GIVEN** a visitor signed in as "alice"
- **WHEN** the sign-out address is submitted as a form post rather than followed as a link
- **THEN** a sign-off event is recorded for "alice", the session ends and the signed-out page is shown

#### Scenario: No session

- **GIVEN** a browser with no session
- **WHEN** the sign-out link is followed
- **THEN** the signed-out page is shown and no event is recorded

### Requirement: Return to the originally requested protected page

ID: SWHR5-R-0216
Recovered from: SIGN-REQ-0003
After a successful sign-in the system SHALL send the user to the protected page they originally asked for in this session; if no page was recorded the system SHALL send the user to the home page.

#### Scenario: Sign-in requested by a protected page

- **GIVEN** an anonymous visitor who opened My Account and was shown the Sign In page
- **WHEN** the visitor signs in successfully
- **THEN** the visitor is taken to My Account

#### Scenario: No page was recorded

- **GIVEN** an anonymous visitor who opened the Sign In page with no protected page recorded in the session
- **WHEN** the visitor signs in successfully
- **THEN** the visitor is taken to the home page

### Requirement: Return to the first requested sign-in-only page

ID: SWHR5-R-0132
Recovered from: SIGN-RUL-0003
GIVEN an anonymous visitor who requested a sign-in-only page, WHEN they sign in successfully THEN the system SHALL take them to the page first requested; otherwise the system SHALL take them to the home page.

#### Scenario: Sign-in-only page requested first

- **GIVEN** an anonymous visitor who requested My Account and was shown the Sign In page
- **WHEN** the visitor signs in successfully
- **THEN** My Account is shown

### Requirement: Return after sign-in to the page being opened

ID: SWHR5-R-0097
Recovered from: SIGNON-REQ-0002
WHEN a sign-in succeeds THEN the system SHALL return the user to the page they were trying to open, or to the home page if there was none.

#### Scenario: Page being opened

- **GIVEN** an anonymous visitor who tried to open My Account
- **WHEN** the visitor signs in successfully
- **THEN** My Account is shown

#### Scenario: No page being opened

- **GIVEN** a visitor who opened the Sign In page directly
- **WHEN** the visitor signs in successfully
- **THEN** the home page is shown

### Requirement: Return to the intended page on successful sign-in

ID: SWHR5-R-0100
Recovered from: SO-REQ-0001
WHEN a user signs in successfully THEN the system SHALL return them to the page they were trying to open, or to the home page when there was none.

#### Scenario: Intended page recorded

- **GIVEN** an anonymous visitor who tried to open My Account and was asked to sign in
- **WHEN** the visitor signs in successfully
- **THEN** My Account is shown rather than the home page

### Requirement: Banner sign-in link leads through the Welcome page

ID: SWHR5-R-0133
Recovered from: SIGN-RUL-0004
The system SHALL offer a "Sign in" link that opens a sign-in-only Welcome page, so an anonymous visitor is first shown the Sign In page and, after signing in, the Welcome page with the home page content.

#### Scenario: Signing in from the banner link

- **GIVEN** an anonymous visitor on a catalog page
- **WHEN** the visitor follows the "Sign in" link and signs in successfully
- **THEN** the visitor is first shown the Sign In page and then the Welcome page with the home page content

#### Scenario: Already signed in

- **GIVEN** a visitor signed in as "alice"
- **WHEN** the Welcome page address is opened
- **THEN** the Welcome page is shown without a sign-in prompt

### Requirement: Refused sign-in shows the sign-in error page

ID: SWHR5-R-0023
Recovered from: SIGN-REQ-0004
WHEN a sign-in fails because the user name is unknown or the password is wrong, and the account did not become locked by this attempt, THEN the system SHALL show the sign-in error page and SHALL NOT sign the user in.

#### Scenario: Unknown user name

- **GIVEN** no account named "nobody" exists
- **WHEN** a sign-in is submitted with user name "nobody"
- **THEN** the sign-in error page is shown and the visitor is not signed in

#### Scenario: Wrong password that does not lock the account

- **GIVEN** an unlocked account "alice" with 0 consecutive failed sign-ins
- **WHEN** a sign-in is submitted for "alice" with a wrong password
- **THEN** the sign-in error page is shown and the visitor is not signed in

### Requirement: Sign-in error does not disclose which credential was wrong

ID: SWHR5-R-0024
Recovered from: SIGNON-REQ-0003
GIVEN an account that is not locked, WHEN a sign-in is refused because the user name is unknown or the password is wrong and the failure does not lock the account, THEN the system SHALL show the Sign-in Error page, which MUST NOT say which of the two was wrong.

#### Scenario: Same page for an unknown user and a wrong password

- **GIVEN** an unlocked account "alice" and no account "nobody"
- **WHEN** one sign-in is submitted for "nobody" and another for "alice" with a wrong password
- **THEN** both attempts show the same Sign-in Error page with identical wording

### Requirement: Account store failure during sign-in

ID: SWHR5-R-0215
Recovered from: SIGN-REQ-0008
WHEN the account store cannot be reached or fails during a sign-in attempt, THEN the system SHALL NOT sign the user in and SHALL end the request with a general server error rather than the sign-in error page.

#### Scenario: Account store unavailable

- **GIVEN** the account store is unavailable
- **WHEN** a sign-in is submitted for "alice" with the correct password
- **THEN** the visitor is not signed in and a general server error is returned instead of the Sign-in Error page

### Requirement: Remember my user name

ID: SWHR5-R-0217
Recovered from: SIGN-REQ-0005
WHEN the user submits the sign-in form with "Remember My User Name" ticked, THEN the system SHALL store the typed user name in a browser cookie that lasts 31 days (2 678 400 seconds). WHEN it is not ticked, THEN the system SHALL delete any such cookie.

#### Scenario: Ticked

- **GIVEN** the Sign In page with no remembered user name
- **WHEN** "alice" signs in with "Remember My User Name" ticked
- **THEN** the browser keeps the user name "alice" for 31 days

#### Scenario: Unticked

- **GIVEN** the browser holds the remembered user name "alice"
- **WHEN** a sign-in is submitted with "Remember My User Name" unticked
- **THEN** the remembered user name is deleted from the browser

### Requirement: User name remembered whatever the outcome

ID: SWHR5-R-0214
Recovered from: SIGN-REQ-0006
GIVEN "Remember My User Name" is ticked, WHEN a sign-in attempt is submitted, THEN the system SHALL store the typed user name in the cookie whatever the outcome of the attempt (success, wrong password, unknown user or locked account).

#### Scenario: Unknown user with the box ticked

- **GIVEN** no account named "nobody" exists
- **WHEN** a sign-in is submitted for "nobody" with "Remember My User Name" ticked
- **THEN** the sign-in error page is shown and the browser keeps the user name "nobody"

#### Scenario: Locked account with the box ticked

- **GIVEN** a locked account "bob"
- **WHEN** a sign-in is submitted for "bob" with "Remember My User Name" ticked
- **THEN** the sign-in is refused and the browser keeps the user name "bob"

### Requirement: Remembered user name stored or deleted on every attempt

ID: SWHR5-R-0130
Recovered from: SIGN-RUL-0001
GIVEN a sign-in attempt, WHEN "Remember My User Name" is ticked THEN the system SHALL store the typed user name in the browser for 31 days (2 678 400 seconds); WHEN it is not ticked THEN the system SHALL delete any stored user name. This SHALL happen whether or not the sign-in succeeds.

#### Scenario: Unticked on a refused sign-in

- **GIVEN** the browser holds the remembered user name "alice"
- **WHEN** a sign-in for "alice" with a wrong password is submitted with the box unticked
- **THEN** the sign-in is refused and the remembered user name is deleted

### Requirement: Remembered user name pre-fills the sign-in form

ID: SWHR5-R-0213
Recovered from: SIGN-BR-0002
WHEN a user signs in with "Remember My User Name" selected THEN the system SHALL store the user name in a browser cookie that expires after 2 678 400 seconds (31 days), and SHALL pre-fill the sign-in user name from it.

#### Scenario: Returning within 31 days

- **GIVEN** "alice" signed in with "Remember My User Name" selected 10 days ago
- **WHEN** the Sign In page is opened in the same browser
- **THEN** the User Name field is pre-filled with "alice"

#### Scenario: Returning after 31 days

- **GIVEN** "alice" signed in with "Remember My User Name" selected 32 days ago and has not signed in since
- **WHEN** the Sign In page is opened in the same browser
- **THEN** the User Name field is not pre-filled with "alice"

### Requirement: Session inactivity timeout

ID: SWHR5-R-0131
Recovered from: SIGN-RUL-0002
The system SHALL end a visitor's session after 15 minutes without activity, after which the visitor MUST be treated as not signed in.

#### Scenario: Idle beyond 15 minutes

- **GIVEN** a visitor signed in as "alice" whose last request was 16 minutes ago
- **WHEN** the visitor opens My Account
- **THEN** the visitor is shown the Sign In page

#### Scenario: Activity within 15 minutes

- **GIVEN** a visitor signed in as "alice" whose last request was 10 minutes ago
- **WHEN** the visitor opens My Account
- **THEN** My Account is shown without a new sign-in

### Requirement: Sign In page returning-customer form

ID: SWHR5-R-0095
Recovered from: SIGN-SCR-0001
The Sign In page SHALL show a returning-customer form with a User Name field, a Password field, a "Remember My User Name" checkbox and a Sign In button. GIVEN a remembered user name is stored in the browser, the User Name field SHALL be pre-filled with it and the checkbox ticked; otherwise the User Name field SHALL be pre-filled with "j2ee" and the checkbox unticked. The Password field MUST start empty.

#### Scenario: No remembered user name

- **GIVEN** a browser with no remembered user name
- **WHEN** the Sign In page is displayed
- **THEN** the User Name field shows "j2ee", the Password field is empty, the checkbox is unticked and a Sign In button is offered

#### Scenario: Remembered user name present

- **GIVEN** a browser holding the remembered user name "alice"
- **WHEN** the Sign In page is displayed
- **THEN** the User Name field shows "alice", the Password field is empty and the checkbox is ticked

#### Scenario: Submitting the form

- **GIVEN** the Sign In page with "alice" and her correct password entered
- **WHEN** the visitor presses Sign In
- **THEN** the credentials are checked and the visitor is signed in

### Requirement: Sign-in Error page

ID: SWHR5-R-0134
Recovered from: SIGN-SCR-0002
GIVEN a sign-in with a wrong user name or password on an unlocked account, the system SHALL show a Sign-in Error page that says the user name and password were not found, offers a "try again" link to sign in, and states that 3 failed attempts in a row lock the account.

#### Scenario: Error page after a refused sign-in

- **GIVEN** an unlocked account "alice" and a sign-in with a wrong password that does not lock it
- **WHEN** the Sign-in Error page is displayed
- **THEN** it shows the heading "Sign-in Error", the not-found message, the 3-attempt lock warning and a "try again" link

### Requirement: Sign-in Error page try-again link

ID: SWHR5-R-0099
Recovered from: SIGNON-SCR-0004
WHEN the user name or password is wrong THEN the system SHALL show the Sign-in Error page with a "try again" link that leads back to signing in.

#### Scenario: Try again

- **GIVEN** the Sign-in Error page is displayed to a visitor who is not signed in
- **WHEN** the visitor follows "try again"
- **THEN** the Sign In page is displayed

### Requirement: Signed-out page

ID: SWHR5-R-0135
Recovered from: SIGN-SCR-0003
WHEN a signed-in visitor chooses Sign out THEN the system SHALL end their session and show a "You are signed out." page that thanks them and offers a link to sign in again.

#### Scenario: Page after sign-out

- **GIVEN** a visitor signed in as "alice"
- **WHEN** the visitor chooses Sign out
- **THEN** the page shows "You are signed out.", a thank-you line and a "sign in" link

#### Scenario: Sign in again

- **GIVEN** the signed-out page is displayed
- **WHEN** the visitor follows the "sign in" link
- **THEN** the Sign In page is displayed

### Requirement: Banner sign-in status

ID: SWHR5-R-0096
Recovered from: SIGN-SCR-0004
WHILE a visitor is signed in the system SHALL show "Signed in as <user name>" and a "Sign out" link in the banner; WHILE the visitor is not signed in it SHALL show a "Sign in" link instead.

#### Scenario: Signed-in visitor

- **GIVEN** a visitor signed in as "alice"
- **WHEN** any page is displayed
- **THEN** the banner shows "Signed in as alice" and a "Sign out" link, and no "Sign in" link

#### Scenario: Anonymous visitor

- **GIVEN** a visitor who is not signed in
- **WHEN** any page is displayed
- **THEN** the banner shows a "Sign in" link and no "Signed in as" text

## ADDED Requirements

### Requirement: Credential check

The system SHALL accept a sign-in only when an account with exactly the submitted user name exists, the account is not locked, and the submitted password is exactly equal to the stored password; user names and passwords MUST be compared case-sensitively.

#### Scenario: Correct credentials on an unlocked account

- **GIVEN** an unlocked account "j2ee" whose stored password is "j2ee"
- **WHEN** a sign-in is submitted with user name "j2ee" and password "j2ee"
- **THEN** the sign-in is accepted

#### Scenario: Password differs only in letter case

- **GIVEN** an unlocked account "j2ee" whose stored password is "j2ee"
- **WHEN** a sign-in is submitted with user name "j2ee" and password "J2EE"
- **THEN** the sign-in is refused

#### Scenario: User name differs only in letter case

- **GIVEN** an account "j2ee" exists and no account "J2EE" exists
- **WHEN** a sign-in is submitted with user name "J2EE" and the correct password of "j2ee"
- **THEN** the sign-in is refused as an unknown user name and the failure count of "j2ee" is unchanged

#### Scenario: Correct password on a locked account

- **GIVEN** a locked account "alice" whose stored password is "secret"
- **WHEN** a sign-in is submitted with user name "alice" and password "secret"
- **THEN** the sign-in is refused

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

### Requirement: Successful sign-in updates the account

WHEN a sign-in succeeds THEN the system SHALL reset the account's consecutive failed sign-in count to zero and SHALL store the time of that sign-in as the account's last successful sign-in time.

#### Scenario: Sign-in after earlier failures

- **GIVEN** an unlocked account "alice" with 2 consecutive failed sign-ins and last sign-in time 2024-01-01 09:00
- **WHEN** "alice" signs in with the correct password at 2024-03-05 10:15
- **THEN** the account's failed sign-in count is 0 and its last sign-in time is 2024-03-05 10:15

### Requirement: Sign-in outcome audit events

The system SHALL write one audit event for every sign-in attempt, carrying the user name exactly as typed, the event time and the client address: a successful sign-in event when the sign-in is accepted and a failed sign-in event when the user name is unknown or the password is wrong. A failed sign-in for an unknown user name MUST NOT change any account's failure count.

#### Scenario: Successful sign-in is audited

- **GIVEN** an unlocked account "alice"
- **WHEN** "alice" signs in with the correct password
- **THEN** one successful sign-in event is recorded for "alice"

#### Scenario: Unknown user name is audited as typed

- **GIVEN** no account named "Alice" exists and an account "alice" with 0 failed sign-ins exists
- **WHEN** a sign-in is submitted with user name "Alice"
- **THEN** one failed sign-in event is recorded for "Alice" and the failure count of "alice" stays 0

### Requirement: Signed-in session

WHEN a sign-in succeeds THEN the system SHALL record the user name and the account's role in the visitor's session and SHALL mark the session as signed in for the rest of its life.

#### Scenario: Session after a customer signs in

- **GIVEN** an unlocked CUSTOMER account "alice"
- **WHEN** "alice" signs in successfully
- **THEN** the session is marked signed in with user name "alice" and role CUSTOMER

### Requirement: Return to the requested page after sign-in

WHEN a sign-in succeeds THEN the system SHALL send the user to the sign-in-only page they asked for earlier in the same session, and SHALL send them to the home page when no such page was recorded.

#### Scenario: Sign-in requested by a protected page

- **GIVEN** an anonymous visitor who opened My Account and was shown the Sign In page
- **WHEN** the visitor signs in successfully
- **THEN** the visitor is taken to My Account

#### Scenario: No page was requested

- **GIVEN** an anonymous visitor who opened the Sign In page with no sign-in-only page recorded in the session
- **WHEN** the visitor signs in successfully
- **THEN** the visitor is taken to the home page

### Requirement: Remember my user name

WHEN a sign-in is submitted with "Remember My User Name" ticked THEN the system SHALL store the typed user name in the browser for 2 678 400 seconds (31 days); WHEN it is submitted unticked THEN the system SHALL delete any stored user name. The system SHALL do this on every attempt, whatever its outcome (accepted, wrong password, unknown user or locked account).

#### Scenario: Ticked on a successful sign-in

- **GIVEN** the Sign In page with no remembered user name
- **WHEN** "alice" signs in successfully with "Remember My User Name" ticked
- **THEN** the browser keeps the user name "alice" for 31 days

#### Scenario: Ticked on a refused sign-in

- **GIVEN** no account named "nobody" exists
- **WHEN** a sign-in is submitted for "nobody" with "Remember My User Name" ticked
- **THEN** the sign-in error page is shown and the browser keeps the user name "nobody" for 31 days

#### Scenario: Unticked

- **GIVEN** the browser holds the remembered user name "alice"
- **WHEN** a sign-in is submitted with "Remember My User Name" unticked
- **THEN** the remembered user name is deleted from the browser

### Requirement: Session inactivity timeout

The system SHALL end a session after 15 minutes without a request from the visitor, after which the visitor MUST be treated as not signed in.

#### Scenario: Idle beyond 15 minutes

- **GIVEN** a visitor signed in as "alice" whose last request was 16 minutes ago
- **WHEN** the visitor opens My Account
- **THEN** the visitor is shown the Sign In page

#### Scenario: Activity within 15 minutes

- **GIVEN** a visitor signed in as "alice" whose last request was 10 minutes ago
- **WHEN** the visitor opens My Account
- **THEN** My Account is shown without a new sign-in

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

#### Scenario: Sign out by form submission

- **GIVEN** a visitor signed in as "alice"
- **WHEN** the sign-out address is submitted as a form post rather than followed as a link
- **THEN** the outcome is the same as choosing the Sign out link

### Requirement: Account store failure during sign-in

WHEN the account store cannot be reached or fails during a sign-in attempt THEN the system SHALL NOT sign the user in and SHALL end the request with a general server error rather than the sign-in error page.

#### Scenario: Database unavailable

- **GIVEN** the account store is unavailable
- **WHEN** a sign-in is submitted for "alice" with the correct password
- **THEN** the visitor is not signed in and a general server error is returned instead of the Sign-in Error page

### Requirement: UTF-8 request decoding before sign-in

The system SHALL decode the text of every incoming request (form fields and query parameters) as UTF-8 before any sign-in or access check reads it, so that user names, passwords and other submitted text containing non-ASCII characters MUST be received intact.

#### Scenario: Non-ASCII password

- **GIVEN** an unlocked account "jose" whose stored password is "contraseña"
- **WHEN** a sign-in is submitted for "jose" with the password "contraseña"
- **THEN** the sign-in is accepted

### Requirement: Passwords stored and compared as entered

The system SHALL store account passwords exactly as entered, in readable form, and SHALL compare the submitted password with the stored value as entered at sign-in.

#### Scenario: Stored password matches the entered text

- **GIVEN** an account created with the password "Pa55word"
- **WHEN** the account record is read
- **THEN** its stored password is "Pa55word"

### Requirement: Account sign-on timestamps

The system SHALL keep on every account the time the account was created, which MUST be present and SHALL default to the current time, and the time of its most recent successful sign-in, which SHALL be empty until the first successful sign-in and SHALL equal the time of the account's latest successful sign-in event in the audit trail.

#### Scenario: New account never signed in

- **GIVEN** an account created at 2024-02-01 08:00 that has never signed in
- **WHEN** the account record is read
- **THEN** its creation time is 2024-02-01 08:00 and its last sign-in time is empty

#### Scenario: Last sign-in agrees with the audit trail

- **GIVEN** an account whose latest successful sign-in event is at 2024-03-05 10:15
- **WHEN** the account record is read
- **THEN** its last sign-in time is 2024-03-05 10:15

### Requirement: Existing user names containing a full stop

The system SHALL hold existing accounts whose user names contain "." and SHALL let them sign in, even though the self-registration rule does not permit "." in a new user name.

#### Scenario: Migrated account with a dotted user name

- **GIVEN** a migrated, unlocked account "al.khan" with a known password
- **WHEN** a sign-in is submitted for "al.khan" with that password
- **THEN** the sign-in is accepted

### Requirement: Sign In page returning-customer form

The Sign In page SHALL carry the page title "Sign On" and the heading "Sign In", and SHALL offer a returning-customer form with a User Name field, a masked Password field, a "Remember My User Name" checkbox and a Sign In button. WHEN a remembered user name is stored in the browser the User Name field SHALL be pre-filled with it and the checkbox ticked; otherwise the User Name field SHALL be pre-filled with "j2ee" and the checkbox unticked. The Password field MUST always start empty.

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

The Sign-in Error page SHALL carry the page title "Sign On Error" and the heading "Sign-in Error", SHALL state that the user name and password entered were not found, SHALL offer a "try again" link that leads back to the Sign In page, and SHALL state that an account is locked after 3 failed attempts in a row.

#### Scenario: Error page after a refused sign-in

- **GIVEN** an unlocked account "alice" and a sign-in with a wrong password that does not lock it
- **WHEN** the Sign-in Error page is displayed
- **THEN** it shows the heading "Sign-in Error", the not-found message, the 3-attempt lock warning and a "try again" link

#### Scenario: Try again

- **GIVEN** the Sign-in Error page is displayed to a visitor who is not signed in
- **WHEN** the visitor follows "try again"
- **THEN** the Sign In page is displayed

### Requirement: Signed-out page

The signed-out page SHALL carry the page title "Sign Off" and the heading "You are signed out.", SHALL thank the visitor for visiting the Pet Store, and SHALL offer a link to sign in again that leads to the Sign In page.

#### Scenario: Page after sign-out

- **GIVEN** a visitor signed in as "alice"
- **WHEN** the visitor chooses Sign out
- **THEN** the page shows "You are signed out.", a thank-you line and a "sign in" link

#### Scenario: Sign in again

- **GIVEN** the signed-out page is displayed
- **WHEN** the visitor follows the "sign in" link
- **THEN** the Sign In page is displayed

### Requirement: Banner sign-in status

The banner on every page SHALL show "Signed in as <user name>" and a "Sign out" link WHILE the visitor is signed in, and SHALL show a "Sign in" link instead, with no signed-in text, WHILE the visitor is not signed in.

#### Scenario: Signed-in visitor

- **GIVEN** a visitor signed in as "alice"
- **WHEN** any page is displayed
- **THEN** the banner shows "Signed in as alice" and a "Sign out" link, and no "Sign in" link

#### Scenario: Anonymous visitor

- **GIVEN** a visitor who is not signed in
- **WHEN** any page is displayed
- **THEN** the banner shows a "Sign in" link and no "Signed in as" text

#### Scenario: Sign out from the banner

- **GIVEN** a visitor signed in as "alice"
- **WHEN** the visitor follows the banner "Sign out" link
- **THEN** the visitor is signed out and the signed-out page is shown

### Requirement: Sign-in Welcome page

The banner "Sign in" link SHALL open a sign-in-only Welcome page: an anonymous visitor following it MUST first be shown the Sign In page and, after signing in, SHALL land on the Welcome page, which carries the page title "Welcome" and shows the home page content on the shared layout.

#### Scenario: Signing in from the banner link

- **GIVEN** an anonymous visitor on a catalog page
- **WHEN** the visitor follows the banner "Sign in" link and signs in successfully
- **THEN** the Welcome page is displayed with the home page content and the banner shows "Signed in as <user name>"

#### Scenario: Already signed in

- **GIVEN** a visitor signed in as "alice"
- **WHEN** the Welcome page address is opened
- **THEN** the Welcome page is displayed without a sign-in prompt

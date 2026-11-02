## ADDED Requirements

### Requirement: User name length

ID: SWHR5-R-0166
Recovered from: REG-BR-0001
The system SHALL refuse to create an account whose user name is missing or whose length, after leading and trailing spaces are removed, is shorter than 3 or longer than 25 characters, with the message "The user name must be 3 to 25 characters."

#### Scenario: User name too short

- **GIVEN** a visitor on the sign-up form
- **WHEN** they submit the user name "ab" with a valid, matching password
- **THEN** no account is created and the refusal reason shown is "The user name must be 3 to 25 characters."

#### Scenario: User name too long

- **GIVEN** a visitor on the sign-up form
- **WHEN** they submit a 26-character user name with a valid, matching password
- **THEN** no account is created and the refusal reason shown is "The user name must be 3 to 25 characters."

#### Scenario: User name missing

- **GIVEN** a visitor on the sign-up form
- **WHEN** they submit an empty user name with a valid, matching password
- **THEN** no account is created and the refusal reason shown is "The user name must be 3 to 25 characters."

#### Scenario: Boundary lengths accepted

- **GIVEN** no account named "abc" exists
- **WHEN** a visitor submits the user name "abc" with a valid, matching password
- **THEN** the account "abc" is created

### Requirement: User name characters

ID: SWHR5-R-0015
Recovered from: REG-BR-0002
The system SHALL refuse to create an account whose user name contains any character other than a letter, a digit, '-' or '_', with the message "The user name can only contain letters, digits, '-' and '_'."

#### Scenario: User name with a space

- **GIVEN** a visitor on the sign-up form
- **WHEN** they submit the user name "pet lover" with a valid, matching password
- **THEN** no account is created and the refusal reason shown is "The user name can only contain letters, digits, '-' and '\_'."

#### Scenario: User name with surrounding spaces

- **GIVEN** a visitor on the sign-up form
- **WHEN** they submit the user name " alice " with a valid, matching password
- **THEN** the length check passes, no account is created, and the refusal reason shown is "The user name can only contain letters, digits, '-' and '\_'."

#### Scenario: Hyphen and underscore accepted

- **GIVEN** no account named "pet_lover-1" exists
- **WHEN** a visitor submits the user name "pet_lover-1" with a valid, matching password
- **THEN** the account "pet_lover-1" is created

### Requirement: Password length

ID: SWHR5-R-0158
Recovered from: REG-BR-0003
The system SHALL refuse to create an account whose password is missing, shorter than 4 characters or longer than 25 characters, with the message "The password must be 4 to 25 characters."

#### Scenario: Password too short

- **GIVEN** a visitor on the sign-up form with a valid user name
- **WHEN** they submit the password "abc" twice
- **THEN** no account is created and the refusal reason shown is "The password must be 4 to 25 characters."

#### Scenario: Password too long

- **GIVEN** a visitor on the sign-up form with a valid user name
- **WHEN** they submit a 26-character password twice
- **THEN** no account is created and the refusal reason shown is "The password must be 4 to 25 characters."

### Requirement: Accepted password lengths

ID: SWHR5-R-0035
Recovered from: REG-RUL-0001
The system SHALL accept a new password only when it is 4 to 25 characters long, and spaces in the password MUST count towards its length without trimming.

#### Scenario: Boundary lengths accepted

- **GIVEN** a visitor on the sign-up form with a valid, unused user name
- **WHEN** they submit a 4-character password twice, or a 25-character password twice
- **THEN** the password length check passes

#### Scenario: Spaces count towards length

- **GIVEN** a visitor on the sign-up form with a valid, unused user name
- **WHEN** they submit the password "ab " (two letters and two spaces) twice
- **THEN** the password is accepted as 4 characters long

### Requirement: Password confirmation

ID: SWHR5-R-0016
Recovered from: REG-BR-0004
The system SHALL refuse to create an account when the repeated password is not identical to the password, with the message "The password and the confirmation do not match."

#### Scenario: Confirmation differs

- **GIVEN** a visitor on the sign-up form with a valid user name
- **WHEN** they submit the password "secret1" and the repeated password "secret2"
- **THEN** no account is created and the refusal reason shown is "The password and the confirmation do not match."

#### Scenario: Confirmation differs only in case

- **GIVEN** a visitor on the sign-up form with a valid user name
- **WHEN** they submit the password "Secret1" and the repeated password "secret1"
- **THEN** no account is created and the refusal reason shown is "The password and the confirmation do not match."

### Requirement: User name already taken

ID: SWHR5-R-0017
Recovered from: REG-BR-0005
The system SHALL refuse to create an account whose user name exactly matches the user name of an existing account, with the message "The user name <name> is already taken. Choose another user name." where <name> is the submitted user name.

#### Scenario: Name already taken

- **GIVEN** an account named "j2ee" exists
- **WHEN** a visitor submits the user name "j2ee" with a valid, matching password
- **THEN** no account is created and the refusal reason shown is "The user name j2ee is already taken. Choose another user name."

### Requirement: Case-sensitive user names

ID: SWHR5-R-0033
Recovered from: REG-BR-0006
The system SHALL treat user names as case-sensitive, so that user names differing only in letter case MUST be different accounts.

#### Scenario: Same name in different case

- **GIVEN** an account named "j2ee" exists and none named "J2EE"
- **WHEN** a visitor submits the user name "J2EE" with a valid, matching password
- **THEN** a separate account "J2EE" is created and the account "j2ee" is unchanged

### Requirement: Check order and single refusal reason

ID: SWHR5-R-0034
Recovered from: REG-REQ-0001
The system SHALL check a sign-up request in this order: user name length, user name characters, password length, password confirmation, then user name already taken; and SHALL report only the first failing check.

#### Scenario: Several rules broken

- **GIVEN** a visitor on the sign-up form
- **WHEN** they submit the user name "a b" with the password "ab" and the repeated password "xy"
- **THEN** no account is created and the only refusal reason shown is "The user name can only contain letters, digits, '-' and '\_'."

#### Scenario: Duplicate checked only after field rules pass

- **GIVEN** an account named "shopper" exists
- **WHEN** a visitor submits the user name "shopper" with the password "abc" twice
- **THEN** the only refusal reason shown is "The password must be 4 to 25 characters."

### Requirement: Initial state of a self-registered account

ID: SWHR5-R-0007
Recovered from: REG-REQ-0002
The system SHALL create every self-registered account with the CUSTOMER role, a failed sign-on count of zero, an unlocked state and its creation time, and self-registration SHALL NOT be able to create an administrator account.

#### Scenario: New account defaults

- **GIVEN** no account named "newpet" exists
- **WHEN** a visitor signs up as "newpet" with a valid, matching password
- **THEN** the account "newpet" has the CUSTOMER role, zero failed sign-ons, is unlocked, has no lock time and carries its creation time

#### Scenario: Role cannot be requested

- **GIVEN** a sign-up request that additionally carries a role value of ADMIN
- **WHEN** the account is created
- **THEN** the account has the CUSTOMER role

### Requirement: No self-service administrator accounts

ID: SWHR5-R-0038
Recovered from: REG-WF-0001
WHEN an account is created successfully THEN it SHALL be given the CUSTOMER role, and the system SHALL offer no self-service way to create an ADMIN account.

#### Scenario: Only customer sign-up is offered

- **GIVEN** an anonymous visitor
- **WHEN** they look for a way to create an account
- **THEN** the only account-creation surface offered is the customer sign-up form, and no surface lets them choose the ADMIN role

### Requirement: Immediate sign-in after account creation

ID: SWHR5-R-0164
Recovered from: REG-REQ-0003
WHEN a new account is created successfully, THEN the system SHALL sign the new user in immediately with the CUSTOMER role, without asking them to sign in again.

#### Scenario: New user is signed in

- **GIVEN** an anonymous visitor on the sign-up form
- **WHEN** they create the account "newpet" successfully
- **THEN** they are signed in as "newpet" with the CUSTOMER role and can open customer-only pages without entering their password again

### Requirement: Destination after account creation

ID: SWHR5-R-0168
Recovered from: AR-WF-0003
The system SHALL, after creating an account, take the new user to the page they originally asked for before being sent to sign in, or to the home page when there was none.

#### Scenario: Visitor was sent to sign in from a protected page

- **GIVEN** an anonymous visitor who was sent to the Sign In page when requesting a protected page
- **WHEN** they create an account successfully
- **THEN** they are taken to the protected page they originally requested

#### Scenario: Visitor opened the Sign In page directly

- **GIVEN** an anonymous visitor with no recorded original destination
- **WHEN** they create an account successfully
- **THEN** they are taken to the home page

### Requirement: Successful sign-up sequence

ID: SWHR5-R-0169
Recovered from: REG-REQ-0007
WHEN a new account passes every rule THEN the system SHALL create it with the CUSTOMER role, record an account-created (USER_CREATED) event, sign the user in at once and take them to the page they asked for or to the home page; the system SHALL offer no screen for creating an ADMIN account.

#### Scenario: Valid sign-up completes every step

- **GIVEN** no account named "newpet" exists and the visitor has no recorded original destination
- **WHEN** they sign up as "newpet" with a valid, matching password
- **THEN** the account exists with the CUSTOMER role, one USER_CREATED event for "newpet" is recorded, the visitor is signed in as "newpet" and the home page is displayed

### Requirement: Account-created audit event

ID: SWHR5-R-0032
Recovered from: AR-REQ-0001
WHEN an account is created through self sign-up THEN the system SHALL record exactly one USER_CREATED audit event carrying the user name and the requesting client address. A refused sign-up SHALL NOT record a USER_CREATED event.

#### Scenario: Sign-up is audited

- **GIVEN** no account named "newpet" exists
- **WHEN** a visitor at address 10.0.0.5 signs up as "newpet" successfully
- **THEN** the audit log holds one USER_CREATED event for "newpet" with client address 10.0.0.5

#### Scenario: Refused sign-up is not audited

- **GIVEN** an account named "j2ee" exists
- **WHEN** a visitor's sign-up as "j2ee" is refused as already taken
- **THEN** no new USER_CREATED event is recorded

### Requirement: Account-created event timing

ID: SWHR5-R-0159
Recovered from: ACCT-BR-0001
WHEN a customer account is created THEN the system SHALL record its account-created event at the account's creation time, and no other audit event for that account SHALL precede it; creating an account SHALL NOT itself record a successful sign-on event.

#### Scenario: Event time equals creation time

- **GIVEN** no account named "newpet" exists
- **WHEN** a visitor signs up as "newpet" successfully
- **THEN** the account-created event for "newpet" has a timestamp equal to the account's creation time, it is the earliest event for "newpet", and no successful sign-on event for "newpet" is recorded

### Requirement: Password stored as entered

ID: SWHR5-R-0162
Recovered from: REG-REQ-0004
The system SHALL store the account password exactly as entered, without hashing or encryption, and SHALL compare it as stored at sign-on.

#### Scenario: Stored password matches entry

- **GIVEN** a visitor signs up as "newpet" with the password "Secret 1"
- **WHEN** the stored account is read back
- **THEN** its password value is "Secret 1"

### Requirement: One account per user name

ID: SWHR5-R-0165
Recovered from: ACCREG-ENT-0001
The system SHALL hold one sign-on account per user name, where the user name is mandatory, at most 25 characters and unique, and the password is mandatory and at most 25 characters; the system SHALL refuse to store a second account with the same user name.

#### Scenario: Second account with the same user name is refused by the store

- **GIVEN** an account named "shopper" is stored
- **WHEN** a second account named "shopper" is stored by any path
- **THEN** the store refuses it and the existing account is unchanged

#### Scenario: Account without a password is refused by the store

- **GIVEN** no account named "nopass" exists
- **WHEN** an account named "nopass" is stored with no password
- **THEN** the store refuses it

### Requirement: Account creation time defaults

ID: SWHR5-R-0160
Recovered from: AR-ENT-0001
The system SHALL store each account under a unique user name of at most 25 characters, SHALL require a password of at most 25 characters, and SHALL record the time the account was created, defaulting to the moment the account is stored.

#### Scenario: Creation time defaults

- **GIVEN** an account is stored without an explicit creation time
- **WHEN** the account is read back
- **THEN** its creation time is the moment it was stored

### Requirement: Last sign-on time kept on the account

ID: SWHR5-R-0161
Recovered from: AREG-ENT-0001
The system SHALL keep one sign-on account per user name, recording when the account was created (defaulting to the moment of creation) and when the user last signed on; the last sign-on time MUST be empty until the first successful sign-on.

#### Scenario: New account has no last sign-on time

- **GIVEN** no account named "newpet" exists
- **WHEN** a visitor signs up as "newpet" successfully
- **THEN** the account "newpet" has a creation time and an empty last sign-on time

### Requirement: Account record fields and defaults

ID: SWHR5-R-0163
Recovered from: REG-ENT-0001
The system SHALL keep, for each account, a unique user name of at most 25 characters, a password, a role of CUSTOMER or ADMIN (default CUSTOMER), a consecutive failed attempt count (default 0), a locked flag of Y or N (default N), the time it was locked (empty when unlocked), the time of the last successful sign-on (empty until the first one) and the creation time.

#### Scenario: Defaults applied when only name and password are given

- **GIVEN** an account is stored with only a user name and a password
- **WHEN** the account is read back
- **THEN** its role is CUSTOMER, its failed attempt count is 0, its locked flag is N, its lock time and last sign-on time are empty and its creation time is set

#### Scenario: Role outside the allowed set

- **GIVEN** an account is stored with the role "MANAGER"
- **WHEN** the store validates the record
- **THEN** the store refuses it

### Requirement: Default role is CUSTOMER

ID: SWHR5-R-0167
Recovered from: AR-BR-0002
GIVEN an account is created without an explicit role THEN the system SHALL give it the CUSTOMER role.

#### Scenario: Role omitted

- **GIVEN** an account is stored by any path without a role value
- **WHEN** the account is read back
- **THEN** its role is CUSTOMER

### Requirement: Sign-up form on the Sign In page

ID: SWHR5-R-0036
Recovered from: REG-SCR-0001
The Sign In page SHALL offer a new-customer form with a User Name text input, a masked Password input, a masked Password (Repeat) input and a "Create New Account" button, and SHALL display the rules "User name: 3 to 25 letters, digits, '-' or '\_'." and "Password: 4 to 25 characters." Pressing "Create New Account" MUST submit the three values as one sign-up request.

#### Scenario: Form displayed to an anonymous visitor

- **GIVEN** an anonymous visitor
- **WHEN** the Sign In page is displayed
- **THEN** the new-customer form shows the User Name, Password and Password (Repeat) inputs (both passwords masked, all empty), the "Create New Account" button and the two rule lines

#### Scenario: Form submitted

- **GIVEN** the visitor has filled in User Name, Password and Password (Repeat)
- **WHEN** they press "Create New Account"
- **THEN** the three values are submitted as one sign-up request and the visitor sees either the page reached after successful sign-up or the account creation refusal page

### Requirement: Account creation refusal reason and go-back link

ID: SWHR5-R-0110
Recovered from: REG-SCR-0002
GIVEN an account-creation request that breaks a field rule or uses a taken user name THEN the system SHALL show a page headed "Could Not Create Your Account" with the specific refusal reason and a "go back" link to the Sign In page.

#### Scenario: Refusal displayed

- **GIVEN** a visitor submitted a sign-up with mismatching passwords
- **WHEN** the refusal page is displayed
- **THEN** it shows the heading "Could Not Create Your Account", the reason "The password and the confirmation do not match." and a "go back" link

#### Scenario: Go back

- **GIVEN** the refusal page is displayed to an anonymous visitor
- **WHEN** they follow the "go back" link
- **THEN** the Sign In page with the empty sign-up form is displayed

### Requirement: Could Not Create Your Account page

ID: SWHR5-R-0037
Recovered from: REG-SCR-0008
WHEN account creation is refused THEN the system SHALL show the "Could Not Create Your Account" page, titled "Create Account Error" within the store's standard page layout, carrying the message of the rule that was broken.

#### Scenario: Taken user name refused

- **GIVEN** an account named "j2ee" exists
- **WHEN** a visitor signs up as "j2ee" with a valid, matching password
- **THEN** the page titled "Create Account Error" is displayed with the store's standard banner, sidebar and footer, headed "Could Not Create Your Account", showing "The user name j2ee is already taken. Choose another user name."

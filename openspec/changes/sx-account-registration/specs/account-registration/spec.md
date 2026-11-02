## ADDED Requirements

### Requirement: User name length

The system SHALL refuse to create an account whose user name is missing or whose length, after leading and trailing spaces are ignored, is less than 3 or more than 25 characters, with the message "The user name must be 3 to 25 characters."

#### Scenario: User name too short

- **GIVEN** a visitor on the sign-up form
- **WHEN** they submit the user name "ab" with a valid, matching password
- **THEN** no account is created and the refusal reason shown is "The user name must be 3 to 25 characters."

#### Scenario: User name too long

- **GIVEN** a visitor on the sign-up form
- **WHEN** they submit a 26-character user name with a valid, matching password
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

The system SHALL refuse to create an account whose password is missing, shorter than 4 characters or longer than 25 characters, with the message "The password must be 4 to 25 characters." Spaces in the password MUST count towards its length.

#### Scenario: Password too short

- **GIVEN** a visitor on the sign-up form with a valid user name
- **WHEN** they submit the password "abc" twice
- **THEN** no account is created and the refusal reason shown is "The password must be 4 to 25 characters."

#### Scenario: Spaces count towards length

- **GIVEN** a visitor on the sign-up form with a valid user name
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

### Requirement: Unique case-sensitive user name

ID: SWHR5-R-0017
Recovered from: REG-BR-0005
The system SHALL refuse to create an account whose user name exactly matches the user name of an existing account, comparing case-sensitively, with the message "The user name <name> is already taken. Choose another user name." where <name> is the submitted user name.

#### Scenario: Name already taken

- **GIVEN** an account named "j2ee" exists
- **WHEN** a visitor submits the user name "j2ee" with a valid, matching password
- **THEN** no account is created and the refusal reason shown is "The user name j2ee is already taken. Choose another user name."

#### Scenario: Same name in different case

- **GIVEN** an account named "j2ee" exists and none named "J2EE"
- **WHEN** a visitor submits the user name "J2EE" with a valid, matching password
- **THEN** a separate account "J2EE" is created

### Requirement: Check order and single refusal reason

The system SHALL check a sign-up request in this order: user name length, user name characters, password length, password confirmation, then user name already taken; and SHALL report only the first failing check.

#### Scenario: Several rules broken

- **GIVEN** a visitor on the sign-up form
- **WHEN** they submit the user name "a b" (3 characters including a space) with the password "ab" and the repeated password "xy"
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
- **THEN** the account "newpet" has the CUSTOMER role, zero failed sign-ons, is unlocked, has no lock time and no last sign-on time, and carries its creation time

#### Scenario: Role cannot be requested

- **GIVEN** a sign-up request that additionally carries a role value of ADMIN
- **WHEN** the account is created
- **THEN** the account has the CUSTOMER role

### Requirement: Sign-in and redirect after account creation

When an account is created successfully, the system SHALL sign the new user in immediately with the CUSTOMER role and SHALL take them to the page they originally requested before being sent to sign in, or to the home page when no such page was recorded.

#### Scenario: Visitor was sent to sign in from a protected page

- **GIVEN** an anonymous visitor who was sent to the Sign In page when requesting a protected page
- **WHEN** they create an account successfully
- **THEN** they are signed in as a customer and taken to the protected page they originally requested

#### Scenario: Visitor opened the Sign In page directly

- **GIVEN** an anonymous visitor with no recorded original destination
- **WHEN** they create an account successfully
- **THEN** they are signed in as a customer and taken to the home page

### Requirement: Account-created audit event

The system SHALL record exactly one account-created audit event for each self-registered account, carrying the user name, the requesting client address and a timestamp equal to the account's creation time; no audit event for that account SHALL precede it. Creating an account SHALL NOT itself record a successful sign-on event or set the last sign-on time.

#### Scenario: Sign-up is audited

- **GIVEN** no account named "newpet" exists
- **WHEN** a visitor signs up as "newpet" successfully
- **THEN** the audit log holds one account-created event for "newpet" whose time equals the account's creation time, and no successful sign-on event for "newpet"

#### Scenario: Refused sign-up is not audited

- **GIVEN** an account named "j2ee" exists
- **WHEN** a visitor's sign-up as "j2ee" is refused as already taken
- **THEN** no account-created event is recorded

### Requirement: Account record

The system SHALL keep, for each account, a required user name of at most 25 characters that is unique across accounts, a required password of at most 25 characters, a role of CUSTOMER or ADMIN, a consecutive failed sign-on count, a locked flag with the time it was locked (empty while unlocked), the time of the last successful sign-on (empty until the first) and a required creation time that defaults to the moment the account is stored.

#### Scenario: Second account with the same user name is refused by the store

- **GIVEN** an account named "shopper" is stored
- **WHEN** a second account named "shopper" is stored by any path
- **THEN** the store refuses it and the existing account is unchanged

#### Scenario: Creation time defaults

- **GIVEN** an account is stored without an explicit creation time
- **WHEN** the account is read back
- **THEN** its creation time is the moment it was stored

### Requirement: Sign-up form on the Sign In page

The Sign In page SHALL offer, beside the existing-customer sign-in, a new-customer section headed "No. I would like to sign up for an account." with a User Name text input, a masked Password input, a masked Password (Repeat) input and a "Create New Account" button, and SHALL display under the form the rules "User name: 3 to 25 letters, digits, '-' or '\_'." and "Password: 4 to 25 characters." Pressing "Create New Account" MUST submit the three values as one sign-up request.

#### Scenario: Form displayed to an anonymous visitor

- **GIVEN** an anonymous visitor
- **WHEN** the Sign In page is displayed
- **THEN** the new-customer section shows the heading, the User Name, Password and Password (Repeat) inputs (both passwords masked, all empty), the "Create New Account" button and the two rule lines

#### Scenario: Form submitted

- **GIVEN** the visitor has filled in User Name, Password and Password (Repeat)
- **WHEN** they press "Create New Account"
- **THEN** the three values are submitted as a sign-up request and the visitor sees either the page reached after successful sign-up or the account creation refusal page

### Requirement: Account creation refusal message

When a sign-up request is refused for a field rule or a taken user name, the system SHALL display a page headed "Could Not Create Your Account" showing the specific refusal reason produced by the first failing check, and a "go back" link that returns the visitor to the Sign In page to try again.

#### Scenario: Refusal displayed

- **GIVEN** a visitor submitted a sign-up with mismatching passwords
- **WHEN** the refusal page is displayed
- **THEN** it shows the heading "Could Not Create Your Account", the reason "The password and the confirmation do not match." and the text "Please go back and try again." with "go back" as a link

#### Scenario: Go back

- **GIVEN** the refusal page is displayed to an anonymous visitor
- **WHEN** they follow the "go back" link
- **THEN** the Sign In page with the empty sign-up form is displayed

### Requirement: Create Account Error page

The system SHALL present the account creation refusal as its own page titled "Create Account Error", rendered within the store's standard page layout (banner, sidebar and footer) like every other store page.

#### Scenario: Error page framing

- **GIVEN** a visitor whose sign-up was refused
- **WHEN** the refusal is displayed
- **THEN** the browser page title is "Create Account Error" and the store banner, sidebar and footer surround the refusal message

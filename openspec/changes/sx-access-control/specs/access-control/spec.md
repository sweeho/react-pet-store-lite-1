## ADDED Requirements

### Requirement: Account role domain

ID: SWHR5-R-0001
Recovered from: ACC-BR-0001
The system SHALL give every account exactly one role, which SHALL be either CUSTOMER or ADMIN, and SHALL default the role to CUSTOMER when none is given; any other role value SHALL be refused.

#### Scenario: Account created without a role

- **GIVEN** a new account is stored with no role supplied
- **WHEN** the account is saved
- **THEN** the account's role is CUSTOMER

#### Scenario: Account stored with an ADMIN role

- **GIVEN** a new account is stored with role ADMIN
- **WHEN** the account is saved
- **THEN** the account is saved with role ADMIN

#### Scenario: Account stored with an unknown role

- **GIVEN** an account is stored with the role value MANAGER
- **WHEN** the account is saved
- **THEN** the save is refused and no account is stored

### Requirement: Page access by role

ID: SWHR5-R-0002
Recovered from: ACL-REQ-0002
The system SHALL leave the home, category, product, item, search, sign-in and create-account pages open to everyone; SHALL require a sign-in for My Account; and SHALL open Catalog Administration only to the ADMIN role, showing Access Denied to a signed-in CUSTOMER.

#### Scenario: Anonymous visitor browses the catalog

- **GIVEN** a visitor who is not signed in
- **WHEN** the visitor opens the home, a category, a product, an item, the search results, the sign-in or the create-account page
- **THEN** the requested page is served without a sign-in

#### Scenario: Signed-in customer opens My Account

- **GIVEN** a user signed in with role CUSTOMER
- **WHEN** the user opens My Account
- **THEN** the My Account page is served

#### Scenario: Signed-in customer opens Catalog Administration

- **GIVEN** a user signed in with role CUSTOMER
- **WHEN** the user opens Catalog Administration
- **THEN** the Access Denied page is shown instead of Catalog Administration

#### Scenario: Signed-in administrator opens Catalog Administration

- **GIVEN** a user signed in with role ADMIN
- **WHEN** the user opens Catalog Administration
- **THEN** the Catalog Administration page is served

### Requirement: Protected page set

The system SHALL protect exactly three pages: My Account and the sign-in welcome page, which any signed-in user MAY open, and Catalog Administration, which only a signed-in user with role ADMIN MAY open. Every other page SHALL be open to anonymous visitors.

#### Scenario: Anonymous visitor opens the sign-in welcome page

- **GIVEN** a visitor who is not signed in
- **WHEN** the visitor opens the sign-in welcome page
- **THEN** the Sign In page is shown in its place

#### Scenario: Signed-in user opens the sign-in welcome page

- **GIVEN** a user signed in with role CUSTOMER
- **WHEN** the user opens the sign-in welcome page
- **THEN** the sign-in welcome page is served

### Requirement: Sign-in interception and return

WHEN a visitor who is not signed in requests a protected page, the system SHALL show the Sign In page in place of the requested page and SHALL remember the requested page. After a successful sign-in, or after the visitor creates an account, the system SHALL send the user to the remembered page; WHEN no page was remembered the system SHALL send the user to the catalog home page.

#### Scenario: Anonymous visitor is returned after sign-in

- **GIVEN** a visitor who is not signed in
- **WHEN** the visitor requests My Account and then signs in successfully
- **THEN** the Sign In page is shown first and, after the sign-in, the visitor is sent to My Account

#### Scenario: Anonymous visitor is returned after creating an account

- **GIVEN** a visitor who is not signed in has requested My Account and been shown the Sign In page
- **WHEN** the visitor creates a new account
- **THEN** the visitor is signed in and sent to My Account

#### Scenario: Direct sign-in with nothing remembered

- **GIVEN** a visitor who has not requested any protected page in the session
- **WHEN** the visitor signs in successfully
- **THEN** the visitor is sent to the catalog home page

### Requirement: Role check on a protected page

GIVEN a signed-in user requests a protected page, the system SHALL serve the page WHEN the page lists no required role, SHALL serve it WHEN the user's role is one of the page's required roles, and SHALL otherwise show the Access Denied page.

#### Scenario: Protected page with no role restriction

- **GIVEN** a user signed in with role CUSTOMER
- **WHEN** the user requests My Account, which lists no required role
- **THEN** the page is served

#### Scenario: Role not among the required roles

- **GIVEN** a user signed in with role CUSTOMER
- **WHEN** the user requests a page that requires role ADMIN
- **THEN** the Access Denied page is shown and the requested page is not served

### Requirement: Role held for the session

The system SHALL read the account's role at sign-in and SHALL use that role for every access decision for the rest of the session; a change to the account's role SHALL take effect at the account's next sign-in.

#### Scenario: Role changed during a session

- **GIVEN** a user signed in with role CUSTOMER
- **WHEN** the account's stored role is changed to ADMIN while the session is open, and the user then opens Catalog Administration
- **THEN** the Access Denied page is shown

#### Scenario: Role change seen at next sign-in

- **GIVEN** an account whose stored role was changed from CUSTOMER to ADMIN
- **WHEN** the user signs out, signs in again and opens Catalog Administration
- **THEN** the Catalog Administration page is served

### Requirement: Self-registered accounts are customers

The system SHALL give every account created through self-registration the role CUSTOMER; an ADMIN account SHALL NOT be obtainable through self-registration.

#### Scenario: Visitor creates an account

- **GIVEN** a visitor on the create-account page
- **WHEN** the visitor creates an account
- **THEN** the new account's role is CUSTOMER and the visitor is signed in with role CUSTOMER

### Requirement: Forced sample-data reload restricted to administrators

GIVEN a forced reload of the sample data is requested, WHEN the requester is not signed in with role ADMIN, THEN the system SHALL NOT reload or remove any data, SHALL leave the requester's session intact, and SHALL send the requester to the Access Denied page. This check SHALL apply to the reload request itself, independently of the page that offers it, and SHALL apply whichever request method is used.

#### Scenario: Customer requests a forced reload

- **GIVEN** a user signed in with role CUSTOMER
- **WHEN** the user sends a forced reload request directly
- **THEN** no data is reloaded and the Access Denied page is shown

#### Scenario: Anonymous visitor requests a forced reload

- **GIVEN** a visitor who is not signed in
- **WHEN** the visitor sends a forced reload request directly
- **THEN** no data is reloaded and the Access Denied page is shown

#### Scenario: Administrator requests a forced reload

- **GIVEN** a user signed in with role ADMIN
- **WHEN** the user requests a forced reload
- **THEN** the reload proceeds

### Requirement: First sample-data load open to everyone

The system SHALL allow any visitor, including one who is not signed in, to make a first (non-forced) sample-data load request, so that a store with an empty database can start without an account.

#### Scenario: Anonymous first load on an empty store

- **GIVEN** an empty store database and a visitor who is not signed in
- **WHEN** the visitor requests the first (non-forced) sample-data load
- **THEN** the load proceeds without a sign-in and without showing the Access Denied page

### Requirement: Store is the only exposed web application

The system SHOULD serve the store as the only web application on its server, under the single path /petstore, and SHALL NOT expose a server administration or sample application alongside it.

#### Scenario: Request for a path outside the store

- **GIVEN** the store is deployed
- **WHEN** a client requests a server administration console path outside /petstore
- **THEN** no administration console is served

### Requirement: Access Denied page display

The Access Denied page SHALL display the title "Access Denied", the message "You do not have permission to view this page.", the explanation that the page is for store administrators only, and a link back to the catalog; it SHALL be displayed within the store's shared page layout.

#### Scenario: Access Denied page is displayed

- **GIVEN** a user signed in with role CUSTOMER has opened Catalog Administration
- **WHEN** the Access Denied page is displayed
- **THEN** it shows the title "Access Denied", the message "You do not have permission to view this page.", the statement that the page is for store administrators only, and a catalog link, inside the shared layout

#### Scenario: Catalog link is followed

- **GIVEN** the Access Denied page is displayed
- **WHEN** the user selects the catalog link
- **THEN** the catalog home page is shown

### Requirement: Banner Admin link

WHILE the signed-in user has role ADMIN, the banner SHALL show an "Admin" link that leads to Catalog Administration; for a signed-in CUSTOMER or an anonymous visitor the banner SHALL NOT show it.

#### Scenario: Administrator sees the Admin link

- **GIVEN** a user signed in with role ADMIN
- **WHEN** any page with the banner is displayed
- **THEN** the banner shows an "Admin" link, and selecting it opens Catalog Administration

#### Scenario: Customer does not see the Admin link

- **GIVEN** a user signed in with role CUSTOMER
- **WHEN** any page with the banner is displayed
- **THEN** the banner shows no "Admin" link

#### Scenario: Anonymous visitor does not see the Admin link

- **GIVEN** a visitor who is not signed in
- **WHEN** any page with the banner is displayed
- **THEN** the banner shows no "Admin" link

### Requirement: Banner Account link

The banner SHALL show an "Account" link to every visitor, signed in or not, leading to My Account; selecting it as an anonymous visitor SHALL show the Sign In page.

#### Scenario: Anonymous visitor selects Account

- **GIVEN** a visitor who is not signed in
- **WHEN** the visitor selects the banner's "Account" link
- **THEN** the Sign In page is shown, and after a successful sign-in the visitor is sent to My Account

#### Scenario: Signed-in user selects Account

- **GIVEN** a user signed in with role CUSTOMER
- **WHEN** the user selects the banner's "Account" link
- **THEN** the My Account page is shown

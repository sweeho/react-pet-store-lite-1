## ADDED Requirements

### Requirement: Account role domain

ID: SWHR5-R-0001
Recovered from: ACC-BR-0001
The system SHALL give every account exactly one role, which SHALL be either CUSTOMER or ADMIN, and SHALL default the role to CUSTOMER when none is given; any other role value SHALL be refused.

#### Scenario: Account created without a role
ID: SWHR5-R-0001.01

- **GIVEN** a new account is stored with no role supplied
- **WHEN** the account is saved
- **THEN** the account's role is CUSTOMER

#### Scenario: Account stored with an ADMIN role
ID: SWHR5-R-0001.02

- **GIVEN** a new account is stored with role ADMIN
- **WHEN** the account is saved
- **THEN** the account is saved with role ADMIN

#### Scenario: Account stored with an unknown role
ID: SWHR5-R-0001.03

- **GIVEN** an account is stored with the role value MANAGER
- **WHEN** the account is saved
- **THEN** the save is refused and no account is stored

### Requirement: Page access by role

ID: SWHR5-R-0002
Recovered from: ACL-REQ-0002
The system SHALL leave the home, category, product, item, search, sign-in and create-account pages open to everyone; SHALL require a sign-in for My Account; and SHALL open Catalog Administration only to the ADMIN role, showing Access Denied to a signed-in CUSTOMER.

#### Scenario: Anonymous visitor browses the catalog
ID: SWHR5-R-0002.01

- **GIVEN** a visitor who is not signed in
- **WHEN** the visitor opens the home, a category, a product, an item, the search results, the sign-in or the create-account page
- **THEN** the requested page is served without a sign-in

#### Scenario: Signed-in customer opens My Account
ID: SWHR5-R-0002.02

- **GIVEN** a user signed in with role CUSTOMER
- **WHEN** the user opens My Account
- **THEN** the My Account page is served

#### Scenario: Signed-in customer opens Catalog Administration
ID: SWHR5-R-0002.03

- **GIVEN** a user signed in with role CUSTOMER
- **WHEN** the user opens Catalog Administration
- **THEN** the Access Denied page is shown instead of Catalog Administration

#### Scenario: Signed-in administrator opens Catalog Administration
ID: SWHR5-R-0002.04

- **GIVEN** a user signed in with role ADMIN
- **WHEN** the user opens Catalog Administration
- **THEN** the Catalog Administration page is served

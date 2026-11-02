## ADDED Requirements

### Requirement: Store entry page

ID: SWHR5-R-0092
Recovered from: SDP-SCR-0001
The system SHALL show an entry page describing the store with an "enter the store" link, stating that the database is populated automatically on first use and that administrators can reload the sample data after signing in.

#### Scenario: Entry page is displayed
ID: SWHR5-R-0092.01

- **GIVEN** a visitor who opens the store's root address
- **WHEN** the entry page is displayed
- **THEN** it shows the store description, an "enter the store" link, a note that the database is populated automatically on first use, and a note that administrators can reload the sample data after signing in

### Requirement: Catalog Administration page

ID: SWHR5-R-0129
Recovered from: POP-SCR-0002
The system SHALL show administrators a Catalog Administration page that warns that reloading drops and recreates every catalog and sign-on table, deletes all accounts created in the store and all sign-in history, and signs the administrator out, and that offers a "Reload Sample Data" button which requests a forced reload followed by the home page.

#### Scenario: Administrator opens the page
ID: SWHR5-R-0129.01

- **GIVEN** a user signed in with the ADMIN role
- **WHEN** the Catalog Administration page is displayed
- **THEN** it shows the warning that every catalog and sign-on table is dropped and recreated, that all accounts created in the store and all sign-in history are deleted and that the administrator will be signed out, and a "Reload Sample Data" button

#### Scenario: Administrator presses Reload Sample Data
ID: SWHR5-R-0129.02

- **GIVEN** the Catalog Administration page displayed to a signed-in ADMIN
- **WHEN** the administrator presses "Reload Sample Data"
- **THEN** a forced reload of the sample data is requested and, on success, the home page is shown with the administrator signed out

### Requirement: Entering the store requests a first load

ID: SWHR5-R-0128
Recovered from: POP-SCR-0001
The system SHALL show an entry page with an "enter the store" link; WHEN the link is followed THEN the system SHALL show "Please wait while the Java Pet Store Application is being populated..." and immediately request a first load (not a forced reload) of the sample data, then show the home page. Any visitor SHALL be able to do this without signing in.

#### Scenario: Anonymous visitor follows the link
ID: SWHR5-R-0128.01

- **GIVEN** the entry page displayed to a visitor who is not signed in
- **WHEN** the visitor follows the "enter the store" link
- **THEN** the "Please wait while the Java Pet Store Application is being populated..." message is shown, a first-load population is requested, and the home page is shown without any sign-in prompt

### Requirement: Daily catalog check triggers first load

ID: SWHR5-R-0207
Recovered from: POP-REQ-0001
GIVEN the daily 06:00 catalog check finds the catalog empty WHEN it runs THEN the system SHALL perform a first load of the sample data (not a forced reload) and SHALL then check the catalog again.

#### Scenario: Catalog empty at 06:00
ID: SWHR5-R-0207.01

- **GIVEN** a store whose catalog is empty
- **WHEN** the daily 06:00 catalog check runs
- **THEN** a first load of the sample data is requested and the catalog is checked again afterwards

### Requirement: Non-forced population check

ID: SWHR5-R-0306
Recovered from: POP-WF-0001
WHEN a population request arrives that is not a forced reload, the system SHALL check whether the catalog (categories, category texts, products, product texts, items, item texts) and the sign-on accounts each hold at least one row. GIVEN all of them hold data, THEN the system SHALL change nothing. GIVEN any of them is empty or cannot be read, THEN the system SHALL drop, recreate and reload every catalog and sign-on table from the sample data file, exactly as for a forced reload.

#### Scenario: Store already populated
ID: SWHR5-R-0306.01

- **GIVEN** a store whose catalog and sign-on account tables all hold rows
- **WHEN** a non-forced population request arrives
- **THEN** no catalog, account or sign-on history data is changed

#### Scenario: One catalog table empty
ID: SWHR5-R-0306.02

- **GIVEN** a store whose item texts table is empty and whose other checked tables hold rows
- **WHEN** a non-forced population request arrives
- **THEN** every catalog and sign-on table is dropped, recreated and reloaded from the sample data file

### Requirement: Failed check counts as not populated

ID: SWHR5-R-0295
Recovered from: POP-BR-0001
GIVEN a non-forced population request, WHEN any one of the seven checked tables has no rows, OR the check itself fails for any reason (for example a table is missing or the database returns an error), THEN the system SHALL treat the store as not yet populated and SHALL perform the full drop-and-reload, which also deletes every sign-on account and all sign-on history. The sign-on history table SHALL NOT be part of the check.

#### Scenario: Missing table
ID: SWHR5-R-0295.01

- **GIVEN** a database in which the product table does not exist
- **WHEN** a non-forced population request arrives
- **THEN** the full drop-and-reload runs and deletes every existing sign-on account and all sign-on history

#### Scenario: Empty sign-on history only
ID: SWHR5-R-0295.02

- **GIVEN** a store whose seven checked tables all hold rows and whose sign-on history table is empty
- **WHEN** a non-forced population request arrives
- **THEN** no data is changed

### Requirement: Sample catalog invariants

ID: SWHR5-R-0088
Recovered from: SDP-BR-0002
The system SHALL load a sample catalog of five categories (FISH, DOGS, REPTILES, CATS, BIRDS), sixteen products and twenty-eight items, with US English text only, in which every category has at least one product, every product has at least one item, and every item's list price is at least its unit cost.

#### Scenario: Catalog invariants after load
ID: SWHR5-R-0088.01

- **GIVEN** an empty database
- **WHEN** the sample data is loaded
- **THEN** the catalog holds the categories FISH, DOGS, REPTILES, CATS and BIRDS, 16 products and 28 items, every category has a product, every product has an item, and no item's list price is below its unit cost

### Requirement: Forced-mode flag interpretation

ID: SWHR5-R-0084
Recovered from: POP-BR-0002
The system SHALL treat a population request as a forced reload only when its "forcefully" parameter is the word true (in any letter case). GIVEN the parameter is absent, empty or any other value, THEN the request SHALL be handled as a first-load request.

#### Scenario: Parameter absent
ID: SWHR5-R-0084.01

- **GIVEN** any caller
- **WHEN** a population request carries no "forcefully" parameter
- **THEN** the request is handled as a first-load request

### Requirement: Forced value matched case-insensitively

ID: SWHR5-R-0089
Recovered from: SDP-BR-0013
The system SHALL treat a population request as forced only when its "forcefully" value is "true" (in any letter case); any other or absent value SHALL be handled as a first-load request.

#### Scenario: Mixed-case true
ID: SWHR5-R-0089.01

- **GIVEN** a signed-in ADMIN
- **WHEN** a population request carries the "forcefully" value "TRUE"
- **THEN** the request is handled as a forced reload

#### Scenario: Unrecognised value
ID: SWHR5-R-0089.02

- **GIVEN** any caller
- **WHEN** a population request carries the "forcefully" value "yes"
- **THEN** the request is handled as a first-load request

### Requirement: First-load requests open to any caller

ID: SWHR5-R-0302
Recovered from: SDP-BR-0004
The system SHALL allow a first-load (non-forced) population request from any caller, signed on or not.

#### Scenario: Customer requests a first load
ID: SWHR5-R-0302.01

- **GIVEN** a user signed in with the CUSTOMER role
- **WHEN** the user requests a non-forced population
- **THEN** the request is accepted and is not answered with Access Denied

### Requirement: Forced reload restricted to administrators

ID: SWHR5-R-0022
Recovered from: POP-REQ-0003
The system SHALL allow a forced reload of the sample data only to a user signed in with the ADMIN role, and SHALL show Access Denied to anyone else, anonymous or CUSTOMER, who asks for it.

#### Scenario: Anonymous visitor requests a forced reload
ID: SWHR5-R-0022.01

- **GIVEN** a visitor who is not signed in
- **WHEN** the visitor requests a forced reload of the sample data
- **THEN** Access Denied is shown and no table is dropped, recreated or loaded

#### Scenario: Customer requests a forced reload
ID: SWHR5-R-0022.02

- **GIVEN** a user signed in with the CUSTOMER role
- **WHEN** the user requests a forced reload of the sample data
- **THEN** Access Denied is shown and no table is dropped, recreated or loaded

#### Scenario: Administrator requests a forced reload
ID: SWHR5-R-0022.03

- **GIVEN** a user signed in with the ADMIN role
- **WHEN** the user requests a forced reload of the sample data
- **THEN** the reload is performed

### Requirement: Forced reload rule

ID: SWHR5-R-0208
Recovered from: POP-RUL-0001
WHEN a forced reload of the sample data is requested THEN the system SHALL perform it only for a signed-in user with role ADMIN, SHALL show Access Denied to anyone else, and on success SHALL delete and recreate all catalog, account and sign-on history data from the sample file and SHALL end the requester's session.

#### Scenario: Successful forced reload
ID: SWHR5-R-0208.01

- **GIVEN** a populated store holding a self-registered customer account and sign-on history
- **WHEN** a signed-in ADMIN performs a forced reload
- **THEN** the self-registered account and all sign-on history are gone, the sample catalog and sample accounts are present, and the administrator is signed out

### Requirement: Reload Sample Data replaces all store tables

ID: SWHR5-R-0087
Recovered from: POP-REQ-0004
WHEN an ADMIN chooses Reload Sample Data on the Catalog Administration page THEN the system SHALL drop and recreate the CATEGORY, CATEGORY_DETAILS, PRODUCT, PRODUCT_DETAILS, ITEM, ITEM_DETAILS, SIGNON and SIGNON_AUDIT data, load the sample data, end the administrator's session and show the home page.

#### Scenario: Administrator reloads
ID: SWHR5-R-0087.01

- **GIVEN** a signed-in ADMIN on the Catalog Administration page
- **WHEN** the administrator chooses Reload Sample Data
- **THEN** all eight tables are dropped, recreated and loaded from the sample data, the administrator is signed out and the home page is shown

### Requirement: Session ended on every accepted population request

ID: SWHR5-R-0296
Recovered from: POP-BR-0003
WHEN a population request passes the access check, the system SHALL end the requester's session before checking or loading any data, whether or not a reload then takes place. GIVEN a signed-in user enters the store through the first-load page on an already populated store, THEN that user SHALL be signed out.

#### Scenario: Signed-in customer enters a populated store
ID: SWHR5-R-0296.01

- **GIVEN** a user signed in with the CUSTOMER role and a populated store
- **WHEN** the user enters the store through the first-load page
- **THEN** no data changes and the user is signed out

### Requirement: Population step order

ID: SWHR5-R-0299
Recovered from: POP-WF-0002
WHEN a reload is performed (forced, or first load on an empty store), the system SHALL (1) drop the item texts, items, product texts, products, category texts and categories, then the sign-on history and the sign-on accounts, ignoring any table that cannot be dropped; (2) create categories, category texts, products, product texts, items, item texts, then sign-on accounts and sign-on history, stopping with an error if any table cannot be created; (3) load users and catalog from the sample data file.

#### Scenario: Table absent at drop time
ID: SWHR5-R-0299.01

- **GIVEN** a database in which the sign-on history table does not exist
- **WHEN** a reload runs
- **THEN** the missing table is ignored at the drop step, and all tables are created and loaded

#### Scenario: Table cannot be created
ID: SWHR5-R-0299.02

- **GIVEN** a database in which the item table cannot be created
- **WHEN** a reload runs
- **THEN** the reload stops with an error and the sample data file is not loaded

### Requirement: Eight-table populated check and recreation

ID: SWHR5-R-0294
Recovered from: SDP-WF-0005
The system SHALL treat the store as already populated only when every one of the eight store tables (category, category details, product, product details, item, item details, sign-on accounts, sign-on audit) can be read; WHEN it (re)populates THEN it SHALL drop and recreate all eight tables, including all sign-on accounts and the whole sign-on audit history, before loading the sample data.

#### Scenario: Sign-on audit table unreadable
ID: SWHR5-R-0294.01

- **GIVEN** a store whose sign-on audit table does not exist
- **WHEN** a first-load population request arrives
- **THEN** all eight tables are dropped and recreated and the sample data is loaded

### Requirement: No rollback on partial failure

ID: SWHR5-R-0209
Recovered from: POP-BR-0004
GIVEN a reload fails part-way (a table cannot be created, a row cannot be inserted, or the data file cannot be read), THEN the system SHALL leave the tables in whatever state the failure reached: tables already dropped stay dropped and rows already inserted stay inserted. No step of the reload SHALL be undone.

#### Scenario: Insert fails mid-load
ID: SWHR5-R-0209.01

- **GIVEN** a reload whose sample data contains a row that violates a table constraint
- **WHEN** the insert of that row fails
- **THEN** the reload reports failure and the rows inserted before it remain in the database

### Requirement: Language code normalisation

ID: SWHR5-R-0085
Recovered from: POP-BR-0005
WHEN the system loads a language code from the sample data file, it SHALL replace every hyphen with an underscore before storing it (for example en-US is stored as en_US).

#### Scenario: en-US in the data file
ID: SWHR5-R-0085.01

- **GIVEN** a sample data text entry with language "en-US"
- **WHEN** the reload loads it
- **THEN** the stored language code is "en_US"

### Requirement: Sample data file validation on read

ID: SWHR5-R-0297
Recovered from: POP-BR-0006
WHEN the sample data file is read, the system SHALL validate it against its declared document type. GIVEN the file contains a validity error that is not fatal, THEN the system SHALL report it in the server log and continue loading. GIVEN the file is not well-formed (a fatal error), THEN the system SHALL stop the load and report a population failure.

#### Scenario: Malformed file
ID: SWHR5-R-0297.01

- **GIVEN** a sample data file with an unclosed element
- **WHEN** the reload reads it
- **THEN** the load stops and a population failure is reported

#### Scenario: Non-fatal validity error
ID: SWHR5-R-0297.02

- **GIVEN** a well-formed sample data file in which an item omits a required child
- **WHEN** the reload reads it
- **THEN** the error is written to the server log and loading continues

### Requirement: Sample data referential validation

ID: SWHR5-R-0301
Recovered from: SDP-BR-0001
The system SHALL validate the sample data before loading it, and SHALL require that every category, product and item in it has at least one localized text entry carrying a language code, that every product names a category defined in the same data, and that every item names a product defined in the same data.

#### Scenario: Product names an undefined category
ID: SWHR5-R-0301.01

- **GIVEN** sample data in which a product names a category that is not defined in the same data
- **WHEN** the sample data is validated
- **THEN** the validation reports the product as invalid

### Requirement: Population result redirection

ID: SWHR5-R-0298
Recovered from: POP-BR-0007
WHEN a population request completes, the system SHALL send the requester to the success page named in the request; GIVEN none is named, to the page the request came from; GIVEN neither is known, it SHALL return an empty successful response. WHEN population fails, GIVEN an error page is named in the request, THEN the system SHALL send the requester there; otherwise it SHALL return a server error. A page name beginning with a single slash or no slash SHALL be resolved inside the store; one beginning with two slashes SHALL be resolved against the current request address.

#### Scenario: Success with a named page
ID: SWHR5-R-0298.01

- **GIVEN** a population request naming the home page as its success page
- **WHEN** the population succeeds
- **THEN** the requester is sent to the home page

#### Scenario: Failure without an error page
ID: SWHR5-R-0298.02

- **GIVEN** a population request that names no error page
- **WHEN** the population fails
- **THEN** the request fails with a server error

### Requirement: Loaded account attributes

ID: SWHR5-R-0127
Recovered from: POP-ENT-0001
WHEN a reload loads users, the system SHALL create one sign-on account per user in the data file with the user's id as the user name, the password exactly as written in the file, and the role given in the file. Every other account attribute SHALL take its default: zero failed sign-ins, not locked, no lock time, no last sign-on, created now.

#### Scenario: Loaded account defaults
ID: SWHR5-R-0127.01

- **GIVEN** a sample data file listing user "shopper" with role CUSTOMER
- **WHEN** the reload loads it
- **THEN** the account "shopper" has the role CUSTOMER, zero failed sign-ins, is not locked, has no lock time and no last sign-on time, and has the load time as its creation time

### Requirement: Catalog record structure on load

ID: SWHR5-R-0307
Recovered from: POP-ENT-0002
WHEN a reload loads the catalog, the system SHALL create, for each category in the data file, a category with its id and one text row per language (name, image, description, language); for each product, a product with its id and category plus one text row per language (language, name, image, description); and for each item, an item with its id and product plus one detail row per language (list price, unit cost, language, up to five attributes, image, description). Each category, product and item SHALL be created before its text or detail rows. A field missing from the file SHALL be stored as empty (null).

#### Scenario: Item without optional attributes
ID: SWHR5-R-0307.01

- **GIVEN** a sample item that declares only one attribute
- **WHEN** the reload loads it
- **THEN** the item row is created before its detail row, and the detail row holds that attribute with its other four attributes empty

### Requirement: Sample account passwords

ID: SWHR5-R-0292
Recovered from: POP-ENT-0005
The system SHALL provide, from the sample data, the accounts j2ee (CUSTOMER, password j2ee), shopper (CUSTOMER, password j2ee) and admin (ADMIN, password admin).

#### Scenario: Sign in with a sample account
ID: SWHR5-R-0292.01

- **GIVEN** a store freshly loaded from the sample data
- **WHEN** a user signs in as admin with password admin
- **THEN** the sign-in succeeds with the ADMIN role

### Requirement: Sample accounts created on load

ID: SWHR5-R-0293
Recovered from: SDP-REQ-0003
The system SHALL create three sample sign-on accounts when it loads sample data: "j2ee" and "shopper" with the CUSTOMER role, and "admin" with the ADMIN role, each with a fixed password supplied in the sample data.

#### Scenario: Accounts after first load
ID: SWHR5-R-0293.01

- **GIVEN** an empty database
- **WHEN** the first load completes
- **THEN** exactly the accounts j2ee, shopper and admin exist with the roles CUSTOMER, CUSTOMER and ADMIN

### Requirement: Sample data content

ID: SWHR5-R-0090
Recovered from: SDP-ENT-0001
The sample data SHALL contain 5 categories (Birds, Cats, Dogs, Fish, Reptiles), 16 products and 28 items, and three accounts: j2ee (CUSTOMER), shopper (CUSTOMER) and admin (ADMIN), each with the documented sample password.

#### Scenario: Counts after first load
ID: SWHR5-R-0090.01

- **GIVEN** an empty database
- **WHEN** the first load completes
- **THEN** the store holds 5 categories, 16 products, 28 items and the three sample accounts

### Requirement: Sample item identifiers and prices

ID: SWHR5-R-0091
Recovered from: SDP-REQ-0002
The system SHALL load a fixed sample catalog of 5 categories (Fish, Dogs, Reptiles, Cats, Birds), 16 products and 28 items (EST-1 to EST-28), each with English (United States) text and, for items, the list price and unit cost given in the sample data.

#### Scenario: Item identifiers after load
ID: SWHR5-R-0091.01

- **GIVEN** an empty database
- **WHEN** the first load completes
- **THEN** the items are EST-1 to EST-28, all text has language en_US, and each item's list price and unit cost equal the values in the sample data

### Requirement: Configured data file, statements and dialect

ID: SWHR5-R-0086
Recovered from: POP-INT-0001
The system SHALL load the sample data from a configured data file (by default the store's bundled UTF-8 sample file) and SHALL take the table statements from a configured statements file, using only the statement set for the configured database dialect (by default derby). GIVEN a statement needed for a table and operation is not defined for that dialect, THEN the population SHALL fail with an error naming the missing statement.

#### Scenario: Missing dialect statement
ID: SWHR5-R-0086.01

- **GIVEN** a configured dialect that lacks the create statement for the item table
- **WHEN** a reload runs
- **THEN** the population fails with an error naming the missing statement

### Requirement: Two database dialects

ID: SWHR5-R-0303
Recovered from: SDP-INT-0006
The system SHALL provide the store table definitions for two database products (Derby and Oracle) and SHALL use the set selected by configuration, Derby by default.

#### Scenario: No dialect configured
ID: SWHR5-R-0303.01

- **GIVEN** a deployment that sets no database dialect
- **WHEN** a reload runs
- **THEN** the Derby table definitions are used

### Requirement: First load callable by the catalog check job

ID: SWHR5-R-0305
Recovered from: POP-INT-0002
The system SHALL expose the first-load population as an address that the daily catalog check job can call without signing in. GIVEN the call succeeds or there was nothing to load, THEN the call SHALL report success; GIVEN population fails, THEN the call SHALL report failure, so the job can end with its population-failed exit code.

#### Scenario: Nothing to load
ID: SWHR5-R-0305.01

- **GIVEN** a populated store
- **WHEN** the job calls the first-load address without signing in
- **THEN** the call reports success

#### Scenario: Load fails during a job call
ID: SWHR5-R-0305.02

- **GIVEN** an empty store whose load fails
- **WHEN** the job calls the first-load address
- **THEN** the call reports failure that the job can detect

### Requirement: Repeatable sign-on history seed

ID: SWHR5-R-0300
Recovered from: SAMPLE-WF-0001
The system SHALL provide an optional, repeatable sign-on history data set, loaded only after the first catalog/account load, that adds 40 extra CUSTOMER accounts and 90 days of sign-on audit events ending on a chosen end date (default 2026-10-30), and SHALL produce the identical data set every time for the same end date.

#### Scenario: Seed loaded after first population
ID: SWHR5-R-0300.01

- **GIVEN** a store populated with the sample data
- **WHEN** the default seed is loaded
- **THEN** 40 additional CUSTOMER accounts and 90 days of sign-on audit events ending 2026-10-30 exist

#### Scenario: Regenerated for the same end date
ID: SWHR5-R-0300.02

- **GIVEN** the seed generated twice for end date 2026-10-30
- **WHEN** the two outputs are compared
- **THEN** they are identical

### Requirement: Seed account roles

ID: SWHR5-R-0304
Recovered from: SDP-RULE-0001
The system SHALL keep the three built-in accounts (j2ee, shopper, admin) as rows the sign-on history seed updates but never creates, and every account the seed creates SHALL have the CUSTOMER role.

#### Scenario: Roles after seeding
ID: SWHR5-R-0304.01

- **GIVEN** the seed has been loaded after the first population
- **WHEN** accounts are listed by role
- **THEN** admin is the only ADMIN account and every account added by the seed has the CUSTOMER role

#### Scenario: Seed loaded before first population
ID: SWHR5-R-0304.02

- **GIVEN** a store that has not been populated
- **WHEN** the seed is loaded
- **THEN** no j2ee, shopper or admin account is created by the seed

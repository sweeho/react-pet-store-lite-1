## ADDED Requirements

### Requirement: Store entry page

Recovered from: SDP-SCR-0001
The store entry page SHALL be the first page a visitor sees. It SHALL describe the store and offer an "enter the store" link. It SHALL state that the database is populated automatically on first use and that administrators can reload the sample data after signing in.

#### Scenario: Entry page is displayed

- **GIVEN** a visitor who opens the store's root address
- **WHEN** the entry page is displayed
- **THEN** it shows the store description, an "enter the store" link, a note that the database is populated automatically on first use, and a note that administrators can reload the sample data from the Admin page after signing in

#### Scenario: Visitor follows the enter-the-store link

- **GIVEN** the entry page is displayed
- **WHEN** the visitor follows the "enter the store" link
- **THEN** the message "Please wait while the Java Pet Store Application is being populated..." is shown, a first-load (non-forced) population is requested, and the home page is shown once it completes

### Requirement: Catalog Administration page

Recovered from: POP-SCR-0002, SDP-SCR-0004, POP-SCR-0001
The system SHALL provide a page titled "Catalog Administration", shown within the store's shared layout to a signed-in ADMIN. The page SHALL warn that reloading the sample data drops and recreates every catalog and sign-on table, deletes all accounts created in the store and all sign-in history, and signs the administrator out. It SHALL offer a "Reload Sample Data" button that requests a forced reload and then shows the home page.

#### Scenario: Administrator opens the page

- **GIVEN** a user signed in with the ADMIN role
- **WHEN** the Catalog Administration page is displayed
- **THEN** it shows the title "Catalog Administration", the warning that every catalog and sign-on table is dropped and recreated, that all accounts created in the store and all sign-in history are deleted and that the administrator will be signed out, and a "Reload Sample Data" button

#### Scenario: Administrator presses Reload Sample Data

- **GIVEN** the Catalog Administration page displayed to a signed-in ADMIN
- **WHEN** the administrator presses "Reload Sample Data"
- **THEN** a forced reload of the sample data is requested and, on success, the home page is shown with the administrator signed out

### Requirement: First load on entering the store

Recovered from: SDP-WF-0002, POP-SCR-0001, SDP-REQ-0001, POP-WF-0001, POP-REQ-0001
WHEN a visitor enters the store, the system SHALL request a first-load (non-forced) population without requiring sign-in. The system SHALL change no data when the store is already populated, and SHALL drop, recreate and load every catalog and sign-on table from the sample data when it is not.

#### Scenario: Anonymous visitor enters an empty store

- **GIVEN** a freshly installed store with no tables and no signed-in user
- **WHEN** the visitor enters the store
- **THEN** the sample data is loaded and the home page is shown, without any sign-in prompt

#### Scenario: Visitor enters an already populated store

- **GIVEN** a store whose catalog and account tables already hold data
- **WHEN** a visitor enters the store
- **THEN** no catalog, account or sign-on history data is changed

### Requirement: First-load requests open to any caller

Recovered from: SDP-BR-0004, POP-INT-0001
The system SHALL accept a first-load (non-forced) population request from any caller, signed on or not.

#### Scenario: Customer requests a first load

- **GIVEN** a user signed in with the CUSTOMER role
- **WHEN** the user requests a non-forced population
- **THEN** the request is accepted and is not answered with Access Denied

### Requirement: Forced reload restricted to administrators

ID: SWHR5-R-0022
Recovered from: POP-REQ-0003
The system SHALL allow a forced reload of the sample data only to a user signed in with the ADMIN role, and SHALL show Access Denied to anyone else, anonymous or CUSTOMER, who asks for it.

#### Scenario: Anonymous visitor requests a forced reload

- **GIVEN** a visitor who is not signed in
- **WHEN** the visitor requests a forced reload of the sample data
- **THEN** Access Denied is shown and no table is dropped, recreated or loaded

#### Scenario: Customer requests a forced reload

- **GIVEN** a user signed in with the CUSTOMER role
- **WHEN** the user requests a forced reload of the sample data
- **THEN** Access Denied is shown and no table is dropped, recreated or loaded

#### Scenario: Administrator requests a forced reload

- **GIVEN** a user signed in with the ADMIN role
- **WHEN** the user requests a forced reload of the sample data
- **THEN** the reload is performed

### Requirement: Refused forced reload leaves the session intact

Recovered from: SDP-BR-0003
WHEN a forced reload is refused because the requester is not a signed-in ADMIN, the system SHALL NOT end the requester's session.

#### Scenario: Customer stays signed in after a refused reload

- **GIVEN** a user signed in with the CUSTOMER role
- **WHEN** the user requests a forced reload and is shown Access Denied
- **THEN** the user is still signed in

### Requirement: Forced reload replaces all store data

Recovered from: POP-REQ-0004, POP-WF-0002, SDP-REQ-0002, POP-RUL-0001
WHEN a signed-in ADMIN performs a forced reload, the system SHALL drop and recreate the category, category details, product, product details, item, item details, sign-on and sign-on audit tables, SHALL load the sample data, SHALL end the administrator's session and SHALL show the home page.

#### Scenario: Forced reload on a store with customer data

- **GIVEN** a populated store holding a self-registered customer account and sign-on history
- **WHEN** an ADMIN performs a forced reload
- **THEN** the self-registered account and all sign-on history are gone, the sample catalog and sample accounts are present, the administrator is signed out and the home page is shown

### Requirement: Forced-mode flag interpretation

Recovered from: SDP-BR-0013, POP-BR-0002
The system SHALL treat a population request as forced only when its forced-mode value is the word "true" in any letter case. An absent, empty or other value SHALL be handled as a first-load request.

#### Scenario: Mixed-case true

- **GIVEN** a signed-in ADMIN
- **WHEN** a population request carries the forced-mode value "TRUE"
- **THEN** the request is handled as a forced reload

#### Scenario: Unrecognised value

- **GIVEN** any caller
- **WHEN** a population request carries the forced-mode value "yes"
- **THEN** the request is handled as a first-load request

### Requirement: Already-populated check

Recovered from: SDP-WF-0001, POP-WF-0001, SDP-WF-0005
On a first-load request the system SHALL treat the store as already populated only when the category, category details, product, product details, item, item details and sign-on account tables each hold at least one row. The sign-on audit table SHALL NOT be part of the check. WHEN the store is already populated, the system SHALL change nothing. Otherwise it SHALL perform the full drop, recreate and reload.

#### Scenario: One catalog table empty

- **GIVEN** a store whose item details table is empty and whose other checked tables hold rows
- **WHEN** a first-load request arrives
- **THEN** every catalog and sign-on table is dropped, recreated and reloaded

#### Scenario: Empty sign-on audit table

- **GIVEN** a store whose seven checked tables all hold rows and whose sign-on audit table is empty
- **WHEN** a first-load request arrives
- **THEN** no data is changed

### Requirement: Failed check counts as not populated

Recovered from: SDP-BR-0002, POP-BR-0001
GIVEN a first-load request, WHEN the already-populated check itself fails (for example because a table is missing or the database returns an error), the system SHALL treat the store as not populated and SHALL perform the full drop, recreate and reload.

#### Scenario: Missing table

- **GIVEN** a database in which the product table does not exist
- **WHEN** a first-load request arrives
- **THEN** the full drop, recreate and reload runs and deletes every existing sign-on account and all sign-on history

### Requirement: Population removes all accounts and history

Recovered from: SDP-BR-0005
WHEN a population runs (a forced reload, or a first load that finds the store not populated), the system SHALL delete every user account and the whole sign-on audit history, and SHALL recreate only the accounts listed in the sample data.

#### Scenario: Self-registered account after population

- **GIVEN** a store holding the sample accounts plus a self-registered account "alice"
- **WHEN** a population runs
- **THEN** only the accounts listed in the sample data exist and "alice" does not

### Requirement: Session ended on every accepted population request

Recovered from: SDP-BR-0006, POP-BR-0003, SDP-BR-0003
The system SHALL end the requester's session on every accepted population request, before any data is checked or loaded, and whether or not a reload then takes place. No sign-off audit event SHALL be recorded for this session end. (Disputed: the administration guide says nothing happens on an already populated store.)

#### Scenario: Signed-in customer enters a populated store

- **GIVEN** a user signed in with the CUSTOMER role and a populated store
- **WHEN** the user enters the store through the entry page
- **THEN** no data changes, the user is signed out, and no sign-off event is recorded

### Requirement: Population step order

Recovered from: SDP-WF-0007, POP-WF-0002
A population SHALL drop item details, items, product details, products, category details, categories, sign-on audit and sign-on, in that order. It SHALL then create categories, category details, products, product details, items, item details, sign-on and sign-on audit, in that order, and SHALL then load the sample data. A failure to drop a table SHALL be ignored. A failure to create a table SHALL stop the population and report a failure.

#### Scenario: Table absent at drop time

- **GIVEN** a database in which the sign-on audit table does not exist
- **WHEN** a population runs
- **THEN** the missing table is ignored at the drop step, and all eight tables are created and loaded

### Requirement: No rollback on partial failure

Recovered from: POP-BR-0004
GIVEN a population fails part-way (a table cannot be created, a row cannot be inserted or the data file cannot be read), the system SHALL leave the tables in the state the failure reached. Tables already dropped SHALL stay dropped and rows already inserted SHALL stay inserted.

#### Scenario: Insert fails mid-load

- **GIVEN** a population whose sample data contains a row that violates a table constraint
- **WHEN** the insert of that row fails
- **THEN** the population reports failure and the rows inserted before it remain in the database

### Requirement: Sample accounts

Recovered from: SDP-REQ-0003, SDP-BR-0001, POP-ENT-0005, POP-BR-0001
The sample data SHALL create exactly three accounts: "j2ee" (CUSTOMER, password "j2ee"), "shopper" (CUSTOMER, password "j2ee") and "admin" (ADMIN, password "admin"). They SHALL be created through population and not through self-registration, so they carry no account-created audit event.

#### Scenario: Accounts after first load

- **GIVEN** an empty database
- **WHEN** the first load completes
- **THEN** exactly the accounts j2ee, shopper and admin exist with the roles CUSTOMER, CUSTOMER and ADMIN, and the sign-on audit history holds no account-created event for them

### Requirement: Loaded account attributes

Recovered from: POP-ENT-0001
WHEN population loads users, the system SHALL create one sign-on account per user in the sample data. The user name SHALL be the user's id, the password SHALL be stored exactly as written in the data, and the role SHALL be the one given there. All other attributes SHALL take their defaults: zero failed sign-ins, not locked, no lock time, no last sign-on, and a creation time of now.

#### Scenario: Loaded account defaults

- **GIVEN** a sample data file listing user "shopper" with role CUSTOMER
- **WHEN** population loads it
- **THEN** the account "shopper" has zero failed sign-ins, is not locked, has no last sign-on time, and has the population time as its creation time

### Requirement: Sample catalog content

Recovered from: SDP-REQ-0002, SDP-BR-0002, POP-ENT-0002, SDP-ENT-0001, POP-ENT-0001, SDP-BR-0001
The sample data SHALL contain five categories (FISH, DOGS, REPTILES, CATS, BIRDS), sixteen products and twenty-eight items (EST-1 to EST-28), with US English text only. Every category SHALL have at least one product, every product at least one item, and every item's list price SHALL be at least its unit cost. The loaded catalog SHALL be identical to the sample data in every price, cost, attribute, image and description.

#### Scenario: Catalog after first load

- **GIVEN** an empty database
- **WHEN** the first load completes
- **THEN** the catalog holds 5 categories, 16 products and 28 items, all text has language en_US, and no item's list price is below its unit cost

### Requirement: Catalog record structure on load

Recovered from: SDP-ENT-0008, POP-ENT-0002
WHEN population loads the catalog, the system SHALL create each category with its id and one text row per language (name, image, description). It SHALL create each product with its id and owning category, plus one text row per language (name, image, description). It SHALL create each item with its id and owning product, plus one detail row per language (list price, unit cost, up to five attributes, image, description). Each category, product and item SHALL be created before its text or detail rows, and each text or detail row SHALL take its id from the enclosing record. A field missing from the data SHALL be stored as empty.

#### Scenario: Item without optional attributes

- **GIVEN** a sample item that declares only one attribute
- **WHEN** population loads it
- **THEN** the item detail row holds that attribute and its other four attributes are empty

### Requirement: Language code normalisation

Recovered from: SDP-BR-0009, POP-BR-0005, SDP-BR-0004
WHEN the system loads a language code from the sample data, it SHALL replace every hyphen with an underscore before storing it.

#### Scenario: en-US in the data file

- **GIVEN** a sample data text entry with language "en-US"
- **WHEN** population loads it
- **THEN** the stored language code is "en_US"

### Requirement: Sample data validation

Recovered from: SDP-BR-0015, POP-BR-0006, SDP-BR-0001, SDP-BR-0003
The system SHALL validate the sample data against its declared structure while loading: accounts before the catalog, categories before products before items, every product naming a declared category, every item naming a declared product, and every category, product and item carrying at least one text entry with a language code. GIVEN the data is not well-formed, the load SHALL stop and report a population failure. GIVEN well-formed data that breaks the declared structure, the system SHALL log the problem and SHOULD continue loading. (Pass disagreement: one pass says the data is rejected and nothing is loaded.)

#### Scenario: Malformed file

- **GIVEN** a sample data file with an unclosed element
- **WHEN** population reads it
- **THEN** the population fails and reports a failure

#### Scenario: Structural violation in a well-formed file

- **GIVEN** a well-formed sample data file in which an item element omits a required child
- **WHEN** population reads it
- **THEN** the violation is written to the server log and loading continues

### Requirement: Configured data source and dialect

Recovered from: SDP-BR-0014, POP-INT-0001, SDP-INT-0006, SDP-BR-0004
The system SHALL take the location of the sample data, the location of the table statements and the database dialect from deployment configuration. The dialect SHALL default to "derby", with "oracle" as the alternative. The system SHALL use only the statements declared for the configured dialect, and the two dialects SHALL describe the same tables, columns and constraints. GIVEN a statement needed for a table and operation is not defined for the dialect, the population SHALL fail with an error naming the missing statement.

#### Scenario: Missing dialect statement

- **GIVEN** a configured dialect that lacks the create statement for the item table
- **WHEN** a population runs
- **THEN** the population fails with an error naming the missing statement

### Requirement: Sign-on audit identifier

Recovered from: SAUD-BR-0002
The system SHALL give every sign-on audit event a unique identifier generated automatically when the event is recorded. (Disputed: the legacy Oracle population definitions do not generate it.)

#### Scenario: Audit event after population

- **GIVEN** a freshly populated store
- **WHEN** a sign-on event is recorded
- **THEN** it is stored with a new, unique identifier that the caller did not supply

### Requirement: Population result redirection

Recovered from: SDP-REQ-0010, SDP-REQ-0011, POP-BR-0007
WHEN a population request completes without error, the system SHALL send the requester to the success page named in the request. If none is named, it SHALL send the requester to the referring page. If neither is available, it SHALL return an empty successful response. WHEN a population fails, the system SHALL log the underlying cause and SHALL send the requester to the error page named in the request, or otherwise SHALL fail the request with a server error. A page name starting with two slashes SHALL be resolved against the current request address, and any other page name SHALL be resolved inside the store.

#### Scenario: Success with a named page

- **GIVEN** a population request naming the home page as its success page
- **WHEN** the population succeeds
- **THEN** the requester is sent to the home page

#### Scenario: Failure without an error page

- **GIVEN** a population request that names no error page
- **WHEN** the population fails
- **THEN** the cause is logged and the request fails with a server error

### Requirement: First load callable by the catalog check job

Recovered from: SDP-INT-0012, POP-INT-0002, POP-INT-0001
The system SHALL expose the first-load population at a fixed address that the daily catalog check job can call over HTTP without signing in. The call SHALL report success when the load succeeds or is not needed, and SHALL report failure when the load fails.

#### Scenario: Load fails during a job call

- **GIVEN** the job calls the first-load address and the population fails
- **WHEN** the response is returned
- **THEN** the response carries a failure status that the job can detect

### Requirement: Daily catalog check triggers first load

Recovered from: POP-WF-0001, SDP-WF-0001, POP-REQ-0001
GIVEN the catalog tables do not exist when the daily 06:00 catalog check runs, the system SHALL request a first (non-forced) load of the sample data and SHALL then run the catalog checks again on the loaded data. IF the load request fails, the run SHALL end with the technical-failure outcome (exit code 8). A catalog whose tables exist but hold no rows SHALL NOT trigger a load from the job.

#### Scenario: Missing tables at 06:00

- **GIVEN** the catalog tables do not exist
- **WHEN** the daily catalog check runs
- **THEN** a first load is requested and the catalog checks run again on the loaded data

#### Scenario: Load request fails

- **GIVEN** the catalog tables do not exist and the store cannot complete the load
- **WHEN** the daily catalog check runs
- **THEN** the job ends with exit code 8

### Requirement: Sign-on history seed

Recovered from: POP-WF-0001, SDP-WF-0001, SAMP-WF-0001, SAMPLE-WF-0001, SEED-REQ-0001
The system SHALL provide an optional sign-on history seed, loaded as a separate step after the first sample-data population, and applied in a single transaction so that either all of it is stored or none of it is. The seed SHALL add 40 CUSTOMER accounts with user names of 3 to 25 characters and 90 days of sign-on audit events ending on a chosen end date (default 2026-10-30). It SHALL set the creation time of the three sample accounts to the start of the period and give them a last sign-on time. The seed SHALL be identical every time it is produced for the same end date.

#### Scenario: Seed loaded after first population

- **GIVEN** a store populated with the sample data
- **WHEN** the default seed is loaded
- **THEN** 40 additional CUSTOMER accounts and the audit events from 2026-08-01 to 2026-10-30 exist, and the accounts j2ee, shopper and admin have creation time 2026-08-01 00:00:00

#### Scenario: Seed loaded before first population

- **GIVEN** a store that has not been populated
- **WHEN** the seed is loaded
- **THEN** the updates to the three sample accounts affect no rows

#### Scenario: Regenerated for the same end date

- **GIVEN** the seed generated twice for end date 2026-10-30
- **WHEN** the two outputs are compared
- **THEN** they are identical

#### Scenario: Locked accounts at period end

- **GIVEN** the default seed has been loaded
- **WHEN** the account states at the end of the period are examined
- **THEN** exactly two customer accounts are locked, each with a lock less than 30 minutes old

### Requirement: Seed account roles

Recovered from: SDP-RULE-0001
The sign-on history seed SHALL update but never create the three sample accounts, and every account it creates SHALL have the CUSTOMER role.

#### Scenario: Roles after seeding

- **GIVEN** the seed has been loaded
- **WHEN** accounts are listed by role
- **THEN** admin is the only ADMIN account

### Requirement: Store database location and connection limits

Recovered from: BO-INT-0001
The system SHALL keep its catalog, accounts and sign-on history in a single database at /var/petstore/db/PetStoreDB, created if missing. Connections SHALL come from a pool of at most 20 that waits at most 10 seconds for a free connection.

#### Scenario: First start on a new host

- **GIVEN** no database exists at /var/petstore/db/PetStoreDB
- **WHEN** the store first connects
- **THEN** the database is created at that location

### Requirement: Daily online backup

Recovered from: BAT-BR-0001
The system SHALL take an online backup of the whole store database every day at 01:00 without stopping the store. It SHALL keep the backup in a folder named PetStoreDB_YYYYMMDD, replacing any backup already taken that day, and SHALL delete dated backups older than 7 whole days.

#### Scenario: Backup retention

- **GIVEN** dated backups from the previous 9 days
- **WHEN** the 01:00 backup completes
- **THEN** today's backup exists and every backup older than 7 whole days is deleted

### Requirement: Batch retries

Recovered from: BAT-BR-0005
GIVEN the nightly backup fails, the system SHALL retry it automatically up to 2 more times, 10 minutes apart. GIVEN the audit extract fails, the system SHALL retry it automatically once. Other batch jobs SHALL NOT be retried automatically.

#### Scenario: Catalog check failure

- **GIVEN** the daily catalog check ends with a failure
- **WHEN** the scheduler evaluates it
- **THEN** the job is not rerun automatically

### Requirement: Batch job log lines

Recovered from: BATCH-REQ-0006
The system SHALL write one line to the batch job log for each job start and each job end.

#### Scenario: Job run is logged

- **GIVEN** any batch job
- **WHEN** it starts and then ends
- **THEN** the batch job log gains exactly two lines for that run, one for the start and one for the end

### Requirement: Restore from a dated backup

Recovered from: BAT-REQ-0001, BO-REQ-0002
Operations SHALL be able to restore the store database from a dated backup by stopping the application, moving the current database aside, copying the backup into its place and restarting the application.

#### Scenario: Restore after an unwanted reload

- **GIVEN** a forced reload that deleted customer accounts and a backup taken before it
- **WHEN** operations follow the restore procedure with that backup
- **THEN** the store restarts with the accounts and history as they were at backup time

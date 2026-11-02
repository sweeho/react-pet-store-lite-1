## 1. Sample data set

- [ ] 1.1 Define the sample data set: 3 accounts, 5 categories, 16 products, 28 items with en_US text
- [ ] 1.2 Define the sample data structure and its ordering rules (accounts, categories, products, items)
- [ ] 1.3 Implement validation of the sample data (well-formedness failure versus logged structural violation)
- [ ] 1.4 Implement language code normalisation (hyphen to underscore) on load
- [ ] 1.5 Implement account loading with default attributes (no failed sign-ins, unlocked, created now)
- [ ] 1.6 Implement catalog loading: parent record before text/detail rows, missing fields stored empty

## 2. Population engine

- [ ] 2.1 Implement the already-populated check over the seven checked tables, treating a failed check as not populated
- [ ] 2.2 Implement the drop order with drop failures ignored
- [ ] 2.3 Implement the create order with create failures stopping the population
- [ ] 2.4 Implement the load step after create, reporting failure on any load error
- [ ] 2.5 Record the decision on partial-failure behaviour (legacy: no rollback) and implement it
- [ ] 2.6 Ensure every population deletes all accounts and sign-on history and recreates only sample accounts
- [ ] 2.7 Ensure sign-on audit events receive a generated unique identifier after population

## 3. Population request handling

- [ ] 3.1 Implement forced-mode flag parsing (case-insensitive "true" only)
- [ ] 3.2 Implement the ADMIN-only gate for forced reload with Access Denied for anonymous and CUSTOMER callers
- [ ] 3.3 Keep the session intact when a forced reload is refused
- [ ] 3.4 Implement session end on accepted requests, pending the Business Owner decision on SDP-BR-0003
- [ ] 3.5 Implement success, referer and empty-response handling and error-page or server-error handling
- [ ] 3.6 Expose the first-load address to unauthenticated callers with success and failure statuses

## 4. Screens

- [ ] 4.1 Build the store entry page with its description, notes and enter-the-store link
- [ ] 4.2 Build the please-wait step that requests a first load and then shows the home page
- [ ] 4.3 Build the Catalog Administration page with its warning and Reload Sample Data button
- [ ] 4.4 Restrict the Catalog Administration page to signed-in ADMIN users

## 5. Batch and operations

- [ ] 5.1 Make the daily catalog check request a first load when tables are missing and re-run its checks
- [ ] 5.2 End the catalog check with exit code 8 when the load request fails
- [ ] 5.3 Implement the daily 01:00 online backup with dated folders and 7-day retention
- [ ] 5.4 Implement batch retry rules (backup twice at 10 minutes, audit extract once, others never)
- [ ] 5.5 Write one job-log line per batch job start and end
- [ ] 5.6 Document the restore-from-backup procedure
- [ ] 5.7 Configure the database location and connection pool limits

## 6. Sign-on history seed

- [ ] 6.1 Implement the deterministic history generator (40 customers, 90 days, end date parameter)
- [ ] 6.2 Implement the single-transaction seed load that back-dates the three sample accounts
- [ ] 6.3 Verify the seed creates only CUSTOMER accounts and leaves two recently locked accounts

## 7. Verification

- [ ] 7.1 Write tests for every scenario in the sample-data-population spec
- [ ] 7.2 Write an end-to-end test for entry-page first load and admin forced reload

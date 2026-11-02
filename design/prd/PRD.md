## Summary

Pet Store Lite Modernisation replaces the legacy Java Pet Store Lite web store with a rebuilt application that keeps the behaviour approved in this initiative's specification. The store is a catalog-only pet shop: visitors browse five pet categories down to individual items, search the catalog by keyword, sign up, sign in and out, and see their own recent sign-in activity. Administrators can reload the sample catalog. Behind the store, scheduled jobs lock and unlock accounts, keep a 90-day sign-on audit trail with a daily extract and report for the security team, back up the database nightly and check the catalog's integrity every morning. There is no shopping cart, ordering or payment.

## Context

The legacy store's behaviour was extracted from its source, reviewed and approved as ten capability specifications, listed in `build/manifest.yaml`. That specification is the only statement of what the replacement must do. No product documents were supplied with this initiative, so this PRD draws only on the approved specifications and the manifest.

Several approved requirements describe the legacy behaviour as it is, including behaviour the extraction itself flags as disputed or as a suspected defect. Examples are case-sensitive search, `%` and `_` acting as wildcards in search, and passwords stored readable. These are carried forward as specified and listed under Open questions for a Business Owner decision rather than silently corrected.

## Goals

- Every visitor, signed in or not, can move from the home page to a category, a product and an item, and page through each listing two entries at a time, with en_US text and US-dollar prices.
- Visitors can find items by keyword from a search box on every page.
- Customers can create their own account from the Sign In page and are signed in immediately; administrator accounts cannot be self-created.
- Users sign in and out with a user name and password, and are returned to the page they were trying to open.
- Accounts are protected by locking after three consecutive wrong passwords, and are unlocked automatically about 30 minutes later.
- Pages are open to everyone except My Account, which needs a sign-in, and Catalog Administration, which needs the ADMIN role.
- Every sign-on event is recorded, kept for 90 days, extracted daily for the security team and summarised in a daily report, and each signed-in user can see their own 10 most recent events.
- The store can populate itself with the sample catalog and accounts on first use, and an administrator can force a full reload.
- The store's data is backed up nightly, can be restored from a dated backup, and the nightly jobs run in a fixed order with defined retries, exit codes and alerts.
- The catalog's four integrity rules (C1 to C4) are enforced on write and checked every morning before the store opens.

## Non-goals

- Shopping cart, ordering and payment: the legacy store has none.
- Editing individual catalog records: there is no catalog maintenance screen; the catalog changes only through a sample-data reload.
- Role management screens: roles are set only in the data.
- An in-application unlock screen: early unlock is an operations procedure.
- Profile, address or payment details on an account, password reset and account deletion.
- Creating administrator accounts through sign-up.
- Searching item attributes, and relevance ranking of search results.
- Auditing catalog or administration actions: only sign-on events are recorded.
- Enforcing a minimum catalog size of 5 categories and 28 items.

## Users

- Visitor: anyone using the store without signing in. Browses and searches the catalog, signs up or signs in.
- Customer: a signed-in user with the CUSTOMER role. Everything a visitor can do, plus My Account.
- Administrator: a signed-in user with the ADMIN role. Everything a customer can do, plus Catalog Administration and the forced sample-data reload.
- Operations team: runs and monitors the scheduled jobs, receives backup-failure alerts, restores the store from a backup and performs early manual unlocks.
- Security team: collects the daily sign-on audit extract and receives extract-failure alerts.
- Catalog team: receives the alert when the morning catalog integrity check finds bad data.

## User journeys

1. Browse to an item: Store entry page, Home page, Category products page, Product items page, Item page.
2. Search the catalog: any store page (banner search box), Search page, Item page.
3. Sign in: Sign In page, then the page the visitor was trying to open or the Home page. From the banner Sign in link: Sign In page, Welcome page.
4. Sign in with a wrong user name or password: Sign In page, Sign-in Error page, Sign In page.
5. Sign in to a locked account: Sign In page, Account Locked page, Home page.
6. Create an account: Sign In page (new-customer form), then the page the visitor was trying to open or the Home page.
7. Create an account that breaks a rule: Sign In page (new-customer form), Could Not Create Your Account page, Sign In page.
8. Review recent sign-in activity: Home page, My Account page. A visitor who is not signed in is shown the Sign In page first, then the My Account page.
9. Sign out: any store page, Signed-out page, Sign In page.
10. Reload the sample data: Sign In page, Home page (banner Admin link), Catalog Administration page, Home page signed out.
11. Customer tries to open Catalog Administration: Catalog Administration address, Access Denied page.
12. Enter the store for the first time: Store entry page, populating wait message, Home page.
13. Recover from an unexpected error: any store page, General Error page, Home page.

## Capability map

- catalog-browsing: the public three-level catalog of categories, products and items, with paged listings, the home page, the item page, the shared page frame and the General Error page.
- catalog-search: keyword search from the banner search box, with paged results on the Search page.
- sign-on: signing in and out with a user name and password, the remembered user name, the 15-minute session timeout and the return to the requested page.
- account-lockout: locking an account on the third consecutive wrong password, refusing sign-in while locked and unlocking it automatically after 30 minutes.
- account-registration: self-service customer sign-up from the Sign In page, with its field rules and refusal page.
- access-control: the CUSTOMER and ADMIN roles and which pages each may open.
- sign-on-audit: the append-only sign-on audit log, its 90-day retention, daily extract and report, and the My Account recent activity view.
- sample-data-population: loading the sample catalog and accounts on first use and the administrator's forced reload.
- batch-operations: the nightly job chain (backup, audit extract, report, purge), its retries, exit codes, logs, alerts and the restore procedure.
- catalog-data-integrity: the catalog rules C1 to C4, enforced on write and checked daily at 06:00.

## Screens

- Store entry page: describes the store, offers an "enter the store" link, says the database is populated automatically on first use and that administrators can reload the sample data after signing in.
- Home page: a pet picture whose Birds, Fish, Dogs, Reptiles and Cats regions link to their category pages; titled "Welcome to the BluePrints Petstore".
- Store page frame: every store page has a banner (logo to the home page, search box with a Search button, Account link, Sign in or Sign out link, "Signed in as <user name>" when signed in, Admin link for administrators), a Pets side bar of up to five categories in name order, the page body and a footer.
- Category products page: "Products for this Category", two products at a time with name (linking to the product's items) and description, Previous and Next links only when those pages exist.
- Product items page: "Items for this Product", two items at a time with attribute and product name (linking to the item page), description and list price in US dollars, with the same paging links.
- Item page: item image, heading of attribute and product name, "List Price", "Your Price" (the unit cost), description and "Item ID".
- Search page: titled "Search"; "Search Results:", "Items matching any of: <search text>" shown as literal text, and two matches at a time with paging links; or only "No results were found for your search."
- Sign In page: a returning-customer form (User Name, masked Password, "Remember My User Name", Sign In button) and a new-customer form (User Name, masked Password and Password (Repeat), "Create New Account" button, and the user name and password rule lines).
- Sign-in Error page: says the user name and password were not found without saying which, warns that 3 failed attempts in a row lock the account, and offers a "try again" link.
- Account Locked page: titled "Account Locked"; says the account locks after 3 failed attempts in a row and unlocks automatically 30 minutes later, advises trying later or contacting the administrator, and links to keep browsing the catalog.
- Could Not Create Your Account page: titled "Create Account Error", headed "Could Not Create Your Account", shows the one rule that was broken and a "go back" link to the Sign In page.
- Welcome page: titled "Welcome", shown after signing in from the banner link, with the home page content.
- Signed-out page: "You are signed out.", a thank-you line and a link to sign in again.
- My Account page: titled "My Account"; User Name, Role, and "Recent Sign-in Activity" listing the 10 most recent events newest first with When, Event and From columns, and the note "Showing your 10 most recent events."
- Catalog Administration page: for administrators only; warns that reloading drops and recreates every catalog and sign-on table, deletes all store-created accounts and all sign-in history and signs the administrator out, and offers a "Reload Sample Data" button.
- Populating wait message: "Please wait while the Java Pet Store Application is being populated..." shown while a first load runs.
- Access Denied page: titled "Access Denied", shown to a signed-in user without the required role, with a link back to the catalog.
- General Error page: says an unexpected error occurred and links back to the catalog home page.

## Constraints and assumptions

- The store presents all catalog text in en_US and all prices in US dollars, whatever the visitor's browser asks for, and reads every request as UTF-8.
- Catalog listings and search results show 2 entries per page by default, using one paging rule for every list.
- User names are case-sensitive, at most 25 characters; self-registered names are 3 to 25 letters, digits, '-' or '\_'. Passwords are 4 to 25 characters.
- A session ends after 15 minutes without activity. The remembered user name lasts 31 days.
- The account lock threshold is 3 consecutive wrong passwords; the unlock job runs every 15 minutes and releases locks more than 30 minutes old.
- Sign-on audit events are kept for 90 days and purged weekly on Sunday after that day's extract has succeeded.
- The nightly chain runs from 01:00 (backup), 01:30 (audit extract), 01:45 (report) and Sunday 02:00 (purge), each only after its predecessor succeeded; the catalog check runs at 06:00 and the unlock job every 15 minutes, independent of the chain.
- Batch jobs end with exit code 0 on success, 8 on a database or file error and 4 only when the catalog check finds bad data.
- Dated backups are kept for 7 days; the restore procedure is stop the store, set the current database aside, copy the dated backup in and restart.
- The rebuild runs on this project's pinned stack: a Vite single-page application with a Nitro server in one repository, storing its data in SQLite through Drizzle. Requirements written against the legacy database server (see Open questions) have to be met in that form or re-decided.

## Open questions

- Passwords are specified as stored and compared readable, without hashing (SWHR5-R-0310, SWHR5-R-0211, SWHR5-R-0162). The extraction marks this as a Business Owner decision. This PRD carries the specified behaviour; whether the rebuild hashes passwords is open.
- Search compares keywords exactly as typed against lower-cased text, so a keyword with a capital letter matches nothing (SWHR5-R-0203, SWHR5-R-0205, SWHR5-R-0288, SWHR5-R-0202, SWHR5-R-0204). The specification itself notes that the legacy User Guide says search is not case-sensitive. That guide was not supplied to this initiative, so it is not recorded as a divergence; the case rule needs a Business Owner decision.
- In search, `%` and `_` act as wildcards (SWHR5-R-0206, SWHR5-R-0287), and a search request with no search-text field reaches the General Error page (SWHR5-R-0077). Both are flagged in the specification as suspected legacy defects. Should the rebuild keep them?
- The two specifications disagree on the source recorded for an automatic unlock. Account-lockout says the unlock event is "attributed to the unlock job rather than to a client address" and its scenario says it "carries no client address" (SWHR5-R-0006, SWHR5-R-0142). Sign-on-audit says the client address is "batch:PSL_ACCT_UNLOCK" (SWHR5-R-0240, SWHR5-R-0238, SWHR5-R-0250), and the My Account view shows that value in the From column. This PRD assumes the sign-on-audit wording is current, because the extract and My Account depend on it.
- The batch-operations specification describes the legacy database server: the database reached by the batch jobs on port 1527 (SWHR5-R-0268) and a connection pool of at most 20 connections waiting at most 10 seconds (SWHR5-R-0044). Sample-data population and catalog browsing also name Derby and Oracle statement sets (SWHR5-R-0303, SWHR5-R-0086, SWHR5-R-0189). The rebuild's embedded SQLite store has no network listener, pool or second dialect. These requirements need restating as the outcome they protect (batch jobs read and write the live data while the store stays available) or being retired.
- The Sign In page pre-fills the User Name field with the demo name "j2ee" when no name is remembered (SWHR5-R-0095). Keep it in the rebuilt store?
- Every population request that passes the access check ends the requester's session, even when nothing is reloaded (SWHR5-R-0296); the extraction notes a dispute with the legacy guide. A forced reload also has no rollback on partial failure (SWHR5-R-0209). Both are carried as specified.
- Backup retention keeps backups up to 8 whole days old and deletes those aged 9 and more (SWHR5-R-0262), which reads as about 8 copies against the "7 days" of SWHR5-R-0170. Which is intended?
- Access control has only two approved requirements (SWHR5-R-0001, SWHR5-R-0002). The exhaustive list of protected pages and the per-page role check are still pending approval, so the access rules above may grow.
- Your Price shows the item's unit cost (SWHR5-R-0178, SWHR5-R-0176); whether that is a customer price or a member price is recorded as disputed in the manifest.
- The branch carries an eleventh change, swhr5-i-0002-bootstrap-landing-page-and (capability site-shell), which the manifest does not list. It adds a landing page at the root route, one global navigation, a shared header and footer, and shared empty, error and loading frames. It is not in the Capability map, which follows the manifest. Its landing page overlaps the sample-data-population Store entry page and the catalog-browsing Home page, and its navigation overlaps the catalog-browsing store page frame; which of these the rebuild builds needs deciding before the site shell is scheduled.
- The manifest's change directories point at `openspec/changes/sx-<slug>`, while the changes on this branch are named `openspec/changes/swhr5-i-00NN-<name>`. The importer renamed them; the specification read for this PRD is the renamed set.

## Sources

See `design/prd/sources.yaml`. No product documents were supplied; every section is drawn from the approved specifications under `openspec/changes/` and from `build/manifest.yaml`.

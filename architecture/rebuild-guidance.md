# Rebuild guidance: Java Pet Store Lite (spec extraction SX-0001)

This is guidance for the teams rebuilding the legacy Java Pet Store Lite on this repository's
stack. It says what to read, in what order to build, how the legacy shapes map onto the target
stack, and which legacy behaviours must not be copied without a decision. It is not a design:
the Architect owns the target design in `ARCHITECTURE.md` and `DESIGN.md`.

## 1. What to read, and which source wins

| Source                                                        | What it is                                                     | Authority                      |
| ------------------------------------------------------------- | -------------------------------------------------------------- | ------------------------------ |
| `openspec/changes/sx-<capability>/specs/<capability>/spec.md` | The requirements to build, one delta spec per capability       | **Wins over everything below** |
| `openspec/changes/sx-<capability>/design.md`                  | How the legacy code did it, and the open questions             | Context for the spec           |
| `build/manifest.yaml`                                         | Release order, dependencies, canvas and screens per capability | The schedule                   |
| `api/openapi.yaml`                                            | The legacy HTTP surface (HTML pages and redirects)             | Evidence only                  |
| `architecture/erd.mermaid`, `architecture/schema.sql`         | The legacy data model (Derby/Oracle DDL)                       | Evidence only                  |
| `legacy-analysis/ir/_recommendations/<capability>.yaml`       | Open SME items per capability                                  | Open questions                 |

The three evidence files describe the system that exists, not the one to build. Do not copy a
table, column type or endpoint from them into `db/` or `routes/` without finding the
requirement for it in a delta spec. Where they disagree with a delta spec, the delta spec wins.

Requirements with an `ID:` line (`SWHR5-R-00xx`) were approved by an SME. Requirements without
one are drafts awaiting a decision. No capability has a named reviewer recorded, so every
`reviewedBy` in the manifest is `null`.

## 2. Build order

The manifest's `order` and `dependsOn` encode this sequence:

1. **catalog-browsing**: the catalog data model, the shared layout and the public pages. Everything else renders inside this layout.
2. **catalog-search**: reuses the catalog model, paging and the item page.
3. **sign-on**: the account record, the session and the banner sign-in status.
4. **account-lockout**: extends the credential check with the failure counter and lock.
5. **account-registration**: creates accounts in the store that sign-on reads.
6. **access-control**: the protected-page matrix, sign-in interception and the Access Denied page.
7. **sign-on-audit**: the audit log written by 3 to 6, the My Account page (protected by 6) and the extract, report and purge.
8. **sample-data-population**: first load and the ADMIN-only forced reload; needs the catalog and account tables and the ADMIN check.
9. **batch-operations**: the job schedule over the jobs of 4, 7 and 8.
10. **catalog-data-integrity**: the price guard and the daily C1 to C4 check, which triggers the first load (8) from the schedule (9).

The catalog price guard (`listprice >= unitcost`) is specified under catalog-data-integrity
but belongs in the catalog table definition. Build it into the schema when catalog-browsing
creates the tables, and let catalog-data-integrity add the daily check and alert.

## 3. Mapping the legacy shapes onto this stack

The target is a Vite React SPA with a Nitro (H3) server, SQLite through Drizzle, Tailwind
(CSS-first) and Vitest/Playwright. Read exact versions from `package.json`.

| Legacy                                                                                           | Target                                                                                                                                                           |
| ------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `*.screen` pages composed by a template servlet from screen definitions                          | SPA pages under `src/pages/` (file-based routes) inside one shared layout component holding banner, Pets side bar, body and footer                               |
| Servlets and the sign-on filter (`j_signon_check`, `createuser.do`, `signoff.do`, `/Populate`)   | JSON handlers under `routes/api/`, plus server middleware under `middleware/` for the per-request session and role checks                                        |
| 302 redirects as the result of every action                                                      | API responses the SPA acts on (navigate to the target page). The _page the user ends up on_ is the requirement, not the redirect                                 |
| Servlet session (`j_signon`, `j_signon_username`, `j_signon_role`), 15-minute inactivity timeout | A server-side session cookie with the same 15-minute inactivity timeout; role read from the session, not from the client                                         |
| `bp_signon` cookie for Remember My User Name, 31 days                                            | A cookie with the same lifetime and behaviour (set when ticked, deleted when not)                                                                                |
| Derby/Oracle tables in schema `ESTOREUSER`                                                       | Drizzle tables in `db/schema.ts`; every change produces a migration in `drizzle/` through `db-generate`                                                          |
| Shell scripts, SQL scripts and Control-M jobs                                                    | Server-side jobs that run under Bun against the same database. How they are scheduled is an Architect decision to record in `ARCHITECTURE.md` `## Key Decisions` |
| JSP text and `fmt:formatNumber` en_US currency                                                   | React components with `Intl.NumberFormat("en-US", { style: "currency", currency: "USD" })`                                                                       |

The page list, the parameters each page reads and the redirect targets are in
`api/openapi.yaml`. Use it to find every surface; take the behaviour from the delta specs.

## 4. Data model notes for the Drizzle schema

- **Tables.** Six catalog tables (category, product, item, each with a per-locale `*_details`
  table) and two account tables (`signon`, `signon_audit`). The view `v_catalog_item` has no
  reader; do not build it unless a delta spec requires it.
- **Money.** `listprice` and `unitcost` are exact to two decimal places in the legacy schema.
  SQLite has no fixed-point type, so choose a representation that keeps exact cents (for
  example integer cents) and record the choice as a Key Decision. Floating-point storage would
  break the price guard at the boundary `listprice = unitcost`.
- **Constraints to keep at the data layer.** The primary and foreign keys; `listprice >= unitcost`;
  `role in ('CUSTOMER','ADMIN')`; `locked in ('Y','N')` or a boolean equivalent; the closed
  set of seven audit event types. Drizzle supports `check()` constraints on SQLite tables.
- **No foreign key from `signon_audit.username` to `signon`.** Failed sign-ins for unknown
  user names are recorded with the name as typed. Adding the foreign key would break the
  "Sign-in outcome audit events" requirement.
- **Identifiers.** Legacy Derby keys are `char(10)` (space-padded); Oracle keys are
  `varchar(10)`. Whether padding matters is held for an SME decision. Use plain text keys
  unless that decision says otherwise.
- **Audit identifier.** An ascending, system-assigned integer (`integer` primary key with
  autoincrement in SQLite). The legacy Oracle populate path did not generate it; do not
  reproduce that.
- **Indexes.** `product(catid)`, `item(productid)`, `signon_audit(username, event_ts)` and
  `signon_audit(event_ts)` back the listing, My Account and extract/purge queries.

## 5. Cross-cutting rules every capability shares

- The store shows en_US text and US-dollar prices only, whatever the browser language.
- Request text is decoded as UTF-8.
- Catalog and search lists show two rows per page by default, with Previous and Next shown
  only when an earlier or later page exists.
- Every page uses the same layout: banner (logo, search box, Account link, Sign in or
  Sign out with "Signed in as <user name>", Admin link for ADMIN), Pets side bar with one link
  per category in alphabetical order, body, footer.
- An unhandled error shows the General Error page with a link back to the catalog.
- My Account, the sign-in Welcome page and Catalog Administration are the only protected
  pages; Catalog Administration and the forced reload are ADMIN only.

## 6. Legacy behaviours not to copy without a decision

These exist in the legacy system and appear in the delta specs as drafts or disputes. Each
needs the named decision before it is built; until then, raise it rather than reproduce it.

| Code | Behaviour                                                                                                                             | Decision owner | Capability                     |
| ---- | ------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------------------------ |
| R1   | Passwords are stored and compared as entered (no hashing)                                                                             | Business Owner | sign-on, account-registration  |
| R2   | A keyword with a capital letter matches nothing, although the User Guide says search is not case-sensitive                            | Business Owner | catalog-search                 |
| R3   | `%` and `_` in a keyword act as wildcards                                                                                             | SME            | catalog-search                 |
| R4   | A search request with no search-text field shows the General Error page                                                               | SME            | catalog-search                 |
| R5   | Existing user names containing `.` (the sign-up rule forbids them)                                                                    | Business Owner | sign-on                        |
| R6   | Every store entry ends the visitor's session, against the guide                                                                       | Business Owner | sample-data-population         |
| R7   | A forced reload deletes every account and all sign-on history, with no rollback on partial failure                                    | SME            | sample-data-population         |
| R8   | Timing of the ACCOUNT_LOCKED event relative to the failed sign-in event                                                               | SME            | account-lockout, sign-on-audit |
| R9   | Behaviour of a locked account with no lock time                                                                                       | SME            | account-lockout                |
| R10  | Backup retention (7 days or about 8 copies), the extract rerun, the undefined `PSL_CAL` calendar, and jobs that fail without an alert | SME            | batch-operations               |
| R11  | Whether "Your Price" (the unit cost) is a customer price or a member price                                                            | SME            | catalog-browsing               |

## 7. Working with the extraction outputs

- **Record keys repeat.** The same IR record key can name different records in different
  pass files (for example `ACC-SCR-0001` is both the Access Denied page and the banner Admin
  link). When you trace a requirement back, match on the key and the source path, not the key
  alone. Each change's `design.md` lists the collisions it resolved.
- **Screens.** `canvas.screens` in the manifest lists one line per extracted screen record.
  Two capabilities, batch-operations and catalog-data-integrity, have no user interface.
- **Acceptance criteria.** The manifest's acceptance criteria are the delta spec scenarios,
  one per scenario, in the form "Requirement — Scenario: outcome". Write one test per
  scenario at the tier the repository's test table prescribes: a unit or UI test for a rule or
  a page, an integration test with a real `H3Event` for an API route, a Playwright spec for a
  cross-page flow such as sign-in interception and return.
- **Legacy sample data.** `legacy-source/j2ee-pet-store-lite/src/main/webapp/populate/Populate-UTF8.xml`
  holds the sample catalog and accounts, and `legacy-source/j2ee-pet-store-lite/vortex/samples/`
  holds captured sign-on decisions, search cases and anonymised audit events. They are useful
  as test fixtures for the scenarios that name concrete values.

## 8. Repository state to note before building

- `tailwind.config.ts` exists at the repository root. This stack is CSS-first and treats a
  Tailwind config file as a defect; the rebuild should not add tokens to it.
- `db/schema.ts` currently holds only the template's `users` table, and `db/client.ts` seeds
  two demo users. The catalog and account tables replace that demo data as capabilities land.

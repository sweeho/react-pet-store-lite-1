# Expected extraction: Java Pet Store Lite

The answer key for a Vortex spec extraction run over `vortex/inputs`. Use it
to score a run: each item below should appear as an IR record, a finding, an
inventory item or a link. Line numbers refer to this repository.

## 1. Inventory (deterministic stages)

| Source | Adapter | Expected |
|---|---|---|
| `01-code/petstore-lite-code.zip` | code / j2ee | Folders `src/main/java` and `src/main/webapp` profile as J2EE. Markers `pom.xml`, `web.xml`. |
| same zip | database / ddl-export | `db/schema/*.sql` detected inside code: 8 tables, 4 indexes, 1 view (Derby). Oracle adds 1 sequence, 1 trigger. |
| same zip | scheduler / control-m | `scheduler/control-m/PSL_PETSTORE.xml` detected inside code: 6 jobs |
| same zip | configuration / properties | `conf/petstore.properties`, `conf/env.sh` |
| `02-database/` | ddl-export | as above, standalone |
| `03-scheduler/PSL_PETSTORE.xml` | control-m | 6 jobs, 2 folders, 0 unresolved conditions |
| `04-configuration/petstore.properties` | properties | 26 config keys; `petstore.db.password` stored as hash only |
| `05-documents/*.pdf` | pdf | 3 documents. Roles: User manual (UG, AG), Runbook (RB) |
| `05-documents/screenshots/*.png` | images | 16 screens, described by `describe-images` |
| `06-samples/*.csv`, `*.json` | csv, json | 3 sample sets, residual risk 0 |

Verified against Vortex `HEAD ef75702e` by running `filterSourcePath`,
`detectSources`, `parseControlM`, `parseDdl` and `parseKeyValueConfig` on the
unzipped code bundle:

| Result | Detail |
|---|---|
| 123 files, 102 kept | 21 images dropped as media |
| J2EE folders | `src/main/webapp` 0.90, `src/main/java` 0.80, root `.` 0.30 (pom.xml, Dockerfile) |
| Not extracted, planned adapter | `batch/` (Shell), `src/main/webapp/META-INF/context.xml` (JNDI) |
| Not extracted, no adapter | `db/batch/*.sql` (no CREATE statements, so the DDL adapter does not claim them) |
| Control-M | 6 jobs; `runs` targets are `/opt/petstore/batch/*.sh` |
| DDL | Derby 8 tables, 4 indexes, 1 view. Oracle adds 1 sequence, 1 trigger. |
| Properties | 26 keys |

The batch scripts are not read, but each is still a `file` row, so
`link-sources` resolves every job's absolute `runs` path by its unique base name.

### Job links (`link-sources`)

| Job | Runs | Waits for |
|---|---|---|
| PSL_DB_BACKUP | `batch/psl_db_backup.sh` | - |
| PSL_AUDIT_EXTRACT | `batch/psl_audit_extract.sh` | PSL_DB_BACKUP |
| PSL_SIGNON_REPORT | `batch/psl_signon_report.sh` (CMDLINE) | PSL_AUDIT_EXTRACT |
| PSL_AUDIT_PURGE | `batch/psl_audit_purge.sh` | PSL_AUDIT_EXTRACT |
| PSL_CATALOG_CHECK | `batch/psl_catalog_check.sh` (CMDLINE) | - |
| PSL_ACCT_UNLOCK | `batch/psl_acct_unlock.sh` | - (cyclic, 15 min) |

Every job's script is in the code zip, so no job should be held for a missing
script when the zip is a source. Adding `03-scheduler` without the zip should raise 6 holds.

## 2. Capabilities

| Key | Capability |
|---|---|
| CAP-1 | Catalog browsing and search |
| CAP-2 | Sample data population |
| CAP-3 | Sign-on and access control |
| CAP-X | Batch operations (cross-cutting: backup, audit extract/report/purge, catalog check, unlock) |

## 3. Entities

| Entity | Table | Key | Notes |
|---|---|---|---|
| Category | CATEGORY + CATEGORY_DETAILS | catid | details per locale |
| Product | PRODUCT + PRODUCT_DETAILS | productid | FK catid |
| Item | ITEM + ITEM_DETAILS | itemid | FK productid; listprice, unitcost, attr1-5 |
| Sign-on account | SIGNON | username | role, failed_attempts, locked, locked_ts, last_signon |
| Sign-on event | SIGNON_AUDIT | audit_id | event_type enum of 7 values |

## 4. Business rules

| ID | Rule | Evidence |
|---|---|---|
| BR-01 | Lock after 3 consecutive failed sign-ons | `UserDAO.java:69,142`; AG R3; samples S04 |
| BR-02 | Locked account refused even with right password; failed count unchanged | `UserDAO.java:127`; S05, S10 |
| BR-03 | Successful sign-on resets failed attempts to 0 | `UserDAO.java:132`; S06, S11 |
| BR-04 | Unlock 30+ minutes after lock, checked every 15 minutes | `db/batch/acct_unlock.sql`; Control-M PSL_ACCT_UNLOCK |
| BR-05 | User name 3-25 chars of letters, digits, `-`, `_`; unique | `CreateUserServlet.java:102-117` |
| BR-06 | Password 4-25 chars, must equal confirmation | `CreateUserServlet.java:102-117` |
| BR-07 | New self-registered accounts are CUSTOMER | `UserDAO.createUser` |
| BR-08 | `account.screen` needs sign-on; `populate_admin.screen` needs ADMIN | `signon-config.xml` |
| BR-09 | After sign-on the user returns to the page first asked for, else `main.screen` | `SignOnFilter.validateSignOn` |
| BR-10 | Remember-me cookie `bp_signon` keeps the user name 31 days | `SignOnFilter.java:76,178` |
| BR-11 | Session timeout 15 minutes | `web.xml` |
| BR-12 | First load open to all; forced reload ADMIN only and wipes all tables | `PopulateServlet.java:121-122` |
| BR-13 | Search: OR of whitespace-separated words, substring match on product name, category id, item description | `GenericCatalogDAO.java:363`; `CatalogDAOSQL.xml:119-122` |
| BR-14 | Lists page 2 rows at a time with Next/Previous | `category.jsp`, `product.jsp`, `search.jsp` |
| BR-15 | List price >= unit cost | `ck_item_details_price`; PSL_CATALOG_CHECK C3 |
| BR-16 | Audit kept 90 days; purged Sundays only after the extract | `audit_purge.sql`; Control-M INCOND |
| BR-17 | Every sign-on event is audited with time and client address | `UserDAO.audit` |
| BR-18 | Backups kept 7 days | `psl_db_backup.sh` |

## 5. Screens

15 screens from `screendefinitions_en_US.xml` plus `index.jsp` and
`populating.jsp`: main, category, product, item, search, signon,
signon_welcome, signon_error, signon_locked, user_creation_error, signoff,
account, access_denied, populate_admin, general_error. Each maps to one
screenshot in `05-documents/screenshots` except signon_welcome (renders main).

## 6. Integrations

- JNDI data source `java:comp/env/jdbc/CatalogDB` (Derby, `META-INF/context.xml`)
- Batch jobs connect over Derby network server, port 1527
- PSL_CATALOG_CHECK calls the store over HTTP (`Populate?forcefully=false`)
- Outbound file `signon_audit_YYYYMMDD.csv` (no header, trailer `TRAILER,date,count`) to the security team
- Control-M mail alerts on job failure

## 7. Planted findings

A good run reports these as conflicts, suspected defects or risks.

| ID | Type | Finding | Evidence |
|---|---|---|---|
| F1 | conflict | User Guide 4 says search is not case-sensitive. The SQL lowercases the columns but not the keyword, so any capital letter returns nothing. | `GenericCatalogDAO.java:363`; `catalog_search_cases.json`: `Bulldog` 0, `dog` 13 |
| F2 | conflict | User Guide 3.3 says Your Price is a member discount. The page shows `unitCost` (supplier cost) to everyone, signed in or not. | `item.jsp:30`; screenshot 06 |
| F3 | defect (security) | Protected pages can be opened without sign-on by adding `;jsessionid=x` to the URL. The filter compares the raw request URI to the pattern with `equals`. | `SignOnFilter.java:115,151,235` |
| F4 | risk (security) | Passwords stored and compared in plain text. Sample admin password `admin`. | `UserDAO.java:132`; SIGNON.password; `Populate-UTF8.xml` |
| F5 | defect | POST to `j_signon_check` with no user name gives HTTP 500 (audit insert of a null user name). | `UserDAO.authenticate` |
| F6 | risk | Forced reload deletes all accounts and audit history with no backup step. | `PopulateServlet`; AG 3.2 |
| F7 | ambiguity | `catalog.pageSize=2` in `petstore.properties` is never read; page size is hard-coded in JSPs. | `category.jsp:31` |
| F8 | ambiguity | Unknown user names are audited as SIGNON_FAIL rows and never lock anything. | `UserDAO.java`; sample S07 |
| F9 | data quality | Product FI-SW-01 references image `fish1.jpg`, which is not shipped. | `Populate-UTF8.xml`; `data/migration/product_details.csv` |
| F10 | risk | The CatalogDAOSQL URL is a hard-coded file path in `web.xml`. | `web.xml` env-entry `url/CatalogDAOSQLURL` |
| F11 | ambiguity | No screen to create an ADMIN or unlock an account; both need SQL. | AG 1, 2.1 |

## 8. Migration data checks

`data/migration` holds full extracts: category 5, category_details 5,
product 16, product_details 16, item 28, item_details 28, signon 43,
signon_audit 1,686 rows. Two accounts are locked at extract time. A target
load should reconcile those counts, keep `audit_id` order, and decide on
F4 (plain-text passwords) before go-live.

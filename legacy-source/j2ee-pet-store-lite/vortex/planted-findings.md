# Planted findings: Java Pet Store Lite

Defects, conflicts and risks a correct Vortex extraction should report.
Line numbers refer to this repository. F3 and F4 come from the original
Pet Store 1.3.2 code. The others were added or kept deliberately.

Base URL for the reproduction steps: `http://localhost:8080/petstore`.

## Summary

| ID | Type | Finding | Show in demo |
|---|---|---|---|
| F1 | conflict | Search is case-sensitive, but the User Guide says it is not | Yes |
| F2 | conflict | "Your Price" shows supplier cost, but the User Guide calls it a member discount | Yes |
| F3 | defect (security) | `;jsessionid=x` in the URL bypasses sign-on | Yes |
| F4 | risk (security) | Passwords stored and compared in plain text | |
| F5 | defect | Sign-on with no user name gives HTTP 500 | |
| F6 | risk | Forced reload deletes all accounts and audit history | |
| F7 | ambiguity | `catalog.pageSize` config key is never read | |
| F8 | ambiguity | Unknown user names are audited and never lock | |
| F9 | data quality | Product image `fish1.jpg` is not shipped | |
| F10 | risk | Catalog SQL file path is hard-coded in `web.xml` | |
| F11 | ambiguity | No screen to create an ADMIN or unlock an account | |

## F1. Search case sensitivity (conflict)

- **Document:** User Guide section 4 says "Search is not case-sensitive."
- **Code:** `CatalogDAOSQL.xml:119-122` lowercases the columns (`lower(name) like ?`). `GenericCatalogDAO.java:363` passes the keyword unchanged (`"%" + keywords[i] + "%"`). Any keyword with a capital letter matches nothing.
- **Evidence:** `06-samples/catalog_search_cases.json` shows `Bulldog` returning 0 results and `dog` returning 13. Screenshot `08-search-no-results.png`.
- **Reproduce:** `/search.screen?keywords=Bulldog` shows "No results were found for your search."

## F2. "Your Price" shows supplier cost (conflict)

- **Document:** User Guide section 3.3 says "Your Price: the discounted price for members."
- **Code:** `item.jsp:30` renders `item.unitCost`, which is the supplier cost from `ITEM_DETAILS.UNITCOST`. It shows to everyone, signed in or not. No discount logic exists.
- **Evidence:** Screenshot `06-item-detail.png` shows EST-6 with List Price $18.50 and Your Price $12.00.
- **Reproduce:** Open `/item.screen?item_id=EST-6` without signing in.

## F3. Sign-on bypass with a path parameter (security defect)

- **Code:** `SignOnFilter.java:115` takes the target from `getRequestURI()`, which keeps `;jsessionid=...`. Lines 151 and 235 compare it to the protected pattern with `equals`. `populate_admin.screen;jsessionid=x` matches no pattern, so the filter lets it through.
- **Impact:** An anonymous user can open `account.screen` and `populate_admin.screen` (ADMIN only).
- **Reproduce:** `curl "/populate_admin.screen;jsessionid=anything"` returns the Catalog Administration page.
- **Origin:** Pet Store 1.3.2 `SignOnFilter`.

## F4. Plain-text passwords (security risk)

- **Code:** `UserDAO.java:132` compares `storedPassword.equals(password)`. `SIGNON.PASSWORD` is `varchar(25)` with no hashing.
- **Data:** `data/migration/signon.csv` holds 43 passwords in clear. The sample admin password is `admin` (`populate/Populate-UTF8.xml`).
- **Migration impact:** The target needs a decision before go-live, for example force a reset or hash on load.

## F5. Missing user name gives HTTP 500 (defect)

- **Code:** `UserDAO.authenticate` finds no row for a null user name, then writes an audit row with a null `USERNAME`. That breaks the `NOT NULL` constraint, and the `SQLException` becomes a `ServletException`.
- **Reproduce:** `curl -X POST /j_signon_check` returns 500 and the Error page.

## F6. Forced reload wipes accounts and audit (risk)

- **Code:** `PopulateServlet` with `forcefully=true` drops and recreates all 8 tables, including `SIGNON` and `SIGNON_AUDIT`. There is no backup step.
- **Document:** Administrator Guide 3.2 warns about it but relies on the operator to run PSL_DB_BACKUP first.

## F7. Unused page size setting (ambiguity)

- **Config:** `conf/petstore.properties` sets `catalog.pageSize=2`.
- **Code:** Nothing reads it. Page size is hard-coded in `category.jsp:31`, `product.jsp` and `search.jsp`.

## F8. Unknown user names (ambiguity)

- **Code:** `UserDAO.authenticate` writes `SIGNON_FAIL` under any name typed, even one with no account. No account exists to lock, so repeated guesses never trigger the lockout.
- **Evidence:** Case S07 in `06-samples/signon_decision_cases.csv`.
- **Question:** Is the audit table meant to record names that do not exist?

## F9. Missing product image (data quality)

- **Data:** Product FI-SW-01 (Angelfish) references `fish1.jpg` in `Populate-UTF8.xml` and `data/migration/product_details.csv`. That file is not in `src/main/webapp/images`. The 1.3.2 original did not ship it either.
- **Impact:** None on screen today, because product images are not shown. It breaks if the target shows them.

## F10. Hard-coded catalog SQL path (risk)

- **Code:** In `web.xml`, env-entry `url/CatalogDAOSQLURL` is `file:/usr/local/tomcat/webapps/petstore/CatalogDAOSQL.xml`. The app breaks if it is deployed at another path or under another context name.

## F11. No admin or unlock screens (ambiguity)

- **Code:** New accounts are always CUSTOMER (`UserDAO.createUser`). No screen can create an ADMIN or unlock an account early.
- **Document:** Administrator Guide sections 1 and 2.1 tell administrators to use SQL.
- **Question:** Should the target add these screens or keep them as operator tasks?

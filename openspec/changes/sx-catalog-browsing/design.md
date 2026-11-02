## Context

This file records how the legacy J2EE Pet Store Lite implements catalog browsing. It holds implementation notes only. The behaviour to be matched is in `specs/catalog-browsing/spec.md`, and the target design is drafted separately by the Architect after the Product Requirement is approved.

All paths below are relative to `legacy-source/j2ee-pet-store-lite/`.

### Data access

- The web tier reads the catalog directly over JDBC (the "Fast Lane Reader" pattern), with no EJB in between. `catalog/client/CatalogHelper.java` is a session-scoped bean that the JSPs configure with `locale`, `start`, `count` and an identifier (`categoryId`, `productId`, `itemId`) and then read (`categories`, `products`, `items`, `item`).
- `catalog/dao/CatalogDAOFactory.java` picks the DAO class from a JNDI environment entry. `catalog/dao/GenericCatalogDAO.java` loads `src/main/webapp/CatalogDAOSQL.xml` on first use and selects the `derby` or `oracle` statement set named by deployment configuration (GenericCatalogDAO.java 89-100, 525-528).
- Statements: `GET_CATEGORIES` (CatalogDAOSQL.xml 71-77) and `GET_PRODUCTS` (85-91) filter by locale and `ORDER BY name`. `GET_ITEM` (92-100) and `GET_ITEMS` (102-111) join `item`, `item_details` and `product_details` on the same locale and have no ORDER BY. Both dialects state the same filters and order.
- Paging is cursor-based: the DAO runs the full query, calls `resultSet.absolute(start + 1)`, then reads rows `while ((hasNext = resultSet.next()) && (--count > 0))` (GenericCatalogDAO.java 249-257). Because of that loop, a count of zero or less still returns one row (CATB-RULE-0003). A negative or out-of-range start returns `Page.EMPTY_PAGE`. `catalog/model/Page.java` 75-91: `previousPageAvailable` is `start > 0`, `startOfNextPage` is `start + size`, `startOfPreviousPage` is `max(start - size, 0)`. The containing-list-size check is commented out (`// XXX`), so "next available" depends only on whether the cursor found one more row.
- `CatalogHelper` defaults `start=0`, `count=2` (CatalogHelper.java 73-74). `catalog.pageSize=2` in `conf/petstore.properties` line 27 duplicates that value, but the JSPs hard-code it again.
- `CatalogHelper` locale parsing (295-322): `"default"` maps to `Locale.getDefault()`, `xx_YY` is split on the underscore, anything else gives null.
- `catalog/util/DatabaseNames.java` 55-65 maps ja/zh locales to `_ja`/`_zh` tables. Nothing references it (CATB-RULE-0006, disputed). `getCategory`/`getProduct` on the DAO have no caller in `CatalogHelper` (CATB-REQ-0005, disputed).
- DAO `SQLException`s become `CatalogDAOSysException`, which `CatalogHelper` rethrows as a catalog exception (CatalogHelper.java 186-195). That exception propagates to the container, and `web.xml` 131-134 maps it to `general_error.jsp`.

### Schema

- `db/schema/petstore_derby.sql` and `petstore_oracle.sql` define `category`/`category_details`, `product`/`product_details` and `item`/`item_details`. Codes are `varchar(10)` primary keys. Detail tables are keyed on (code, locale). Names are `varchar(80) not null`. Item image and description are `not null`. Prices are `decimal(10,2) not null`. Foreign keys run product → category and item → product. A CHECK requires `listprice >= unitcost`. The Oracle DDL comment (133-134) says unitcost is the price shown as "Your Price".
- Parent-code indexes on `product(catid)` and `item(productid)` (derby 96-97, oracle 107-108) are the only evidence for the "no full scan" requirement.
- The view `v_catalog_item` (derby 101-109, oracle 112-120) joins all six tables per locale. No Java, JSP, batch or populate file reads it, and `PopulateSQL.xml` does not recreate it on reload.
- Seed data: `data/migration/*.csv` and `src/main/webapp/populate/Populate-UTF8.xml`, for example EST-1 Large Angelfish (FI-SW-01) with list price 16.50 and unit cost 10.00.

### Page-template framework (waf)

- `*.screen` requests go to `waf/view/template/TemplateServlet.java` (`web.xml` 103-106). It reads `WEB-INF/screendefinitions_en_US.xml` per configured language at start-up, using `ScreenDefinitionDAO.java`. When a definition is duplicated, the first one is kept and a warning is logged (173-178).
- Language: request parameter `locale`, then session attribute, then the default from `web.xml` 56-63 (`en_US`, the only one configured) (TemplateServlet.java 151-160, 228-235).
- An unknown screen name writes the bare text `Error: Definition for screen <name> not found` to the response, with status 200 and no template (242-246).
- `PREVIOUS.screen` re-renders the screen recorded in the session. Previous-request caching is off (TemplateServlet.java 79-94, 168-176, 197-199). No page links to it.
- `src/main/webapp/template.jsp` 36-50 lays out title, banner, sidebar, body and footer using `waf` `InsertTag`. It declares `charset=UTF-8`. `web.xml` 19-43 installs an encoding filter that sets UTF-8 on every request.

### Pages

- `banner.jsp`: the logo links to `main.screen`. The search form posts `keywords` to `search.screen`. "Signed in as" is shown from session attribute `j_signon_username`. The Admin link (`populate_admin.screen`) is shown when `j_signon_role == 'ADMIN'`. Sign out goes to `signoff.do`. Sign in links to `signon_welcome.screen`, a protected screen that forces the sign-on form and then shows the Welcome page.
- `sidebar.jsp` 15-35 sets `count=5`, `start=0` and `locale=en_US` on the helper and links each category to `category.screen?category_id=<id>`. The side bar has no paging links, so a sixth category is never shown.
- `main.jsp`: an image map over `images/splash.gif`, with six areas for five categories (Birds appears twice).
- `category.jsp` 23-97 and `product.jsp` 34-100: if `count` is present on the request, the `start` and `count` request parameters are used as given; otherwise 0 and 2. Next links carry `count=${pageResults.size}`. Previous links hard-code `count=2`. `search.jsp` 90-109 has the same pattern. On product.jsp the label is `item.attribute` (attribute 1) plus the product name, and only the list price is shown.
- `item.jsp` 18-34: List Price = `listCost`, Your Price = `unitCost`, both through `fmt:formatNumber type="currency"` with `fmt:setLocale en_US`. There is no sign-on check.
- `general_error.jsp` shows the heading "Error" and a link to `main.screen`.
- `footer.jsp` shows the "Petstore Lite is a reduced version of the Java Pet Store Demo 1.3.2" text and the Sun copyright line.
- Page titles come from `screendefinitions_en_US.xml` 13-117. `signon_welcome` reuses `/main.jsp` as its body.

### Deployment

- `Dockerfile` 1-17 deploys the WAR as the only application, at `/petstore/` on port 8080.

## Goals / Non-Goals

**Goals:**

- Record where each catalog-browsing rule is implemented in the legacy tree, so an SME can check a requirement against its source.

**Non-Goals:**

- Any design for the replacement system.
- Search, sign-on, account and catalog administration behaviour. Other capabilities cover them.

## Decisions

- D1. Screen records from different passes that describe the same page were merged into one screen requirement each, giving ten: shared layout, banner, Admin link, Pets side bar, named pages and titles, home, category, product, item and General Error. The footer is stated within the shared-layout requirement.
- D2. `BROWSE-REQ-0006` exists under two modules: the user-guide pass ("en_US and US dollars") and the catalog-module pass ("single item lookup"). The approved key SWHR5-R-0008 is attached to the en_US / US-dollar record. That record is high confidence and corroborated by BROW-REQ-0002, CB-REQ-0003 and `petstore.properties` line 26, which fits the "both passes agree plus a second source" acceptance rule. The single-item lookup is written as a draft. If the server's approval was for the other record, the ID line moves to "Single item lookup".
- D3. The item page requirement states what is shown today: "Your Price" is the unit cost and is shown to everyone. Whether that is intended stays open as a dispute (below). The requirement is not rewritten to match the user guide.
- D4. Requirements recovered from code with no established caller are written with MAY and listed under Risks for confirmation, not dropped.

## Risks / Trade-offs

- R1. **"Your Price" is the unit cost** (BROW-SCR-0003, CB-SCR-0005, CB-REQ-0001, CB-RULE-0001; contradicts-docs). The user guide calls it a member discount. The schema treats it as cost (`listprice >= unitcost`). Product lists show only list price, while search shows only Your Price. Goes to Intent for the Business Owner.
- R2. **Previous link hard-codes a page size of 2** while Next keeps the current size (CB-BR-0007, BROW-RUL-0005). With a custom page size, Previous changes the page size. Suspected legacy defect; the Business Owner decides whether to keep it.
- R3. **Count ≤ 0 returns one row** (CATB-RULE-0003). This is a side effect of the do/while loop. Suspected defect.
- R4. **Side bar silently truncates at five categories** (BROWSE-RULE-0002, BROW-RUL-0003). The catalog has exactly five today. `catalog.minCategories=5` in `petstore.properties` is never enforced.
- R5. **Unresolved reachability**: PREVIOUS page (CATALOG-BROWSING-WF-0001 / CATB-WF-0001), `_ja`/`_zh` tables (CATB-RULE-0006), single category/product lookup (CATB-REQ-0005), `v_catalog_item` (CATB-REQ-0001 ddl-003, CBR-REQ-0001, CB-BR-0005). Access logs or a DBA/SME confirmation would settle each one.
- R6. **Undefined page names return status 200** with a bare message instead of the General Error page. That is recorded as current behaviour, and is also a candidate defect.
- R7. Item listing has no defined order. A rebuild that sorts the items would differ visibly from the legacy store.

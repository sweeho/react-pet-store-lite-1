## Context

These are notes on how the legacy Java Pet Store Lite (`legacy-source/j2ee-pet-store-lite/`) implements catalog search. They are evidence for the requirements in `specs/catalog-search/spec.md`. They describe the legacy system only. The target design is drafted separately once the Product Requirement is approved.

### Request path

1. `banner.jsp:14-17` renders a GET form with `action="search.screen"`, a text input named `keywords` and a submit button labelled `Search`. Every screen in `WEB-INF/screendefinitions_en_US.xml` uses the banner as a parameter, so the box appears on every page.
2. `search.screen` is the `search` screen in `screendefinitions_en_US.xml:41-47`: title `Search`, body `/search.jsp`, with the shared banner, sidebar and footer.
3. `search.jsp:24-37` sets the locale to a hard-coded `en_US`, sets `start`/`count` from the request when `count` is present and to `0`/`2` otherwise, and copies `param.keywords` into the catalog helper's `searchQuery`. It then reads `catalog.searchItems`.
4. `CatalogHelper` delegates to `GenericCatalogDAO.searchItems(searchQuery, start, count, locale)` (`GenericCatalogDAO.java:344-397`). This is the Fast Lane Reader pattern: JDBC from the web tier, with no EJB in the path.

### Tokenisation and matching (`GenericCatalogDAO.java:346-366`, `CatalogDAOSQL.xml:112-127`)

- `java.util.StringTokenizer` with its default delimiters (space, tab, newline, carriage return, form feed) splits the query. Tokens go into a `HashSet`, which removes duplicates and loses their order.
- An empty set returns `Page.EMPTY_PAGE` before a connection is opened.
- The `SEARCH_ITEMS` statement has a fixed fragment holding the locale and the first keyword's three `LIKE` tests, plus a `VARIABLE` fragment repeated once per extra keyword and joined with `OR`. `buildSQLStatement` repeats the variable fragment while parameters remain.
- The tested columns are `lower(product_details.name)`, `lower(item.catid)` and `lower(item_details.descn)`. `attr1`..`attr5` are selected for display but never filtered on.
- Each keyword is bound as `"%" + keyword + "%"`. It is not lower-cased and `%`/`_` are not escaped. These two facts produce the case and wildcard behaviours.
- The statement has no `ORDER BY` in either the derby or the oracle dialect.

### Paging

- Paging uses `resultSet.absolute(start + 1)` and reads `count` rows. `hasNext` is whether one more row exists. Because the result set is unordered, page boundaries depend on the database's row order.
- The page size of 2 is hard-coded in `search.jsp` (default `count`, and the Previous link's `count=2`). The Next link passes `count=${pageResults.size}`. `conf/petstore.properties:27` also declares `catalog.pageSize=2`. The search path never reads it; it was cited as corroboration only.
- Captured samples in `vortex/samples/catalog_search_cases.json` all use page size 2, and `pages = ceil(resultCount / 2)` holds for every case.

### Rendering (`search.jsp:39-110`)

- The empty branch fires on `param.keywords == ''` or `pageResults.size == 0`.
- The result rows render `item.attribute` + `item.productName` as a link to `/item.screen?item_id=<itemId>`, then `item.description`, then `item.unitCost` through `fmt:formatNumber type="currency"` under locale `en_US`. The product page shows `listCost`; search shows `unitCost`.
- The typed text is echoed through `c:out`, which HTML-escapes it.
- Previous and Next are wrapped in `c:if` on `previousPageAvailable` / `nextPageAvailable`, and both carry `keywords`, `start` and `count`.

### Request encoding

`EncodingFilter` (`encodingfilter/web/EncodingFilter.java:61-78`) calls `request.setCharacterEncoding` with the `encoding` init-param, which `WEB-INF/web.xml:18-29` sets to `UTF-8`. It is mapped to `/*` and declared before `SignOnFilter`, so it runs first. This behaviour is cross-cutting. The record was assigned to this capability because search keywords are its main free-text input.

### Missing parameter path

If `keywords` is absent, `searchQuery` is null and `new StringTokenizer(null)` throws a `NullPointerException`, which the WAF maps to `general_error.screen`. This was read in the code and never executed. The banner form always sends the parameter, so only a hand-built URL reaches it.

## Goals / Non-Goals

**Goals:**

- Record the legacy search behaviour precisely enough that the rebuild can be checked against it.
- Make the three disputed or defect-shaped behaviours visible for a decision.

**Non-Goals:**

- The item page and category/product browsing (`catalog-browsing`).
- Choosing between the documented and the observed case behaviour. That decision belongs to the Business Owner.

## Decisions

- D1. Thirty-nine pass records (35 distinct keys) were merged into 15 requirements. Each requirement names one representative record in `Recovered from:`. Records that repeat it are covered by the same requirement and listed in the recommendations file.
- D2. The three screen-kind records collapse into two screen requirements. `SRCH-SCR-0001` (webapp pass and waf pass) and `CS-SCR-0004` describe the same Search page. `CS-SCR-0001` is the banner search box.
- D3. The case-sensitivity requirement states the observed behaviour. Code (lower() on the columns only), the captured `Bulldog` → 0 sample and every code pass agree on it. The User Guide §4 ("Search is not case-sensitive") is the only source against it. The requirement is a draft and the conflict goes to Intent.
- D4. The two User-Guide passes that wrote "ignoring case" into the matching rule (`SRCH-BR-0001`, `CS-BR-0001`) are recommended for edit, so that the matching rule stays neutral on case and the case rule lives in one requirement.

## Risks / Trade-offs

- R1. The locale is hard-coded to `en_US` in `search.jsp`, so the "shopper's locale" is always en_US in the legacy system. The DAO accepts any locale.
- R2. Live Derby `LIKE` collation was not checked against a running instance. The case behaviour rests on the code and one captured sample.
- R3. Wildcards and the missing-parameter error are suspected defects. Whether the rebuild keeps them is a defect-register decision.

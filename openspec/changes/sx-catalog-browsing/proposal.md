## Why

Spec extraction SX-0001 is recovering the behaviour of the legacy J2EE Pet Store Lite so it can be rebuilt. Catalog browsing is the store's public surface: every visitor, signed in or not, uses it to move from the home page to a category, a product and an item. Its rules (paging arithmetic, locale filtering, which price is shown as "Your Price") live in SQL statements, JSP pages and a page-template framework, and the user guide disagrees with the code in places. This change records that behaviour as verifiable requirements.

## What Changes

- Adds the `catalog-browsing` capability: the three-level catalog (category, product, item) and its stored records, the category, product and item listings, single-item lookup, paging and its Next/Previous links, language and currency rules, error behaviour, and the ten user-facing surfaces (shared layout, banner, Admin link, Pets side bar, named pages and titles, home, category, product, item and General Error pages).
- Two requirements carry approved keys: category product paging (SWHR5-R-0018, from BROWSE-REQ-0002) and the en_US / US-dollar presentation rule (SWHR5-R-0008, from BROWSE-REQ-0006). Every other requirement is a draft awaiting SME decision. The recommendations are in `legacy-analysis/ir/_recommendations/catalog-browsing.yaml`.
- Records open disputes instead of resolving them: whether "Your Price" (the unit cost) is a customer price or a member price, and whether several code paths with no caller (PREVIOUS page, locale-suffixed tables, single category/product lookup, the combined catalog view) are live.

## Capabilities

### New Capabilities

- `catalog-browsing`: browsing the pet catalog by category, product and item, the pages that present it, and the paging, locale and error rules behind them.

### Modified Capabilities

- none

## Impact

- Source modules read: `catalog` (DAO, model, helper), `waf` (page-template framework), `src/main/webapp` (JSPs, `CatalogDAOSQL.xml`, `web.xml`, screen definitions), `db/schema` and the DDL inventory exports, `conf/petstore.properties`, `data/migration`, `Dockerfile`, and the user and admin guides.
- Search results, sign-on, account and catalog administration are covered by other capabilities. They appear here only where the shared layout links to them.

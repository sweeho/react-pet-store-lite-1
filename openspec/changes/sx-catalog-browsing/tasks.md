## 1. Catalog data model

- [ ] 1.1 Define the category record with its unique 10-character code and per-locale name, image and description
- [ ] 1.2 Define the product record with its unique code, mandatory category reference and per-locale text
- [ ] 1.3 Define the item record with its unique code, mandatory product reference, per-locale prices, image, description and five attributes
- [ ] 1.4 Enforce one text entry per record and locale, and the field length and mandatory constraints
- [ ] 1.5 Index products by category and items by product
- [ ] 1.6 Load the five standard categories and the sample products and items

## 2. Catalog queries

- [ ] 2.1 List categories with text in a locale, ordered by localised name
- [ ] 2.2 List a category's products with text in a locale, ordered by localised name
- [ ] 2.3 List a product's items with no sort, filtered to items whose item and product text exist in the locale
- [ ] 2.4 Look up a single item by identifier, returning nothing when its locale text is missing
- [ ] 2.5 Decide with the SME whether single category and product lookup are needed and build them only if so
- [ ] 2.6 Raise a catalog error carrying the underlying message when the catalog data cannot be read

## 3. Paging

- [ ] 3.1 Implement start/count paging with next-available and previous-available flags and next/previous start positions
- [ ] 3.2 Return an empty page for a negative or out-of-range start
- [ ] 3.3 Default to start 0 and page size 2 when no count is supplied, and honour start and count when it is
- [ ] 3.4 Reproduce or retire the one-row result for a count of zero or less, per the SME decision
- [ ] 3.5 Build Next links with the current page size and Previous links with a page size of 2, per the SME decision

## 4. Language, currency and encoding

- [ ] 4.1 Present all catalog text in en_US and format all prices as US dollars
- [ ] 4.2 Choose the display language from the request, then the session, then en_US, falling back to en_US per page
- [ ] 4.3 Interpret locale text ("default", language_COUNTRY, other)
- [ ] 4.4 Decode requests and render pages as UTF-8

## 5. Shared layout

- [ ] 5.1 Build the shared layout of page title, banner, side bar, body and footer, with a default layout
- [ ] 5.2 Build the banner with logo, search box, Account link, Sign in or Sign out link and "Signed in as"
- [ ] 5.3 Show the Admin link in the banner only to users with the ADMIN role
- [ ] 5.4 Build the Pets side bar listing the first five categories by name
- [ ] 5.5 Build the footer text
- [ ] 5.6 Register the named catalog pages with their titles, with Welcome reusing the Home body

## 6. Catalog pages

- [ ] 6.1 Build the home page picture with a link region per category
- [ ] 6.2 Build the category page with product rows and conditional Previous and Next links
- [ ] 6.3 Build the product page with item rows, list price and conditional Previous and Next links
- [ ] 6.4 Build the item page with picture, List Price, Your Price, description and Item ID
- [ ] 6.5 Allow anonymous navigation from home to category, product and item by identifier

## 7. Error handling

- [ ] 7.1 Show the General Error page for any unhandled request failure
- [ ] 7.2 Reproduce or replace the bare message for an undefined page name, per the SME decision
- [ ] 7.3 Load page definitions once at start-up, keeping the first duplicate and logging a warning

## 8. Open decisions

- [ ] 8.1 Obtain the Business Owner decision on whether "Your Price" is the unit cost shown to all visitors
- [ ] 8.2 Confirm whether the PREVIOUS page, locale-suffixed tables and the combined catalog view are used
- [ ] 8.3 Confirm the deployment address (port 8080, path /petstore/) for the rebuild

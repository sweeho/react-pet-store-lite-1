## ADDED Requirements

### Requirement: Category product list paging

ID: SWHR5-R-0018
Recovered from: BROWSE-REQ-0002
The system SHALL list the products of a category two at a time, each with its name and description, and SHALL show a Next link only when a following page exists and a Previous link only when a preceding page exists.

#### Scenario: First page of a category with more than two products

- **GIVEN** a category containing 5 products
- **WHEN** the visitor opens the category without paging parameters
- **THEN** the first 2 products are listed with their name and description, a Next link is shown and no Previous link is shown

#### Scenario: Last page of a category

- **GIVEN** a category containing 5 products
- **WHEN** the visitor is on the page that starts at the fifth product
- **THEN** only the fifth product is listed, a Previous link is shown and no Next link is shown

#### Scenario: Category with exactly two products

- **GIVEN** a category containing 2 products
- **WHEN** the visitor opens the category
- **THEN** both products are listed and neither a Next nor a Previous link is shown

### Requirement: Store language and currency

ID: SWHR5-R-0008
Recovered from: BROWSE-REQ-0006
The system SHALL present the store in English (en_US) and SHALL show prices in US dollars.

#### Scenario: Visitor with a non-English browser

- **GIVEN** a visitor whose browser requests the French language
- **WHEN** the visitor opens an item page
- **THEN** the catalog text is shown in en_US and both prices are formatted as US-dollar amounts such as "$16.50"

### Requirement: Shared page layout

The system SHALL compose every store page from one shared layout made of a page title, a banner at the top, a category side bar, a body area holding the requested page content and a footer at the bottom, where each page supplies its own title and body and shares the banner, side bar and footer. A page that names no layout of its own SHALL use the default layout. The footer SHALL state that the store is a reduced version of the Java Pet Store Demo 1.3.2 and carry the copyright notice.

#### Scenario: Any catalog page is displayed

- **GIVEN** the visitor requests the product list of a category
- **WHEN** the page is displayed
- **THEN** the browser title is that page's title, the banner appears above the body, the side bar appears beside the body, and the footer appears below it

#### Scenario: A page with no layout of its own

- **GIVEN** a page definition that names a title and body but no layout
- **WHEN** that page is requested
- **THEN** it is displayed in the default layout with the shared banner, side bar and footer

### Requirement: Store banner

The banner SHALL display the store logo linking to the home page, a keyword search box with a Search button, an Account link, and a Sign in link to an anonymous visitor or a Sign out link to a signed-in user; WHEN a user is signed in THEN the banner SHALL also display "Signed in as <user name>".

#### Scenario: Anonymous visitor sees the banner

- **GIVEN** a visitor who has not signed in
- **WHEN** any store page is displayed
- **THEN** the banner shows the logo, the search box with a Search button, an Account link and a Sign in link, and does not show "Signed in as"

#### Scenario: Signed-in user sees the banner

- **GIVEN** a user signed in with the user name "j2ee"
- **WHEN** any store page is displayed
- **THEN** the banner shows "Signed in as j2ee", an Account link and a Sign out link in place of Sign in

#### Scenario: Banner controls

- **GIVEN** any store page
- **WHEN** the visitor clicks the logo, or types "fish" in the search box and presses Search
- **THEN** the logo opens the home page, and Search opens the search results for the keyword "fish"

### Requirement: Banner Admin link for administrators

The banner SHALL display an Admin link, leading to the catalog administration page, only to a user signed in with the ADMIN role.

#### Scenario: Administrator signed in

- **GIVEN** a user signed in with the ADMIN role
- **WHEN** any store page is displayed
- **THEN** the banner shows an Admin link that opens the Catalog Administration page

#### Scenario: Customer signed in

- **GIVEN** a user signed in without the ADMIN role
- **WHEN** any store page is displayed
- **THEN** the banner shows no Admin link

### Requirement: Pets side bar

The side bar SHALL display the heading "Pets" and one link per catalog category, showing the category's localised name, in ascending order of name, limited to the first five categories with no way to page further; each link SHALL open that category's product list.

#### Scenario: Side bar with the standard catalog

- **GIVEN** the catalog holds the categories Birds, Cats, Dogs, Fish and Reptiles
- **WHEN** any store page is displayed
- **THEN** the side bar shows "Pets" followed by the links Birds, Cats, Dogs, Fish, Reptiles in that order

#### Scenario: More than five categories exist

- **GIVEN** the catalog holds six categories
- **WHEN** any store page is displayed
- **THEN** only the first five categories by name are listed and no Next link is offered in the side bar

#### Scenario: Following a side bar link

- **GIVEN** the side bar is displayed
- **WHEN** the visitor clicks "Dogs"
- **THEN** the product list of the Dogs category is displayed

### Requirement: Named catalog pages and their titles

The system SHALL provide the catalog pages Home, Products (category), Items (product), Item and General Error, each addressable by name, with the page titles "Welcome to the BluePrints Petstore", "Products", "Items", "Item" and "General Error" respectively, and the Welcome page shown after sign-in SHALL reuse the Home page body under the title "Welcome".

#### Scenario: Page titles

- **GIVEN** the visitor opens the home page, a category, a product and an item in turn
- **WHEN** each page is displayed
- **THEN** the titles are "Welcome to the BluePrints Petstore", "Products", "Items" and "Item" respectively

#### Scenario: Welcome page after sign-in

- **GIVEN** a visitor who has just signed in
- **WHEN** the Welcome page is displayed
- **THEN** its title is "Welcome" and its body is the same pet picture as the home page

### Requirement: Home page

The home page SHALL display a picture of pets in which each pet region links to the product list of its category: Birds, Fish, Dogs, Reptiles and Cats.

#### Scenario: Choosing a pet on the home page

- **GIVEN** the home page is displayed
- **WHEN** the visitor clicks the region of the picture showing a fish
- **THEN** the product list of the Fish category is displayed

#### Scenario: Every category is reachable from the picture

- **GIVEN** the home page is displayed
- **WHEN** the visitor inspects the picture's regions
- **THEN** there is a region for each of Birds, Fish, Dogs, Reptiles and Cats, each with that category name as its alternative text

### Requirement: Category page

The category page SHALL display the heading "Products for this Category" and the chosen category's products in ascending order of name, two at a time, each showing its name as a link to that product's item list and its description beneath, with a Previous link only when an earlier page exists and a Next link only when a later page exists.

#### Scenario: Displaying a category

- **GIVEN** the Fish category holds the products Angelfish, Goldfish, Koi and Tiger Shark
- **WHEN** the visitor opens the Fish category
- **THEN** the page shows "Products for this Category", lists Angelfish and Goldfish with their descriptions, and shows a Next link but no Previous link

#### Scenario: Following a product link

- **GIVEN** the Fish category page is displayed
- **WHEN** the visitor clicks "Angelfish"
- **THEN** the item list of the Angelfish product is displayed

#### Scenario: Unknown or empty category

- **GIVEN** a category identifier that has no products in the store locale
- **WHEN** the category page is requested
- **THEN** the heading is shown with an empty list and neither Previous nor Next

### Requirement: Product page

The product page SHALL display the heading "Items for this Product" and the chosen product's items two at a time, each showing its first attribute and product name as a link to the item page, its description and its list price formatted as US-dollar currency, with a Previous link only when an earlier page exists and a Next link only when a later page exists.

#### Scenario: Displaying a product

- **GIVEN** the Angelfish product has the items "Large" priced 16.50 and "Small" priced 16.50
- **WHEN** the visitor opens the Angelfish product
- **THEN** the page shows "Items for this Product" and the rows "Large Angelfish" and "Small Angelfish", each with its description and "$16.50"

#### Scenario: Following an item link

- **GIVEN** the Angelfish product page is displayed
- **WHEN** the visitor clicks "Large Angelfish"
- **THEN** the item page of that item is displayed

### Requirement: Item page

The item page SHALL display, to every visitor whether signed in or not, the item's first attribute and product name as its heading, the item picture, "List Price" showing the item's list price, "Your Price" showing the item's unit cost, the item description and "Item ID" showing the item identifier, with both prices formatted as US-dollar currency.

#### Scenario: Anonymous visitor views an item

- **GIVEN** the item EST-1 "Large Angelfish" with list price 16.50 and unit cost 10.00
- **WHEN** a visitor who is not signed in opens its item page
- **THEN** the page shows the heading "Large Angelfish", the item picture, "List Price: $16.50", "Your Price: $10.00", the description and "Item ID: EST-1"

#### Scenario: Item without text in the store locale

- **GIVEN** an item identifier whose item or product has no text in en_US
- **WHEN** its item page is requested
- **THEN** no item is found and no item details are displayed

### Requirement: General Error page

WHEN a request fails with an error that is not otherwise handled THEN the system SHALL display the General Error page, headed "Error", stating that an unexpected error occurred and offering a link back to the catalog home page.

#### Scenario: Catalog database unavailable

- **GIVEN** the catalog database cannot be reached
- **WHEN** the visitor opens a category page
- **THEN** the General Error page is displayed with the text "An unexpected error occurred. Please return to the catalog and try again." and the word "catalog" links to the home page

### Requirement: Three-level catalog with five categories

The system SHALL organise the catalog in three levels, where each item belongs to exactly one product and each product belongs to exactly one category, and SHALL offer the five categories Birds, Cats, Dogs, Fish and Reptiles.

#### Scenario: Walking the hierarchy

- **GIVEN** the standard catalog
- **WHEN** the visitor lists the categories, then the products of Dogs, then the items of one dog product
- **THEN** each level lists only the children of the level above it

### Requirement: Category record

The system SHALL identify each category by a mandatory, unique code of at most 10 characters, and SHALL hold its display text once per locale: a mandatory name of at most 80 characters and an optional image reference and description of at most 255 characters each, with at most one text entry per category and locale.

#### Scenario: Duplicate category code

- **GIVEN** a category with code "FISH" exists
- **WHEN** a second category with code "FISH" is stored
- **THEN** the store is rejected

#### Scenario: Second text entry for the same locale

- **GIVEN** category "FISH" has en_US text
- **WHEN** another en_US text entry for "FISH" is stored
- **THEN** the store is rejected

### Requirement: Product record

The system SHALL identify each product by a mandatory, unique code of at most 10 characters, SHALL assign it to exactly one existing category, and SHALL hold its display text once per locale: a mandatory name of at most 80 characters and an optional image reference and description of at most 255 characters each.

#### Scenario: Product with an unknown category

- **GIVEN** no category with code "INSECTS" exists
- **WHEN** a product assigned to "INSECTS" is stored
- **THEN** the store is rejected

### Requirement: Item record

The system SHALL identify each item by a mandatory, unique code of at most 10 characters, SHALL assign it to exactly one existing product, and SHALL hold per locale a mandatory list price and unit cost (up to 8 integer digits and exactly 2 decimals), a mandatory image reference and description of at most 255 characters each, and up to five optional attributes of at most 80 characters each; the item's default attribute SHALL be its first attribute.

#### Scenario: Item missing its description

- **GIVEN** an item text entry with no description
- **WHEN** it is stored
- **THEN** the store is rejected

#### Scenario: Asking for an attribute out of range

- **GIVEN** an item whose first attribute is "Large"
- **WHEN** attribute position 7 is asked for
- **THEN** "Large" is returned

### Requirement: Category listing

The system SHALL list the catalog categories that have text in the shopper's locale, each with its identifier, localised name and localised description, in ascending order of localised name, one page at a time.

#### Scenario: Category without text in the locale

- **GIVEN** a category that has text only in ja_JP
- **WHEN** the category list is requested for en_US
- **THEN** that category is not listed

### Requirement: Product listing

The system SHALL list the products of a chosen category that have text in the shopper's locale, each with its identifier, localised name and localised description, in ascending order of localised name, one page at a time.

#### Scenario: Products in name order

- **GIVEN** the Fish category holds Koi, Angelfish and Goldfish
- **WHEN** its product list is requested with a page size of 3
- **THEN** the products are returned as Angelfish, Goldfish, Koi

### Requirement: Item listing

The system SHALL list the items of a chosen product in the shopper's locale, each with its item identifier, product name, image, localised description, up to five attributes, list price and unit cost, one page at a time; the order of items SHALL be whatever order the data store returns, with no sort applied.

#### Scenario: Items of a product

- **GIVEN** the Angelfish product has two items with en_US text
- **WHEN** its item list is requested
- **THEN** both items are returned with their prices, attributes and descriptions, in no guaranteed order

### Requirement: Single item lookup

The system SHALL return a single item by its identifier in the shopper's locale with its category, product identifier, product name, image, localised description, up to five attributes, list price and unit cost, and SHALL return no item, without raising an error, when the item or its product has no text in that locale.

#### Scenario: Unknown item identifier

- **GIVEN** no item "EST-999" exists
- **WHEN** item "EST-999" is requested
- **THEN** no item is returned and no error is raised

### Requirement: Single category and product lookup

The system MAY look up a single category or a single product by identifier in the shopper's locale, returning its localised name and description, and SHALL return nothing when no localised text exists.

#### Scenario: Category lookup in a locale with no text

- **GIVEN** category "FISH" has text only in en_US
- **WHEN** "FISH" is looked up in ja_JP
- **THEN** nothing is returned

### Requirement: Locale completeness of items

The system SHALL show an item in a product list, an item page or a search result only when both the item's text and its product's text exist in the requested locale.

#### Scenario: Item whose product has no text in the locale

- **GIVEN** an item with en_US text whose product has no en_US text
- **WHEN** the product's item list or the item page is requested for en_US
- **THEN** the item is not shown

### Requirement: Page arithmetic

The system SHALL page every catalog list (categories, products, items and search results) by a zero-based start position and a requested count: a page SHALL hold at most count rows from start; a next page SHALL be available only when at least one row exists after the page; a previous page SHALL be available whenever start is greater than zero; the next page SHALL start at start plus the rows shown; the previous page SHALL start at start minus the rows shown, never below zero.

#### Scenario: Middle page

- **GIVEN** a list of 5 rows
- **WHEN** start 2 and count 2 are requested
- **THEN** rows 3 and 4 are returned, next and previous are both available, the next page starts at 4 and the previous page starts at 0

#### Scenario: Start beyond the end

- **GIVEN** a list of 5 rows
- **WHEN** start 9 is requested
- **THEN** an empty page is returned with neither next nor previous available

#### Scenario: Negative start

- **GIVEN** a list of 5 rows
- **WHEN** start -1 is requested
- **THEN** an empty page is returned and no error is raised

### Requirement: Default page position and size

The system SHALL start a catalog list at position 0 with a page size of 2 when the request does not supply a count, and SHALL use the start and count given in the request when a count is supplied.

#### Scenario: No paging parameters

- **GIVEN** a category with 5 products
- **WHEN** the category page is requested with no start or count
- **THEN** the first 2 products are shown

#### Scenario: Paging parameters in the address

- **GIVEN** a category with 5 products
- **WHEN** the category page is requested with start 1 and count 3
- **THEN** the second, third and fourth products are shown

### Requirement: Non-positive page size

WHEN a catalog list is requested with a count of zero or less and a valid start position THEN the system SHALL return exactly one row.

#### Scenario: Count of zero

- **GIVEN** a category with 5 products
- **WHEN** start 0 and count 0 are requested
- **THEN** exactly one product is returned

### Requirement: Next and Previous link targets

WHEN the visitor follows Next on a category, product or search list THEN the system SHALL show the page that starts after the last entry shown with the current page's size; WHEN the visitor follows Previous THEN the system SHALL show the page that starts at the current start minus the number of entries on the current page, never below the first entry, with a page size of 2.

#### Scenario: Previous from a short last page

- **GIVEN** a list of 5 entries and the visitor on the last page, which shows entry 5 only
- **WHEN** the visitor clicks Previous
- **THEN** the page shown starts at entry 4 and shows entries 4 and 5

#### Scenario: Next keeps the page size

- **GIVEN** a list of 9 entries shown 3 at a time from the first entry
- **WHEN** the visitor clicks Next
- **THEN** entries 4, 5 and 6 are shown

### Requirement: Display language selection

The system SHALL choose the display language of each page from, in order, a language named on the request, then the language remembered in the visitor's session, then the store default en_US; WHEN the chosen language has no page definitions, or a page is not defined in it, THEN the system SHALL show the en_US version.

#### Scenario: Unsupported language requested

- **GIVEN** only en_US pages are defined
- **WHEN** a page is requested with the language de_DE on the request
- **THEN** the en_US page is shown

### Requirement: Locale text interpretation

The system SHALL interpret a locale given as text as follows: "default" in any letter case means the server's default locale, "language_COUNTRY" means that language and country, and text without an underscore means no locale.

#### Scenario: Locale text forms

- **GIVEN** the locale texts "DEFAULT", "en_US" and "english"
- **WHEN** each is interpreted
- **THEN** they yield the server default locale, English (United States) and no locale respectively

### Requirement: Locale-specific catalog tables

The system MAY read catalog data for the Japan locale from tables suffixed "\_ja", for the China locale from tables suffixed "\_zh", and SHALL read every other locale from the base tables.

#### Scenario: Locale other than Japan or China

- **GIVEN** a catalog request in en_US
- **WHEN** the table to read is chosen
- **THEN** the base catalog tables are read

### Requirement: Undefined page name

WHEN a page is requested by a name that has no definition in the requested language or the default language THEN the system SHALL respond with the bare message "Error: Definition for screen <name> not found", without the shared layout, without an error status and instead of the General Error page.

#### Scenario: Mistyped page name

- **GIVEN** no page named "catgory" is defined
- **WHEN** "catgory" is requested
- **THEN** the response body is "Error: Definition for screen catgory not found" with no banner, side bar or footer

### Requirement: Return to previous page

The system MAY remember, per visitor session, the last named page shown, and WHEN the special page name "PREVIOUS" is requested THEN the system SHALL show that remembered page again without replacing the remembered page and without re-applying that page's earlier request inputs.

#### Scenario: Requesting PREVIOUS after viewing an item

- **GIVEN** the visitor last viewed the item page
- **WHEN** the visitor requests "PREVIOUS"
- **THEN** the item page is shown again and remains the remembered page

### Requirement: Page definitions loading

The system SHALL load the page definitions for each configured language once at start-up; WHEN a page, part or layout is defined more than once THEN the system SHALL keep the first definition, ignore later ones and log a non-fatal warning; WHEN a language's definitions are missing or unreadable THEN the system SHALL log an error and serve that language from the default language.

#### Scenario: Duplicate page definition

- **GIVEN** the definitions declare the page "item" twice with different titles
- **WHEN** the store starts
- **THEN** the first definition is used, a warning is logged and the store starts normally

### Requirement: Catalog data failure

WHEN the catalog data cannot be read, because the database is unavailable, a query fails or the catalog configuration is missing, THEN the system SHALL fail the catalog list, item or search request with a catalog error carrying the underlying message.

#### Scenario: Query fails

- **GIVEN** the catalog database rejects the product query
- **WHEN** a category's products are requested
- **THEN** the request fails with a catalog error that carries the database's message

### Requirement: Catalog query dialect configuration

The system SHALL hold the catalog queries as one statement set per supported database product and SHALL select the set, and the catalog data-access implementation, named by deployment configuration when the catalog is first used.

#### Scenario: Oracle deployment

- **GIVEN** the deployment configuration names the oracle dialect
- **WHEN** the catalog is first used
- **THEN** the oracle statement set is used for every catalog query

### Requirement: Anonymous catalog navigation

The system SHALL let any visitor, without signing in, navigate from the home page or side bar to a category's product list, to a product's item list, to an item page, with each step identified by the category, product or item identifier in its address.

#### Scenario: Browsing without an account

- **GIVEN** a visitor who has not signed in
- **WHEN** the visitor opens category "FISH", then product "FI-SW-01", then item "EST-1"
- **THEN** each page is displayed without a sign-in prompt

### Requirement: Character encoding

The system SHALL decode every incoming request as UTF-8 and SHALL render every page as UTF-8.

#### Scenario: Non-ASCII search keyword

- **GIVEN** the visitor types the keyword "café" into the search box
- **WHEN** the search is submitted
- **THEN** the keyword is received as "café" and the results page is served as UTF-8

### Requirement: Store address

The system SHALL serve the store as its only web application on HTTP port 8080 under the path /petstore/.

#### Scenario: Opening the store

- **GIVEN** the store is running
- **WHEN** a browser requests http://<host>:8080/petstore/
- **THEN** the store home page is returned

### Requirement: Listing by parent without full scan

The system SHALL be able to retrieve the products of a category and the items of a product by their parent code, and SHOULD do so without reading the whole catalog.

#### Scenario: Products of one category

- **GIVEN** a catalog with many categories
- **WHEN** the products of one category are requested
- **THEN** they are found through the category code rather than a scan of every product

### Requirement: Combined catalog item listing

The system MAY provide a combined per-locale listing of catalog items giving category code and name, product code and name, item code, list price, unit cost, first attribute, description, image and locale, and SHALL include an item for a locale only when its product and its category both have text in that locale.

#### Scenario: Category without text in the item's locale

- **GIVEN** an item and product with en_US text whose category has no en_US text
- **WHEN** the combined listing for en_US is read
- **THEN** that item does not appear

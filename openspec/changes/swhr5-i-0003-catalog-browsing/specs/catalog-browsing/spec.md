## ADDED Requirements

### Requirement: Category products page

ID: SWHR5-R-0112
Recovered from: BROW-SCR-0001
The system SHALL show, for a chosen category, a "Products for this Category" page listing that category's products two at a time, each with its name (linking to the product's items) and description, with a Previous link only when an earlier page exists and a Next link only when a later page exists.

#### Scenario: First page of a category with five products
ID: SWHR5-R-0112.01

- **GIVEN** a category containing five products
- **WHEN** a visitor opens the category page without paging parameters
- **THEN** the page is headed "Products for this Category" and shows the first two products by name and description, each name linking to that product's items
- **AND** a Next link is shown and no Previous link is shown

#### Scenario: Last page of a category
ID: SWHR5-R-0112.02

- **GIVEN** a category containing five products and the visitor is on the page starting at the fifth product
- **WHEN** the page is displayed
- **THEN** one product is shown, a Previous link is shown and no Next link is shown

### Requirement: Product items page

ID: SWHR5-R-0197
Recovered from: BROW-SCR-0002
The system SHALL show, for a chosen product, an "Items for this Product" page listing that product's items two at a time, each with its attribute and product name (linking to the item page), its description and its list price formatted as en_US currency, with the same conditional Previous and Next links as the category page.

#### Scenario: Product with three items
ID: SWHR5-R-0197.01

- **GIVEN** a product "Bulldog" with three items, the first having attribute "Male Adult" and list price 18.50
- **WHEN** a visitor opens the product page
- **THEN** the page is headed "Items for this Product" and shows two items, the first labelled "Male Adult Bulldog" linking to its item page, with its description and the price "$18.50"
- **AND** a Next link is shown and no Previous link is shown

### Requirement: Item page

ID: SWHR5-R-0176
Recovered from: BROW-SCR-0003
The system SHALL show an item page titled with the item attribute and product name, showing the item image, "List Price" (the item's list price), "Your Price" (the item's unit cost), the item description and the Item ID, with both prices formatted as en_US currency.

#### Scenario: Item page for a seeded item
ID: SWHR5-R-0176.01

- **GIVEN** item EST-1 "Large Angelfish" with list price 16.50 and unit cost 10.00
- **WHEN** any visitor, signed in or not, opens the item page for EST-1
- **THEN** the page shows the item image, the heading "Large Angelfish", "List Price $16.50", "Your Price $10.00", the item description and "Item ID: EST-1"

### Requirement: Home page pet picture

ID: SWHR5-R-0052
Recovered from: BROW-SCR-0004
The system SHALL show a home page with a pet picture whose regions link to the Birds, Fish, Dogs, Reptiles and Cats category pages.

#### Scenario: Visitor clicks a pet on the home page
ID: SWHR5-R-0052.01

- **GIVEN** a visitor on the home page
- **WHEN** the visitor clicks the dog region of the picture
- **THEN** the Dogs category page is shown

### Requirement: Store page frame

ID: SWHR5-R-0113
Recovered from: BROW-SCR-0005
The system SHALL compose every store page from a banner (logo linking to the home page, a keyword search box, an Account link and a Sign in or Sign out link), a Pets side bar, the page body and a footer.

#### Scenario: Anonymous visitor views any store page
ID: SWHR5-R-0113.01

- **GIVEN** a visitor who is not signed in
- **WHEN** the visitor opens any store page
- **THEN** the page shows the banner with the logo, a search box, an Account link and a Sign in link, the Pets side bar, the page body and the footer
- **AND** clicking the logo shows the home page

#### Scenario: Signed-in visitor sees Sign out
ID: SWHR5-R-0113.02

- **GIVEN** a visitor who is signed in
- **WHEN** the visitor opens any store page
- **THEN** the banner shows a Sign out link in place of the Sign in link

### Requirement: General Error page

ID: SWHR5-R-0114
Recovered from: BROW-SCR-0006
The system SHALL show a General Error page saying that an unexpected error occurred, with a link back to the catalog, whenever an unexpected error is raised while serving a page and not otherwise handled.

#### Scenario: Unhandled error while serving a page
ID: SWHR5-R-0114.01

- **GIVEN** the catalog data cannot be read
- **WHEN** a visitor opens a category page
- **THEN** the General Error page is shown, stating that an unexpected error occurred
- **AND** it offers a link that returns the visitor to the catalog home page

### Requirement: Banner Admin link

ID: SWHR5-R-0056
Recovered from: BROWSE-SCR-0007
The system SHALL render every page with a banner (logo returning to the home page, Search box, Account link and Sign in or Sign out link, plus "Signed in as <user name>" when signed in), a category side bar, the requested body and a footer, and SHALL show an extra Admin link in the banner to a user signed in with the ADMIN role.

#### Scenario: Administrator is signed in
ID: SWHR5-R-0056.01

- **GIVEN** a user "admin" signed in with the ADMIN role
- **WHEN** the user opens any store page
- **THEN** the banner shows "Signed in as admin", a Sign out link and an Admin link

#### Scenario: Customer is signed in
ID: SWHR5-R-0056.02

- **GIVEN** a user "j2ee" signed in without the ADMIN role
- **WHEN** the user opens any store page
- **THEN** the banner shows "Signed in as j2ee" and a Sign out link, and no Admin link

### Requirement: Shared page layout from page definitions

ID: SWHR5-R-0194
Recovered from: CATALOG-BROWSING-SCREEN-0001
The system SHALL render every named page from one shared page layout made of a title, banner, sidebar, body and footer, where each page's title text and the content of each region are taken from that page's definition, and SHALL use the default layout when a page names no layout of its own.

#### Scenario: Page with no layout of its own
ID: SWHR5-R-0194.01

- **GIVEN** the "category" page definition names the title "Products" and its own body, and names no layout
- **WHEN** the category page is requested
- **THEN** the page is rendered on the default layout with the title "Products", the shared banner, sidebar and footer, and the category body

### Requirement: Named catalog pages and titles

ID: SWHR5-R-0192
Recovered from: CATB-SCR-0001
The system SHALL provide the catalog pages Home, Products (category), Items (product), Item and General Error, each addressable by name, with the page titles "Welcome to the BluePrints Petstore", "Products", "Items", "Item" and "General Error" respectively; the Welcome page shown after sign-in SHALL reuse the Home page body.

#### Scenario: Page titles
ID: SWHR5-R-0192.01

- **GIVEN** the store is running
- **WHEN** a visitor opens the home, category, product, item and general error pages in turn
- **THEN** the page titles are "Welcome to the BluePrints Petstore", "Products", "Items", "Item" and "General Error"

#### Scenario: Welcome page after sign-in
ID: SWHR5-R-0192.02

- **GIVEN** a visitor who has just signed in
- **WHEN** the Welcome page is shown
- **THEN** its title is "Welcome" and its body is the same pet picture as the home page

### Requirement: Home page category links

ID: SWHR5-R-0063
Recovered from: CB-SCR-0001
The system SHALL show, as the home page, a picture of pets in which each pet region links to the product list of its category (Birds, Fish, Dogs, Reptiles, Cats).

#### Scenario: Visitor opens the store root
ID: SWHR5-R-0063.01

- **GIVEN** a visitor arriving at the store
- **WHEN** the home page is displayed
- **THEN** a picture of pets is shown in which each of the Birds, Fish, Dogs, Reptiles and Cats regions links to that category's product list

### Requirement: Three-level catalog drill-down

ID: SWHR5-R-0047
Recovered from: BROW-REQ-0001
The catalog SHALL be organised in three levels (category, product, item); a category page SHALL list its products with name and description, and a product page SHALL list its items with attribute, name, description and list price.

#### Scenario: Drilling from category to item
ID: SWHR5-R-0047.01

- **GIVEN** category Dogs contains product Bulldog, which contains item "Male Adult Bulldog"
- **WHEN** a visitor opens Dogs, then Bulldog
- **THEN** the Dogs page lists Bulldog with its name and description, and the Bulldog page lists "Male Adult Bulldog" with its description and list price

### Requirement: Category and product ordering

ID: SWHR5-R-0048
Recovered from: BROW-RUL-0001
The system SHALL list categories, and the products of a category, in ascending order of their localized name.

#### Scenario: Categories in name order
ID: SWHR5-R-0048.01

- **GIVEN** categories named Fish, Dogs, Reptiles, Cats and Birds
- **WHEN** the category list is shown
- **THEN** they appear in the order Birds, Cats, Dogs, Fish, Reptiles

### Requirement: Item order is undefined

ID: SWHR5-R-0049
Recovered from: BROW-RUL-0002
The system SHALL list the items of a product without any defined sort order; the order is whatever the data store returns.

#### Scenario: Items of a product are not sorted
ID: SWHR5-R-0049.01

- **GIVEN** a product with items EST-2 and EST-1
- **WHEN** the product's items are listed
- **THEN** the items are returned without any sort being applied, and a consumer MUST NOT rely on their order

### Requirement: Pets side bar shows at most five categories

ID: SWHR5-R-0181
Recovered from: BROW-RUL-0003
The system SHALL show in the Pets side bar at most the first five categories, in name order, each linking to its category page.

#### Scenario: Side bar with the five seeded categories
ID: SWHR5-R-0181.01

- **GIVEN** the five categories Birds, Cats, Dogs, Fish and Reptiles
- **WHEN** any store page is shown
- **THEN** the Pets side bar lists Birds, Cats, Dogs, Fish and Reptiles in that order, each linking to its category page

### Requirement: en_US text and US-dollar prices on pages

ID: SWHR5-R-0196
Recovered from: BROW-RUL-0004
The system SHALL present all catalog text in the en_US locale and format all prices as US-dollar currency, regardless of the visitor's browser locale.

#### Scenario: Browser asks for French
ID: SWHR5-R-0196.01

- **GIVEN** a visitor whose browser requests the fr_FR locale
- **WHEN** the visitor opens an item page
- **THEN** the catalog text is the en_US text and prices are formatted like "$16.50"

### Requirement: Next and Previous link targets

ID: SWHR5-R-0182
Recovered from: BROW-RUL-0005
The system SHALL, on a category, product or search listing, make the Next link start the next page after the last item shown while keeping the current page's size, and make the Previous link start at the current start minus the number of items on the current page (never below zero) with a page size of 2.

#### Scenario: Next keeps the page size
ID: SWHR5-R-0182.01

- **GIVEN** a listing shown from start 0 with a page size of 3 and three items on the page
- **WHEN** the visitor follows Next
- **THEN** the next page starts at position 3 with a page size of 3

#### Scenario: Previous resets the page size to 2
ID: SWHR5-R-0182.02

- **GIVEN** a listing shown from start 3 with a page size of 3 and three items on the page
- **WHEN** the visitor follows Previous
- **THEN** the page shown starts at position 0 with a page size of 2

### Requirement: Items shown only with locale text

ID: SWHR5-R-0050
Recovered from: BROW-RUL-0006
The system SHALL show an item (on the product page, the item page or in search results) only when both the item and its product have descriptive text in the store locale.

#### Scenario: Item without en_US product text
ID: SWHR5-R-0050.01

- **GIVEN** an item that has en_US item text but whose product has no en_US text
- **WHEN** a visitor opens the product page, the item page or searches for the item
- **THEN** the item does not appear

### Requirement: UTF-8 request interpretation

ID: SWHR5-R-0051
Recovered from: BROW-RUL-0007
The system SHALL interpret every incoming request as UTF-8.

#### Scenario: Search words with accented characters
ID: SWHR5-R-0051.01

- **GIVEN** a visitor enters the search word "café"
- **WHEN** the request is received
- **THEN** the word is read as "café" with its accented character intact

### Requirement: Category list with descriptions

ID: SWHR5-R-0053
Recovered from: BROWSE-REQ-0001
The system SHALL list the catalog categories in the requested locale, each with its identifier, name and description, ordered alphabetically by category name.

#### Scenario: Category list in en_US
ID: SWHR5-R-0053.01

- **GIVEN** five categories with en_US text
- **WHEN** the category list is requested for en_US
- **THEN** five entries are returned, each with identifier, name and description, ordered by name

### Requirement: Category product paging

ID: SWHR5-R-0018
Recovered from: BROWSE-REQ-0002
The system SHALL list the products of a category two at a time, each with its name and description, and SHALL show a Next link only when a following page exists and a Previous link only when a preceding page exists.

#### Scenario: Middle page of a category
ID: SWHR5-R-0018.01

- **GIVEN** a category with five products and the visitor on the page starting at the third product
- **WHEN** the page is shown
- **THEN** two products are shown with name and description, and both a Previous and a Next link are shown

#### Scenario: Category with two products
ID: SWHR5-R-0018.02

- **GIVEN** a category with exactly two products
- **WHEN** the category page is shown
- **THEN** both products are shown and neither a Next nor a Previous link is shown

### Requirement: Category navigation limited to five

ID: SWHR5-R-0174
Recovered from: BROWSE-RULE-0002
The system SHALL show at most five categories in the category navigation list, starting from the first category, with no way to page to further categories.

#### Scenario: Six categories exist
ID: SWHR5-R-0174.01

- **GIVEN** six categories with en_US text
- **WHEN** the category navigation list is shown
- **THEN** only the first five by name are listed and no Next link is offered

### Requirement: Product list for a category

ID: SWHR5-R-0054
Recovered from: BROWSE-REQ-0003
The system SHALL list the products of a selected category in the requested locale, each with its identifier, name and description, ordered alphabetically by product name, two products per page by default.

#### Scenario: Default product page
ID: SWHR5-R-0054.01

- **GIVEN** category FISH with four products in en_US
- **WHEN** the products of FISH are requested for en_US with no start or count
- **THEN** the first two products by name are returned, each with identifier, name and description

### Requirement: Item list for a product

ID: SWHR5-R-0198
Recovered from: BROWSE-REQ-0004
The system SHALL list the items of a selected product in the requested locale, each with item identifier, image, description, up to five attributes, product name, list price and unit cost, two items per page by default, in no defined order.

#### Scenario: Default item page
ID: SWHR5-R-0198.01

- **GIVEN** product FI-SW-01 with two items in en_US
- **WHEN** the items of FI-SW-01 are requested for en_US with no start or count
- **THEN** both items are returned, each with identifier, image, description, attributes, product name, list price and unit cost

### Requirement: Shared side bar on every page

ID: SWHR5-R-0055
Recovered from: BROWSE-REQ-0005
The system SHALL show on every page a side bar listing one link per category in alphabetical order.

#### Scenario: Side bar on the item page
ID: SWHR5-R-0055.01

- **GIVEN** a visitor on an item page
- **WHEN** the page is displayed
- **THEN** a side bar lists one link per category in alphabetical order

### Requirement: Single item lookup

ID: SWHR5-R-0008
Recovered from: BROWSE-REQ-0006
The system SHALL retrieve a single item by its identifier in the requested locale, returning its category, product identifier, product name, image, description, five attributes, list price and unit cost, and SHALL return no item and raise no error when no item matches in that locale.

#### Scenario: Known item
ID: SWHR5-R-0008.01

- **GIVEN** item EST-1 with en_US text
- **WHEN** item EST-1 is requested for en_US
- **THEN** its category, product identifier, product name, image, description, five attributes, list price 16.50 and unit cost 10.00 are returned

#### Scenario: Unknown item
ID: SWHR5-R-0008.02

- **GIVEN** no item EST-999 exists
- **WHEN** item EST-999 is requested for en_US
- **THEN** no item is returned and no error is raised

### Requirement: Category structure, item fields and per-locale text

ID: SWHR5-R-0183
Recovered from: CAT-ENT-0001
The system SHALL organise the catalog as a hierarchy of categories, products within a category, and items within a product, with display text, images and prices held per locale for products and items.

#### Scenario: Item belongs to a product and category
ID: SWHR5-R-0183.01

- **GIVEN** item EST-1 of product FI-SW-01 in category FISH
- **WHEN** the item's en_US details are read
- **THEN** its en_US description, image, list price and unit cost are returned, together with its product and category

### Requirement: Default page size with request override

ID: SWHR5-R-0115
Recovered from: CATALOG-BROWSING-BR-0001
The system SHALL show catalog listings 2 entries per page by default, and SHALL use the page size named by a listing request in place of the default.

#### Scenario: No page size requested
ID: SWHR5-R-0115.01

- **GIVEN** a category with five products
- **WHEN** the category page is opened without a page size
- **THEN** two products are shown

#### Scenario: Page size requested
ID: SWHR5-R-0115.02

- **GIVEN** a category with five products
- **WHEN** the category page is opened with start 0 and a page size of 4
- **THEN** four products are shown

### Requirement: Default catalog page size

ID: SWHR5-R-0193
Recovered from: BROWSE-BR-0001
The system SHALL show catalog listings 2 entries per page by default.

#### Scenario: Product page with default size
ID: SWHR5-R-0193.01

- **GIVEN** a product with three items
- **WHEN** the product page is opened without a page size
- **THEN** two items are shown

### Requirement: Undefined page name

ID: SWHR5-R-0184
Recovered from: CATALOG-BROWSING-REQ-0001
The system SHALL, when a requested page name has no definition in the requested language or in the default language, respond with a plain error page reading "Error: Definition for screen <name> not found" instead of a store page.

#### Scenario: Unknown page requested
ID: SWHR5-R-0184.01

- **GIVEN** no page named "nosuch" is defined
- **WHEN** the page "nosuch" is requested
- **THEN** the response is the plain text "Error: Definition for screen nosuch not found", without the banner, side bar or footer

### Requirement: Return to previous page

ID: SWHR5-R-0171
Recovered from: CATALOG-BROWSING-WF-0001
The system SHALL remember, per user session, the last page displayed, and SHALL re-display that remembered page when the special page name "PREVIOUS" is requested; re-supplying the previous request's inputs and data SHALL happen only when explicitly enabled, which it is not.

#### Scenario: PREVIOUS after viewing a category
ID: SWHR5-R-0171.01

- **GIVEN** a visitor whose last displayed page was the category page
- **WHEN** the visitor requests the page "PREVIOUS"
- **THEN** the category page is displayed again, without re-supplying the previous request's parameters

### Requirement: Display language selection

ID: SWHR5-R-0185
Recovered from: CATB-BR-0001
The system SHALL choose the display language for each page request in this order: a language named on the request itself, else the language remembered in the visitor's session, else the store default; and SHALL use the store default, US English (en_US), the only language configured, when the chosen language has no page definitions.

#### Scenario: Request names an unconfigured language
ID: SWHR5-R-0185.01

- **GIVEN** only en_US page definitions exist
- **WHEN** a page is requested with the language ja_JP named on the request
- **THEN** the page is shown with the en_US definitions

#### Scenario: Nothing named
ID: SWHR5-R-0185.02

- **GIVEN** no language on the request and none in the session
- **WHEN** a page is requested
- **THEN** the page is shown in en_US

### Requirement: Category record

ID: SWHR5-R-0057
Recovered from: CATB-ENT-0001
The system SHALL represent a category with an identifier, a localised name and a localised description.

#### Scenario: Category read in en_US
ID: SWHR5-R-0057.01

- **GIVEN** category DOGS with en_US name "Dogs" and a description
- **WHEN** the category is read for en_US
- **THEN** its identifier "DOGS", name "Dogs" and description are returned

### Requirement: Product record

ID: SWHR5-R-0186
Recovered from: CATB-ENT-0002
The system SHALL represent a product with an identifier, a localised name and a localised description, belonging to one category.

#### Scenario: Product belongs to one category
ID: SWHR5-R-0186.01

- **GIVEN** product K9-BD-01 "Bulldog" in category DOGS
- **WHEN** the product is read for en_US
- **THEN** its identifier, name "Bulldog" and description are returned and it belongs to DOGS only

### Requirement: Item record

ID: SWHR5-R-0179
Recovered from: CATB-ENT-0003
The system SHALL represent an item with its category, product identifier, product name, item identifier, image location, localised description, up to five attributes, list price and unit cost, and SHALL give the first attribute when asked for "the" attribute or for an attribute position outside 1 to 5.

#### Scenario: Attribute position out of range
ID: SWHR5-R-0179.01

- **GIVEN** an item whose first attribute is "Large"
- **WHEN** attribute position 7 is requested
- **THEN** "Large" is returned

### Requirement: Item fields and optional category description

ID: SWHR5-R-0187
Recovered from: CATB-ENT-0004
The system SHALL hold for each item a list price, unit cost, image, description and up to five free-text attributes, where image and description are always present and the attributes are optional; category descriptions MAY be empty.

#### Scenario: Item without attributes
ID: SWHR5-R-0187.01

- **GIVEN** an item with list price, unit cost, image and description and no attributes
- **WHEN** the item is stored
- **THEN** it is accepted

#### Scenario: Item without description
ID: SWHR5-R-0187.02

- **GIVEN** an item with no description
- **WHEN** the item is stored
- **THEN** it is rejected

### Requirement: Category listing in the shopper's locale

ID: SWHR5-R-0116
Recovered from: CATB-REQ-0001
The system SHALL list all catalog categories in the shopper's locale, each with its identifier, localised name and localised description, ordered by localised name, and returned one page at a time.

#### Scenario: Paged category listing
ID: SWHR5-R-0116.01

- **GIVEN** five categories with en_US text
- **WHEN** categories are requested for en_US from start 0 with count 2
- **THEN** the first two categories by name are returned and a next page is available

### Requirement: Product listing in the shopper's locale

ID: SWHR5-R-0058
Recovered from: CATB-REQ-0002
The system SHALL list the products of a chosen category in the shopper's locale, each with its identifier, localised name and localised description, ordered by localised name, and returned one page at a time.

#### Scenario: Paged product listing
ID: SWHR5-R-0058.01

- **GIVEN** category DOGS with six products in en_US
- **WHEN** products of DOGS are requested for en_US from start 2 with count 2
- **THEN** the third and fourth products by name are returned

### Requirement: Item listing in the shopper's locale

ID: SWHR5-R-0188
Recovered from: CATB-REQ-0003
The system SHALL list the items of a chosen product in the shopper's locale, each with its item identifier, product name, image, localised description, up to five attributes, list price and unit cost, returned one page at a time and in no defined order.

#### Scenario: Paged item listing
ID: SWHR5-R-0188.01

- **GIVEN** product K9-BD-01 with three items in en_US
- **WHEN** its items are requested for en_US from start 0 with count 2
- **THEN** two items are returned with their identifier, product name, image, description, attributes, list price and unit cost, and a next page is available

### Requirement: Item view requires locale text

ID: SWHR5-R-0180
Recovered from: CATB-REQ-0004
The system SHALL show a single item by its identifier in the shopper's locale with its category, product, product name, image, localised description, up to five attributes, list price and unit cost, and SHALL return no item when no item detail or no product detail exists for that item in the shopper's locale.

#### Scenario: Item detail missing in the locale
ID: SWHR5-R-0180.01

- **GIVEN** item EST-1 has no item detail for ja_JP
- **WHEN** item EST-1 is requested for ja_JP
- **THEN** no item is returned

### Requirement: Catalog page arithmetic

ID: SWHR5-R-0195
Recovered from: CATB-RULE-0001
The system SHALL page every catalog list (categories, products, items, search results) by a zero-based start and a count, returning at most count rows from start. A next page SHALL be offered only when a further row exists, starting at start plus rows shown. A previous page SHALL be offered when start is above zero, starting at start minus rows shown, never below zero.

#### Scenario: Start negative
ID: SWHR5-R-0195.01

- **GIVEN** a list of four rows
- **WHEN** the page from start -1 with count 2 is requested
- **THEN** an empty page is returned

#### Scenario: Last page exactly filled
ID: SWHR5-R-0195.02

- **GIVEN** a list of four rows
- **WHEN** the page from start 2 with count 2 is requested
- **THEN** two rows are returned, no next page is offered, a previous page is offered and it starts at 0

#### Scenario: Start beyond the last row
ID: SWHR5-R-0195.03

- **GIVEN** a list of four rows
- **WHEN** the page from start 9 with count 2 is requested
- **THEN** an empty page is returned

### Requirement: Default start and page size

ID: SWHR5-R-0059
Recovered from: CATB-RULE-0002
The system SHALL default a catalog list to start position 0 and a page size of 2 rows when the request does not supply them.

#### Scenario: No start or count supplied
ID: SWHR5-R-0059.01

- **GIVEN** a list of five categories
- **WHEN** the list is requested with no start or count
- **THEN** the first two rows are returned

### Requirement: Non-positive page size returns one row

ID: SWHR5-R-0190
Recovered from: CATB-RULE-0003
The system SHALL return exactly one row when a catalog list is requested with a count of zero or less and a valid start position.

#### Scenario: Count of zero
ID: SWHR5-R-0190.01

- **GIVEN** a list of five categories
- **WHEN** the page from start 0 with count 0 is requested
- **THEN** exactly one row is returned

### Requirement: Locale completeness of catalog text

ID: SWHR5-R-0060
Recovered from: CATB-RULE-0004
The system SHALL show catalog text only in the shopper's locale, and an item SHALL appear in a list, a search result or the item view only when both its item detail and its product detail exist in that same locale.

#### Scenario: Item detail exists but product detail does not
ID: SWHR5-R-0060.01

- **GIVEN** item EST-1 has en_US item detail and its product has no en_US product detail
- **WHEN** the items of that product are listed for en_US
- **THEN** EST-1 is not listed

### Requirement: Locale text interpretation

ID: SWHR5-R-0191
Recovered from: CATB-RULE-0005
The system SHALL interpret a locale given as text as follows: "default" (any case) means the server's default locale; "language_COUNTRY" means that language and country; text with no underscore means no locale.

#### Scenario: Locale strings
ID: SWHR5-R-0191.01

- **GIVEN** the locale texts "DEFAULT", "en_US" and "english"
- **WHEN** each is interpreted
- **THEN** they yield the server's default locale, English (United States), and no locale respectively

### Requirement: Catalog data failure

ID: SWHR5-R-0061
Recovered from: CATB-RULE-0007
The system SHALL fail a catalog list, item or search request with a catalog error carrying the underlying message when the catalog data cannot be read (data store unavailable, query error or configuration missing).

#### Scenario: Data store unavailable
ID: SWHR5-R-0061.01

- **GIVEN** the catalog data store is unavailable
- **WHEN** the category list is requested
- **THEN** the request fails with a catalog error carrying the underlying message, and no empty list is returned

### Requirement: Catalog query dialect configuration

ID: SWHR5-R-0189
Recovered from: CATB-REQ-0006
The system SHALL read the catalog queries from a configuration that holds one set of statements per database product, selecting the set named by deployment configuration when the catalog is first used.

#### Scenario: Deployment names the Derby set
ID: SWHR5-R-0189.01

- **GIVEN** the configuration holds Derby and Oracle statement sets and the deployment names Derby
- **WHEN** the catalog is first used
- **THEN** the Derby statements are used for every catalog query

### Requirement: Listing by parent without full scan

ID: SWHR5-R-0177
Recovered from: CB-REQ-0001
The system SHALL support looking up the products of a category and the items of a product by their parent code without scanning the whole catalog.

#### Scenario: Products of a category looked up by parent code
ID: SWHR5-R-0177.01

- **GIVEN** a catalog with many categories, products and items
- **WHEN** the products of category DOGS are listed
- **THEN** they are found through a lookup on the category code, not by reading every product

### Requirement: Store language and currency

ID: SWHR5-R-0062
Recovered from: CB-REQ-0003
The system SHALL present the store in English (en_US) and show prices in US dollars.

#### Scenario: Prices on the product page
ID: SWHR5-R-0062.01

- **GIVEN** an item with list price 18.50
- **WHEN** its product page is shown
- **THEN** the page text is in English and the price reads "$18.50"

### Requirement: Price labels

ID: SWHR5-R-0178
Recovered from: CB-RULE-0001
The system SHALL present an item's list price as "List Price" and its unit cost as "Your Price".

#### Scenario: Item prices labelled
ID: SWHR5-R-0178.01

- **GIVEN** item EST-1 with list price 16.50 and unit cost 10.00
- **WHEN** its item page is shown
- **THEN** 16.50 is labelled "List Price" and 10.00 is labelled "Your Price"

### Requirement: Five pet categories

ID: SWHR5-R-0175
Recovered from: CB-RULE-0002
The system SHALL offer the pet categories FISH, DOGS, REPTILES, CATS and BIRDS.

#### Scenario: Seeded categories
ID: SWHR5-R-0175.01

- **GIVEN** a freshly populated catalog
- **WHEN** the category list is requested
- **THEN** exactly the categories FISH, DOGS, REPTILES, CATS and BIRDS are present

### Requirement: Anonymous catalog navigation

ID: SWHR5-R-0064
Recovered from: CB-WF-0008
The system SHALL let any visitor, without signing in, navigate from the home page or side bar to a category product list, then a product item list, then an item page, each step identified by the category id, product id or item id in the link.

#### Scenario: Anonymous drill-down
ID: SWHR5-R-0064.01

- **GIVEN** a visitor who is not signed in
- **WHEN** the visitor follows the side bar link for FISH, then product FI-SW-01, then item EST-1
- **THEN** each page is shown without a sign-in prompt, and the links carry category id FISH, product id FI-SW-01 and item id EST-1

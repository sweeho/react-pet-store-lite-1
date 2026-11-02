## ADDED Requirements

### Requirement: Keyword match on product name, category code and item description

ID: SWHR5-R-0021
Recovered from: SRCH-REQ-0001
The system SHALL split a search query into keywords on whitespace, drop duplicate keywords, and return every item in the shopper's locale whose product name, category identifier or item description contains at least one keyword as a substring.

#### Scenario: Part of a word matches a product name

- **GIVEN** the en_US catalog contains items of the product "Bulldog"
- **WHEN** the shopper searches for "dog"
- **THEN** every Bulldog item is returned, together with every item in the DOGS category and every item whose description contains "dog"

#### Scenario: Keyword matches the category code

- **GIVEN** the REPTILES category holds three items in the en_US catalog
- **WHEN** the shopper searches for "reptiles"
- **THEN** those three items are returned

#### Scenario: Duplicate keywords collapse

- **GIVEN** the en_US catalog
- **WHEN** the shopper searches for "koi koi"
- **THEN** the result is identical to a search for "koi", with no item listed twice

### Requirement: Several keywords match any word

ID: SWHR5-R-0020
Recovered from: SEARCH-BR-0002
WHEN a search contains several words separated by spaces THEN the system SHALL list items that match ANY of the words.

#### Scenario: Two words, each matching different items

- **GIVEN** "snake" matches only snake items and "koi" matches only koi items
- **WHEN** the shopper searches for "snake koi"
- **THEN** both the snake items and the koi items are returned

#### Scenario: One word matches nothing

- **GIVEN** "zzz" matches no item and "poodle" matches the Poodle items
- **WHEN** the shopper searches for "zzz poodle"
- **THEN** the Poodle items are returned

### Requirement: Search results paged two per page

ID: SWHR5-R-0014
Recovered from: SRCH-BR-0005
The system SHALL page search results two items per page, so that the number of pages equals the result count divided by two, rounded up.

#### Scenario: Odd result count

- **GIVEN** a search that matches 7 items
- **WHEN** the results are paged
- **THEN** there are 4 pages, the first three holding 2 items and the last holding 1

#### Scenario: No results

- **GIVEN** a search that matches 0 items
- **WHEN** the results are paged
- **THEN** there are 0 pages

### Requirement: Keyword case handling

Recovered from: SEARCH-BR-0003
The system SHALL compare each keyword exactly as typed against the lower-cased product name, category code and item description, so that a keyword containing an upper-case letter MUST match no item. This records the observed behaviour; the User Guide states search is not case-sensitive and the conflict is open for a business decision.

#### Scenario: Lower-case keyword matches regardless of stored case

- **GIVEN** an item whose product name is "Bulldog"
- **WHEN** the shopper searches for "bulldog"
- **THEN** the item is returned

#### Scenario: Keyword with a capital letter matches nothing

- **GIVEN** an item whose product name is "Bulldog"
- **WHEN** the shopper searches for "Bulldog"
- **THEN** no item is returned and the no-results message is shown

### Requirement: Item attributes are not searched

Recovered from: SRCH-BR-0003
The system SHALL NOT match search keywords against item attributes such as size or sex/age variants; a keyword found only in an item attribute SHALL return no results.

#### Scenario: Keyword present only in an attribute

- **GIVEN** "large" appears only in item attributes and not in any product name, category code or item description
- **WHEN** the shopper searches for "large"
- **THEN** no item is returned

### Requirement: Search limited to the shopper's locale

Recovered from: CATSEARCH-BR-0006
The system SHALL restrict search to item and product text held in the shopper's locale.

#### Scenario: Text in another locale is not matched

- **GIVEN** an item whose description contains a word only in its non-en_US description
- **WHEN** an en_US shopper searches for that word
- **THEN** the item is not returned

### Requirement: Empty query returns no results without a catalog query

Recovered from: SRCH-RULE-0001
GIVEN a search query that is empty or contains only whitespace WHEN a search is run THEN the system SHALL return no results without querying the catalog.

#### Scenario: Whitespace-only query

- **GIVEN** the search text consists only of spaces
- **WHEN** the search runs
- **THEN** zero results and zero pages are returned and no catalog query is executed

### Requirement: No-results message

Recovered from: SRCH-BR-0004
GIVEN an empty search query, or a query that matches no item WHEN the search runs THEN the system SHALL show no results and the message "No results were found for your search."

#### Scenario: Query matches nothing

- **GIVEN** no item matches "zzz"
- **WHEN** the shopper searches for "zzz"
- **THEN** the page shows "No results were found for your search." and lists no items

#### Scenario: Empty query

- **GIVEN** the search box is empty
- **WHEN** the shopper submits the search
- **THEN** the page shows "No results were found for your search." and lists no items

### Requirement: Search request without a search-text field

Recovered from: CS-BR-0005
GIVEN the search address is requested with no search-text field at all WHEN the page is built THEN the system SHALL show the generic error page. This is read from code, not executed, and is a suspected legacy defect.

#### Scenario: Missing search-text parameter

- **GIVEN** a request to the search page that carries no search-text field
- **WHEN** the page is built
- **THEN** the generic error page is shown instead of search results or the no-results message

### Requirement: Wildcard characters in keywords

Recovered from: SRCH-RULE-0003
GIVEN a keyword containing "%" or "_" WHEN a search is run THEN the system SHALL treat "%" as any run of characters and "_" as any single character. This is observed behaviour and a suspected legacy defect.

#### Scenario: Percent sign matches everything

- **GIVEN** the en_US catalog
- **WHEN** the shopper searches for "%"
- **THEN** every en_US item is returned

#### Scenario: Underscore matches one character

- **GIVEN** an item whose product name is "Koi"
- **WHEN** the shopper searches for "k_i"
- **THEN** the Koi item is returned

### Requirement: Search results have no defined order

Recovered from: SRCH-RULE-0004
The system SHALL return search results one page at a time using the catalog paging rule, in no defined order.

#### Scenario: Results are paged without a sort key

- **GIVEN** a search that matches 13 items
- **WHEN** pages 1 to 7 are requested in turn
- **THEN** together they return each of the 13 items exactly once, in an order no requirement fixes

### Requirement: Search result item data

Recovered from: SEARCH-REQ-0004
The system SHALL return each search result with its category, product identifier, product name, item identifier, image, description, attributes, list price and unit cost.

#### Scenario: A result carries the full item data

- **GIVEN** a search that matches item EST-6
- **WHEN** the results are returned
- **THEN** the EST-6 result carries its category, product identifier, product name, item identifier, image, description, attributes, list price and unit cost

### Requirement: Request text decoded as UTF-8

Recovered from: CATSRCH-REQ-0001
The system SHALL interpret the text of every incoming request (form fields and query parameters, on every page and endpoint) as UTF-8 before any page or business logic reads it, so that non-ASCII characters typed by a user are received unaltered.

#### Scenario: Non-ASCII search keyword

- **GIVEN** a shopper types the keyword "café" into the search box
- **WHEN** the search request is received
- **THEN** the keyword used for the search is "café", unaltered

### Requirement: Banner search box screen

Recovered from: CS-SCR-0001
The system SHALL show a keyword search box with a Search button in the banner of every page; submitting it MUST open the Search page for the typed text.

#### Scenario: Search box shown on every page

- **GIVEN** the shopper is on any storefront page
- **WHEN** the page is displayed
- **THEN** the banner shows an empty text box for search words and a button labelled "Search"

#### Scenario: Submitting the search box

- **GIVEN** the shopper has typed "dog" in the banner search box
- **WHEN** the shopper clicks "Search"
- **THEN** the Search page opens showing the first page of results for "dog"

### Requirement: Search results screen

Recovered from: SRCH-SCR-0001
The system SHALL provide a Search page, titled "Search", that, WHEN the search text is empty or nothing matches, shows only "No results were found for your search.", and otherwise shows the heading "Search Results:", the line "Items matching any of: <search text>" and the matches two at a time. Each row MUST show the item attribute and product name as a link to the item page, the item description, and the item's unit cost (not its list price) formatted as US-dollar currency. A Previous link MUST appear only when an earlier page exists and a Next link only when a later page exists, and both MUST keep the search text.

#### Scenario: First page of results

- **GIVEN** a search for "dog" that matches 13 items
- **WHEN** the Search page is displayed
- **THEN** it shows "Search Results:", "Items matching any of: dog", the first 2 matching items each with attribute and product name linked to its item page, its description and its unit cost as US-dollar currency, a Next link, and no Previous link

#### Scenario: Middle page navigation

- **GIVEN** the shopper is on page 2 of the results for "dog"
- **WHEN** the shopper clicks Next
- **THEN** page 3 of the results for "dog" is shown, with both Previous and Next links

#### Scenario: Opening a result

- **GIVEN** the Search page lists item EST-6
- **WHEN** the shopper clicks its name
- **THEN** the item page for EST-6 opens

#### Scenario: No matches

- **GIVEN** a search for "zzz" that matches nothing
- **WHEN** the Search page is displayed
- **THEN** it shows "No results were found for your search." with no heading, no echo line, no rows and no paging links

#### Scenario: Search text is shown escaped

- **GIVEN** a search for "dog <i>" whose word "dog" matches items
- **WHEN** the Search page is displayed
- **THEN** the echo line shows "dog <i>" as literal characters and does not render them as markup

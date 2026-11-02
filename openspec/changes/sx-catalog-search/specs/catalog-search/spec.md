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

ID: SWHR5-R-0203
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

ID: SWHR5-R-0083
Recovered from: SRCH-BR-0003
The system SHALL NOT match search keywords against item attributes such as size or sex/age variants; a keyword found only in an item attribute SHALL return no results.

#### Scenario: Keyword present only in an attribute

- **GIVEN** "large" appears only in item attributes and not in any product name, category code or item description
- **WHEN** the shopper searches for "large"
- **THEN** no item is returned

### Requirement: Search limited to the shopper's locale

ID: SWHR5-R-0076
Recovered from: CATSEARCH-BR-0006
The system SHALL restrict search to item and product text held in the shopper's locale.

#### Scenario: Text in another locale is not matched

- **GIVEN** an item whose description contains a word only in its non-en_US description
- **WHEN** an en_US shopper searches for that word
- **THEN** the item is not returned

### Requirement: Empty query returns no results without a catalog query

ID: SWHR5-R-0291
Recovered from: SRCH-RULE-0001
GIVEN a search query that is empty or contains only whitespace WHEN a search is run THEN the system SHALL return no results without querying the catalog.

#### Scenario: Whitespace-only query

- **GIVEN** the search text consists only of spaces
- **WHEN** the search runs
- **THEN** zero results and zero pages are returned and no catalog query is executed

### Requirement: No-results message

ID: SWHR5-R-0125
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

### Requirement: No-results message and missing search-text field

ID: SWHR5-R-0077
Recovered from: CS-BR-0005
The system SHALL show "No results were found for your search." when the search text is empty, contains only spaces, or matches no item. GIVEN the search address is requested with no search-text field at all WHEN the page is built THEN the system SHALL show the generic error page. The missing-field behaviour is read from code, not executed, and is a suspected legacy defect.

#### Scenario: Search text of spaces only

- **GIVEN** the search text consists only of spaces
- **WHEN** the shopper submits the search
- **THEN** the page shows "No results were found for your search."

#### Scenario: Missing search-text parameter

- **GIVEN** a request to the search page that carries no search-text field
- **WHEN** the page is built
- **THEN** the generic error page is shown instead of search results or the no-results message

### Requirement: Wildcard characters in keywords

ID: SWHR5-R-0206
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

ID: SWHR5-R-0289
Recovered from: SRCH-RULE-0004
The system SHALL return search results one page at a time using the catalog paging rule, in no defined order.

#### Scenario: Results are paged without a sort key

- **GIVEN** a search that matches 13 items
- **WHEN** pages 1 to 7 are requested in turn
- **THEN** together they return each of the 13 items exactly once, in an order no requirement fixes

### Requirement: Search result item data

ID: SWHR5-R-0081
Recovered from: SEARCH-REQ-0004
The system SHALL return search results two per page by default, each with category, product identifier, product name, item identifier, image, description, attributes, list price and unit cost, in no defined order, using the catalog paging rules.

#### Scenario: A result carries the full item data

- **GIVEN** a search that matches item EST-6
- **WHEN** the results are returned
- **THEN** the EST-6 result carries its category, product identifier, product name, item identifier, image, description, attributes, list price and unit cost

### Requirement: Request text decoded as UTF-8

ID: SWHR5-R-0290
Recovered from: CATSRCH-REQ-0001
The system SHALL interpret the text of every incoming request (form fields and query parameters, on every page and endpoint) as UTF-8 before any page or business logic reads it, so that non-ASCII characters typed by a user are received unaltered.

#### Scenario: Non-ASCII search keyword

- **GIVEN** a shopper types the keyword "café" into the search box
- **WHEN** the search request is received
- **THEN** the keyword used for the search is "café", unaltered

### Requirement: Banner search box screen

ID: SWHR5-R-0079
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

ID: SWHR5-R-0126
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

### Requirement: Substring match per search word

ID: SWHR5-R-0080
Recovered from: SEARCH-REQ-0001
The system SHALL match a search word when it appears anywhere (as a substring) in the product name, the category code or the item description, for items in the current locale.

#### Scenario: Word found inside an item description

- **GIVEN** an en_US item whose description contains "friendly" and whose product name and category code do not
- **WHEN** the shopper searches for "friend"
- **THEN** the item is returned

### Requirement: Distinct-keyword substring search in en_US

ID: SWHR5-R-0205
Recovered from: SRCH-RUL-0001
The system SHALL split the search text on whitespace into distinct keywords and return every en_US item whose product name, category code or item description contains any keyword as a substring, comparing against the lower-cased field values and the keyword exactly as typed; GIVEN a keyword containing an upper-case letter THEN that keyword SHALL match nothing. The case clause contradicts the User Guide, and that conflict is open for a business decision.

#### Scenario: Repeated and mixed keywords

- **GIVEN** the en_US catalog
- **WHEN** the shopper searches for "koi koi Bulldog"
- **THEN** the Koi items are returned once each and the keyword "Bulldog" contributes no item

### Requirement: Keyword compared as typed against lower-cased text

ID: SWHR5-R-0288
Recovered from: SRCH-RULE-0002
The system SHALL compare search keywords against lower-cased product names, category identifiers and item descriptions, using each keyword exactly as typed. GIVEN a keyword containing any upper-case letter WHEN a search is run THEN that keyword SHALL match no item.

#### Scenario: Upper-case category code typed

- **GIVEN** the DOGS category holds items in the en_US catalog
- **WHEN** the shopper searches for "DOGS"
- **THEN** no item is returned

### Requirement: Capitalised product name search

ID: SWHR5-R-0202
Recovered from: CS-BR-0003
The system SHALL compare search words against lower-cased product names, category codes and descriptions without lower-casing the words themselves. The User Guide states search is not case-sensitive, and the conflict is open for a business decision.

#### Scenario: Capitalised product name

- **GIVEN** an item whose product name is "Bulldog"
- **WHEN** the visitor searches for "Bulldog"
- **THEN** no result is found

#### Scenario: Lower-case product name

- **GIVEN** an item whose product name is "Bulldog"
- **WHEN** the visitor searches for "bulldog"
- **THEN** the item is found

### Requirement: Capitalised keyword matches nothing

ID: SWHR5-R-0204
Recovered from: SRCH-BR-0002
GIVEN a search keyword that contains an upper-case letter WHEN the search runs THEN the system SHALL compare it unchanged against lower-cased catalog text, so that the keyword matches nothing.

#### Scenario: Captured Bulldog sample

- **GIVEN** the en_US sample catalog
- **WHEN** the shopper searches for "Bulldog" and then for "dog"
- **THEN** "Bulldog" returns no results and "dog" returns the Bulldog items

### Requirement: Result order and wildcard characters

ID: SWHR5-R-0287
Recovered from: CS-BR-0006
The system SHALL return search results in no defined order. GIVEN a search word containing "%" or "\_" WHEN the search runs THEN those characters SHALL act as wildcards (any run of characters, any single character) rather than literal characters. The wildcard behaviour is a suspected legacy defect.

#### Scenario: Underscore is not literal

- **GIVEN** no item text contains the literal string "d_g" and an item description contains "dog"
- **WHEN** the shopper searches for "d_g"
- **THEN** the item whose description contains "dog" is returned

### Requirement: Search result listing and empty search

ID: SWHR5-R-0078
Recovered from: CS-REQ-0001
The system SHALL list search results two at a time with Next and Previous links, each result linking to its item page. GIVEN the search box is empty or no item matches WHEN the customer searches THEN the system SHALL show "No results were found for your search."

#### Scenario: Three matches

- **GIVEN** a search that matches 3 items
- **WHEN** the customer searches
- **THEN** the first 2 items are listed, each linking to its item page, and a Next link leads to the third

#### Scenario: Empty search box

- **GIVEN** the search box is empty
- **WHEN** the customer searches
- **THEN** "No results were found for your search." is shown

### Requirement: Search results paging links and item navigation

ID: SWHR5-R-0082
Recovered from: SEARCH-REQ-0005
The system SHALL list search results two at a time with Next and Previous links, and SHALL open the item page when a result is clicked.

#### Scenario: Previous from the second page

- **GIVEN** the shopper is on page 2 of results for "dog"
- **WHEN** the shopper clicks Previous
- **THEN** page 1 of results for "dog" is shown

#### Scenario: Clicking a result

- **GIVEN** a results page listing item EST-6
- **WHEN** the shopper clicks that result
- **THEN** the item page for EST-6 opens

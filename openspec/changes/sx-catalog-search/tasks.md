## 1. Search query handling

- [ ] 1.1 Tokenise the search text on whitespace into a de-duplicated keyword set
- [ ] 1.2 Return an empty result without querying the catalog when the keyword set is empty
- [ ] 1.3 Decide and implement the handling of a request with no search-text field (legacy shows the generic error page)
- [ ] 1.4 Decode request text as UTF-8 before search reads it

## 2. Matching

- [ ] 2.1 Match each keyword as a substring of product name, category code and item description
- [ ] 2.2 Combine keywords with any-word (OR) semantics
- [ ] 2.3 Restrict matching to item and product text in the shopper's locale
- [ ] 2.4 Exclude item attributes from matching
- [ ] 2.5 Implement keyword case handling per the Business Owner's decision on the case-sensitivity conflict
- [ ] 2.6 Implement "%" and "\_" handling per the defect-register decision on wildcard characters

## 3. Results and paging

- [ ] 3.1 Return each result with category, product id, product name, item id, image, description, attributes, list price and unit cost
- [ ] 3.2 Page results two per page with page count equal to ceil(result count / 2)
- [ ] 3.3 Report previous-page and next-page availability for a results page
- [ ] 3.4 Leave result order unspecified, or record a chosen order as a deliberate deviation

## 4. Banner search box screen

- [ ] 4.1 Render a search text box and a Search button in the banner of every page
- [ ] 4.2 Submit the typed text to the Search page

## 5. Search results screen

- [ ] 5.1 Render the Search page titled "Search" on the shared layout
- [ ] 5.2 Show "No results were found for your search." for empty text or zero matches
- [ ] 5.3 Show the "Search Results:" heading and the escaped "Items matching any of: <text>" line
- [ ] 5.4 Render each result row with attribute and product name linked to the item page, description and unit cost as US-dollar currency
- [ ] 5.5 Render conditional Previous and Next links that keep the search text

## 6. Verification

- [ ] 6.1 Replay the captured search samples (catalog_search_cases.json) as characterisation tests
- [ ] 6.2 Add UI tests for both screens covering results, no-results and paging states

## 1. Catalog data model

- [ ] 1.1 Define the category, product and item records with unique codes of at most 10 characters
- [ ] 1.2 Enforce that each product references an existing category and each item an existing product
- [ ] 1.3 Define category and product display text keyed by record and locale, with name required and image and description optional
- [ ] 1.4 Define item details keyed by item and locale with list price, unit cost, image, description and five optional attributes
- [ ] 1.5 Apply the field length limits (name 80, image and description 255, attributes 80, locale 10)
- [ ] 1.6 Store list price and unit cost as two-decimal amounts with a maximum of 99,999,999.99
- [ ] 1.7 Refuse localised text for unknown records and refuse removal of a record that still has text
- [ ] 1.8 Generate and commit the schema migration for the catalog tables

## 2. Write-time integrity

- [ ] 2.1 Add the data-layer constraint that refuses a list price below the unit cost, accepting equality
- [ ] 2.2 Normalise hyphenated locale tags to underscore form when loading catalog seed data
- [ ] 2.3 Write tests for duplicate codes, unknown parents, duplicate locale entries and missing required fields
- [ ] 2.4 Write tests for the price guard at 19.99/20.00, 20.00/20.00 and 12.50/11.10

## 3. Catalog integrity checks

- [ ] 3.1 Implement check C1: categories with no product
- [ ] 3.2 Implement check C2: products with no item
- [ ] 3.3 Implement check C3: item details with list price below unit cost, in any locale
- [ ] 3.4 Implement check C4: items with no en_US details, excluding categories and products
- [ ] 3.5 Compute the category and item totals without applying any minimum
- [ ] 3.6 Write tests for each check against a catalog that breaches it and one that does not

## 4. Daily check job

- [ ] 4.1 Schedule the catalog integrity check daily at 06:00, independent of the backup and audit jobs
- [ ] 4.2 Append each breaching rule and code plus the totals to the catalog check log on every run
- [ ] 4.3 End the run with exit code 4 on any breach and exit code 0 when all checks pass
- [ ] 4.4 Detect a missing catalog, request a non-forced first load, and re-run the checks
- [ ] 4.5 End the run with exit code 8 when the first-load request fails
- [ ] 4.6 Write tests for the clean, breach, missing-catalog and failed-load paths

## 5. Alerting

- [ ] 5.1 Send an urgent e-mail to the catalog team naming the check log when a run ends with exit code 4
- [ ] 5.2 Verify that no catalog-integrity e-mail is sent for exit code 0 or exit code 8

## 6. SME decisions

- [ ] 6.1 Record the SME decision on the 5-category and 28-item minimums and update the check if they become a rule
- [ ] 6.2 Record the SME decision on the combined catalog-item view and on identifier padding

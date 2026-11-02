## ADDED Requirements

### Requirement: Catalog hierarchy and identity

The system SHALL hold the catalog as three levels: categories, products and items. Every product MUST belong to exactly one existing category and every item MUST belong to exactly one existing product. Each category, product and item SHALL be identified by a mandatory code of at most 10 characters that is unique within its level, and the system SHALL refuse a second record with the same code.

#### Scenario: Product under an existing category is accepted

- **GIVEN** a category with code DOGS exists
- **WHEN** a product K9-BD-01 is stored under category DOGS
- **THEN** the product is accepted

#### Scenario: Product under an unknown category is refused

- **GIVEN** no category with code UNICORNS exists
- **WHEN** a product is stored under category UNICORNS
- **THEN** the product is refused and nothing is stored

#### Scenario: Item under an unknown product is refused

- **GIVEN** no product with code XX-NONE exists
- **WHEN** an item is stored under product XX-NONE
- **THEN** the item is refused and nothing is stored

#### Scenario: Duplicate code is refused

- **GIVEN** a category with code FISH exists
- **WHEN** a second category with code FISH is stored
- **THEN** the second category is refused

#### Scenario: Code longer than 10 characters is refused

- **GIVEN** an item code of 11 characters
- **WHEN** the item is stored
- **THEN** the item is refused

### Requirement: Category and product display text per locale

The system SHALL hold the display text of each category and of each product per locale, at most once per record and locale. Each text entry MUST carry a name of at most 80 characters and MAY carry an image reference and a description of at most 255 characters each.

#### Scenario: Text entry with only a name is accepted

- **GIVEN** an existing product with no text in locale en_US
- **WHEN** a text entry with name "Bulldog" and no image or description is stored for en_US
- **THEN** the entry is accepted

#### Scenario: Second text entry for the same locale is refused

- **GIVEN** a category that already has a text entry for locale en_US
- **WHEN** another text entry for the same category and locale en_US is stored
- **THEN** the second entry is refused

#### Scenario: Text entry without a name is refused

- **GIVEN** an existing category
- **WHEN** a text entry with no name is stored for it
- **THEN** the entry is refused

### Requirement: Item details per locale

The system SHALL hold the details of each item per locale, at most once per item and locale. Each details entry MUST carry a list price, a unit cost, an image reference and a description (image reference and description at most 255 characters each), and MAY carry up to five descriptive attributes of at most 80 characters each.

#### Scenario: Complete details entry is accepted

- **GIVEN** an existing item EST-1 with no details in locale en_US
- **WHEN** details with list price 16.50, unit cost 10.00, image fish3.gif, description "Fresh Water fish from Japan" and attributes "Large" and "Cuddly" are stored for en_US
- **THEN** the entry is accepted

#### Scenario: Details entry without a description is refused

- **GIVEN** an existing item
- **WHEN** a details entry with no description is stored
- **THEN** the entry is refused

#### Scenario: Second details entry for the same locale is refused

- **GIVEN** an item that already has details for locale en_US
- **WHEN** another details entry for the same item and locale en_US is stored
- **THEN** the second entry is refused

### Requirement: Item price precision

The system SHALL store each item's list price and unit cost as monetary amounts with exactly two decimal places and at most eight digits before the decimal point, so the largest storable amount is 99,999,999.99.

#### Scenario: Amount within range is stored with two decimals

- **GIVEN** an item details entry
- **WHEN** a list price of 16.5 is stored
- **THEN** it is held as 16.50

#### Scenario: Amount above the maximum is refused

- **GIVEN** an item details entry
- **WHEN** a list price of 100,000,000.00 is stored
- **THEN** the entry is refused

### Requirement: List price never below unit cost

The system SHALL refuse to store an item details entry, in any locale, whose list price is below its unit cost. A list price equal to the unit cost SHALL be accepted.

#### Scenario: List price below cost is refused

- **GIVEN** an item details entry with unit cost 20.00
- **WHEN** it is stored with list price 19.99
- **THEN** the entry is refused and nothing is stored

#### Scenario: List price equal to cost is accepted

- **GIVEN** an item details entry with unit cost 20.00
- **WHEN** it is stored with list price 20.00
- **THEN** the entry is accepted

#### Scenario: List price above cost is accepted

- **GIVEN** an item details entry with unit cost 11.10
- **WHEN** it is stored with list price 12.50
- **THEN** the entry is accepted

### Requirement: Localised text refers to an existing record

The system SHALL refuse a category text, product text or item details entry that names a category, product or item that does not exist, and SHALL refuse to remove a category, product or item while localised text for it still exists.

#### Scenario: Text for an unknown category is refused

- **GIVEN** no category with code UNICORNS exists
- **WHEN** a text entry for category UNICORNS is stored
- **THEN** the entry is refused

#### Scenario: Removing a category that still has text is refused

- **GIVEN** category FISH has a text entry for locale en_US
- **WHEN** category FISH is removed
- **THEN** the removal is refused and the category and its text remain

### Requirement: Locale codes

The system SHALL hold each locale as a code of at most 10 characters in underscore form (for example en_US). WHEN catalog data supplied with a hyphenated language tag is loaded, THEN the system SHALL store the tag with the hyphen replaced by an underscore.

#### Scenario: Hyphenated tag is normalised on load

- **GIVEN** catalog seed data whose category text carries language tag "en-US"
- **WHEN** the seed data is loaded
- **THEN** the category text is stored under locale "en_US"

### Requirement: Category has at least one product (rule C1)

Every category SHALL have at least one product. The system MUST report each category that has no product as a catalog integrity breach of rule C1; the rule is checked, not enforced when data is written.

#### Scenario: Empty category is reported

- **GIVEN** category BIRDS exists and has no products
- **WHEN** the catalog integrity check runs
- **THEN** BIRDS is reported as a breach of rule C1

#### Scenario: Category with a product is not reported

- **GIVEN** category DOGS has product K9-BD-01
- **WHEN** the catalog integrity check runs
- **THEN** DOGS is not reported under rule C1

### Requirement: Product has at least one item (rule C2)

Every product SHALL have at least one item. The system MUST report each product that has no item as a catalog integrity breach of rule C2; the rule is checked, not enforced when data is written.

#### Scenario: Product without items is reported

- **GIVEN** product K9-BD-01 exists and has no items
- **WHEN** the catalog integrity check runs
- **THEN** K9-BD-01 is reported as a breach of rule C2

### Requirement: Price at or above cost is re-checked (rule C3)

The catalog integrity check SHALL report each item details entry, in any locale, whose list price is below its unit cost as a breach of rule C3, in addition to the refusal at write time.

#### Scenario: Below-cost entry already present is reported

- **GIVEN** an item details entry for item EST-13 with list price 9.99 and unit cost 10.00 is present in the catalog
- **WHEN** the catalog integrity check runs
- **THEN** EST-13 is reported as a breach of rule C3

### Requirement: Every item has an en_US description (rule C4)

Every item SHALL have a details entry in locale en_US. The system MUST report each item that has no en_US details entry as a breach of rule C4. Categories and products SHALL NOT be checked for en_US text by this rule.

#### Scenario: Item without en_US details is reported

- **GIVEN** item EST-1 has details only in a locale other than en_US
- **WHEN** the catalog integrity check runs
- **THEN** EST-1 is reported as a breach of rule C4

#### Scenario: Product without en_US text is not reported

- **GIVEN** a product has no en_US text and all its items have en_US details
- **WHEN** the catalog integrity check runs
- **THEN** no breach of rule C4 is reported for the product or its items

### Requirement: Daily catalog integrity check

ID: SWHR5-R-0019
Recovered from: CATINT-WF-0005
The system SHALL run the catalog checks C1 to C4 every day at 06:00 and, WHEN any check finds offending rows, SHALL end with exit code 4, write the details to the catalog check log and alert the catalog team by mail.

#### Scenario: A check finds offending rows

- **GIVEN** the catalog contains a product with no items
- **WHEN** the daily catalog check runs at 06:00
- **THEN** the run ends with exit code 4, the offending product is written to the catalog check log, and the catalog team is alerted by mail

#### Scenario: No check finds offending rows

- **GIVEN** the catalog satisfies rules C1 to C4
- **WHEN** the daily catalog check runs at 06:00
- **THEN** the run ends successfully with exit code 0 and no alert is sent

### Requirement: Catalog check log content

On every run the catalog integrity check SHALL append to the catalog check log each breaching row with its rule (C1 to C4) and the offending category, product or item code, together with the total number of categories and the total number of items. The totals SHALL be recorded only; the check MUST NOT fail on them.

#### Scenario: Totals are logged on a clean run

- **GIVEN** a catalog of 5 categories and 28 items that satisfies rules C1 to C4
- **WHEN** the catalog integrity check runs
- **THEN** the log records 5 categories and 28 items and the run succeeds

#### Scenario: Low totals do not fail the check

- **GIVEN** a catalog of 1 category, 1 product and 1 item that satisfies rules C1 to C4
- **WHEN** the catalog integrity check runs
- **THEN** the totals are logged and the run succeeds

### Requirement: First load when the catalog does not exist

WHEN the catalog integrity check finds that the catalog tables do not exist, THEN the system SHALL request a first, non-forced load of the sample catalog data and SHALL run the checks again. IF the load request fails, THEN the run SHALL end as failed with exit code 8, distinct from the integrity-breach outcome.

#### Scenario: Missing catalog is loaded and re-checked

- **GIVEN** the catalog tables do not exist
- **WHEN** the catalog integrity check runs
- **THEN** a first load of the sample data is requested without forcing a reload, and checks C1 to C4 run again against the loaded catalog

#### Scenario: Load request fails

- **GIVEN** the catalog tables do not exist and the store does not answer the load request
- **WHEN** the catalog integrity check runs
- **THEN** the run ends with exit code 8 and the checks are not repeated

### Requirement: Catalog team alert

The catalog integrity check SHALL run independently of the nightly backup and audit jobs. WHEN a run ends with the integrity-breach outcome (exit code 4), THEN the system SHALL send an urgent e-mail to the catalog team whose subject states that the catalog integrity check failed and whose body points to the catalog check log.

#### Scenario: Breach raises an urgent mail

- **GIVEN** the nightly backup job has not completed
- **WHEN** the catalog integrity check runs at 06:00 and ends with exit code 4
- **THEN** an urgent e-mail is sent to the catalog team naming the catalog check log

#### Scenario: Other failure does not raise the catalog mail

- **GIVEN** the catalog integrity check ends with exit code 8
- **WHEN** the run completes
- **THEN** the catalog-integrity e-mail is not sent

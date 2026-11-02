## ADDED Requirements

### Requirement: Catalog hierarchy with populated levels

ID: SWHR5-R-0069
Recovered from: CATDI-ENT-0001
The system SHALL hold the catalog as a three-level hierarchy of categories, products and items, where every product belongs to exactly one existing category, every item belongs to exactly one existing product, every category has at least one product and every product has at least one item.

#### Scenario: Migrated catalog forms a complete hierarchy
ID: SWHR5-R-0069.01

- **GIVEN** the migrated sample catalog
- **WHEN** its categories, products and items are inspected
- **THEN** every product names one existing category, every item names one existing product, and no category or product is empty

### Requirement: Three-level catalog with unique identifiers

ID: SWHR5-R-0278
Recovered from: CDI-ENT-0001
The system SHALL hold a catalog of three levels: categories, products and items. Each product SHALL belong to exactly one existing category, and each item SHALL belong to exactly one existing product. Each category, product and item SHALL be identified by a unique identifier of at most 10 characters.

#### Scenario: Product under an unknown category is refused
ID: SWHR5-R-0278.01

- **GIVEN** no category with code UNICORNS exists
- **WHEN** a product is stored under category UNICORNS
- **THEN** the product is refused and nothing is stored

#### Scenario: Duplicate category identifier is refused
ID: SWHR5-R-0278.02

- **GIVEN** a category with code FISH exists
- **WHEN** a second category with code FISH is stored
- **THEN** the second category is refused

### Requirement: Item identity and parent product

ID: SWHR5-R-0123
Recovered from: CDI-RULE-0004
The system SHALL require every item to have an item identifier of at most 10 characters, unique across the catalog, and to belong to exactly one existing product; an item referring to an unknown product SHALL be rejected.

#### Scenario: Item under an unknown product is rejected
ID: SWHR5-R-0123.01

- **GIVEN** no product with code XX-NONE exists
- **WHEN** an item is stored under product XX-NONE
- **THEN** the item is rejected and nothing is stored

#### Scenario: Duplicate item identifier is rejected
ID: SWHR5-R-0123.02

- **GIVEN** an item EST-1 exists
- **WHEN** a second item EST-1 is stored
- **THEN** the second item is rejected

### Requirement: Identifier and locale code length

ID: SWHR5-R-0200
Recovered from: CDI-RULE-0006
The system SHALL treat catalog identifiers and locale codes as text of at most 10 characters.

#### Scenario: Identifier longer than 10 characters is refused
ID: SWHR5-R-0200.01

- **GIVEN** an item identifier of 11 characters
- **WHEN** the item is stored
- **THEN** the item is refused

#### Scenario: Locale code of 10 characters is accepted
ID: SWHR5-R-0200.02

- **GIVEN** an existing category
- **WHEN** a text entry with a locale code of exactly 10 characters is stored for it
- **THEN** the entry is accepted

### Requirement: Referential integrity across the catalog

ID: SWHR5-R-0284
Recovered from: CDI-BR-0002
The system SHALL reject a product that names a non-existent category, an item that names a non-existent product, and any localised text or price record that names a non-existent category, product or item.

#### Scenario: Item details for an unknown item are rejected
ID: SWHR5-R-0284.01

- **GIVEN** no item with code EST-999 exists
- **WHEN** item details for EST-999 are stored
- **THEN** the details are rejected

#### Scenario: Product text for an unknown product is rejected
ID: SWHR5-R-0284.02

- **GIVEN** no product with code XX-NONE exists
- **WHEN** a product text entry for XX-NONE is stored
- **THEN** the entry is rejected

### Requirement: Category text refers to an existing category

ID: SWHR5-R-0119
Recovered from: CATDI-BR-0001
The system SHALL refuse to store category display text for a category code that does not exist, and SHALL refuse to remove a category that still has display text.

#### Scenario: Text for an unknown category is refused
ID: SWHR5-R-0119.01

- **GIVEN** no category with code UNICORNS exists
- **WHEN** a text entry for category UNICORNS is stored
- **THEN** the entry is refused

#### Scenario: Removing a category that still has text is refused
ID: SWHR5-R-0119.02

- **GIVEN** category FISH has a text entry for locale en_US
- **WHEN** category FISH is removed
- **THEN** the removal is refused and the category and its text remain

### Requirement: Descriptive text per locale

ID: SWHR5-R-0121
Recovered from: CDI-ENT-0002
The system SHALL store the descriptive text of each category, product and item per locale, with at most one description per (identifier, locale) pair, and each description SHALL refer to an existing category, product or item. A category or product description SHALL have a name of at most 80 characters, and MAY have an image reference and a description of at most 255 characters each.

#### Scenario: Text entry with only a name is accepted
ID: SWHR5-R-0121.01

- **GIVEN** an existing category with no text in locale en_US
- **WHEN** a text entry with name "Fish" and no image or description is stored for en_US
- **THEN** the entry is accepted

#### Scenario: Second description for the same locale is refused
ID: SWHR5-R-0121.02

- **GIVEN** a category that already has a text entry for locale en_US
- **WHEN** another text entry for the same category and locale en_US is stored
- **THEN** the second entry is refused

#### Scenario: Name longer than 80 characters is refused
ID: SWHR5-R-0121.03

- **GIVEN** an existing product
- **WHEN** a text entry with a name of 81 characters is stored for it
- **THEN** the entry is refused

### Requirement: Product text per locale

ID: SWHR5-R-0122
Recovered from: CDI-RULE-0003
The system SHALL hold at most one set of product text per product and locale; each set SHALL belong to an existing product and SHALL carry a name of at most 80 characters, while the image reference and description (each at most 255 characters) are optional.

#### Scenario: Product text without a name is refused
ID: SWHR5-R-0122.01

- **GIVEN** an existing product K9-BD-01
- **WHEN** a product text entry with no name is stored for it
- **THEN** the entry is refused

#### Scenario: Product text with only a name is accepted
ID: SWHR5-R-0122.02

- **GIVEN** an existing product K9-BD-01 with no en_US text
- **WHEN** a text entry with name "Bulldog" is stored for en_US
- **THEN** the entry is accepted

### Requirement: English text for every catalog record

ID: SWHR5-R-0068
Recovered from: CATDI-BR-0003
The system SHALL hold English (en_US) descriptive text for every category, product and item, keyed by the record and its locale, and the catalog SHALL contain no other locale.

#### Scenario: Migrated catalog carries en_US text only
ID: SWHR5-R-0068.01

- **GIVEN** the migrated sample catalog
- **WHEN** the text entries of its categories, products and items are inspected
- **THEN** every category, product and item has an en_US entry and no entry carries another locale

### Requirement: Item details per locale

ID: SWHR5-R-0273
Recovered from: CDI-ENT-0003
The system SHALL store, for each item and locale, exactly one set of item details holding a list price and a unit cost (each a decimal amount with 2 decimal places and at most 10 digits in total), an image reference and a description (each required, at most 255 characters), and up to five optional attributes of at most 80 characters each.

#### Scenario: Complete details entry is accepted
ID: SWHR5-R-0273.01

- **GIVEN** an existing item EST-1 with no details in locale en_US
- **WHEN** details with list price 16.50, unit cost 10.00, image fish3.gif, description "Fresh Water fish from Japan" and attributes "Large" and "Cuddly" are stored for en_US
- **THEN** the entry is accepted

#### Scenario: Details entry without a description is refused
ID: SWHR5-R-0273.02

- **GIVEN** an existing item EST-1
- **WHEN** a details entry with no description is stored
- **THEN** the entry is refused

### Requirement: One detail record per item and locale

ID: SWHR5-R-0274
Recovered from: CDI-ENT-0004
The system SHALL hold at most one priced, described record per item per locale, each requiring a list price, a unit cost, an image reference and a description (each of at most 255 characters), and allowing up to five optional attributes of at most 80 characters each, and SHALL refuse such a record for an item that does not exist.

#### Scenario: Second details entry for the same locale is refused
ID: SWHR5-R-0274.01

- **GIVEN** item EST-1 already has details for locale en_US
- **WHEN** another details entry for EST-1 and locale en_US is stored
- **THEN** the second entry is refused

#### Scenario: Details entry without an image is refused
ID: SWHR5-R-0274.02

- **GIVEN** an existing item EST-1 with no details in locale en_US
- **WHEN** a details entry with no image reference is stored
- **THEN** the entry is refused

### Requirement: Item details amounts and attributes

ID: SWHR5-R-0286
Recovered from: CDI-RULE-0005
The system SHALL hold at most one set of item details per item and locale; each set SHALL belong to an existing item and SHALL carry a list price and a unit cost (each a monetary amount with two decimal places and at most 8 integer digits), an image reference and a description (each at most 255 characters); up to five optional attributes of at most 80 characters each MAY be recorded.

#### Scenario: Amount with nine integer digits is refused
ID: SWHR5-R-0286.01

- **GIVEN** an item details entry
- **WHEN** a unit cost of 100,000,000.00 is stored
- **THEN** the entry is refused

#### Scenario: Attribute longer than 80 characters is refused
ID: SWHR5-R-0286.02

- **GIVEN** an item details entry
- **WHEN** an attribute of 81 characters is stored
- **THEN** the entry is refused

### Requirement: Two-decimal prices never below cost

ID: SWHR5-R-0282
Recovered from: CATDI-BR-0002
The system SHALL store each item's list price and unit cost as amounts with two decimal places and SHALL NOT hold an item whose list price is below its unit cost.

#### Scenario: Price is held with two decimals
ID: SWHR5-R-0282.01

- **GIVEN** an item details entry with unit cost 10.00
- **WHEN** a list price of 16.5 is stored
- **THEN** it is held as 16.50

#### Scenario: Price below cost is not held
ID: SWHR5-R-0282.02

- **GIVEN** an item details entry with unit cost 10.00
- **WHEN** a list price of 9.99 is stored
- **THEN** the entry is refused

### Requirement: List price never below unit cost

ID: SWHR5-R-0275
Recovered from: CDI-RULE-0001
The system SHALL NOT store an item whose list price is lower than its unit cost. A list price equal to the unit cost SHALL be accepted.

#### Scenario: List price below cost is rejected
ID: SWHR5-R-0275.01

- **GIVEN** item details with unit cost 20.00
- **WHEN** the list price is 19.99
- **THEN** the record is rejected

#### Scenario: List price equal to cost is accepted
ID: SWHR5-R-0275.02

- **GIVEN** item details with unit cost 20.00
- **WHEN** the list price is 20.00
- **THEN** the record is accepted

### Requirement: Localised details price guard

ID: SWHR5-R-0285
Recovered from: CDI-BR-0003
The system SHALL refuse to store an item's localized details whose list price is lower than its unit cost. A list price equal to the unit cost SHALL be accepted.

#### Scenario: Price above cost is accepted
ID: SWHR5-R-0285.01

- **GIVEN** an item detail with list price 12.50 and unit cost 11.10
- **WHEN** it is stored
- **THEN** it is accepted

#### Scenario: Price below cost is rejected
ID: SWHR5-R-0285.02

- **GIVEN** an item detail with list price 9.99 and unit cost 10.00
- **WHEN** it is stored
- **THEN** it is rejected

### Requirement: Item price below cost is refused (rule C3)

ID: SWHR5-R-0283
Recovered from: CATINT-BR-0003
The system SHALL refuse any item whose list price is below its unit cost (rule C3).

#### Scenario: Below-cost item is refused in another locale
ID: SWHR5-R-0283.01

- **GIVEN** an item EST-1 with unit cost 15.00
- **WHEN** details in locale ja_JP with list price 14.99 are stored
- **THEN** the details are refused

### Requirement: Price guard refused and re-checked

ID: SWHR5-R-0281
Recovered from: CAT-BR-0003
An item's list price SHALL never be below its unit cost, in any locale. The system SHALL refuse to store such a price, and the daily catalog check SHALL report any item detail row where it holds (check C3) as a breach.

#### Scenario: Write is refused
ID: SWHR5-R-0281.01

- **GIVEN** an item details entry with unit cost 20.00
- **WHEN** it is stored with list price 19.99
- **THEN** the entry is refused and nothing is stored

#### Scenario: Row already present is reported
ID: SWHR5-R-0281.02

- **GIVEN** an item details row for EST-13 with list price 9.99 and unit cost 10.00 is present in the catalog
- **WHEN** the daily catalog check runs
- **THEN** EST-13 is reported as a breach of check C3

### Requirement: Locale normalisation and seed details

ID: SWHR5-R-0120
Recovered from: CDI-BR-0004
The system SHALL require every category, product and item loaded from the sample data to carry at least one set of localized details, and SHALL store the locale in underscore form (a seed language tag "en-US" is stored as "en_US").

#### Scenario: Hyphenated tag is normalised on load
ID: SWHR5-R-0120.01

- **GIVEN** catalog seed data whose category text carries language tag "en-US"
- **WHEN** the seed data is loaded
- **THEN** the category text is stored under locale "en_US"

#### Scenario: Seed record without localized details is refused
ID: SWHR5-R-0120.02

- **GIVEN** seed data containing a product with no localized details
- **WHEN** the seed data is loaded
- **THEN** the seed data is refused

### Requirement: Every category has a product (check C1)

ID: SWHR5-R-0117
Recovered from: CAT-BR-0001
Every category SHALL have at least one product. The daily catalog check SHALL report each category that has none (check C1) as a breach.

#### Scenario: Empty category is reported
ID: SWHR5-R-0117.01

- **GIVEN** category BIRDS exists and has no products
- **WHEN** the daily catalog check runs
- **THEN** BIRDS is reported as a breach of check C1

#### Scenario: Category with a product is not reported
ID: SWHR5-R-0117.02

- **GIVEN** category DOGS has product K9-BD-01
- **WHEN** the daily catalog check runs
- **THEN** DOGS is not reported under check C1

### Requirement: Four catalog rules hold at all times

ID: SWHR5-R-0074
Recovered from: CDI-BR-0001
The catalog SHALL satisfy four rules at all times: C1 every category has at least one product; C2 every product has at least one item; C3 an item's list price is never below its unit cost; C4 every item has an en_US description.

#### Scenario: A catalog breaking one rule is not valid
ID: SWHR5-R-0074.01

- **GIVEN** a catalog where every rule holds except that product K9-BD-01 has no item
- **WHEN** the four rules are evaluated
- **THEN** rule C2 is reported as broken for K9-BD-01 and rules C1, C3 and C4 hold

### Requirement: Migrated catalog satisfies C1 to C3

ID: SWHR5-R-0070
Recovered from: CATINT-BR-0001
The catalog SHALL satisfy these rules: every category has at least one product, every product has at least one item, and every item's list price is at or above its unit cost.

#### Scenario: Migrated sample catalog satisfies the rules
ID: SWHR5-R-0070.01

- **GIVEN** the migrated sample catalog
- **WHEN** the rules are evaluated
- **THEN** no category without a product, no product without an item and no item priced below cost is found

### Requirement: Every product has an item (check C2)

ID: SWHR5-R-0118
Recovered from: CAT-BR-0002
Every product SHALL have at least one item. The daily catalog check SHALL report each product that has none (check C2) as a breach.

#### Scenario: Product without items is reported
ID: SWHR5-R-0118.01

- **GIVEN** product K9-BD-01 exists and has no items
- **WHEN** the daily catalog check runs
- **THEN** K9-BD-01 is reported as a breach of check C2

### Requirement: Every product has an item (rule C2)

ID: SWHR5-R-0071
Recovered from: CATINT-BR-0002
The system SHALL ensure every product has at least one item (rule C2).

#### Scenario: Product with an item satisfies C2
ID: SWHR5-R-0071.01

- **GIVEN** product K9-BD-01 has item EST-6
- **WHEN** rule C2 is evaluated
- **THEN** K9-BD-01 is not reported

### Requirement: Every item has an en_US description (check C4)

ID: SWHR5-R-0065
Recovered from: CAT-BR-0004
Every item SHALL have a description in the en_US locale. The daily catalog check SHALL report each item without one (check C4) as a breach. Categories and products SHALL NOT be checked for an en_US description.

#### Scenario: Item without en_US details is reported
ID: SWHR5-R-0065.01

- **GIVEN** item EST-1 has details only in a locale other than en_US
- **WHEN** the daily catalog check runs
- **THEN** EST-1 is reported as a breach of check C4

#### Scenario: Product without en_US text is not reported
ID: SWHR5-R-0065.02

- **GIVEN** a product has no en_US text and all its items have en_US details
- **WHEN** the daily catalog check runs
- **THEN** no breach of check C4 is reported

### Requirement: C4 violation per item

ID: SWHR5-R-0066
Recovered from: CAT-BR-0005
Every item SHALL have a description in the en_US locale; the daily catalog check SHALL report each item without one as a C4 violation.

#### Scenario: Each offending item is listed
ID: SWHR5-R-0066.01

- **GIVEN** items EST-1 and EST-2 both lack en_US details
- **WHEN** the daily catalog check runs
- **THEN** EST-1 and EST-2 are each reported as a C4 violation

### Requirement: Every item has an en_US description (rule C4)

ID: SWHR5-R-0072
Recovered from: CATINT-BR-0004
The system SHALL ensure every item has an en_US description (rule C4).

#### Scenario: Item with en_US details satisfies C4
ID: SWHR5-R-0072.01

- **GIVEN** item EST-1 has details in locale en_US
- **WHEN** rule C4 is evaluated
- **THEN** EST-1 is not reported

### Requirement: en_US catalog locale

ID: SWHR5-R-0124
Recovered from: INTEG-BR-0001
The system SHALL require catalog text in the en_US locale, and the daily integrity check SHALL report every item that has no en_US description.

#### Scenario: Item lacking en_US text is reported
ID: SWHR5-R-0124.01

- **GIVEN** item EST-20 has no en_US details
- **WHEN** the daily integrity check runs
- **THEN** EST-20 is reported

### Requirement: Catalog totals are logged

ID: SWHR5-R-0067
Recovered from: CAT-BR-0006
The daily catalog check SHALL record the total number of categories and the total number of items in its log. The system SHALL NOT fail the check on these totals; no minimum is applied.

#### Scenario: Totals are logged on a clean run
ID: SWHR5-R-0067.01

- **GIVEN** a catalog of 5 categories and 28 items that satisfies checks C1 to C4
- **WHEN** the daily catalog check runs
- **THEN** the log records 5 categories and 28 items and the run succeeds

### Requirement: Totals are not judged

ID: SWHR5-R-0073
Recovered from: CATINT-REQ-0002
The daily catalog check SHALL record the total number of categories and the total number of items in its log, without judging them against any minimum.

#### Scenario: Low totals do not fail the check
ID: SWHR5-R-0073.01

- **GIVEN** a catalog of 1 category, 1 product and 1 item that satisfies checks C1 to C4
- **WHEN** the daily catalog check runs
- **THEN** the totals are logged and the run succeeds

### Requirement: Declared catalog minimums are not enforced

ID: SWHR5-R-0201
Recovered from: INTEG-BR-0002
The configuration declares that the catalog SHALL hold at least 5 categories and at least 28 items. The system SHALL NOT enforce or check these minimums; no write is refused and no check fails because a total is below them.

#### Scenario: Catalog below the declared minimums
ID: SWHR5-R-0201.01

- **GIVEN** a catalog of 4 categories and 20 items that satisfies checks C1 to C4
- **WHEN** the daily catalog check runs
- **THEN** the run succeeds and no breach is reported

### Requirement: Daily catalog integrity check

ID: SWHR5-R-0019
Recovered from: CATINT-WF-0005
The system SHALL run the catalog checks C1 to C4 every day at 06:00 and, WHEN any check finds offending rows, SHALL end with exit code 4, write the details to the catalog check log and alert the catalog team by mail.

#### Scenario: A check finds offending rows
ID: SWHR5-R-0019.01

- **GIVEN** the catalog contains a product with no items
- **WHEN** the daily catalog check runs at 06:00
- **THEN** the run ends with exit code 4, the offending product is written to the catalog check log, and the catalog team is alerted by mail

#### Scenario: No check finds offending rows
ID: SWHR5-R-0019.02

- **GIVEN** the catalog satisfies rules C1 to C4
- **WHEN** the daily catalog check runs at 06:00
- **THEN** the run ends successfully with exit code 0 and no alert is sent

### Requirement: Daily check log and exit codes

ID: SWHR5-R-0276
Recovered from: CAT-WF-0001
Every day at 06:00 the system SHALL run the catalog checks C1 to C4, append their results and the counts of categories and items to the catalog check log, and end with code 4 when any check finds a violating row, which SHALL raise an urgent mail to the catalog team; otherwise it SHALL end with code 0.

#### Scenario: Results are appended, not overwritten
ID: SWHR5-R-0276.01

- **GIVEN** the catalog check log already holds the previous day's results
- **WHEN** the daily catalog check runs
- **THEN** the new results and counts are appended after the previous ones

#### Scenario: Violation ends with code 4
ID: SWHR5-R-0276.02

- **GIVEN** category BIRDS has no products
- **WHEN** the daily catalog check runs
- **THEN** the run ends with code 4 and an urgent mail is sent to the catalog team

### Requirement: Check before the store opens

ID: SWHR5-R-0279
Recovered from: CAT-WF-0005
The system SHALL run the catalog checks C1 to C4 every day at 06:00, before the store opens. WHEN any check finds at least one breaching row, THEN the run SHALL end as failed with the "bad catalog data" outcome (code 4) and the catalog team SHALL be alerted, with the breaching rows written to the catalog check log. WHEN no check finds a row, THEN the run SHALL end successfully.

#### Scenario: Breach ends as failed
ID: SWHR5-R-0279.01

- **GIVEN** item EST-1 has no en_US details
- **WHEN** the check runs at 06:00
- **THEN** the run ends as failed with code 4 and the C4 row for EST-1 is in the catalog check log

### Requirement: Breaching rows and totals are logged

ID: SWHR5-R-0075
Recovered from: CDI-WF-0001
The system SHALL run the catalog integrity checks C1 to C4 every day at 06:00, SHALL log every breaching row together with the total number of categories and items, and WHEN any check returns a row THEN SHALL end the run with the "integrity breach" outcome (exit code 4) so that the catalog team is alerted.

#### Scenario: Breaching row is logged with its rule and code
ID: SWHR5-R-0075.01

- **GIVEN** product K9-BD-01 has no items and the catalog holds 5 categories and 27 items
- **WHEN** the daily check runs
- **THEN** the log carries a C2 row naming K9-BD-01 and the totals 5 and 27, and the run ends with exit code 4

### Requirement: First load when the catalog does not exist

ID: SWHR5-R-0277
Recovered from: CATINT-BR-0006
WHEN the daily catalog check finds that the catalog tables do not exist THEN the system SHALL request the first load of sample data and SHALL run the checks again.

#### Scenario: Missing catalog is loaded and re-checked
ID: SWHR5-R-0277.01

- **GIVEN** the catalog tables do not exist
- **WHEN** the daily catalog check runs
- **THEN** a first load of the sample data is requested, and checks C1 to C4 run again against the loaded catalog

### Requirement: Independent schedule and catalog team alert

ID: SWHR5-R-0280
Recovered from: CATI-REQ-0001
The system SHALL run the catalog integrity check every day from 06:00, independently of the nightly backup and audit chain, and GIVEN the check finds catalog data that breaks an integrity rule (job result code 4), THEN the system SHALL send an urgent e-mail to the catalog team pointing to the catalog check log.

#### Scenario: Breach raises an urgent mail without waiting for the backup
ID: SWHR5-R-0280.01

- **GIVEN** the nightly backup job has not completed
- **WHEN** the catalog integrity check runs at 06:00 and ends with result code 4
- **THEN** an urgent e-mail is sent to the catalog team naming the catalog check log

#### Scenario: Other result raises no catalog mail
ID: SWHR5-R-0280.02

- **GIVEN** the catalog integrity check ends with a result code other than 4
- **WHEN** the run completes
- **THEN** the catalog-integrity e-mail is not sent

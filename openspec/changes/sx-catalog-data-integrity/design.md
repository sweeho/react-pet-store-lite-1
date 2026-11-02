# Design notes: catalog-data-integrity (legacy implementation)

These notes record how the LEGACY Pet Store Lite implements the capability. They describe no target
design. Paths are relative to `legacy-source/j2ee-pet-store-lite/`.

## User interface

No screen records were extracted for this capability; its user interface is unspecified. The
capability is enforced by the database and by an unattended batch job. Its only human-facing outputs
are the catalog check log and the alert e-mail.

## Where the rules live

| Rule                                 | Legacy mechanism                                                                                                                                            | Source                                                                                                                                       |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Hierarchy, identifier uniqueness     | `pk_category`, `pk_product`, `pk_item`; `fk_product_1`, `fk_item_1`                                                                                         | `db/schema/petstore_derby.sql:11-48`, same in `petstore_oracle.sql`, and the create statements in `src/main/webapp/populate/PopulateSQL.xml` |
| One text entry per record and locale | composite PKs `(catid, locale)`, `(productid, locale)`, `(itemid, locale)`                                                                                  | `petstore_derby.sql:18, 37, 63`                                                                                                              |
| Text refers to an existing record    | `fk_category_details_1`, `fk_product_details_1`, `fk_item_details_1` (no cascade, so a parent with text cannot be deleted)                                  | `petstore_derby.sql:19-20, 38-39, 64-65`                                                                                                     |
| Field lengths and optionality        | `name varchar(80) not null`, `image`/`descn varchar(255)` (nullable on category/product, `not null` on item), `attr1..attr5 varchar(80)`                    | `petstore_derby.sql:14-62`                                                                                                                   |
| Price precision                      | `decimal(10,2) not null` (Derby), `number(10,2) not null` (Oracle)                                                                                          | `petstore_derby.sql:53-54`, `petstore_oracle.sql:53-54`                                                                                      |
| List price ≥ unit cost               | `ck_item_details_price check (listprice >= unitcost)`                                                                                                       | `petstore_derby.sql:66`, `petstore_oracle.sql:66`, `PopulateSQL.xml:132`                                                                     |
| Locale normalisation                 | seed loader replaces `-` with `_` in the locale attribute                                                                                                   | `src/main/java/com/sun/j2ee/blueprints/petstore/tools/populate/XMLDBHandler.java:180`                                                        |
| C1 to C4                             | four `SELECT` statements; any returned row is a breach                                                                                                      | `db/batch/catalog_check.sql:3-13`                                                                                                            |
| Totals                               | `COUNT(*)` of `category` and `item`, logged only                                                                                                            | `db/batch/catalog_check.sql:14-16`                                                                                                           |
| Daily run, exit codes, first load    | shell wrapper                                                                                                                                               | `batch/psl_catalog_check.sh:9-21`                                                                                                            |
| Schedule and alert                   | Control-M job `PSL_CATALOG_CHECK`, `TIMEFROM=0600`, `WEEKDAYS=ALL`, no `INCOND`, `ON CODE=COMPSTAT=4` → `DOMAIL URGENCY=U` to `psl-catalog@example.invalid` | `scheduler/control-m/PSL_PETSTORE.xml:62-71`                                                                                                 |
| Documented rule table                | Administrator Guide §3.3, Operations Runbook §3.5                                                                                                           | `docs/guides/admin-guide.html:91-99`, `docs/guides/operations-runbook.html:66-69`                                                            |

## Batch job behaviour (`psl_catalog_check.sh`)

1. Runs `catalog_check.sql` through Derby `ij`.
2. If the output contains `does not exist` (tables missing), calls
   `$PSL_STORE_URL/Populate?forcefully=false`. If that call fails, logs `FAILED: populate` and exits 8.
   Otherwise re-runs the SQL.
3. Appends the whole SQL output to `$PSL_LOG_DIR/catalog_check.log` (production path
   `/var/petstore/log/catalog_check.log`). The output holds breaching rows as `C<n> <code>` and the two
   totals.
4. If any line starts with `C1 ` to `C4 `, exits 4. Otherwise exits 0.

Control-M mails only on `COMPSTAT=4`. Exit 8 and any other failure raise no catalog mail; they surface
only as a failed job in Control-M. The job is `CRITICAL="1"`, priority `AA`, and runs as `tomcat` on
`psl-app01`.

## Gotchas found while synthesising

- **C3 is enforced twice.** The check constraint makes C3 unreachable for data written through the
  database; the batch query still exists and would only fire if the constraint were dropped or the
  data were bulk-loaded around it. Both are kept as requirements.
- **C1 and C2 are not enforced at write.** Nothing stops a category without products; only the daily
  check reports it.
- **C4 checks items only.** `catalog_check.sql:11-13` looks at `item_details` for `en_US`. Categories
  and products without `en_US` text are not reported. `CATDI-BR-0003` claims en_US text is required for
  all three levels; the code does not support that for categories and products.
- **Breach detection is text matching.** The wrapper greps `ij` output for `^C[1-4] ` and for
  `does not exist`. A rebuild should use the check results directly; the requirement is the outcome,
  not the grep.
- **Totals versus minimums.** `conf/petstore.properties:28-29` declares `catalog.minCategories=5` and
  `catalog.minItems=28`. No code reads them. The migrated sample data has exactly 5 categories and 28
  items (`data/migration/category.csv`, `data/migration/item.csv`), which suggests the keys describe
  the sample set rather than a live rule. Held for an SME.
- **Identifier type differs by dialect.** Derby (runtime) declares identifiers and locale as
  `char(10)` (blank-padded); Oracle (reference production) declares the identifier `varchar(10)`
  (`petstore_oracle.sql:10`). Data moved from Derby may carry trailing blanks. The requirement states
  only the 10-character limit; padding is held for an SME (`CDI-RULE-0006`).
- **`v_catalog_item` view** (`petstore_derby.sql:101-109`, `petstore_oracle.sql:112-120`) joins items to
  their product and category text in the same locale. No reader exists in the tree outside the
  byte-identical copies under `vortex/inputs/`, and `PopulateSQL.xml` does not create it. Not written
  as a requirement (`unresolved-reachability`).
- **Price range.** `decimal(10,2)` gives 8 integer digits, maximum 99,999,999.99. Pass records state it
  as "at most 10 digits in total"; both are the same constraint.

## Record-key collisions

Several record keys were minted independently by different shards and mean different things. The
server ingested 37 records against 41 distinct keys found in the pass files. Mapping used for the
delta spec:

| Requirement in `spec.md`                       | Contributing records (pass file)                                                                                                                                                                       |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Catalog hierarchy and identity                 | CDI-ENT-0001 (db/schema/a, populate/a, ddl-001/b), CATDI-ENT-0001, CDI-RULE-0002 (ddl-002/b), CDI-RULE-0004, CDI-ENT-0003 (ddl-002/c), CDI-BR-0001 (populate/b), CDI-BR-0002 (populate/b, db/schema/b) |
| Category and product display text per locale   | CDI-ENT-0001 (data/migration/b, populate/b), CDI-ENT-0002 (all), CDI-RULE-0003, CDI-BR-0001 (ddl-001/b), CDI-BR-0004 (populate/a), CATINT-ENT-0002                                                     |
| Item details per locale                        | CDI-ENT-0003 (data/migration/b, db/schema/a, populate/b), CDI-ENT-0004, CDI-RULE-0005, CDI-BR-0004 (populate/a)                                                                                        |
| Item price precision                           | CATDI-BR-0002, CDI-BR-0003 (populate/a), CDI-RULE-0002 (ddl-002/c), CDI-RULE-0005                                                                                                                      |
| List price never below unit cost               | CDI-RULE-0001, CATINT-BR-0003, CDI-BR-0001 (db/schema/b), CDI-BR-0002 (populate/a), CDI-BR-0003 (populate/b), CAT-BR-0003 (db/batch/a), CAT-BR-0004 (batch/a), CATDI-BR-0002                           |
| Localised text refers to an existing record    | CATDI-BR-0001, CDI-BR-0002 (db/schema/b, ddl-001/b)                                                                                                                                                    |
| Locale codes                                   | CDI-BR-0004 (populate/b), CDI-RULE-0006 (length only)                                                                                                                                                  |
| Rule C1                                        | CAT-BR-0001, CAT-BR-0002 (batch/a), CATINT-BR-0001, CDI-BR-0001 (db/batch/b, docs/guides/b, c, data/migration/b)                                                                                       |
| Rule C2                                        | CAT-BR-0002 (db/batch/a), CAT-BR-0003 (batch/a), CATINT-BR-0002, CDI-BR-0002 (db/batch/b)                                                                                                              |
| Rule C3 re-check                               | CAT-BR-0003 (db/batch/a), CAT-BR-0004 (batch/a), CDI-BR-0003 (db/batch/b)                                                                                                                              |
| Rule C4                                        | CAT-BR-0004 (db/batch/a), CAT-BR-0005, CATINT-BR-0004, CDI-BR-0004 (db/batch/b), INTEG-BR-0001, CATDI-BR-0003, CATINT-ENT-0002                                                                         |
| Daily catalog integrity check (`SWHR5-R-0019`) | CATINT-WF-0005 (approved); corroborated by CAT-WF-0001, CAT-WF-0005, CATINT-WF-0001, CDI-WF-0001                                                                                                       |
| Catalog check log content                      | CAT-BR-0006, CATINT-REQ-0002, CDI-WF-0001 (db/batch/b), CAT-WF-0001                                                                                                                                    |
| First load when the catalog does not exist     | CATINT-BR-0006, CDI-WF-0001 (docs/guides/b, c); exit 8 from `psl_catalog_check.sh:12`                                                                                                                  |
| Catalog team alert                             | CATI-REQ-0001, CATINT-REQ-0001                                                                                                                                                                         |

Not written as requirements: CATALOG-DATA-INTEGRITY-BR-0001, INTEG-BR-0002 (minimum counts),
CDI-RULE-0002 in db/schema/a (view), CDI-RULE-0006 padding aspect.

## Open questions for the SME

- Q1. Are the minimum counts (5 categories, 28 items) a rule the check should enforce, or a
  description of the sample data?
- Q2. Is `v_catalog_item` present in production, and does any report read it?
- Q3. Which database is live, and does any consumer compare identifiers including trailing blanks?
- Q4. Should C4 also require en_US text for categories and products, as one pass record claims and
  the Administrator Guide does not?

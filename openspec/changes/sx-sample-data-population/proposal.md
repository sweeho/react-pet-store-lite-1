# Sample data population (recovered from Java Pet Store Lite)

## Why

The legacy store fills its own database from a bundled sample data set. A visitor's first entry triggers the load, the daily catalog check job also triggers it when the tables are missing, and an administrator can force a full reload from the Catalog Administration page. A full reload deletes every account and all sign-on history, so who may trigger it, and what it destroys, are operational and access-control rules. They have to be carried into the rebuild exactly as stated. None of this is documented in one place: it is spread across the populate servlet, the table statement file, two JSPs, the batch chain and the admin guide.

## What Changes

- ADDED capability `sample-data-population`: 32 requirements recovered from the legacy code, configuration, batch scripts, seed data and guides.
- Two screens: the store entry page and the Catalog Administration page.
- One approved requirement: forced reload restricted to ADMIN (`SWHR5-R-0022`, from `POP-REQ-0003`). The other requirements are drafts awaiting SME review. Recommendations are in `legacy-analysis/ir/_recommendations/sample-data-population.yaml`.
- Disputed items carried as drafts for the Business Owner:
  - the session ends on every store entry, against the guide's "nothing happens";
  - the Oracle definitions do not generate the audit identifier;
  - the passes disagree on whether a structurally invalid data file is rejected or loaded with a log entry.
- Records whose content belongs to batch or operations were tagged to this capability by the extraction and are kept here as drafts: daily backup, batch retries, job log lines, restore procedure, and database location. The SME may re-home them.

## Impact

- Data: categories, products, items and their localized details, sign-on accounts, sign-on audit.
- Access control: the forced reload is ADMIN-only. The first load is open to anyone, including the batch job.
- Operations: the daily catalog check depends on the first-load address. A reload is destructive, and the guide pairs it with the backup job.

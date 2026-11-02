# Sample data population (recovered from Java Pet Store Lite)

## Why

The legacy store fills its own database from a bundled sample data set. A visitor's first entry triggers the load, the daily catalog check job also triggers it when the tables are missing, and an administrator can force a full reload from the Catalog Administration page. A full reload deletes every account and all sign-on history, so who may trigger it, and what it destroys, are operational and access-control rules. They have to be carried into the rebuild exactly as stated. None of this is documented in one place: it is spread across the populate servlet, the table statement file, two JSPs, the batch chain and the admin guide.

## What Changes

- ADDED capability `sample-data-population`: 32 requirements, one per SME-approved record, recovered from the legacy code, configuration, batch scripts, seed data and guides. Each carries its approved requirement key.
- Two screens: the store entry page (`SDP-SCR-0001`) and the Catalog Administration page (`POP-SCR-0002`).
- Records not yet approved are left out of the spec. Recommendations for them are in `legacy-analysis/ir/_recommendations/sample-data-population.yaml`.
- Behaviour that contradicts the guide is carried as approved, with the conflict noted in `design.md` for the Business Owner: the session ends on every accepted population request, against the guide's "nothing happens" (`POP-BR-0003`).

## Impact

- Data: categories, products, items and their localized details, sign-on accounts, sign-on audit.
- Access control: the forced reload is ADMIN-only. The first load is open to anyone, including the batch job.
- Operations: the daily catalog check depends on the first-load address. A reload is destructive, and the guide pairs it with the backup job.

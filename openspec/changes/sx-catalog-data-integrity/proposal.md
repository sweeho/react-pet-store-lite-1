# Proposal: catalog-data-integrity (recovered from the legacy Pet Store Lite)

## Why

The legacy store keeps its catalog consistent in two places that nobody documented together: database
constraints that refuse bad data at write time, and a daily 06:00 batch check (C1 to C4) that reports
the rules the database cannot enforce and alerts the catalog team. A rebuild that carries over only the
tables loses the check, and one that carries over only the check loses the price guard. This change
states both as one capability so the rebuild keeps them.

## What changes

- ADDED the catalog structure rules: three-level hierarchy, identifier rules, per-locale display text
  and item details, monetary precision, referential integrity and locale code form.
- ADDED the price guard: a list price is never below the unit cost (refused at write, re-checked daily).
- ADDED the four checked catalog rules C1 to C4.
- ADDED the daily catalog integrity check, its log, its first-load behaviour on an empty database, and
  the catalog team alert.

## Scope

In scope: the 41 IR record keys tagged `catalog-data-integrity` (the server reports 37; several keys
are reused across pass files with different content, see `design.md`). One record is approved
(`CATINT-WF-0005` → `SWHR5-R-0019`); every other requirement in the delta spec is a draft without an
`ID:` line.

Out of scope, held for an SME decision (not written as requirements):

- Minimum catalog size of 5 categories and 28 items (`CATALOG-DATA-INTEGRITY-BR-0001`, `INTEG-BR-0002`).
- The combined catalog-item view (`CDI-RULE-0002` in `db/schema/a.yaml`), which has no reader.
- Fixed-width versus variable-width identifier storage (`CDI-RULE-0006`).

Catalog browsing, the populate/reload administration and the catalog page size belong to other
capabilities.

## Impact

- No screen records were extracted for this capability.
- The rebuild must carry the price guard as a data-layer constraint and the C1 to C4 check as a
  scheduled job with an alert path.

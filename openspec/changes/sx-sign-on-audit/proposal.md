# Proposal: sx-sign-on-audit

## Why

The legacy Java Pet Store Lite records every sign-in outcome, lock, unlock, sign-out and new
account in a sign-on audit log, shows each user their recent entries on My Account, exports the
previous day's entries to the security team every night, reports daily statistics and purges
entries older than 90 days every Sunday. The rules are spread across the schema, the data access
code, one page, four scheduled jobs and the operations runbook. The rebuild needs them stated as
testable requirements so the security team's file and the user's view keep working.

## What changes

Adds the `sign-on-audit` capability, recovered from spec extraction SX-0001:

- Approved: the audit entry shape (`SWHR5-R-0010`), the Sunday purge after a successful extract
  (`SWHR5-R-0011`) and the daily extract file (`SWHR5-R-0012`).
- Draft requirements awaiting SME decision: closed event-type set, system-assigned event number,
  user name as typed, the events written per sign-on outcome, the two-event lock, USER_CREATED,
  explicit-only SIGNOFF, audited automatic unlock, origin field content, extract line format,
  trailer, previous-day-only extract, extract failure handling, daily report, purge cutoff and
  indexed retrieval.
- Four screen requirements for My Account: page access, identity display, recent activity
  selection and recent activity rows.

## Impact

- Spec: `specs/sign-on-audit/spec.md` (23 requirements: 3 approved, 16 draft, 4 screens).
- Related capabilities: sign-on, account lockout, account registration and access control produce
  or gate the events; this change covers only what is recorded, shown, exported and purged.
- Open items: the Oracle populate DDL id-generation dispute and low-confidence format details,
  recorded in `legacy-analysis/ir/_recommendations/sign-on-audit.yaml`.

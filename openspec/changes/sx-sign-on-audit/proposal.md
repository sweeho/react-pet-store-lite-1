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

- All 48 records of the capability are approved and each is written as one requirement carrying
  its key: the audit entry fields and closed event-type set, the system-assigned event number,
  user name as typed, the events written per sign-on outcome, the two-event lock, USER_CREATED,
  explicit-only SIGNOFF, audited automatic unlock, origin field content, 90-day retention and the
  Sunday purge, the daily extract file (content, line format, trailer, empty day, previous-day
  window, rerun, location, failure alert), the daily statistics report, and indexed retrieval.
- Four screen requirements for My Account: the page itself, the sign-in gate and identity
  display, recent activity selection and recent activity rows.

## Impact

- Spec: `specs/sign-on-audit/spec.md` (48 approved requirements, 4 of them screens).
- Related capabilities: sign-on, account lockout, account registration and access control produce
  or gate the events; this change covers only what is recorded, shown, exported and purged.
- Open items: the Oracle populate DDL id-generation dispute and low-confidence format details,
  recorded in `legacy-analysis/ir/_recommendations/sign-on-audit.yaml`.

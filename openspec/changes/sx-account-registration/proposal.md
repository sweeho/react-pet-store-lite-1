# Proposal: sx-account-registration

## Why

The legacy Pet Store Lite application lets an anonymous visitor create their own customer account from the Sign In page. The rebuild must reproduce that self-service sign-up: the field rules and their exact messages, the order in which they are checked, the duplicate-name refusal, the fixed CUSTOMER role, the immediate sign-in, the account-created audit event and the screens a visitor sees along the way. This change records that behaviour as recovered from the legacy source (SX-0001), so it can be built and verified against.

## What Changes

- ADDED: user-name rules (trimmed length 3 to 25; letters, digits, `-` and `_` only; unique, case-sensitive).
- ADDED: password rules (4 to 25 characters, spaces counted; repeated entry must match).
- ADDED: check order and first-failure-only reporting.
- ADDED: initial state of a self-registered account (CUSTOMER role, 0 failed sign-ons, unlocked, creation time) and the bar on creating an administrator through sign-up.
- ADDED: immediate sign-in and redirect to the originally requested page or the home page.
- ADDED: account-created audit event at the account's creation time.
- ADDED: the account record's stored attributes and their constraints.
- ADDED: three screen requirements: the sign-up form on the Sign In page, the refusal page body, and the "Create Account Error" page itself.

## Capabilities

- `account-registration` (new): self-service creation of customer accounts.

## Impact

- Shares the account record with sign-on and account lockout; the lock and last-sign-on attributes are written by those capabilities, not this one.
- Shares the audit log with sign-on; this capability writes only the account-created event.
- Open questions for SMEs and the Business Owner (password bounds redacted in the extraction copy, plaintext password storage, non-ASCII letters accepted in user names) are listed in `design.md` and in `legacy-analysis/ir/_recommendations/account-registration.yaml`.

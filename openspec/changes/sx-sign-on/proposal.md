# Proposal: sx-sign-on

## Why

The legacy Java Pet Store Lite signs customers and administrators in and out through a
request filter, a JDBC account store, a sign-out servlet and four pages (Sign In, Sign-in
Error, Welcome, signed out) plus the shared banner. The rules are spread over Java code,
deployment descriptors, configuration, the user and admin guides and the account data
itself. None of it is written down as one specification. The rebuild needs the behaviour
stated as testable requirements so returning customers keep the sign-in experience they
have today.

## What changes

Adds the `sign-on` capability, recovered from spec extraction SX-0001:

- All 34 approved sign-on records, each written as one requirement carrying its key: the
  case-sensitive credential check (and its restatements from the guides and samples), account
  record and sign-in timestamps, failure-count reset on success, readable password storage,
  existing user names containing ".", return to the requested page, the banner Sign in link
  through the Welcome page, the refused-sign-in and account-store-failure paths, Remember My
  User Name, sign out, and the 15-minute inactivity timeout.
- Five screen requirements: the Sign In returning-customer form, the Sign-in Error page,
  the Sign-in Error try-again link, the signed-out page and the banner sign-in status.

## Impact

- Spec: `specs/sign-on/spec.md` (34 approved requirements, 5 of them screens).
- Related capabilities specified separately: account-lockout (failure counting, the lock,
  the Account Locked page), account-registration (sign-up form and the full account record)
  and access-control (protected pages, role checks, sign-in interception).
- Two items need a Business Owner decision through Intent: readable (unhashed) password
  storage, and whether user names containing "." stay valid.
- Open items for the SME are recorded in `legacy-analysis/ir/_recommendations/sign-on.yaml`.

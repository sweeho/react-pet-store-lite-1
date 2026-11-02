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

- Refused sign-in shows the sign-in error page and does not sign the user in (approved,
  `SWHR5-R-0023`).
- The Sign-in Error page does not disclose whether the user name or the password was wrong
  (approved, `SWHR5-R-0024`).
- Sign out records the sign-off, ends the session and shows the signed-out page, also
  without a session (approved, `SWHR5-R-0009`).
- Draft requirements awaiting SME decision: the case-sensitive credential check, account
  updates and audit events on sign-in, the signed-in session, return to the requested page,
  Remember My User Name, the 15-minute inactivity timeout, the account-store failure path,
  UTF-8 request decoding, readable password storage, account sign-on timestamps, and
  (disputed) existing user names containing ".".
- Five screen requirements: the Sign In returning-customer form, the Sign-in Error page,
  the signed-out page, the banner sign-in status and the sign-in Welcome page.

## Impact

- Spec: `specs/sign-on/spec.md` (20 requirements: 3 approved, 12 draft rules, 5 screens).
- Related capabilities specified separately: account-lockout (failure counting, the lock,
  the Account Locked page), account-registration (sign-up form and the full account record)
  and access-control (protected pages, role checks, sign-in interception).
- Two items need a Business Owner decision through Intent: readable (unhashed) password
  storage, and whether user names containing "." stay valid.
- Open items for the SME are recorded in `legacy-analysis/ir/_recommendations/sign-on.yaml`.

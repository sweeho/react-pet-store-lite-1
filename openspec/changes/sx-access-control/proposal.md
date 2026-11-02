# Proposal: sx-access-control

## Why

The legacy Java Pet Store Lite decides who may open which page from three sources: a role
stored with each account, a declarative list of protected pages, and a request filter that
intercepts every request. A separate programmatic check guards the forced reload of sample
data, and the shared banner shows or hides the administration link by role. None of this is
written down as one specification. The rebuild needs the behaviour stated as testable
requirements so it can match what customers and administrators experience today.

## What changes

Adds the `access-control` capability, recovered from spec extraction SX-0001:

- Account role domain: exactly one role per account, CUSTOMER or ADMIN, CUSTOMER by default
  (approved, `SWHR5-R-0001`).
- Page access matrix: open catalog pages, sign-in-only My Account, ADMIN-only Catalog
  Administration (approved, `SWHR5-R-0002`).
- Draft requirements awaiting SME decision: the exhaustive protected-page set, sign-in
  interception with return to the requested page, the per-page role check, role held for
  the session, self-registered accounts as CUSTOMER, the ADMIN-only forced reload, the open
  first load, and single-application deployment.
- Three screen requirements: the Access Denied page, the banner Admin link and the banner
  Account link.

## Impact

- Spec: `specs/access-control/spec.md` (13 requirements: 2 approved, 8 draft rules, 3 screens).
- Related capabilities: sign-on (credential check, lockout, sign-out) and sample-data
  population are specified separately; this change covers only the authorisation decisions
  they depend on.
- Open items for the SME are recorded in
  `legacy-analysis/ir/_recommendations/access-control.yaml`.

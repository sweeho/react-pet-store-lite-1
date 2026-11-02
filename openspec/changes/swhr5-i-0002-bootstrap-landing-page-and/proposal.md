# Bootstrap, landing page and shared site shell

## Why

Every capability in "Pet Store Lite Modernisation" needs one place to start from and one frame to sit in. Without a shared shell each capability invents its own navigation, header and layout, and nothing owns the landing page.

## What Changes

- Stand up the application boilerplate this initiative builds on, or extend the one that exists.
- Add the landing page every user arrives at.
- Add the shared site shell: global navigation, header, footer and page layout that every capability's screens render inside.
- Add the shared empty, error and loading frames every page reuses.

## Impact

- Every other capability in this initiative depends on this one and is released after it ships.
- The global navigation carries one entry per primary area:

- Catalog browsing (`catalog-browsing`)
- Catalog search (`catalog-search`)
- Sign-on and sign-off (`sign-on`)
- Account lockout (`account-lockout`)
- Account registration (`account-registration`)
- Access control (`access-control`)
- Sign-on audit trail (`sign-on-audit`)
- Sample data population (`sample-data-population`)

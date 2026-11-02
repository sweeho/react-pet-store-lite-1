# Design notes: sign-on (legacy implementation)

These notes record how the legacy Java Pet Store Lite implements sign-on and sign-off. They
describe the old system only; the target design is drafted separately once the Product
Requirement is approved. The visible behaviour is specified in `specs/sign-on/spec.md`;
nothing here restates it.

## Sources read

All paths are under `legacy-source/j2ee-pet-store-lite/`.

| Concern                              | Legacy location                                                                                                                                                   |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Sign-in handling                     | `src/main/java/com/sun/j2ee/blueprints/signon/web/SignOnFilter.java` (`validateSignOn`, lines 163-228), mapped to `/*` in `WEB-INF/web.xml`                       |
| Credential check and account updates | `signon/dao/UserDAO.java` `authenticate` (lines 108-160), SQL constants lines 87-100                                                                              |
| Sign-out                             | `signon/web/SignOffServlet.java:58-78`, mapped to `signoff.do` in `web.xml:113-116`                                                                               |
| Page names                           | `WEB-INF/signon-config.xml` (`signon.screen` login page, `signon_error.screen` error page, protected `signon_welcome.screen`)                                     |
| Page titles and layout               | `WEB-INF/screendefinitions_en_US.xml:48-89` (`signon`, `signon_welcome`, `signon_error`, `signoff`)                                                               |
| Page bodies                          | `signon.jsp`, `signon_failed.jsp`, `signoff.jsp`, `banner.jsp:19-30`                                                                                              |
| Session timeout                      | `web.xml:123-125` (`session-timeout 15`), `conf/petstore.properties:21`                                                                                           |
| Remember-me cookie                   | `conf/petstore.properties:22-23`; `SignOnFilter.java:172-192`                                                                                                     |
| Request decoding                     | `encodingfilter/web/EncodingFilter.java:61-78`, ordered before the sign-on filter in `web.xml:19-48`                                                              |
| Schema                               | `db/schema/petstore_derby.sql:69-82` and `petstore_oracle.sql` (`SIGNON`, `SIGNON_AUDIT`)                                                                         |
| Data evidence                        | `data/migration/signon.csv`, `signon_audit.csv`; `data/seed/signon_history.sql`; `vortex/samples/signon_decision_cases.csv`, `signon_audit_events_anonymised.csv` |
| Documentation                        | `docs/guides/user-guide.html` sections 5.2 and 6, `admin-guide.html` rules R1 and R8                                                                              |

## Sign-in sequence

1. The Sign In form posts `j_username`, `j_password` and the optional `j_remember_username`
   to `j_signon_check`. `SignOnFilter.doFilter` intercepts that path before any page logic.
2. The cookie step runs **before** authentication: ticked writes `bp_signon=<typed name>`
   with max-age 2 678 400; unticked expires any `bp_signon` cookie. Because it runs first,
   a refused or locked attempt still writes or clears the cookie. The cookie has no path,
   domain or secure attributes set.
3. `UserDAO.authenticate(userName, password, remoteAddr)`:
   - `select ... from signon where username = ?` (exact match). No row: audit `SIGNON_FAIL`
     against the typed name, return `SIGNON_INVALID`. No account is touched.
   - Locked (`LOCKED = 'Y'`): audit `SIGNON_LOCKED`, return `SIGNON_LOCKED`. The password is
     not compared.
   - `storedPassword.equals(password)`: `update signon set failed_attempts = 0,
last_signon = ?`, audit `SIGNON_OK`.
   - Otherwise the failure counter and lock are updated (account-lockout capability).
4. On `SIGNON_OK` the filter calls `getRole`, stores `j_signon_username`, `j_signon_role`
   and `j_signon = TRUE` in the HTTP session, then redirects to the session attribute
   `j_signon_original_url` or `main.screen`. The original URL is only set when an
   anonymous request hits a protected pattern, and is not cleared after use.
5. `SIGNON_LOCKED` redirects to `signon_locked.screen` (account-lockout capability);
   `SIGNON_INVALID` redirects to the configured error page `signon_error.screen`.
6. A `UserDAOException` (any `SQLException`) is rethrown as `ServletException`, which the
   container turns into a generic HTTP 500. No `error-page` mapping for it was found.

Case sensitivity of the user name depends on database collation. Derby's default is
case-sensitive and the sample decision case S08 confirms it; the Oracle variant was not
checked at runtime.

## Sign-out sequence

`SignOffServlet.doGet` (and `doPost`, which delegates to it) takes the session without
creating one. If a session exists and holds `j_signon_username`, `UserDAO.recordSignOff`
writes a `SIGNOFF` audit row; an exception there is only logged to stderr and sign-out
continues. The session is invalidated and the browser redirected to `signoff.screen`.

## Pages

- `signon.screen` renders `signon.jsp` inside the shared template (banner, sidebar,
  footer). The same page also carries the sign-up form posting to `createuser.do`, which
  belongs to account-registration. The returning-customer pre-fill reads the `bp_signon`
  cookie through JSTL; the literal default `j2ee` is hard-coded in the markup.
- `signon_error.screen` renders `signon_failed.jsp`. Its "try again" link points at
  `signon_welcome.screen`, a protected page, so the filter shows the Sign In page and a
  later success lands on the Welcome page.
- `signon_welcome.screen` reuses `main.jsp` (the home content) under the title "Welcome".
  It is in `signon-config.xml` only so that following the banner link forces a sign-in.
- `signoff.screen` renders `signoff.jsp`.
- The browser titles ("Sign On", "Sign On Error", "Sign Off") differ from the on-page
  headings ("Sign In", "Sign-in Error", "You are signed out.").
- `banner.jsp` tests the session attribute `j_signon` to choose between "Signed in as" plus
  `signoff.do` and the `signon_welcome.screen` link.

## Data

`SIGNON` columns used here: `USERNAME VARCHAR(25)` primary key, `PASSWORD VARCHAR(25)`
(plain text), `FAILED_ATTEMPTS`, `LOCKED`, `LAST_SIGNON TIMESTAMP` (nullable),
`CREATED_TS TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL`. The full account record is
specified under account-registration. `SIGNON_AUDIT` holds `USERNAME`, `EVENT_TYPE`
(`SIGNON_OK`, `SIGNON_FAIL`, `SIGNON_LOCKED`, `ACCOUNT_LOCKED`, `SIGNOFF`, `USER_CREATED`),
`EVENT_TS` and `REMOTE_ADDR`. In the migration and seed extracts `LAST_SIGNON` equals the
latest `SIGNON_OK` time for every account sampled.

## Evidence quality and open points

- **Approved-key ambiguity.** Record keys repeat across modules, and the platform holds one
  record per key. Where a key has several pass-file variants, `spec.md` uses the variant that
  matches the cluster the key was approved in: `SIGN-ENT-0001`, `SIGNON-REQ-0001`,
  `SIGNON-REQ-0003` and `SIGNON-REQ-0005` from the signon module; `SIGN-BR-0001` from
  docs/guides pass b and `SIGN-BR-0002` from conf pass a; `SIGNON-BR-0002`, `-0003`, `-0004`
  and `SIGNON-ENT-0001` from data/migration pass a; `SIGNON-BR-0001` and `SIGNON-REQ-0006`
  from docs/guides pass a; `SIGN-SCR-0001` from webapp pass a (the Sign In form, not the waf
  page-title list). If an SME meant a different variant, only that requirement's text moves.
  Behaviour of the unused variants (UTF-8 request decoding, the signed-in session holding
  user name and role, unknown-user audit events) is not specified in this change.
- **Readable passwords** (`SIGNON-BR-0004`, `SIGNON-BR-0007`, `SIGN-ENT-0001` docs/guides):
  the admin guide states it and the code compares with `String.equals`. Whether the rebuild
  keeps it is a Business Owner decision through Intent; migrating the existing passwords
  depends on it.
- **User names with "."** (`SIGNON-BR-0003`, disputed `conflicting-sources`): 17 of 44
  migrated accounts carry one and were self-registered, while today's registration
  validator refuses it.
- **Unknown-user audit trail**: a failed attempt for an unknown name is written to
  `SIGNON_AUDIT` against the typed name, so the audit table holds user names with no
  account.
- **Sign-off audit**: the sample events show `SIGNOFF` only after a `SIGNON_OK`
  (`SIGNON-BR-0004`, low confidence); the code guarantees it only because the session user
  is set on success alone.
- `vortex/samples/a.yaml` `SIGN-BR-0001` carries two user-guide traces with no line range;
  its claim is covered by the decision-case CSV.

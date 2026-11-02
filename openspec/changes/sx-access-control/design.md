# Design notes: access-control (legacy implementation)

These notes record how the legacy Java Pet Store Lite implements access control. They
describe the old system only; the target design is drafted separately once the Product
Requirement is approved. The visible behaviour is specified in
`specs/access-control/spec.md`; nothing here restates it.

## Sources read

| Concern             | Legacy location                                                                                                                                                                          |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Role column         | `db/schema/petstore_derby.sql` (and the Oracle dialect, `PopulateSQL.xml`): `SIGNON.ROLE VARCHAR(10) DEFAULT 'CUSTOMER' NOT NULL`, `CHECK ck_signon_role (role IN ('CUSTOMER','ADMIN'))` |
| Role constants      | `signon/dao/UserDAO.java:75-76` (`ROLE_CUSTOMER`, `ROLE_ADMIN`); `createUser` always inserts `ROLE_CUSTOMER` (line 184)                                                                  |
| Protected pages     | `src/main/webapp/WEB-INF/signon-config.xml`: `account.screen`, `signon_welcome.screen` (no auth-constraint), `populate_admin.screen` (auth-constraint `ADMIN`)                           |
| Enforcement         | `signon/web/SignOnFilter.java`, mapped to `/*` in `web.xml`                                                                                                                              |
| Config loading      | `signon/web/SignOnDAO.java` parses `signon-config.xml` once at filter init into `ProtectedResource` objects                                                                              |
| Forced reload guard | `petstore/tools/populate/PopulateServlet.java:113-125`                                                                                                                                   |
| Access Denied page  | `access_denied.jsp`, screen `access_denied` in `WEB-INF/screendefinitions_en_US.xml:97-101`                                                                                              |
| Banner              | `src/main/webapp/banner.jsp`                                                                                                                                                             |
| Deployment          | `Dockerfile` runtime stage; `docs/guides/operations-runbook.html`                                                                                                                        |
| Documentation       | `docs/guides/admin-guide.html` sections 1, 1.1 (access matrix), 3.1, 4 (configuration table); `docs/guides/user-guide.html` section 6 (messages table)                                   |

## How the filter decides

1. `SignOnFilter.doFilter` strips everything up to the first `/` after the context root
   (line 117) and compares the remainder with each `url-pattern` by exact string equality
   (lines 151, 235). There is no wildcard or prefix matching. A path with an extra segment
   or a different case does not match and is served unprotected.
2. Not signed in and the path matches: the filter stores the full requested URL in session
   attribute `j_signon_original_url` and _forwards_ (server-side, the address bar keeps the
   requested URL) to `signon.screen` (lines 151-154).
3. Signed in and the path matches: `isRoleAllowed` (lines 244-246) allows the request when
   the resource lists no roles, otherwise only when the session role is in the list. On
   failure it forwards to `/access_denied.screen` (lines 135-136).
4. On a successful sign-in POST to `j_signon_check`, the filter calls `UserDAO.getRole`
   once, stores the trimmed value in session attribute `j_signon_role` (line 210), and
   redirects to `j_signon_original_url`, falling back to `main.screen`
   (`DEFAULT_TARGET_URL`, line 80; lines 216-219). The role is never re-read during the
   session, which is why a role change takes effect only at the next sign-in.
5. `CreateUserServlet` (lines 86-93) sets the same session attributes with role
   `CUSTOMER` directly, without re-reading the database, and redirects to the remembered
   URL the same way.

The banner's "Sign in" link points at `signon_welcome.screen`, which is itself a protected
page; the Sign In page is reached by interception, not by a direct link.

## Forced reload

`PopulateServlet.doGet` delegates to `doPost`. When the `forcefully` parameter is `true`
and session `j_signon_role` is not `ADMIN` (anonymous included), it redirects (client-side,
unlike the filter's forward) to `access_denied.screen` and returns before the session is
invalidated or `populate()` runs. The `/Populate` URL itself is not in `signon-config.xml`,
so a non-forced first load is open to everyone; the code comment at lines 118-120 records
that intent. `index.jsp` links anonymous visitors to `populating.jsp`, which requests
`Populate?forcefully=false`.

## Screens

- `access_denied.jsp` is rendered in the shared template (banner, side index, footer) via
  the `access_denied` screen definition. Its copy hard-codes "store administrators only",
  which is accurate only because `ADMIN` is the sole role used in any auth-constraint. A
  future second restricted role would make the copy wrong.
- `banner.jsp` wraps the `populate_admin.screen` link in
  `<c:if test="${j_signon_role == 'ADMIN'}">`; the `account.screen` link is unconditional.

## Deployment shape

The Dockerfile runtime stage deletes everything under Tomcat's `webapps` directory (ROOT,
manager, host-manager, docs, examples) before deploying `petstore.war` at context
`/petstore` on port 8080. Pass A filed this under access-control because removing the
default consoles is its only access-relevant effect; it may belong with a deployment
capability instead (see the recommendation file).

## Evidence quality and open points

- Role domain: DDL CHECK + default in both dialects, Java constants, seed data and the Admin
  Guide agree. The migration extract holds 42 or 43 CUSTOMER accounts (passes differ by one)
  and 1 ADMIN (the seeded `admin`).
- Page matrix: declarative config, filter code and the Admin Guide matrix agree.
- Self-registration as CUSTOMER: the code is explicit (`createUser` inserts
  `ROLE_CUSTOMER`); the migration passes inferred it from 40/40 self-registered accounts.
- Exact-string URL matching is a possible legacy weakness (a request path variant bypasses
  protection). Whether the rebuild should keep it is a Business Owner decision; no record
  states it as a requirement.
- No record carries a `dispute` block.

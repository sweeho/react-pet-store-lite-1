# Design notes: account-registration (legacy implementation)

These notes record how the LEGACY Pet Store Lite application implements self-service account creation. They are evidence for the requirements in `specs/account-registration/spec.md`, not a design for the rebuild.

## Request path

| Step        | Legacy artefact                                                              | Notes                                                                                                                                                  |
| ----------- | ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Form        | `signon.jsp` lines 63-104, form `newcustomer`                                | Second form on the Sign In page; posts `j_username`, `j_password`, `j_password_confirm` to `createuser.do`. No form bean; raw request parameters.      |
| Mapping     | `WEB-INF/web.xml` lines 108-111                                              | `createuser.do` -> `CreateUserServlet`.                                                                                                                |
| Validation  | `CreateUserServlet.validate()` lines 102-120                                 | Programmatic, early-return; no `validation.xml`.                                                                                                       |
| Persistence | `UserDAO.createUser()` lines 172-188                                         | SELECT by user name, throw `DuplicateUserException` if found, then `INSERT_USER`, then `audit(..., USER_CREATED, remoteAddr)`.                         |
| Success     | `CreateUserServlet.doPost()` lines 85-93                                     | Sets session attributes `j_signon_username`, `j_signon_role=CUSTOMER`, `j_signon=true`; redirects to session `j_signon_original_url` or `main.screen`. |
| Failure     | `CreateUserServlet.doPost()` lines 76-81, 94-96                              | Puts the message in session attribute `j_user_creation_error` and redirects to `user_creation_error.screen`.                                           |
| Error page  | `WEB-INF/screendefinitions_en_US.xml` lines 76-82; `user_creation_error.jsp` | Screen `user_creation_error`, title "Create Account Error", standard banner/sidebar/footer template, body prints the session message.                  |

`UserDAOException` (any SQL error) is rethrown as `ServletException`; there is no user-facing message for it beyond the container's error handling.

## Constants and configuration

- `UserDAO.MIN_USERNAME_LENGTH = 3`, `MAX_USERNAME_LENGTH = 25` (lines 70-71); mirrored, but never read, by `conf/petstore.properties` `signon.username.minLength/maxLength` (lines 17-18).
- `UserDAO.MIN_PASSWORD_LENGTH` / `MAX_PASSWORD_LENGTH` (lines 72-73) and `signon.password.minLength/maxLength` (properties lines 19-20) are REDACTED in the extraction copy. The values 4 and 25 come from the `CreateUserServlet` class comment (lines 55-59), the sign-up hint on `signon.jsp` (lines 100-103), User Guide 5.1 (line 111) and the `SIGNON.PASSWORD varchar(25)` column. An SME must confirm the unredacted values.
- `UserDAO.ROLE_CUSTOMER = "CUSTOMER"`, bound explicitly by `INSERT_USER`; the request never supplies a role.

## Validation details implied by the code

- The length check uses `userName.trim().length()`; the character check walks the UNTRIMMED value. A name with surrounding spaces therefore passes the length check and fails the character check.
- The character check uses `Character.isLetterOrDigit`, which accepts non-ASCII letters and digits (for example accented letters). Whether that is intended is not stated anywhere; it is a Business Owner question.
- The password length check does not trim; spaces count.
- Order: user-name length, user-name characters, password length, confirmation, then (in the DAO) duplicate name. Only the first failure is reported. The order is implicit in statement sequence; no document states it.
- The user name is stored as submitted (not trimmed). Since spaces are refused by the character check, this has no visible effect.
- Duplicate detection is a SELECT-then-INSERT with no lock; `pk_signon` on `SIGNON.username` is the backstop. A concurrent duplicate would surface as `UserDAOException` -> `ServletException`, not as the "already taken" message.

## Data model (legacy)

Table `SIGNON` (`db/schema/petstore_derby.sql` lines 70-82, `petstore_oracle.sql` lines 70-79, repeated in `populate/PopulateSQL.xml` lines 149-165):

- `username varchar(25) not null`, primary key `pk_signon` (plain VARCHAR comparison, hence case-sensitive).
- `password varchar(25) not null` — stored as entered.
- `role varchar(10) default 'CUSTOMER' not null`, CHECK in (`CUSTOMER`, `ADMIN`).
- `failed_attempts integer default 0`, `locked char(1)` CHECK in (`Y`,`N`) default `N`, `locked_ts` (null unless locked), `last_signon` (null until first successful sign-on) — written by sign-on and lockout, not by registration.
- `created_ts timestamp default current_timestamp not null`; `INSERT_USER` supplies it explicitly from the application clock.

Table `SIGNON_AUDIT`: `createUser` writes one `USER_CREATED` row with the remote address. The audit timestamp is taken separately from `created_ts`; in the migration extract all 40 self-registered accounts have `event_ts` exactly equal to `created_ts` (`data/migration/signon_audit.csv`, `signon.csv`). The three sample accounts (`j2ee`, `shopper`, `admin`) are loaded by the populate script and have no `USER_CREATED` row.

The registration path does NOT call `UserDAO.authenticate`, so no `SIGNON_OK` event is written and `last_signon` stays empty after sign-up.

## Suspected legacy defects and open questions

1. **Plaintext passwords** (REG-REQ-0004). `INSERT_USER` binds the raw password; `authenticate` compares with `String.equals`; Admin Guide line 45 confirms "Passwords are stored as entered in table SIGNON". This is recorded as observed behaviour, not as a requirement for the rebuild; whether to keep it is the Business Owner's decision in the defect register.
2. **Redacted password bounds** (REG-BR-0003 and related). Settled by an SME reading the unredacted constants.
3. **Non-ASCII letters in user names**. The code accepts them; the hint text says "letters". Business Owner decision.
4. **Observed migration data** (ACCTREG-BR-0001). All 43 existing user names are lowercase `[a-z0-9._]` of 4-11 characters. The `.` character is NOT accepted by the current sign-up rule, so at least some existing names could not be re-registered today; migration must load existing accounts without re-applying the sign-up validation.

## Screen-record mapping

The three screen records map to the three screen requirements in the spec: the sign-up form on the Sign In page (`signon.jsp`), the refusal message body (`user_creation_error.jsp`), and the page definition that wraps it in the standard layout (`screendefinitions_en_US.xml`, title "Create Account Error").

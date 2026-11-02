## 1. Data model

- [ ] 1.1 Define the account record with user name, password, role, failed sign-on count, locked flag, lock time, last sign-on time and creation time
- [ ] 1.2 Enforce a unique, case-sensitive user name of at most 25 characters at the store level
- [ ] 1.3 Constrain role to CUSTOMER or ADMIN and default the creation time to the moment of storage
- [ ] 1.4 Generate and commit the migration for the account record
- [ ] 1.5 Add the account-created event type to the audit log record

## 2. Validation rules

- [ ] 2.1 Implement the trimmed user name length check (3 to 25) with its exact message
- [ ] 2.2 Implement the user name character check (letters, digits, '-' and '\_') on the untrimmed value with its exact message
- [ ] 2.3 Implement the password length check (4 to 25, spaces counted) with its exact message
- [ ] 2.4 Implement the password confirmation check with its exact message
- [ ] 2.5 Implement the case-sensitive duplicate user name check with its exact message
- [ ] 2.6 Run the checks in the recovered order and stop at the first failure

## 3. Account creation service

- [ ] 3.1 Create the account with CUSTOMER role, zero failed sign-ons, unlocked and creation time, ignoring any role in the request
- [ ] 3.2 Record one account-created audit event with user name, client address and the account's creation time
- [ ] 3.3 Map a store-level uniqueness violation from a concurrent sign-up to the "already taken" refusal
- [ ] 3.4 Ensure account creation records no successful sign-on event and leaves last sign-on empty

## 4. Sign-up endpoint and session

- [ ] 4.1 Expose the sign-up endpoint accepting user name, password and repeated password
- [ ] 4.2 Sign the new user in as CUSTOMER on success
- [ ] 4.3 Redirect to the recorded original destination or to the home page on success
- [ ] 4.4 Carry the refusal reason to the refusal page on failure

## 5. Screens

- [ ] 5.1 Build the new-customer section of the Sign In page with its inputs, button and rule lines
- [ ] 5.2 Build the account creation refusal content with heading, reason and go-back link
- [ ] 5.3 Present the refusal as a "Create Account Error" page within the standard store layout

## 6. Tests

- [ ] 6.1 Unit-test each validation rule including boundaries, surrounding spaces and case
- [ ] 6.2 Unit-test check ordering with multiple rules broken
- [ ] 6.3 Integration-test account creation defaults and the audit event
- [ ] 6.4 Integration-test duplicate and case-variant user names
- [ ] 6.5 UI-test the sign-up form and the refusal page
- [ ] 6.6 End-to-end test sign-up followed by redirect to the original destination and to the home page

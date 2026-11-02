## 1. Account data

- [ ] 1.1 Ensure the account carries a creation time that is required and defaults to the current time
- [ ] 1.2 Add a nullable last-successful-sign-in time to the account
- [ ] 1.3 Add the sign-in audit event store with user name as typed, event type, time and client address
- [ ] 1.4 Store passwords and compare them as entered, pending the Business Owner decision on hashing
- [ ] 1.5 Accept existing user names containing "." at sign-in, pending the SME decision

## 2. Credential check

- [ ] 2.1 Look up the account by exact, case-sensitive user name
- [ ] 2.2 Refuse a locked account before comparing the password
- [ ] 2.3 Compare the submitted password exactly with the stored value
- [ ] 2.4 On success reset the failed sign-in count to zero and set the last sign-in time
- [ ] 2.5 Write a successful or failed sign-in audit event for every attempt
- [ ] 2.6 Leave every account unchanged when the user name is unknown
- [ ] 2.7 Return a general server error, not the sign-in error page, when the account store fails

## 3. Session and navigation

- [ ] 3.1 Store the user name and role on the session and mark it signed in on success
- [ ] 3.2 Redirect to the recorded sign-in-only page or to the home page after success
- [ ] 3.3 Redirect a refused unlocked sign-in to the Sign-in Error page
- [ ] 3.4 End a session after 15 minutes without a request
- [ ] 3.5 Decode all request text as UTF-8 before the sign-in check reads it

## 4. Remember my user name

- [ ] 4.1 Store the typed user name in the browser for 31 days when the box is ticked
- [ ] 4.2 Delete any stored user name when the box is unticked
- [ ] 4.3 Apply the remember step on every attempt regardless of outcome

## 5. Sign out

- [ ] 5.1 Record a sign-off audit event for the signed-in user name
- [ ] 5.2 End the session and show the signed-out page
- [ ] 5.3 Show the signed-out page without recording anything when nobody is signed in
- [ ] 5.4 Accept sign-out by link and by form submission
- [ ] 5.5 Complete sign-out even when the sign-off event cannot be written

## 6. Screens

- [ ] 6.1 Build the Sign In returning-customer form with remembered-name and default pre-fill
- [ ] 6.2 Build the Sign-in Error page with the not-found message, lock warning and try-again link
- [ ] 6.3 Build the signed-out page with the thank-you line and sign-in link
- [ ] 6.4 Show the signed-in status and Sign out link, or the Sign in link, in the banner
- [ ] 6.5 Build the sign-in-only Welcome page showing the home content

## 7. Verification

- [ ] 7.1 Test the credential check against the sample decision cases S01 to S11
- [ ] 7.2 Test the error page wording is identical for unknown user and wrong password
- [ ] 7.3 Test the remember-me cookie on accepted, refused and locked attempts
- [ ] 7.4 Test the return-to-requested-page and home-page redirects end to end
- [ ] 7.5 Test sign-out with and without a signed-in session
- [ ] 7.6 Test session expiry after 15 idle minutes

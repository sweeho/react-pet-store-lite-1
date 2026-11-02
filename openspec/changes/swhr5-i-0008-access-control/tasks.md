## 1. Role model

- [ ] 1.1 Add a role field to the account with the closed value set CUSTOMER and ADMIN
- [ ] 1.2 Default the role to CUSTOMER when an account is stored without one
- [ ] 1.3 Refuse any account write carrying a role outside the closed set
- [ ] 1.4 Assign CUSTOMER to every self-registered account regardless of request input
- [ ] 1.5 Seed the single ADMIN account through the sample-data load only

## 2. Session role

- [ ] 2.1 Read the account role once at successful sign-in and store it on the session
- [ ] 2.2 Set the session role to CUSTOMER when a visitor creates an account and is signed in
- [ ] 2.3 Use the session role for every access decision until sign-out

## 3. Protected pages

- [ ] 3.1 Declare the protected page set: My Account, sign-in welcome, Catalog Administration
- [ ] 3.2 Attach the required role ADMIN to Catalog Administration
- [ ] 3.3 Serve every page outside the protected set to anonymous visitors
- [ ] 3.4 Show the Sign In page when an anonymous visitor requests a protected page
- [ ] 3.5 Remember the requested page and return to it after sign-in or account creation
- [ ] 3.6 Fall back to the catalog home page when no page was remembered
- [ ] 3.7 Show the Access Denied page when a signed-in user's role is not among the required roles

## 4. Sample-data reload guard

- [ ] 4.1 Refuse a forced reload from any requester without the ADMIN session role
- [ ] 4.2 Ensure a refused forced reload changes no data and keeps the session
- [ ] 4.3 Apply the reload guard to the reload request itself for every request method
- [ ] 4.4 Allow a non-forced first load without a sign-in

## 5. Screens

- [ ] 5.1 Build the Access Denied page with its title, message, explanation and catalog link
- [ ] 5.2 Show the banner Admin link only to a signed-in ADMIN
- [ ] 5.3 Show the banner Account link to every visitor

## 6. Deployment

- [ ] 6.1 Serve the store under /petstore as the only application on its server

## 7. Verification

- [ ] 7.1 Test the role domain: default, accepted values, refused value
- [ ] 7.2 Test the page access matrix for anonymous, CUSTOMER and ADMIN
- [ ] 7.3 Test sign-in interception and return for sign-in and account creation
- [ ] 7.4 Test that a role change takes effect only at the next sign-in
- [ ] 7.5 Test the forced-reload guard for anonymous, CUSTOMER and ADMIN
- [ ] 7.6 Test the Access Denied page and banner links in a browser

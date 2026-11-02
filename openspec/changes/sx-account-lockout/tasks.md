## 1. Lock state data model

- [ ] 1.1 Add the per-account failed sign-in count (default 0), locked indicator (default not locked) and nullable lock time
- [ ] 1.2 Enforce that the locked indicator holds only locked or not locked
- [ ] 1.3 Apply the defaults (not locked, count 0, no lock time) to new and populated accounts

## 2. Sign-in failure counting

- [ ] 2.1 Increment the consecutive failed count on a wrong password for an existing, unlocked account
- [ ] 2.2 Reset the failed count to 0 on a successful sign-in
- [ ] 2.3 Record a sign-in failure event for an unknown user name without touching any account

## 3. Locking

- [ ] 3.1 Lock the account and set the lock time when the failed count reaches 3
- [ ] 3.2 Record the sign-in failure event followed by the account-locked event for the locking attempt
- [ ] 3.3 Return a locked-account outcome for the locking attempt, not an ordinary failure
- [ ] 3.4 Apply the same lockout to administrator and customer accounts

## 4. Refusal while locked

- [ ] 4.1 Check the lock before the password and refuse every sign-in to a locked account
- [ ] 4.2 Record a sign-in-while-locked event and leave the failed count and lock time unchanged
- [ ] 4.3 Route every locked-account outcome to the Account Locked page
- [ ] 4.4 Keep catalog browsing available after a locked refusal

## 5. Account Locked page

- [ ] 5.1 Build the Account Locked page with its title, lock explanation, unlock timing and administrator advice
- [ ] 5.2 Add the link back to catalog browsing
- [ ] 5.3 Keep the user signed out after a locked refusal

## 6. Scheduled automatic unlock

- [ ] 6.1 Schedule the unlock every 15 minutes around the clock
- [ ] 6.2 Release locks strictly more than 30 minutes old, reset the failed count and clear the lock time
- [ ] 6.3 Record one account-unlocked event per released account, attributed to the unlock job, in the same transaction
- [ ] 6.4 Timestamp each account-unlocked event with the job's run time
- [ ] 6.5 Support an on-demand run of the same job with the same threshold

## 7. Operations unlock

- [ ] 7.1 Document the manual early-unlock procedure and its account-unlocked event with source "admin"
- [ ] 7.2 Confirm the application exposes no unlock page or control

## 8. Verification

- [ ] 8.1 Unit tests for counting, consecutive-only reset, locking, refusal and unknown user
- [ ] 8.2 Tests for the unlock boundary at exactly 30 minutes and at 29m54s / 44m54s
- [ ] 8.3 UI test for the Account Locked page content and its catalog link
- [ ] 8.4 End-to-end test: three failures, locked page, unlock run, successful sign-in

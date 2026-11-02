## Why

The legacy Pet Store locks a sign-on account after 3 consecutive wrong-password attempts and releases it from a 15-minute batch job once the lock is more than 30 minutes old. The rule is regulated (it guards customer and administrator accounts), it is spread across the sign-on code, a SQL batch script, a Control-M schedule, the schema and three operator/user guides, and no single place states it. The rebuild has to reproduce it exactly, including its edges: the strict 30-minute boundary, the 30 to 45 minute effective lock window, the absence of any unlock screen, and the audit events written at each step.

## What Changes

- Recover the account-lockout capability from the legacy application as one specification `account-lockout`.
- Specify the failed-attempt counter, the lock on the 3rd consecutive failure, the refusal of every sign-in while locked, and the treatment of blank passwords and unknown user names.
- Specify the scheduled automatic unlock, its strict threshold, its audit event, and the manual early-unlock path owned by operations.
- Specify the lock state carried per account and its consistency rule.
- Specify the Account Locked page: what it displays and when it is shown.
- Carry two open questions to an SME: the timing of the account-locked audit event (code and sample disagree) and the behaviour of a locked account with no lock time.

## Capabilities

### New Capabilities

- `account-lockout`: lockout after consecutive sign-in failures, refusal while locked, scheduled and manual unlock, lock state, and the Account Locked page.

### Modified Capabilities

None.

## Impact

- Depends on the sign-on capability (credential check) and the sign-on audit trail; both are specified by their own shards.
- Five requirements carry approved keys (SWHR5-R-0003, -0004, -0005, -0006, -0013); the others are drafts awaiting SME review, with recommendations in `legacy-analysis/ir/_recommendations/account-lockout.yaml`.

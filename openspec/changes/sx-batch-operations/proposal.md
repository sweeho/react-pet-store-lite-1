# Proposal: sx-batch-operations

## Why

The legacy Petstore Lite store depends on a set of scheduled batch jobs that nobody documents as product behaviour: a nightly online database backup with 7-day retention, a sign-on audit extract and report chained behind it, a weekly audit purge, a morning catalog integrity check and a 15-minute account unlock. Their ordering, retry limits, exit-code contract, alert routing and logging are operational requirements the rebuild must reproduce or consciously replace. Today they are spread across a scheduler export, six shell scripts, a shared environment file, six SQL scripts, the container image and the operations runbook.

This change records those behaviours as draft requirements extracted by SX-0001, as requirements approved by an SME, ahead of the target design.

## What changes

- Adds the `batch-operations` capability with requirements for:
  - the nightly job chain (backup, then audit extract, then sign-on report and Sunday audit purge) and its start times;
  - the jobs that run independently of the chain (06:00 catalog check, 15-minute account unlock);
  - the daily online backup, its dated naming, same-day replacement and 7-day retention;
  - automatic retry limits per job;
  - holding the dependent chain when the backup fails;
  - the job exit-code contract (0 / 4 / 8) and how a database step's failure is detected;
  - the shared batch log and the start and end lines each job writes;
  - which failures raise a mail alert, at what urgency and to whom;
  - the audit extract's covered day and rerun rules;
  - output locations, database and store connectivity, packaging and persistent working areas;
  - the manual restore-from-backup procedure.
- All 21 ingested records are approved; each requirement carries its minted `ID:` and the record it was recovered from. Records not in the approved set (the operator rerun after a fix, per-job detail logs and the other pending records) are left out of the spec and carry recommendations in `legacy-analysis/ir/_recommendations/batch-operations.yaml`.

## Out of scope

- The content of the audit extract file, the sign-on report, the purge's 90-day rule, the unlock's 30-minute rule and the catalog check's C1 to C4 rules. They are recorded under their own capabilities (sign-on audit, account lockout, catalog). This capability covers only how the jobs are scheduled, chained, retried, logged and alerted.
- Any target design. The Architect drafts it after the Product Requirement is approved.

## Impact

- Open SME decisions: backup retention (7 days vs about 8 copies), whether the extract's single rerun is automatic, the undefined `PSL_CAL` calendar, the silent-failure paths (catalog check exit 8, report, purge and unlock with no alert), and the Sunday report/purge race. Details are in `design.md` and in `legacy-analysis/ir/_recommendations/batch-operations.yaml`.
- No user interface: no screen records were extracted for this capability.

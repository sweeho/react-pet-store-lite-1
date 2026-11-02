#!/bin/sh
# PSL_AUDIT_PURGE - weekly Sunday 02:00 after PSL_AUDIT_EXTRACT.
# Deletes SIGNON_AUDIT rows older than 90 days.
PSL_JOB=PSL_AUDIT_PURGE
. "${PSL_HOME:-/opt/petstore}/conf/env.sh"
psl_log "start retention=${PSL_AUDIT_RETENTION_DAYS}d"
psl_ij "$PSL_SQL/audit_purge.sql" >> "$PSL_LOG_DIR/audit_purge.log" || { psl_log "FAILED"; exit 8; }
psl_log "end OK"
exit 0

#!/bin/sh
# PSL_ACCT_UNLOCK - every 15 minutes. Unlocks accounts locked > 30 minutes.
PSL_JOB=PSL_ACCT_UNLOCK
. "${PSL_HOME:-/opt/petstore}/conf/env.sh"
psl_log "start"
psl_ij "$PSL_SQL/acct_unlock.sql" >> "$PSL_LOG_DIR/acct_unlock.log" || { psl_log "FAILED"; exit 8; }
psl_log "end OK"
exit 0

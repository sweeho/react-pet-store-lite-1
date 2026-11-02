#!/bin/sh
# PSL_CATALOG_CHECK - daily 06:00 before the store opens.
# Runs the catalog integrity checks. When the catalog is empty it asks the
# store to populate itself (first load, not a forced reload). Any failed
# check ends the job with code 4 so operations is alerted.
PSL_JOB=PSL_CATALOG_CHECK
. "${PSL_HOME:-/opt/petstore}/conf/env.sh"
psl_log "start"
OUT=$(psl_ij "$PSL_SQL/catalog_check.sql")
if echo "$OUT" | grep -q "does not exist"; then
  psl_log "catalog tables missing, requesting first load"
  curl -sf -o /dev/null "$PSL_STORE_URL/Populate?forcefully=false" || { psl_log "FAILED: populate"; exit 8; }
  OUT=$(psl_ij "$PSL_SQL/catalog_check.sql")
fi
echo "$OUT" >> "$PSL_LOG_DIR/catalog_check.log"
if echo "$OUT" | grep -qE "^C[1-4] "; then
  psl_log "FAILED: integrity check found rows"
  exit 4
fi
psl_log "end OK"
exit 0

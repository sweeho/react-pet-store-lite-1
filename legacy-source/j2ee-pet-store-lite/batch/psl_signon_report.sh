#!/bin/sh
# PSL_SIGNON_REPORT - daily 01:45 after PSL_AUDIT_EXTRACT.
# Writes yesterday's sign-on statistics to signon_report_YYYYMMDD.txt.
PSL_JOB=PSL_SIGNON_REPORT
. "${PSL_HOME:-/opt/petstore}/conf/env.sh"
DAY=$(date -d yesterday '+%Y%m%d' 2>/dev/null || date -v-1d '+%Y%m%d')
OUT="$PSL_EXTRACT_DIR/signon_report_$DAY.txt"
psl_log "start day=$DAY"
psl_ij "$PSL_SQL/signon_report.sql" > "$OUT" || { psl_log "FAILED"; exit 8; }
psl_log "end OK file=$OUT"
exit 0

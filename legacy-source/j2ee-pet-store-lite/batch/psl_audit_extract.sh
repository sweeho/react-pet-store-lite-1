#!/bin/sh
# PSL_AUDIT_EXTRACT - daily 01:30 after PSL_DB_BACKUP.
# Exports yesterday's SIGNON_AUDIT rows to signon_audit_YYYYMMDD.csv.
PSL_JOB=PSL_AUDIT_EXTRACT
. "${PSL_HOME:-/opt/petstore}/conf/env.sh"
DAY=$(date -d yesterday '+%Y%m%d' 2>/dev/null || date -v-1d '+%Y%m%d')
OUT="$PSL_EXTRACT_DIR/signon_audit_$DAY.csv"
psl_log "start day=$DAY"
rm -f "$PSL_EXTRACT_DIR/signon_audit_extract.csv"
psl_ij "$PSL_SQL/audit_extract.sql" > /dev/null || { psl_log "FAILED: export"; exit 8; }
mv "$PSL_EXTRACT_DIR/signon_audit_extract.csv" "$OUT"
ROWS=$(wc -l < "$OUT" | tr -d ' ')
echo "TRAILER,$DAY,$ROWS" >> "$OUT"
psl_log "end OK file=$OUT rows=$ROWS"
exit 0

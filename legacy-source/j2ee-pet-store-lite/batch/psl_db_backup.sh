#!/bin/sh
# PSL_DB_BACKUP - daily 01:00. Online Derby backup, keeps 7 days.
PSL_JOB=PSL_DB_BACKUP
. "${PSL_HOME:-/opt/petstore}/conf/env.sh"
STAMP=$(date '+%Y%m%d')
psl_log "start"
rm -rf "$PSL_BACKUP_DIR/PetStoreDB"
psl_ij "$PSL_SQL/db_backup.sql" > /dev/null || { psl_log "FAILED: backup"; exit 8; }
rm -rf "$PSL_BACKUP_DIR/PetStoreDB_$STAMP"
mv "$PSL_BACKUP_DIR/PetStoreDB" "$PSL_BACKUP_DIR/PetStoreDB_$STAMP"
find "$PSL_BACKUP_DIR" -maxdepth 1 -name 'PetStoreDB_*' -mtime +$PSL_BACKUP_KEEP_DAYS -exec rm -rf {} \;
psl_log "end OK backup=$PSL_BACKUP_DIR/PetStoreDB_$STAMP"
exit 0

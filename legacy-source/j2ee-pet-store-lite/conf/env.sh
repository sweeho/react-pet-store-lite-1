#!/bin/sh
# Petstore Lite batch environment. Sourced by every script in batch/.
PSL_HOME=${PSL_HOME:-/opt/petstore}
PSL_CONF=$PSL_HOME/conf
PSL_SQL=$PSL_HOME/db/batch
PSL_LOG_DIR=${PSL_LOG_DIR:-/var/petstore/log}
PSL_BACKUP_DIR=${PSL_BACKUP_DIR:-/var/petstore/backup}
PSL_EXTRACT_DIR=${PSL_EXTRACT_DIR:-/var/petstore/extract}
PSL_STORE_URL=${PSL_STORE_URL:-http://localhost:8080/petstore}
PSL_DB_URL="jdbc:derby://localhost:1527//var/petstore/db/PetStoreDB;user=estoreuser;password=estore"
PSL_AUDIT_RETENTION_DAYS=90
PSL_BACKUP_KEEP_DAYS=7
DERBY_LIB=${DERBY_LIB:-/usr/local/tomcat/lib}
JAVA_CMD=${JAVA_HOME:+$JAVA_HOME/bin/}java
export PSL_HOME PSL_CONF PSL_SQL PSL_LOG_DIR PSL_BACKUP_DIR PSL_EXTRACT_DIR PSL_STORE_URL PSL_DB_URL DERBY_LIB JAVA_CMD

# Run a SQL script with Derby ij against the store database.
# Usage: psl_ij <script.sql>   Fails when ij reports an ERROR line.
psl_ij() {
  out=$("$JAVA_CMD" -cp "$DERBY_LIB/derbytools-10.14.2.0.jar:$DERBY_LIB/derbyclient-10.14.2.0.jar" \
        -Dij.connection.psl="$PSL_DB_URL" -Dij.outfile=/dev/stdout \
        org.apache.derby.tools.ij "$1" 2>&1)
  echo "$out"
  echo "$out" | grep -q "^ERROR" && return 1
  return 0
}

# Write a time-stamped line to the job log and stdout.
psl_log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [$PSL_JOB] $*" | tee -a "$PSL_LOG_DIR/batch.log"
}

#!/bin/sh
# Builds the Vortex source inputs in vortex/inputs from the repository.
# Run from the repository root: sh vortex/build-inputs.sh
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT="$ROOT/vortex/inputs"
rm -rf "$OUT"
mkdir -p "$OUT/01-code" "$OUT/02-database" "$OUT/03-scheduler" "$OUT/04-configuration" \
         "$OUT/05-documents/screenshots" "$OUT/06-samples"

# 01 code: one zip, no wrapping folder, so src/main/java profiles as one J2EE folder.
# Holds the app, its DDL, batch scripts, Control-M export and config, which Vortex
# also detects inside code. Docs, data and these inputs are separate sources.
cd "$ROOT"
zip -q -r -X "$OUT/01-code/petstore-lite-code.zip" \
  README.md LICENSE-SUN.txt pom.xml Dockerfile src db batch conf scheduler \
  -x '*.DS_Store' 'target/*'

# 02-04: the same files as standalone sources (shell scripts stay in the zip:
# a standalone upload starting with #! is refused)
cp db/schema/petstore_oracle.sql db/schema/petstore_derby.sql "$OUT/02-database/"
cp scheduler/control-m/PSL_PETSTORE.xml "$OUT/03-scheduler/"
cp conf/petstore.properties "$OUT/04-configuration/"

# 05 documents: guides and screenshots (dropped as media if put in the zip)
cp docs/PetStoreLite-user-guide.pdf docs/PetStoreLite-admin-guide.pdf docs/PetStoreLite-operations-runbook.pdf "$OUT/05-documents/"
cp docs/screenshots/*.png "$OUT/05-documents/screenshots/"

# 06 samples: anonymised past inputs with their legacy outputs
cp vortex/samples/* "$OUT/06-samples/"

find "$OUT" -type f | sed "s|$ROOT/||" | sort

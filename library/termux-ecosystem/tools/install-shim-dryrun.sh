#!/usr/bin/env bash
set -euo pipefail
DRYFILE="$HOME/kh-scripts/install-shim-dryrun.txt"
: >"$DRYFILE"
# Capture intended actions without performing destructive writes: mark shim writes as DRY-WRITE
"$HOME/kh-scripts/library/termux-ecosystem/tools/install-shim.sh" "$@" 2>&1 | sed -e 's/INFO: wrote shim:/DRY-WRITE: wrote shim:/' | tee -a "$DRYFILE"
printf "Dry-run written to %s\n" "$DRYFILE"

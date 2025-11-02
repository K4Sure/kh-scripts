#!/usr/bin/env bash
set -euo pipefail
LOG=SMOKE:
[ -f MANIFEST.yml ] || { echo "$LOG FAIL: MANIFEST missing"; exit 1; }
[ -f bmc.sh ] || { echo "$LOG FAIL: bmc.sh missing"; exit 2; }
( . ./bmc.sh && bmc::version >/dev/null ) || { echo "$LOG FAIL: sourcing"; exit 3; }
if ./bmc.sh __call__ bmc::version; then echo "$LOG OK"; else echo "$LOG FAIL: call"; exit 4; fi

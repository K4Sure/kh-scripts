#!/usr/bin/env bash
set -euo pipefail
LOG=SMOKE:
[ -f MANIFEST.yml ] || { echo "$LOG FAIL: MANIFEST missing"; exit 1; }
[ -f pml.sh ] || { echo "$LOG FAIL: pml.sh missing"; exit 2; }
( . ./pml.sh && pml::version >/dev/null ) || { echo "$LOG FAIL: sourcing"; exit 3; }
if ./pml.sh __call__ pml::echo "smoke"; then echo "$LOG OK"; else echo "$LOG FAIL: call"; exit 4; fi

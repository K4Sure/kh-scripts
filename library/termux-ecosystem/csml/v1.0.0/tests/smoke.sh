#!/usr/bin/env bash
set -euo pipefail
LOG=SMOKE:
[ -f MANIFEST.yml ] || { echo "$LOG FAIL: MANIFEST missing"; exit 1; }
[ -f csml.sh ] || { echo "$LOG FAIL: csml.sh missing"; exit 2; }
( . ./csml.sh && csml::version >/dev/null ) || { echo "$LOG FAIL: sourcing"; exit 3; }
if ./csml.sh __call__ csml::set "smoke"; then echo "$LOG OK"; else echo "$LOG FAIL: call"; exit 4; fi

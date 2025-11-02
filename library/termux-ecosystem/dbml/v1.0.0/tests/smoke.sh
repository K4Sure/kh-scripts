#!/usr/bin/env bash
set -euo pipefail
LOG=SMOKE:
[ -f MANIFEST.yml ] || { echo "$LOG FAIL: MANIFEST missing"; exit 1; }
[ -f dbml.sh ] || { echo "$LOG FAIL: dbml.sh missing"; exit 2; }
( . ./dbml.sh && dbml::version >/dev/null ) || { echo "$LOG FAIL: sourcing"; exit 3; }
if ./dbml.sh __call__ dbml::connect "smoke"; then echo "$LOG OK"; else echo "$LOG FAIL: call"; exit 4; fi

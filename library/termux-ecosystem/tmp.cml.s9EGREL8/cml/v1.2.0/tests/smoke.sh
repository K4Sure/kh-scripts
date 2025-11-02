#!/usr/bin/env bash
set -euo pipefail
LOG_PREFIX="SMOKE:"
echo "$LOG_PREFIX starting cml smoke"
MANIFEST="$(pwd)/../MANIFEST.yml"
[ -f "$MANIFEST" ] || { echo "$LOG_PREFIX FAIL: MANIFEST missing"; exit 1; }
echo "$LOG_PREFIX OK: MANIFEST present"
if [ ! -x ../cml.sh ]; then chmod +x ../cml.sh 2>/dev/null || true; fi
[ -f ../cml.sh ] || { echo "$LOG_PREFIX FAIL: cml.sh missing"; exit 2; }
echo "$LOG_PREFIX OK: cml.sh present"
( . ../cml.sh && cml::version >/dev/null ) || { echo "$LOG_PREFIX FAIL: sourcing failed"; exit 3; }
echo "$LOG_PREFIX OK: sourced cml.sh and cml::version callable"
if ../cml.sh __call__ cml::print "smoke test"; then
  echo "$LOG_PREFIX OK: cml::print executed"
else
  echo "$LOG_PREFIX FAIL: cml::print failed"; exit 4
fi
echo "$LOG_PREFIX All checks passed"
exit 0

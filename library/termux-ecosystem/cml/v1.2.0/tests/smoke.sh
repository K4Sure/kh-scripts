#!/usr/bin/env bash
set -euo pipefail
LOG_PREFIX="SMOKE:"
echo "$LOG_PREFIX starting cml smoke"

MANIFEST="$(pwd)/MANIFEST.yml"
[ -f "$MANIFEST" ] || { echo "$LOG_PREFIX FAIL: MANIFEST missing"; exit 1; }
echo "$LOG_PREFIX OK: MANIFEST present"

# verify entrypoint (relative to current dir)
if [ ! -x ./../cml.sh ] && [ -f ./cml.sh ]; then
  chmod +x ./cml.sh 2>/dev/null || true
fi
# prefer entrypoint in same dir (installer runs tests from vX.Y.Z)
if [ -f ./cml.sh ]; then
  ENTRY="./cml.sh"
elif [ -f ../cml.sh ]; then
  ENTRY="../cml.sh"
else
  echo "$LOG_PREFIX FAIL: cml.sh missing"; exit 2
fi
echo "$LOG_PREFIX OK: cml.sh present at $ENTRY"

# source test (run in a subshell)
( . "$ENTRY" && cml::version >/dev/null ) || { echo "$LOG_PREFIX FAIL: sourcing failed"; exit 3; }
echo "$LOG_PREFIX OK: sourced cml.sh and cml::version callable"

# sample export invocation using dispatcher contract
if "$ENTRY" __call__ cml::print "smoke test"; then
  echo "$LOG_PREFIX OK: cml::print executed"
else
  echo "$LOG_PREFIX FAIL: cml::print failed"; exit 4
fi

echo "$LOG_PREFIX All checks passed"
exit 0

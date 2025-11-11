#!/usr/bin/env sh
# ci-local - runs lint, unit tests, smoke, and writes audit log (Malaysia TZ)
set -e
TZ="Asia/Kuala_Lumpur"
TS=$(TZ="$TZ" date +%Y%m%dT%H%M)
REPORT="logs/ci-local_${TS}.txt"
{
  echo "CI local run: $TS (Asia/Kuala_Lumpur)"
  echo
  echo "=== MANIFEST LINT ==="
  bin/manifest-lint-1.1.0.sh || echo "manifest-lint: non-zero exit"
  echo
  echo "=== MANIFEST FIX SUGGESTIONS ==="
  bin/manifest-fix-1.0.0.sh || true
  echo
  echo "=== RUN CML UNIT TESTS ==="
  lib/cml/tests/palette_merge_test_v0.1.0.sh || { echo "CML tests failed"; exit 4; }
  echo
  echo "=== RUN LIB SMOKE (DBML) ==="
  bin/te-lib-smoke-1.4.0.sh || { echo "lib smoke failed"; exit 5; }
  echo
  echo "=== FILES WITH VERSION TOKENS (sample) ==="
  find lib -type f -regextype posix-extended -regex '.*v[0-9]+(\\.[0-9]+)*.*' -print | sort | sed -n '1,200p'
} > "$REPORT" 2>&1 || true
echo "CI local complete. Audit: $REPORT"
exit 0

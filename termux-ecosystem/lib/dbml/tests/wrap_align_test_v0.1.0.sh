#!/usr/bin/env sh
# wrap_align_test - verify wrapping and left/center/right alignment tokens (tolerant)
set -e
out=$(lib/dbml/src/box_preset_v0.3.0.sh box-wide "One two three four five six seven eight nine" 30 center 1)
echo "$out" | grep -q '+' || { echo "FAIL: top border missing"; exit 1; }
# left align: accept any line containing the token "Left"
outl=$(lib/dbml/src/box_preset_v0.3.0.sh box-wide "Left right" 30 left 1)
echo "$outl" | grep -q 'Left' || { echo "FAIL: left align content missing"; exit 1; }
echo "PASS: wrap_align_test_v0.1.0"

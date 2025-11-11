#!/usr/bin/env sh
set -e
mkdir -p lib/cml/themes

# Base + file override + stdin override; last-wins expected
out=$(
  { printf 'c: "#aaaaaa"\n'; printf 'b: "#bbbbbb"\n'; } | \
  lib/cml/src/cml_palette_norm_wrap_v0.1.0.sh base lib/cml/themes/override_v1.0.0.yaml -
)

# Normalize once more for assertions (quotes may be absent already)
norm=$(echo "$out" | sed 's/"//g; s/:[[:space:]]*/:/g')
echo "$norm"

# Assertions
echo "$norm" | grep -q '^a:#000000' || { echo "❌ FAIL: a not from base"; exit 1; }
echo "$norm" | grep -q '^b:#bbbbbb' || { echo "❌ FAIL: b not from stdin override"; exit 1; }
echo "$norm" | grep -q '^c:#aaaaaa' || { echo "❌ FAIL: c not from stdin override"; exit 1; }

echo "✅ PASS: palette_lastwins_test_v0.1.0"

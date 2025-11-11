#!/usr/bin/env sh
# palette_merge_test v0.1.0 - assertions for palette merging (normalize quotes/spaces)
set -e
mkdir -p lib/cml/themes
# create base and override theme files in themes dir
cat > lib/cml/themes/base_v1.0.0.yaml <<Y
name: base
version: 1.0.0
palette:
  a: "#000000"
  b: "#111111"
Y

cat > lib/cml/themes/override_v1.0.0.yaml <<Y
name: override
version: 1.0.0
palette:
  b: "#222222"
  c: "#333333"
Y

# call merger with explicit filepaths so test is self-contained
out=$(lib/cml/src/cml_palette_norm_wrap_v0.1.0.sh lib/cml/themes/base_v1.0.0.yaml lib/cml/themes/override_v1.0.0.yaml 2>/dev/null || true)
# normalize: remove quotes and optional spaces after colon
norm=$(echo "$out" | sed 's/"//g; s/:[[:space:]]*/:/g')
echo "$norm" | grep -q '^a:' || { echo "FAIL: missing key a"; exit 1; }
echo "$norm" | grep -q '^b:#222222' || { echo "FAIL: b not overridden"; exit 1; }
echo "$norm" | grep -q '^c:#333333' || { echo "FAIL: missing key c"; exit 1; }
echo "PASS: palette_merge_test_v0.1.0"

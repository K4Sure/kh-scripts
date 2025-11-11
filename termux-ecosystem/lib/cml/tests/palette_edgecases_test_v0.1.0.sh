#!/usr/bin/env sh
set -e
mkdir -p lib/cml/themes

# Pipe stdin override once, pass "-" as last arg
out=$(printf 'z: "#050505"\n' | \
  lib/cml/src/cml_palette_norm_wrap_v0.1.0.sh \
    lib/cml/themes/edge_base_v1.0.0.yaml \
    lib/cml/themes/edge_ovr_v1.0.0.yaml \
    -)

norm=$(echo "$out" | sed 's/"//g; s/:[[:space:]]*/:/g')
echo "$norm"

echo "$norm" | grep -q ^x: || { echo "FAIL: missing x"; exit 1; }
echo "$norm" | grep -q ^y:#030303 || { echo "FAIL: wrong y"; exit 1; }
echo "$norm" | grep -q ^z:#050505 || { echo "FAIL: stdin override not applied (z)"; exit 1; }

echo "PASS: palette_edgecases_test_v0.1.0"

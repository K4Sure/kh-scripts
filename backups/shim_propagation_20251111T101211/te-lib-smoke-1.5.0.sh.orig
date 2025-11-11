#!/usr/bin/env sh
# lib smoke v1.5.0 - run cml tests and dbml preset renderer matrix
set -e
echo "Running CML palette unit test:"
lib/cml/tests/palette_merge_test_v0.1.0.sh || { echo "CML tests failed"; exit 4; }
echo
echo "CML merged palette sample:"
lib/cml/src/cml_palette_v0.3.0.sh theme-default | sed -n '1,20p' || true
echo
echo "DBML preset matrix:"
echo " - single, center"
lib/dbml/src/box_preset_v0.3.0.sh box-wide "Welcome to Termux Ecosystem" 50 center 1 || true
echo
echo " - double, left"
lib/dbml/src/box_preset_v0.3.0.sh box-double "Left aligned paragraph example with more words to wrap" 48 left 1 || true
echo
echo "lib smoke v1.5.0 complete"

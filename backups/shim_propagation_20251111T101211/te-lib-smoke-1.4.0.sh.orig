#!/usr/bin/env sh
# lib smoke v1.4.0 - exercise cml merge and dbml preset renderer
set -e
echo "Running CML palette unit test:"
lib/cml/tests/palette_merge_test_v0.1.0.sh || { echo "CML tests failed"; exit 4; }
echo
echo "CML merged palette sample:"
lib/cml/src/cml_palette_v0.3.0.sh theme-default | sed -n '1,20p' || true
echo
echo "DBML box preset render (preset box-wide, label: Welcome, width: 30):"
lib/dbml/src/box_preset_v0.2.0.sh box-wide "Welcome" 30 || true
echo
echo "lib smoke v1.4.0 complete"

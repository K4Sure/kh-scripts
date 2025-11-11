# Branded Shim Wrapper
#!/usr/bin/env sh
# lib smoke v1.3.0 - exercise cml merge, run unit-style test, and dbml renderer
set -e
echo "Running CML palette unit test:"
lib/cml/tests/palette_merge_test_v0.1.0.sh || { echo "CML tests failed"; exit 4; }
echo
echo "CML merged palette sample (theme-default, no overrides):"
lib/cml/src/cml_palette_v0.3.0.sh theme-default | sed -n '1,50p' || true
echo
echo "DBML box render (sanity):"
lib/dbml/src/box_renderer_v0.1.0.sh "hello" || true
echo
echo "lib smoke v1.3.0 complete"

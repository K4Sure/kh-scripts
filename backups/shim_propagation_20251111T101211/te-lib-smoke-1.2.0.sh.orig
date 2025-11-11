#!/usr/bin/env sh
# lib smoke v1.2.0 - exercise cml named-palette and dbml box renderer
set -e
echo "CML named palette (theme-default, printed as key:value):"
lib/cml/src/cml_palette_v0.2.0.sh theme-default || true
echo
echo "DBML box render (sanity):"
lib/dbml/src/box_renderer_v0.1.0.sh "hello" || true
echo
echo "lib smoke v1.2.0 complete"

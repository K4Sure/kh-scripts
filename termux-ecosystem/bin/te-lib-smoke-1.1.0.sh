#!/usr/bin/env sh
# lib smoke v1.1.0 - exercise cml and dbml minimal features
set -e
echo "CML palette (first 10 lines):"
lib/cml/src/palette_loader_v0.1.0.sh lib/cml/themes/theme-default_v1.0.0.yaml | sed -n '1,10p' || true
echo
echo "DBML box render:"
lib/dbml/src/box_renderer_v0.1.0.sh "hello" || true
echo
echo "lib smoke v1.1.0 complete"

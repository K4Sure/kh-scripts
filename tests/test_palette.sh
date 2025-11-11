#!/usr/bin/env bash
set -euo pipefail
mkdir -p tmp
printf 'x:#010101\ny:#020202\n' > tmp/test.palette
echo "=== norm -> renderer ==="
lib/cml/src/cml_palette_norm_wrap_v0.1.0.sh edge_base 2>/dev/null | lib/cml/src/cml_palette_swatch_v0.1.0.py | sed -n '1,20p'
echo "=== direct renderer test ==="
cat tmp/test.palette | lib/cml/src/cml_palette_swatch_v0.1.0.py | sed -n '1,20p'

#!/usr/bin/env bash
set -euo pipefail
TS_NOW=$(date +%Y%m%dT%H%M%S)
echo "[ci-audit] start ${TS_NOW}"
bash -n bin/cml && echo "[ci-audit] bin/cml syntax OK" || { echo "[ci-audit] bin/cml syntax FAIL"; exit 1; }
[ -x lib/cml/src/cml_palette_swatch_v0.1.0.py ] || { echo "[ci-audit] missing renderer"; exit 1; }
mkdir -p logs/ci
printf 'x:#010101\ny:#020202\n' | lib/cml/src/cml_palette_swatch_v0.1.0.py | sed -n '1,16p' > logs/ci/sw_patch.${TS_NOW}.out 2>&1 || true
bin/cml swatch edge_base 2>&1 | sed -n '1,32p' > logs/ci/swatch.${TS_NOW}.out || true
bin/cml palette edge_base 2>&1 | sed -n '1,64p' > logs/ci/palette.${TS_NOW}.out || true
echo "[ci-audit] logs: $(ls -1 logs/ci | tr '\n' ' ')"
echo "[ci-audit] done"

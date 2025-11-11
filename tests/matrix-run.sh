#!/usr/bin/env bash
set -euo pipefail
TS_NOW=$(date +%Y%m%dT%H%M%S)
LOGDIR=tests/logs/${TS_NOW}
mkdir -p "$LOGDIR"
echo "[matrix] start $TS_NOW" > "$LOGDIR/matrix.out"
for PY in python3 python; do
  if command -v "$PY" >/dev/null 2>&1; then
    echo "[matrix] using $PY" | tee -a "$LOGDIR/matrix.out"
    printf 'x:#010101\ny:#020202\n' | lib/cml/src/cml_palette_swatch_v0.1.0.py 2>&1 | sed -n '1,40p' | tee "$LOGDIR/renderer_${PY}.out"
  fi
done
# run existing tests
bash tests/test_palette.sh 2>&1 | tee -a "$LOGDIR/test_palette.out"
echo "[matrix] done" >> "$LOGDIR/matrix.out"
echo "Logs: $LOGDIR"

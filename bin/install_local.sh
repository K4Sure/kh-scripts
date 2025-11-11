#!/usr/bin/env bash
set -euo pipefail
TS_NOW=$(date +%Y%m%dT%H%M%S)
echo "[install_local] start $TS_NOW"
# ensure python renderer executable
if [ -f lib/cml/src/cml_palette_swatch_v0.1.0.py ]; then
  chmod +x lib/cml/src/cml_palette_swatch_v0.1.0.py
fi
# ensure bin/cml executable
[ -f bin/cml ] && chmod +x bin/cml
# create a timestamped tarball of important artifacts
tar -czf "backups/local_pkg_${TS_NOW}.tar.gz" bin lib manifests tests README.md 2>/dev/null || true
echo "[install_local] created backups/local_pkg_${TS_NOW}.tar.gz"
echo "[install_local] done"
echo "Rollback (copy one of backups/local_pkg_*.tar.gz contents back): tar -xzf <file> -C ."

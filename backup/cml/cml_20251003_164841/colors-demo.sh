#!/data/data/com.termux/files/usr/bin/env bash
# colors-demo.sh — runs a short visual demo of CML
set -euo pipefail
LIB="$HOME/kh-scripts/library/colors/color_master_library.sh"
if [ -f "$LIB" ]; then
  # shellcheck source=/dev/null
  source "$LIB"
else
  echo "CML library not found at $LIB"
  exit 1
fi

echo "Running colors demo..."
for theme in classic solarized neon darkwave minimal; do
  echo
  echo "=== Theme: $theme ==="
  cml_apply_theme "$theme"
  colors
  sleep 1
done
echo "Demo finished."

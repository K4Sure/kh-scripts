#!/data/data/com.termux/files/usr/bin/bash
# dm-launcher.sh — Always runs the latest ytdl_menu_v*.sh
KH_DIR="$HOME/kh-scripts/ytdl_menu"
LATEST_SCRIPT=$(ls -1t "$KH_DIR"/ytdl_menu_v*.sh 2>/dev/null | head -n 1)
if [[ -z "$LATEST_SCRIPT" ]]; then
  echo "❌ No ytdl_menu_v*.sh found in $KH_DIR"
  exit 1
fi
chmod +x "$LATEST_SCRIPT"
exec bash "$LATEST_SCRIPT" "$@"

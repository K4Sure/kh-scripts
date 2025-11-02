#!/data/data/com.termux/files/usr/bin/bash
SRC="$1"
DEST="/sdcard/Download/$(basename "$SRC")"
cp -f "$SRC" "$DEST"
am start -a android.intent.action.VIEW -d "file://$DEST" -t "image/*"

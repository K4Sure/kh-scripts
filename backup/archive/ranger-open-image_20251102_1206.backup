#!/data/data/com.termux/files/usr/bin/bash
FILE="$1"
if [ -z "$FILE" ]; then
  exit 1
fi
# Try to use Termux API 'termux-open' if available, otherwise use am start
if command -v termux-open >/dev/null 2>&1; then
  termux-open "$FILE" >/dev/null 2>&1 &
else
  am start -a android.intent.action.VIEW -d "file://$FILE" -t "image/*" >/dev/null 2>&1 &
fi

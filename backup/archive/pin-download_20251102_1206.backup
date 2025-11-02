#!/data/data/com.termux/files/usr/bin/bash
# ======================================================
# Pinterest Shortlink Downloader (v1.0)
# Author: Kelvin's Termux Toolkit
# ======================================================

URL="$1"

if [ -z "$URL" ]; then
  echo "USAGE: pin-download <pinterest-url>"
  exit 1
fi

# Step 1: Follow redirects to get full Pinterest link
FINAL_URL=$(curl -Ls -o /dev/null -w '%{url_effective}' "$URL")

if [[ "$FINAL_URL" != *"pinterest.com/pin/"* ]]; then
  echo "❌ INVALID OR UNRESOLVED LINK."
  echo "Raw resolved: $FINAL_URL"
  exit 1
fi

echo "✔ FINAL URL: $FINAL_URL"
echo "⏬ STARTING DOWNLOAD..."

# Step 2: Use yt-dlp with browser-like headers
yt-dlp -Uv --add-header "User-Agent: Mozilla/5.0" "$FINAL_URL"

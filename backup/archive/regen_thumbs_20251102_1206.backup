#!/data/data/com.termux/files/usr/bin/bash
# regen_thumbs.sh — Thumbnail refresher with accurate file count and per-file scan
# Ferrari Red banner + true file count + no logging

RED='\e[38;2;255;0;0m'
NC='\e[0m'

VID_DIR="$1"

if [ -z "$VID_DIR" ]; then
  echo -e "${RED}✘ Error:${NC} No path provided."
  echo "Usage: rth \"/path/to/video/folder\"" >&2
  exit 1
fi

if [ ! -d "$VID_DIR" ]; then
  echo -e "${RED}✘ Error:${NC} '$VID_DIR' is not a valid directory."
  exit 1
fi

echo -e "${RED}▶ Refreshing thumbnails in:${NC} $VID_DIR"

# Step 1: Find all video files
mapfile -t FILES < <(find "$VID_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" \))

COUNT="${#FILES[@]}"
if [ "$COUNT" -eq 0 ]; then
  echo -e "${RED}✘ No video files found.${NC}"
  exit 0
fi

# Step 2: Touch + scan each file
for f in "${FILES[@]}"; do
  touch "$f"
  termux-media-scan "$f"
done

echo -e "${RED}✔ Done. Processed $COUNT file(s). Open MiXplorer and check thumbnails.${NC}"

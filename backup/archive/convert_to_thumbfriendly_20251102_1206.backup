#!/data/data/com.termux/files/usr/bin/bash
# convert_to_thumbfriendly.sh — v3.0
# Converts videos in specified folder to H.264 MP4, outputs to same folder, moves originals to ./old
# Spinner + single-line progress + Ferrari Red banner

RED='\e[38;2;255;0;0m'
NC='\e[0m'

SRC_DIR="$1"

if [ -z "$SRC_DIR" ]; then
  echo -e "${RED}✘ Error:${NC} No path provided."
  echo "Usage: convert_to_thumbfriendly.sh \"/path/to/video/folder\"" >&2
  exit 1
fi

if [ ! -d "$SRC_DIR" ]; then
  echo -e "${RED}✘ Error:${NC} '$SRC_DIR' is not a valid directory."
  exit 1
fi

echo -ne "${RED}▶ Converting videos in:${NC} $SRC_DIR\n"

OLD_DIR="$SRC_DIR/old"
mkdir -p "$OLD_DIR"

mapfile -t FILES < <(find "$SRC_DIR" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" \))
COUNT="${#FILES[@]}"
if [ "$COUNT" -eq 0 ]; then
  echo -e "${RED}✘ No video files found in top-level of folder.${NC}"
  exit 0
fi

# Spinner setup
SPIN='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
i=0
CONVERTED=0

for f in "${FILES[@]}"; do
  BASENAME="$(basename "$f")"
  OUTFILE="$SRC_DIR/${BASENAME%.*}_thumb.mp4"

  ffmpeg -y -i "$f" -c:v libx264 -preset fast -crf 23 -c:a aac -strict experimental "$OUTFILE" >/dev/null 2>&1

  if [ -f "$OUTFILE" ]; then
    mv "$f" "$OLD_DIR/"
    ((CONVERTED++))
  fi

  # Spinner tick
  printf "\r${RED}⏳ Converting...${NC} %s %d/%d" "${SPIN:i++%${#SPIN}:1}" "$CONVERTED" "$COUNT"
done

printf "\r${RED}✔ Done.${NC} Converted %d of %d file(s). Originals moved to ./old\n" "$CONVERTED" "$COUNT"

#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

URL="$1"
BASE_DIR='/storage/emulated/0/Download/Social Media'
ARCHIVE_DIR='/storage/emulated/0/Download/Social Media/Archives'
COOKIES_DIR='/storage/emulated/0/Download/Social Media/Cookies'
LOG_FILE='/storage/emulated/0/Download/Social Media/Logs/parallel-download.log'
YTDLP_OUTPUT_TEMPLATE='/storage/emulated/0/Download/Social Media/%(extractor)s/%(uploader)s/%(uploader)s_%(autonumber)03d.%(ext)s'
YTDLP_BASE_OPTS='--limit-rate 5M --format "bv*+ba/b" --merge-output-format mp4 --min-sleep-interval 0 --max-sleep-interval 2 --retries 3 --concurrent-fragments 10 --fragment-retries 3 --extractor-retries 3 --yes-playlist --max-downloads 100 --embed-metadata --embed-thumbnail --continue'
DEFAULT_TIMEOUT='600'

timestamp() { date --iso-8601=seconds; }

map_ext_to_subdir() {
  local ext="${1,,}"
  case "$ext" in
    mp4|mkv|webm|mov|flv|ts|avi) echo "Videos" ;;
    jpg|jpeg|png|gif|bmp|webp|heic) echo "Photos" ;;
    mp3|m4a|aac|opus|wav|flac) echo "Audios" ;;
    *) echo "Others" ;;
  esac
}

organize_uploader_dir() {
  local uploader_dir="$1"
  [ -d "$uploader_dir" ] || return 0
  shopt -s nullglob
  for f in "$uploader_dir"/*.*; do
    [ -f "$f" ] || continue
    local fname="$(basename "$f")"
    local ext="${fname##*.}"
    local subdir
    subdir="$(map_ext_to_subdir "$ext")"
    mkdir -p "$uploader_dir/$subdir"
    mv -n "$f" "$uploader_dir/$subdir/" 2>/dev/null || mv -f "$f" "$uploader_dir/$subdir/" 2>/dev/null
  done
  shopt -u nullglob
}

log_line() {
  printf '%s\t%s\n' "$(timestamp)" "$1" >> "$LOG_FILE"
}

# Determine extractor name for archive & cookies
extractor="$(yt-dlp --get-extractor --no-warnings "$URL" 2>/dev/null || echo site)"
archive_file="$ARCHIVE_DIR/${extractor}-archive.txt"
cookie_file="$COOKIES_DIR/${extractor}-cookies.txt"
cookie_opt=""
if [ -f "$cookie_file" ]; then
  cookie_opt="--cookies \"$cookie_file\""
fi

aria_opts=""
if command -v aria2c >/dev/null 2>&1; then
  aria_opts='--external-downloader aria2c --external-downloader-args "-x4 -s4 -k1M"'
fi

# Build and run yt-dlp command
cmd="yt-dlp $YTDLP_BASE_OPTS --download-archive \"$archive_file\" -o \"$YTDLP_OUTPUT_TEMPLATE\" $aria_opts $cookie_opt \"$URL\""
start_ts="$(date +%s)"
if eval "$cmd" >/dev/null 2>&1; then
  end_ts="$(date +%s)"
  dur=$((end_ts - start_ts))
  # Attempt to find uploader name and organize files
  uploader="$(yt-dlp --get-filename -o '%(uploader)s' --no-warnings \"$URL\" 2>/dev/null || true)"
  if [ -n "$uploader" ]; then
    uploader_dir="$BASE_DIR/$extractor/$uploader"
    organize_uploader_dir "$uploader_dir"
    log_line "OK\t$URL\t$uploader_dir\t${dur}s"
  else
    # fallback: try to find a recently modified dir under extractor
    uploader_dir="$(find \"$BASE_DIR/$extractor\" -mindepth 1 -maxdepth 2 -type d -mmin -5 2>/dev/null | sort -r | head -n1 || true)"
    [ -n "$uploader_dir" ] && organize_uploader_dir "$uploader_dir"
    log_line "OK\t$URL\t${uploader_dir:-$BASE_DIR}\t${dur}s"
  fi
  exit 0
else
  log_line "FAIL\t$URL"
  exit 2
fi

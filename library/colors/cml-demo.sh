#!/usr/bin/env bash
# CML Demo v4.9.6 — Status colors adjusted per request
DEMO_VERSION="v4.9.6"
CML_DIR="$HOME/kh-scripts/library/colors"
THEME_FILE="$CML_DIR/.cml_theme"
ENGINE="$CML_DIR/cml-truecolor.sh"

# THEME READ STANDARD
if [ -f "$THEME_FILE" ]; then
  CURRENT_THEME=$(< "$THEME_FILE")
  CURRENT_THEME="${CURRENT_THEME//[$'\r\n']/}"
  CURRENT_THEME="${CURRENT_THEME^^}"
else
  CURRENT_THEME=""
fi
if [ -z "$CURRENT_THEME" ]; then
  CURRENT_THEME="CLASSIC"
  printf "%s" "$CURRENT_THEME" > "$THEME_FILE"
  sync
fi

# --- leading blank so engine load message appears below it ---
echo ""

# SOURCE ENGINE
if [ -f "$ENGINE" ]; then
  # shellcheck source=/dev/null
  source "$ENGINE"
else
  echo "❌ CML TRUECOLOR ENGINE MISSING. INSTALL cml-truecolor.sh"
  exit 1
fi

# ---------- full-spectrum helpers (HSV->RGB) ----------
hsv_to_rgb() {
  awk -v h="$1" -v s="$2" -v v="$3" 'BEGIN{
    if(s == 0){ r=v; g=v; b=v } else {
      h = (h % 360 + 360) % 360; h /= 60; i=int(h); f=h-i
      p = v*(1-s); q = v*(1-s*f); t = v*(1-s*(1-f));
      if(i==0){ r=v; g=t; b=p }
      else if(i==1){ r=q; g=v; b=p }
      else if(i==2){ r=p; g=v; b=t }
      else if(i==3){ r=p; g=q; b=v }
      else if(i==4){ r=t; g=p; b=v }
      else { r=v; g=p; b=q }
    }
    R=int(r*255+0.5); G=int(g*255+0.5); B=int(b*255+0.5)
    printf("%d %d %d", R, G, B)
  }'
}

spectrum_text_smooth() {
  local text="$*"; local len=${#text}
  [ "$len" -le 0 ] && { echo ""; return; }
  local use_rgb=0
  if type rgb_fg >/dev/null 2>&1 && type cml_reset >/dev/null 2>&1; then use_rgb=1; fi
  local i=0 ch H R G B
  while [ $i -lt "$len" ]; do
    ch="${text:i:1}"
    if [ "$len" -eq 1 ]; then H=0; else H=$(awk -v i="$i" -v n="$len" 'BEGIN{printf "%f", (i/(n-1))*360}'); fi
    read R G B <<< "$(hsv_to_rgb "$H" 1 1)"
    if [ "$use_rgb" -eq 1 ]; then
      printf "%s" "$(rgb_fg "$R" "$G" "$B")$ch$(cml_reset)"
    else
      printf "\033[38;2;%d;%d;%dm%s\033[0m" "$R" "$G" "$B" "$ch"
    fi
    i=$((i+1))
  done
  printf "\n"
}

# Replace engine's load line with spectrum message and extra bar above it
TOP_BAR="══════════════════════════════════════════════"
SPECTRUM_MSG="✔ CML TRUECOLOR ENGINE LOADED (v1.6.1-FIXED)"
tput cuu1 2>/dev/null || true
tput el    2>/dev/null || true
spectrum_text_smooth "$TOP_BAR"
spectrum_text_smooth "$SPECTRUM_MSG"

# Ensure engine palette/state is loaded safely
cml_load_palette "$CURRENT_THEME" 2>/dev/null || true
if type cml_refresh_theme >/dev/null 2>&1; then cml_refresh_theme >/dev/null 2>&1 || true; fi

# helpers for forced truecolor printing
print_rgb_line() {
  local R="$1" G="$2" B="$3"; shift 3
  local text="$*"
  if type rgb_fg >/dev/null 2>&1 && type cml_reset >/dev/null 2>&1; then
    printf "%s\n" "$(rgb_fg "$R" "$G" "$B")${text}$(cml_reset)"
  else
    printf "\033[38;2;%d;%d;%dm%s\033[0m\n" "$R" "$G" "$B" "$text"
  fi
}
print_bold_white_line() {
  local text="$*"
  if type rgb_fg >/dev/null 2>&1 && type cml_reset >/dev/null 2>&1; then
    printf "%b\n" "$(rgb_fg 255 255 255)\033[1m${text}$(cml_reset)"
  else
    printf "%b\n" "\e[1;37m${text}\e[0m"
  fi
}
print_header_left() { print_bold_white_line "$*"; }

# ---------- Render demo ----------
# top full-spectrum title box
spectrum_text_smooth "$TOP_BAR"
spectrum_text_smooth "COLOR MASTER LIBRARY (CML) DEMO — ${DEMO_VERSION}"
spectrum_text_smooth "$TOP_BAR"
echo ""

# ACTIVE THEME line (engine handles gradient for this)
if type cml_apply_theme_gradient >/dev/null 2>&1; then
  cml_apply_theme_gradient "ACTIVE THEME: ${CURRENT_THEME}"
elif type cml_colorize >/dev/null 2>&1; then
  cml_colorize title "ACTIVE THEME: ${CURRENT_THEME}"
else
  print_header_left "ACTIVE THEME: ${CURRENT_THEME}"
fi
echo ""

# [1] TITLE COLORS — LEFT-ALIGNED BOLD WHITE
print_header_left "[1] TITLE COLORS"
PANGRAM="THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG."
spectrum_text_smooth "$PANGRAM"
echo ""

# [2] STATUS COLORS — LEFT-ALIGNED BOLD WHITE
print_header_left "[2] STATUS COLORS"
# — UPDATED: exact text + forced colors
print_bold_white_line "INFO"
print_rgb_line 80 200 120  "SUCCESSFUL"
print_rgb_line 255 200 80  "WARNING"
print_rgb_line 255 90 110   "ERROR"
echo ""

# [3] SYMBOLS DEMO — LEFT-ALIGNED BOLD WHITE; glyphs forced bold white
print_header_left "[3] SYMBOLS DEMO"
print_bold_white_line "ARROWS:  ↑  ↓  ←  →  ↔  ↕"
print_bold_white_line "STARS:   ★  ☆  ✦  ✧"
print_bold_white_line "BLOCKS:  █  ▓  ▒  ░"
print_bold_white_line "MISC:    ✔  ✘  ♥  ♪"
echo ""

# final full-spectrum summary box
spectrum_text_smooth "$TOP_BAR"
spectrum_text_smooth "✔ DEMO COMPLETED"
spectrum_text_smooth "$TOP_BAR"
echo ""

exit 0

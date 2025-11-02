#!/usr/bin/env bash
# ============================================================
# File: ~/kh-scripts/library/colors/cml-theme.sh
# Version: CML v4.6.0 — TrueColor Integrated Edition
# Description: Official theme manager powered by CML TrueColor Engine (v1.6.1-fixed)
# ============================================================

CML_DIR="$HOME/kh-scripts/library/colors"
THEME_FILE="$CML_DIR/.cml_theme"
CML_ENGINE="$CML_DIR/cml-truecolor.sh"

# Ensure structure
mkdir -p "$CML_DIR"

# Source TrueColor engine
if [ -f "$CML_ENGINE" ]; then
  # shellcheck disable=SC1090
  source "$CML_ENGINE"
else
  echo "❌ CML TRUECOLOR ENGINE MISSING: $CML_ENGINE"
  exit 1
fi

# Ensure theme file exists
if [ ! -f "$THEME_FILE" ]; then
  printf "%s" "CLASSIC" > "$THEME_FILE"
fi

# ============================================================
# UTILITIES — THEME HANDLING
# ============================================================

read_current_theme() {
  if [ -f "$THEME_FILE" ]; then
    CURRENT_THEME=$(< "$THEME_FILE")
    CURRENT_THEME="${CURRENT_THEME//[$'\r\n']/}"
    CURRENT_THEME="${CURRENT_THEME^^}"
  fi
  [ -z "$CURRENT_THEME" ] && CURRENT_THEME="CLASSIC"
}

write_theme() {
  local T="$1"
  printf "%s" "${T^^}" > "$THEME_FILE"
  sync
}

confirm_and_exit() {
  local msg="$1"
  read_current_theme
  cml_load_palette "$CURRENT_THEME"
  echo
  cml_colorize "$CML_FG_R" "$CML_FG_G" "$CML_FG_B" "✔ ${msg^^}"
  echo
  sleep 0.7
  clear
  exit 0
}

# ============================================================
# UTILITIES — DRAWING AND BOXING
# ============================================================

compute_box_width() {
  local cols=$(tput cols 2>/dev/null || echo 80)
  cols=${cols//[^0-9]/}
  [ -z "$cols" ] && cols=80
  local w=$(( cols * 8 / 10 ))
  [ "$w" -lt 40 ] && w=40
  local max_w=$(( cols - 4 ))
  [ "$w" -gt "$max_w" ] && w=$max_w
  printf "%d" "$w"
}

make_line() {
  local width="$1" ch="$2" line
  [ -z "$width" ] && width=50
  [ -z "$ch" ] && ch='═'
  printf -v line "%*s" "$width" ""
  echo "${line// /$ch}"
}

draw_boxed_title() {
  local title="$1"
  read_current_theme
  cml_load_palette "$CURRENT_THEME"
  local width padding_left padding_right
  width=$(compute_box_width)

  printf "%b╔%s╗%b\n" "$(rgb_fg "$CML_FG_R" "$CML_FG_G" "$CML_FG_B")" "$(make_line "$width" "═")" "$reset"

  padding_left=$(( (width - ${#title}) / 2 ))
  padding_right=$(( width - ${#title} - padding_left ))
  [ "$padding_left" -lt 0 ] && padding_left=0
  [ "$padding_right" -lt 0 ] && padding_right=0

  printf "%b║%*s%s%*s║%b\n" \
    "$(rgb_fg "$CML_FG_R" "$CML_FG_G" "$CML_FG_B")" \
    "$padding_left" "" \
    "$title" \
    "$padding_right" "" \
    "$reset"

  printf "%b╚%s╝%b\n" "$(rgb_fg "$CML_FG_R" "$CML_FG_G" "$CML_FG_B")" "$(make_line "$width" "═")" "$reset"
  echo
}

# ============================================================
# MENU DRAWING FUNCTIONS
# ============================================================

draw_main_menu_items() {
  local -n items_ref="$1"
  local i item num emoji
  local emojis=("🎩" "🌲" "🐪" "🌊" "🌞" "⛄" "🃏" "🌈")

  for i in "${!items_ref[@]}"; do
    item="${items_ref[$i]}"
    num=$(( i + 1 ))
    emoji="${emojis[$i]}"

    printf "   "
    cml_colorize 255 253 208 "$num   $emoji   "

    if [ "$item" = "NEON" ]; then
      cml_load_palette "$CURRENT_THEME"
      cml_colorize "$CML_FG_R" "$CML_FG_G" "$CML_FG_B" "NEON"
      cml_colorize 255 253 208 "      »»  Choose Base Color"
      echo
    else
      cml_load_palette "$item"
      cml_colorize "$CML_FG_R" "$CML_FG_G" "$CML_FG_B" "$item"
      echo
    fi
  done
}

draw_neon_menu_items() {
  local -n items_ref="$1"
  local i item num emoji
  local emojis=("🔴" "🟠" "🟡" "🟢" "🔵" "🟣")

  for i in "${!items_ref[@]}"; do
    item="${items_ref[$i]}"
    num=$(( i + 1 ))
    emoji="${emojis[$i]}"
    local display="${item#NEON:}"

    printf "   "
    cml_colorize 255 253 208 "$num   $emoji   "

    if [ "$item" = "$CURRENT_THEME" ]; then
      cml_load_palette "$item"
      cml_colorize "$CML_FG_R" "$CML_FG_G" "$CML_FG_B" "$display"
      cml_colorize 255 253 208 "      »»  🌟  Active Theme"
      echo
    else
      cml_load_palette "$item"
      cml_colorize "$CML_FG_R" "$CML_FG_G" "$CML_FG_B" "$display"
      echo
    fi
  done
}

draw_main_menu() {
  clear
  draw_boxed_title "CML v4.6.0 → THEME SELECTION"
  local items=(CLASSIC FOREST DESERT OCEAN SUMMER WINTER WILD NEON)
  draw_main_menu_items items
  echo
  echo
  cml_colorize 255 100 100 "   💢   🚨   PRESS ESC TO ABORT & EXIT"
  echo
  echo
  echo
  cml_colorize 255 253 208 "   🧮   🎨   THEME SELECTION : "
}

draw_neon_menu() {
  clear
  draw_boxed_title "CML v4.6.0 → NEON BASE COLOR SELECTION"
  local items=(NEON:RED NEON:ORANGE NEON:YELLOW NEON:GREEN NEON:BLUE NEON:PURPLE)
  draw_neon_menu_items items
  echo
  echo
  cml_colorize 255 100 100 "   💢   🔙   PRESS ESC TO GO BACK"
  echo
  echo
  echo
  cml_colorize 255 253 208 "   🧮   🎨   NEON BASE COLOR SELECTION : "
}

# ============================================================
# MAIN LOOP
# ============================================================

while true; do
  read_current_theme
  draw_main_menu
  IFS= read -rsn1 key
  case "$key" in
    $'\e') clear; exit 0 ;;
    1) write_theme "CLASSIC"; confirm_and_exit "THEME SET TO: CLASSIC" ;;
    2) write_theme "FOREST";  confirm_and_exit "THEME SET TO: FOREST" ;;
    3) write_theme "DESERT";  confirm_and_exit "THEME SET TO: DESERT" ;;
    4) write_theme "OCEAN";   confirm_and_exit "THEME SET TO: OCEAN" ;;
    5) write_theme "SUMMER";  confirm_and_exit "THEME SET TO: SUMMER" ;;
    6) write_theme "WINTER";  confirm_and_exit "THEME SET TO: WINTER" ;;
    7) write_theme "WILD";    confirm_and_exit "THEME SET TO: WILD" ;;
    8)
      while true; do
        read_current_theme
        draw_neon_menu
        IFS= read -rsn1 nkey
        case "$nkey" in
          $'\e') break ;;
          1) write_theme "NEON:RED";    confirm_and_exit "THEME SET TO: NEON:RED" ;;
          2) write_theme "NEON:ORANGE"; confirm_and_exit "THEME SET TO: NEON:ORANGE" ;;
          3) write_theme "NEON:YELLOW"; confirm_and_exit "THEME SET TO: NEON:YELLOW" ;;
          4) write_theme "NEON:GREEN";  confirm_and_exit "THEME SET TO: NEON:GREEN" ;;
          5) write_theme "NEON:BLUE";   confirm_and_exit "THEME SET TO: NEON:BLUE" ;;
          6) write_theme "NEON:PURPLE"; confirm_and_exit "THEME SET TO: NEON:PURPLE" ;;
          *) ;;
        esac
      done
      ;;
    *) ;;
  esac
done

#!/usr/bin/env bash
# File: ~/kh-scripts/library/colors/cml-theme.sh
# CML Theme Manager v4.3.0
# - Uppercase enforced
# - Two-space formatting
# - NEON sub-menu inline
# - ✔ = current, > = has sub-menu
# - Clean confirmation + clear before exit (no stuck prompt)

CML_DIR="$HOME/kh-scripts/library/colors"
THEME_FILE="$CML_DIR/.cml_theme"

# ensure directory + theme file (uppercase default)
mkdir -p "$CML_DIR"
[ -f "$THEME_FILE" ] || echo "CLASSIC" > "$THEME_FILE"

# read current theme (trim CR/LF and uppercase)
read_current_theme() {
  CURRENT_THEME=$(< "$THEME_FILE")
  CURRENT_THEME="${CURRENT_THEME//[$'\r\n']/}"
  CURRENT_THEME="${CURRENT_THEME^^}"
}

# write theme (always uppercase)
write_theme() {
  local t="$1"
  # ensure uppercase when storing
  printf "%s" "${t^^}" > "$THEME_FILE"
}

# confirmation that prints, pauses, clears, then exits
confirm_and_exit() {
  local msg="$1"
  echo    # fresh line
  printf "✔ %s\n" "${msg^^}"
  sleep 0.7
  clear
  exit 0
}

# draw main menu
draw_main_menu() {
  clear
  echo "=== CML v4.3.0 → THEME SELECTION ==="
  echo
  local items=(CLASSIC NEON FOREST DESERT OCEAN SUMMER WINTER WILD)
  local i=1
  for theme in "${items[@]}"; do
    local mark=""
    local arrow=""
    # mark if current (NEON considered current if CURRENT_THEME starts with NEON:)
    if [[ "$CURRENT_THEME" == "$theme" ]] || [[ "$CURRENT_THEME" == NEON:* && "$theme" == "NEON" ]]; then
      mark="  ✔"
    fi
    # add arrow for NEON submenu
    if [[ "$theme" == "NEON" ]]; then
      arrow="  >"
    fi
    # double-space after bracket
    printf "<%d>  %s%s%s\n" "$i" "$theme" "$mark" "$arrow"
    i=$((i+1))
  done
  echo
  echo "• ✔ = CURRENT THEME"
  echo "• > = CHOOSE COLOR"
  echo "• PRESS ESC TO EXIT."
  echo
  # Prompt is safe because every exit path will clear before exit
  echo -n "• THEME SELECTION: "
}

# draw neon submenu
draw_neon_menu() {
  clear
  echo "=== CML v4.3.0 → NEON THEME BASE COLOR SELECTION ==="
  echo
  local colors=(RED ORANGE YELLOW GREEN BLUE PURPLE)
  local i=1
  for c in "${colors[@]}"; do
    local mark=""
    if [[ "$CURRENT_THEME" == "NEON:$c" ]]; then
      mark="  ✔"
    fi
    printf "<%d>  %s%s\n" "$i" "$c" "$mark"
    i=$((i+1))
  done
  echo
  echo "• ✔ = CURRENT COLOR"
  echo "• PRESS ESC TO GO BACK."
  echo
  echo -n "• NEON BASE COLOR SELECTION: "
}

# main run loop
while true; do
  read_current_theme
  draw_main_menu

  # single keypress
  IFS= read -rsn1 key
  case "$key" in
    $'\e') clear; exit 0 ;;                       # ESC: clean exit from main menu
    1) write_theme "CLASSIC"; confirm_and_exit "THEME SET TO: CLASSIC" ;;
    2)                                            # NEON submenu
       while true; do
         read_current_theme
         draw_neon_menu
         IFS= read -rsn1 nkey
         case "$nkey" in
           $'\e') break ;;                       # ESC: back to main menu
           1) write_theme "NEON:RED";  confirm_and_exit "THEME SET TO: NEON:RED" ;;
           2) write_theme "NEON:ORANGE"; confirm_and_exit "THEME SET TO: NEON:ORANGE" ;;
           3) write_theme "NEON:YELLOW"; confirm_and_exit "THEME SET TO: NEON:YELLOW" ;;
           4) write_theme "NEON:GREEN"; confirm_and_exit "THEME SET TO: NEON:GREEN" ;;
           5) write_theme "NEON:BLUE"; confirm_and_exit "THEME SET TO: NEON:BLUE" ;;
           6) write_theme "NEON:PURPLE"; confirm_and_exit "THEME SET TO: NEON:PURPLE" ;;
           *) ;;  # ignore other keys
         esac
       done
       ;;
    3) write_theme "FOREST"; confirm_and_exit "THEME SET TO: FOREST" ;;
    4) write_theme "DESERT"; confirm_and_exit "THEME SET TO: DESERT" ;;
    5) write_theme "OCEAN";  confirm_and_exit "THEME SET TO: OCEAN" ;;
    6) write_theme "SUMMER"; confirm_and_exit "THEME SET TO: SUMMER" ;;
    7) write_theme "WINTER"; confirm_and_exit "THEME SET TO: WINTER" ;;
    8) write_theme "WILD";   confirm_and_exit "THEME SET TO: WILD" ;;
    *) ;; # ignore other keys
  esac
done

#!/usr/bin/env bash
# File: ~/kh-scripts/library/colors/cml-theme.sh
# CML Theme Manager v4.5.1 — TrueColor, single-column menu

CML_DIR="$HOME/kh-scripts/library/colors"
THEME_FILE="$CML_DIR/.cml_theme"

mkdir -p "$CML_DIR"
[ -f "$THEME_FILE" ] || printf "%s" "CLASSIC" > "$THEME_FILE"

reset='\033[0m'
rgb_fg()  { printf '\033[38;2;%d;%d;%dm' "$1" "$2" "$3"; }
bold='\033[1m'

get_theme_rgb() {
  local theme="${1:-}"
  case "${theme^^}" in
    CLASSIC)      echo "255 255 255" ;;
    NEON:RED)     echo "255 0 0" ;;
    NEON:ORANGE)  echo "255 165 0" ;;
    NEON:YELLOW)  echo "255 255 0" ;;
    NEON:GREEN)   echo "0 255 0" ;;
    NEON:BLUE)    echo "100 150 255" ;;      # Brighter blue
    NEON:PURPLE)  echo "180 80 255" ;;       # Brighter purple
    NEON)         echo "0 255 255" ;;
    FOREST)       echo "50 220 50" ;;        # Brighter forest green
    DESERT)       echo "230 200 160" ;;      # Brighter desert
    OCEAN)        echo "0 150 220" ;;        # Brighter ocean
    SUMMER)       echo "255 140 0" ;;
    WINTER)       echo "100 220 255" ;;      # Brighter winter
    WILD)         echo "255 50 180" ;;       # Brighter wild
    *)            echo "255 255 255" ;;
  esac
}

compute_box_width() {
  local cols
  cols=$(tput cols 2>/dev/null || echo 80)
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
  [ -z "$ch" ] && ch='='
  printf -v line "%*s" "$width" ""
  echo "${line// /$ch}"
}

color_print() {
  local r="$1" g="$2" b="$3"
  shift 3
  printf '%b%s%b' "$(rgb_fg "$r" "$g" "$b")" "$*" "$reset"
}

color_print_bold() {
  local r="$1" g="$2" b="$3"
  shift 3
  printf '%b%b%s%b' "$bold" "$(rgb_fg "$r" "$g" "$b")" "$*" "$reset"
}

read_current_theme() {
  if [ -f "$THEME_FILE" ]; then
    CURRENT_THEME=$(< "$THEME_FILE")
    CURRENT_THEME="${CURRENT_THEME//[$'\r\n']/}"
    CURRENT_THEME="${CURRENT_THEME^^}"
  fi
  [ -z "$CURRENT_THEME" ] && CURRENT_THEME="CLASSIC"
}

write_theme() {
  local t="$1"
  printf "%s" "${t^^}" > "$THEME_FILE"
}

confirm_and_exit() {
  local msg="$1"
  read_current_theme
  read -r r g b <<< "$(get_theme_rgb "$CURRENT_THEME")"
  echo
  color_print "$r" "$g" "$b" "✔ ${msg^^}"
  echo
  sleep 0.7
  clear
  exit 0
}

draw_boxed_title() {
  local title="$1" width padding_left padding_right
  width=$(compute_box_width)
  read -r r g b <<< "$(get_theme_rgb "$CURRENT_THEME")"
  local color_code=$(rgb_fg "$r" "$g" "$b")

  printf "%b╔%s╗%b\n" "$color_code" "$(make_line "$width" "═")" "$reset"
  
  padding_left=$(( (width - ${#title}) / 2 ))
  padding_right=$(( width - ${#title} - padding_left ))
  [ "$padding_left" -lt 0 ] && padding_left=0
  [ "$padding_right" -lt 0 ] && padding_right=0
  
  printf "%b║%*s%b%s%b%*s║%b\n" \
    "$color_code" \
    "$padding_left" "" \
    "$color_code" "$title" \
    "$color_code" \
    "$padding_right" "" \
    "$reset"
    
  printf "%b╚%s╝%b\n" "$color_code" "$(make_line "$width" "═")" "$reset"
  echo
}

draw_main_menu_items() {
  local -n items_ref="$1"
  local i item num emoji
  local emojis=("🎩" "🌲" "🐪" "🌊" "🌞" "⛄" "🃏" "🌈")
  
  for i in "${!items_ref[@]}"; do
    item="${items_ref[$i]}"
    num=$(( i + 1 ))
    emoji="${emojis[$i]}"
    
    # Print number in cream bold
    printf "   "
    color_print_bold 255 253 208 "$num   $emoji   "
    
    if [ "$item" = "NEON" ]; then
      # NEON with active theme color and cream note
      read -r r g b <<< "$(get_theme_rgb "$CURRENT_THEME")"
      color_print_bold "$r" "$g" "$b" "NEON"
      color_print_bold 255 253 208 "      »»  Choose Base Color"
      echo
    else
      # Regular theme in its own color
      read -r r g b <<< "$(get_theme_rgb "$item")"
      color_print_bold "$r" "$g" "$b" "$item"
      echo
    fi
  done
}

draw_neon_menu_items() {
  local -n items_ref="$1"
  local i item num color_emoji display_name
  local color_emojis=("🔴" "🟠" "🟡" "🟢" "🔵" "🟣")
  
  for i in "${!items_ref[@]}"; do
    item="${items_ref[$i]}"
    num=$(( i + 1 ))
    color_emoji="${color_emojis[$i]}"
    
    # Remove "NEON:" prefix for display
    display_name="${item#NEON:}"
    
    # Print number in cream bold
    printf "   "
    color_print_bold 255 253 208 "$num   $color_emoji   "
    
    if [ "$item" = "$CURRENT_THEME" ]; then
      # Active theme with color name and cream note
      read -r r g b <<< "$(get_theme_rgb "$item")"
      color_print_bold "$r" "$g" "$b" "$display_name"
      color_print_bold 255 253 208 "      »»  🌟  Active Theme"
      echo
    else
      # Regular item in its own color
      read -r r g b <<< "$(get_theme_rgb "$item")"
      color_print_bold "$r" "$g" "$b" "$display_name"
      echo
    fi
  done
}

draw_main_menu() {
  clear
  draw_boxed_title "CML v4.5.1 → THEME SELECTION"
  
  # New theme sequence: CLASSIC, FOREST, DESERT, OCEAN, SUMMER, WINTER, WILD, NEON
  local items=(CLASSIC FOREST DESERT OCEAN SUMMER WINTER WILD NEON)
  draw_main_menu_items items
  
  echo
  echo
  color_print_bold 255 100 100 "   💢   🚨   PRESS ESC TO ABORT & EXIT"
  echo
  echo
  echo
  color_print_bold 255 253 208 "   🧮   🎨   THEME SELECTION : "
}

draw_neon_menu() {
  clear
  draw_boxed_title "CML v4.5.1 → NEON BASE COLOR SELECTION"
  
  local items=(NEON:RED NEON:ORANGE NEON:YELLOW NEON:GREEN NEON:BLUE NEON:PURPLE)
  draw_neon_menu_items items
  
  echo
  echo
  color_print_bold 255 100 100 "   💢   🔙   PRESS ESC TO GO BACK"
  echo
  echo
  echo
  color_print_bold 255 253 208 "   🧮   🎨   NEON BASE COLOR SELECTION : "
}

while true; do
  read_current_theme
  draw_main_menu
  IFS= read -rsn1 key
  case "$key" in
    $'\e') clear; exit 0 ;;
    1) write_theme "CLASSIC"; confirm_and_exit "THEME SET TO: CLASSIC" ;;
    2) write_theme "FOREST"; confirm_and_exit "THEME SET TO: FOREST" ;;
    3) write_theme "DESERT"; confirm_and_exit "THEME SET TO: DESERT" ;;
    4) write_theme "OCEAN";  confirm_and_exit "THEME SET TO: OCEAN" ;;
    5) write_theme "SUMMER"; confirm_and_exit "THEME SET TO: SUMMER" ;;
    6) write_theme "WINTER"; confirm_and_exit "THEME SET TO: WINTER" ;;
    7) write_theme "WILD";   confirm_and_exit "THEME SET TO: WILD" ;;
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

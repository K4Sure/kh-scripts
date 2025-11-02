#!/data/data/com.termux/files/usr/bin/bash
CHEAT="$HOME/.config/ranger/cheatsheet-neon.txt"
mkdir -p "$(dirname "$CHEAT")"

# ANSI colors
RED=$'\e[38;2;255;0;0m'
ORANGE=$'\e[38;2;255;165;0m'
PINK=$'\e[38;2;255;105;180m'
CREAM=$'\e[38;2;255;253;208m'
GREEN=$'\e[38;2;0;255;0m'
BOLD=$'\e[1m'
RESET=$'\e[0m'

# Terminal width
TERM_WIDTH=$(tput cols 2>/dev/null)
[ -z "$TERM_WIDTH" ] && TERM_WIDTH=80
BOX_WIDTH=$(( TERM_WIDTH * 70 / 100 ))
[ $BOX_WIDTH -lt 50 ] && BOX_WIDTH=50
INNER=$(( BOX_WIDTH - 2 ))

visible_len() { echo -n "$1" | sed -r 's/\x1b\[[0-9;]*m//g' | wc -c | tr -d ' '; }

center_in_box() {
  local text="$1"
  local vlen=$(visible_len "$text")
  local pad_left=$(( (INNER - vlen) / 2 ))
  local pad_right=$(( INNER - vlen - pad_left ))
  printf "%*s%s%*s\n" "$pad_left" "" "$text" "$pad_right" ""
}

{
printf '%s' "$RED"
printf '╔'; printf '═%.0s' $(seq 1 $INNER); printf '╗\n'
printf '%s' "$RESET"

center_in_box "${BOLD}${CREAM}RANGER — TERMINAL FILE MANAGER${RESET}"
center_in_box "${BOLD}${ORANGE}CUSTOM KEY REFERENCE${RESET}"

printf '%s' "$RED"
printf '╚'; printf '═%.0s' $(seq 1 $INNER); printf '╝\n'
printf '%s' "$RESET"

INDENT_SECTION="   "
INDENT_KEYS="     "

printf "\n"
# MOVEMENT
printf "%s%s%s\n" "$PINK$BOLD" "${INDENT_SECTION}MOVEMENT" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}←      MOVE LEFT" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}↓      MOVE DOWN" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}↑      MOVE UP" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}→      MOVE RIGHT" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}F      JUMP TO FIRST ITEM" "$RESET"
printf "%s%s%s\n\n" "$CREAM$BOLD" "${INDENT_KEYS}L      JUMP TO LAST ITEM" "$RESET"

# FILE OPERATIONS
printf "%s%s%s\n" "$PINK$BOLD" "${INDENT_SECTION}FILE OPERATIONS" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}C      COPY" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}P      PASTE" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}R      RENAME" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}X      DELETE" "$RESET"

# SELECTION
printf "\n%s%s%s\n" "$PINK$BOLD" "${INDENT_SECTION}SELECTION" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}a      ADD TO SELECTION" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}v      TOGGLE SELECTION MODE" "$RESET"

# SEARCH
printf "\n%s%s%s\n" "$PINK$BOLD" "${INDENT_SECTION}SEARCH" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}/      SEARCH" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}n      NEXT RESULT" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}N      PREVIOUS RESULT" "$RESET"

# UI / VIEW
printf "\n%s%s%s\n" "$PINK$BOLD" "${INDENT_SECTION}UI / VIEW" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}i      TOGGLE PREVIEW" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}H      TOGGLE HIDDEN FILES" "$RESET"

# OTHER
printf "\n%s%s%s\n" "$PINK$BOLD" "${INDENT_SECTION}OTHER" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}:      COMMAND MODE" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}r      CHOOSE PROGRAM" "$RESET"
printf "%s%s%s\n" "$GREEN$BOLD" "${INDENT_KEYS}?      SHOW THIS HELPER" "$RESET"
printf "%s%s%s\n" "$CREAM$BOLD" "${INDENT_KEYS}q      QUIT" "$RESET"

} > "$CHEAT"

printf "✔ NEON CHEATSHEET UPDATED: %s\n" "$CHEAT"

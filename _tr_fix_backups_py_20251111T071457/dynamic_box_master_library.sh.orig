#!/data/data/com.termux/files/usr/bin/env bash
# dynamic_box_master_library.sh — v4.0.0
# Purpose: Fancy ASCII/Unicode boxes for KH scripts (DBML)
# Depends on: Color Master Library (CML)
# Location: kh-scripts/library/dynamic_box

set -euo pipefail

# Load CML if available
CML_PATH="$HOME/kh-scripts/library/colors/color_master_library.sh"
if [ -f "$CML_PATH" ]; then
    # shellcheck source=/dev/null
    source "$CML_PATH"
else
    echo "⚠️ CML not found at $CML_PATH. Boxes will be colorless."
    RESET=""
    CML_FG=([primary]="" [accent]="" [muted]="" [error]="" [success]="")
fi

# Basic box-drawing chars
declare -A BOX_CHARS
BOX_CHARS[line]="─│┌┐└┘"
BOX_CHARS[double]="═║╔╗╚╝"
BOX_CHARS[round]="─│╭╮╰╯"

# draw_box STYLE "TITLE" "TEXT..."
draw_box() {
    local style="$1"; shift
    local title="$1"; shift
    local content=("$@")

    local chars
    chars=($(echo "${BOX_CHARS[$style]}" | grep -o .))
    local h="${chars[0]}"; local v="${chars[1]}"
    local tl="${chars[2]}"; local tr="${chars[3]}"
    local bl="${chars[4]}"; local br="${chars[5]}"
    local tl="${chars[2]}"; local tr="${chars[3]}"
    local bl="${chars[4]}"; local br="${chars[5]}"

    local width=0
    for line in "$title" "${content[@]}"; do
        (( ${#line} > width )) && width=${#line}
    done
    width=$((width + 2)) # padding

    local color="${CML_FG[accent]:-}"
    local reset="$RESET"

    # Top
    printf "%s%s" "$color" "$tl"
    printf "%${width}s" | tr ' ' "$h"
    printf "%s%s\n" "$tr" "$reset"

    # Title
    printf "%s%s %-*s %s\n" "$color" "$v" "$width" "$title" "$v$reset"

    # Content
    for line in "${content[@]}"; do
        printf "%s%s %-*s %s\n" "$color" "$v" "$width" "$line" "$v$reset"
    done

    # Bottom
    printf "%s%s" "$color" "$bl"
    printf "%${width}s" | tr ' ' "$h"
    printf "%s%s\n" "$br" "$reset"
}

# Pulse box — cycles through accent colors
pulse_box() {
    local style="$1"; shift
    local title="$1"; shift
    local content=("$@")
    local cycles=3
    for c in "${PULSE_COLORS[@]}"; do
        CML_FG[accent]="$c"
        draw_box "$style" "$title" "${content[@]}"
        sleep 0.3
    done
}

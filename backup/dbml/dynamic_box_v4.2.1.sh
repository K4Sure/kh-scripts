# ==============================
# Dynamic Box Master Library (DBML)
# Version: v4.2.1
# Location: ~/kh-scripts/library/dynamic_box/dynamic_box.sh
# Backup:   ~/kh-scripts/backup/dynamic_box_v4.2.1.sh
# ==============================
# Changelog v4.2.1:
# - Fixed bug: border generation using tr (empty symbol crash)
# - Replaced with safe printf loop for horizontal borders
# ==============================

#!/bin/bash

dbml_version="v4.2.1"

# --- Dependency: CSML ---
if [ -f ~/kh-scripts/library/symbols/symbols.sh ]; then
    source ~/kh-scripts/library/symbols/symbols.sh
else
    echo "[DBML] Warning: CSML not found. Using fallback characters."
    # Fallback chars
    sym_box_single_tl="┌"; sym_box_single_tr="┐"
    sym_box_single_bl="└"; sym_box_single_br="┘"
    sym_box_single_h="─"; sym_box_single_v="│"

    sym_box_double_tl="╔"; sym_box_double_tr="╗"
    sym_box_double_bl="╚"; sym_box_double_br="╝"
    sym_box_double_h="═"; sym_box_double_v="║"

    sym_box_rounded_tl="╭"; sym_box_rounded_tr="╮"
    sym_box_rounded_bl="╰"; sym_box_rounded_br="╯"
    sym_box_rounded_h="─"; sym_box_rounded_v="│"
fi

# --- Core box drawing function ---
draw_box() {
    local style=$1
    shift
    local lines=("$@")

    # Pick symbols
    case "$style" in
        single)
            tl=$sym_box_single_tl; tr=$sym_box_single_tr
            bl=$sym_box_single_bl; br=$sym_box_single_br
            h=$sym_box_single_h;   v=$sym_box_single_v
            ;;
        double)
            tl=$sym_box_double_tl; tr=$sym_box_double_tr
            bl=$sym_box_double_bl; br=$sym_box_double_br
            h=$sym_box_double_h;   v=$sym_box_double_v
            ;;
        rounded)
            tl=$sym_box_rounded_tl; tr=$sym_box_rounded_tr
            bl=$sym_box_rounded_bl; br=$sym_box_rounded_br
            h=$sym_box_rounded_h;   v=$sym_box_rounded_v
            ;;
    esac

    # Find max width
    local max_len=0
    for line in "${lines[@]}"; do
        [ ${#line} -gt $max_len ] && max_len=${#line}
    done

    # Top border
    printf "%s" "$tl"
    for ((i=0; i<max_len; i++)); do printf "%s" "$h"; done
    printf "%s\n" "$tr"

    # Content
    for line in "${lines[@]}"; do
        local pad=$((max_len - ${#line}))
        printf "%s%s%*s%s\n" "$v" "$line" $pad "" "$v"
    done

    # Bottom border
    printf "%s" "$bl"
    for ((i=0; i<max_len; i++)); do printf "%s" "$h"; done
    printf "%s\n" "$br"
}

# --- Public wrappers ---
box_single() { draw_box single "$@"; }
box_double() { draw_box double "$@"; }
box_rounded() { draw_box rounded "$@"; }

# Auto-detect style
box_auto() {
    local style=$1
    shift
    IFS="|" read -r -a lines <<< "$*"
    draw_box "$style" "${lines[@]}"
}

# Wrap long text
box_wrap() {
    local style=$1
    local width=$2
    shift 2
    local text="$*"

    local wrapped=()
    local line=""
    for word in $text; do
        if [ $((${#line} + ${#word} + 1)) -le $width ]; then
            [ -z "$line" ] && line="$word" || line="$line $word"
        else
            wrapped+=("$line")
            line="$word"
        fi
    done
    [ -n "$line" ] && wrapped+=("$line")

    draw_box "$style" "${wrapped[@]}"
}

# Pulse (uses CML if installed)
pulse_box() {
    local style=$1
    local text="$2"
    for i in {1..3}; do
        if declare -F cml_pulse >/dev/null; then
            cml_pulse "$(draw_box "$style" "$text")"
        else
            draw_box "$style" "$text"
        fi
        sleep 0.3
    done
}

# Version
dbml_version() { echo "DBML $dbml_version"; }

# EOF

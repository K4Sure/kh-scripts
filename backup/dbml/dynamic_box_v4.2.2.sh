#!/bin/bash
# Dynamic Box Master Library (DBML)
# Version: 4.2.2 (stable, no tofu issue)

# Ensure UTF-8 environment
export LANG=${LANG:-en_US.UTF-8}
export LC_ALL=${LC_ALL:-en_US.UTF-8}

# Version function
dbml_version() {
    echo "DBML v4.2.2"
}

# Core drawing sets
BOX_SINGLE=( "┌" "─" "┐" "│" "└" "┘" )
BOX_DOUBLE=( "╔" "═" "╗" "║" "╚" "╝" )
BOX_ROUNDED=( "╭" "─" "╮" "│" "╰" "╯" )

# Draw simple box
# Usage: box_draw <style> <text>
box_draw() {
    local style="$1"; shift
    local text="$*"
    local chars=()

    case "$style" in
        single)  chars=("${BOX_SINGLE[@]}") ;;
        double)  chars=("${BOX_DOUBLE[@]}") ;;
        rounded) chars=("${BOX_ROUNDED[@]}") ;;
        *) echo "Unknown style: $style" >&2; return 1 ;;
    esac

    local len=${#text}
    local top="${chars[0]}$(printf "%${len}s" "" | tr " " "${chars[1]}")${chars[2]}"
    local mid="${chars[3]}${text}${chars[3]}"
    local bot="${chars[4]}$(printf "%${len}s" "" | tr " " "${chars[1]}")${chars[5]}"

    echo "$top"
    echo "$mid"
    echo "$bot"
}

# Auto box with multi-line support
# Usage: box_auto <style> "line1|line2|line3"
box_auto() {
    local style="$1"; shift
    local lines=()
    IFS="|" read -r -a lines <<< "$*"
    local chars=()
    local maxlen=0

    case "$style" in
        single)  chars=("${BOX_SINGLE[@]}") ;;
        double)  chars=("${BOX_DOUBLE[@]}") ;;
        rounded) chars=("${BOX_ROUNDED[@]}") ;;
        *) echo "Unknown style: $style" >&2; return 1 ;;
    esac

    for line in "${lines[@]}"; do
        (( ${#line} > maxlen )) && maxlen=${#line}
    done

    local top="${chars[0]}$(printf "%${maxlen}s" "" | tr " " "${chars[1]}")${chars[2]}"
    echo "$top"
    for line in "${lines[@]}"; do
        printf "%s%-*s%s\n" "${chars[3]}" "$maxlen" "$line" "${chars[3]}"
    done
    local bot="${chars[4]}$(printf "%${maxlen}s" "" | tr " " "${chars[1]}")${chars[5]}"
    echo "$bot"
}

# Demo function
dbml_demo() {
    echo "Single-line box:"
    box_draw single "DBML v4.2.2"
    echo
    echo "Double-line box:"
    box_draw double "DBML v4.2.2"
    echo
    echo "Rounded box:"
    box_draw rounded "DBML v4.2.2"
}

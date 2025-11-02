#!/bin/bash
# Dynamic Box Master Library (DBML)
# Version: v4.2.2 (UTF-8 Safe, no tr)
# Location: ~/kh-scripts/library/dynamic_box/dynamic_box.sh

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

DBML_VERSION="v4.2.2"

# --- Safe character repeater (no tr, UTF-8 safe) ---
repeat_char() {
    local char="$1"
    local count="$2"
    local out=""
    for ((i=0; i<count; i++)); do
        out+="$char"
    done
    printf '%s' "$out"
}

# --- Box drawing sets ---
declare -A BOX_CHARS
BOX_CHARS[single_ul]="┌"; BOX_CHARS[single_ur]="┐"
BOX_CHARS[single_ll]="└"; BOX_CHARS[single_lr]="┘"
BOX_CHARS[single_h]="─"; BOX_CHARS[single_v]="│"

BOX_CHARS[double_ul]="╔"; BOX_CHARS[double_ur]="╗"
BOX_CHARS[double_ll]="╚"; BOX_CHARS[double_lr]="╝"
BOX_CHARS[double_h]="═"; BOX_CHARS[double_v]="║"

BOX_CHARS[round_ul]="╭"; BOX_CHARS[round_ur]="╮"
BOX_CHARS[round_ll]="╰"; BOX_CHARS[round_lr]="╯"
BOX_CHARS[round_h]="─"; BOX_CHARS[round_v]="│"

# --- Draw a box around text (single line) ---
box_draw() {
    local style="$1"
    local text="$2"
    local h="${BOX_CHARS[${style}_h]}"
    local v="${BOX_CHARS[${style}_v]}"
    local ul="${BOX_CHARS[${style}_ul]}"
    local ur="${BOX_CHARS[${style}_ur]}"
    local ll="${BOX_CHARS[${style}_ll]}"
    local lr="${BOX_CHARS[${style}_lr]}"

    local width=${#text}
    local line
    line=$(repeat_char "$h" "$width")

    echo "${ul}${line}${ur}"
    echo "${v}${text}${v}"
    echo "${ll}${line}${lr}"
}

# --- Auto box for multi-line input ---
box_auto() {
    local style="$1"
    shift
    local lines=("$@")
    local max=0
    for l in "${lines[@]}"; do
        (( ${#l} > max )) && max=${#l}
    done

    local h="${BOX_CHARS[${style}_h]}"
    local v="${BOX_CHARS[${style}_v]}"
    local ul="${BOX_CHARS[${style}_ul]}"
    local ur="${BOX_CHARS[${style}_ur]}"
    local ll="${BOX_CHARS[${style}_ll]}"
    local lr="${BOX_CHARS[${style}_lr]}"

    local line
    line=$(repeat_char "$h" "$max")

    echo "${ul}${line}${ur}"
    for l in "${lines[@]}"; do
        printf "%s%-*s%s\n" "$v" "$max" "$l" "$v"
    done
    echo "${ll}${line}${lr}"
}

# --- Version check ---
dbml_version() {
    echo "Dynamic Box Master Library $DBML_VERSION"
}

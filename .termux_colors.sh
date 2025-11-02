#!/usr/bin/env bash
# K4Sure Global Color Library with Theme Switcher + Runtime Override
# Path: /data/data/com.termux/files/usr/bin/.termux_colors.sh
# Version: 2.2
# Last Updated: 2025-08-30

# ─────────────────────────────
# 1. THEME SELECTION
# ─────────────────────────────
DEFAULT_THEME="warm"
THEME="${1:-$DEFAULT_THEME}"  # Accept runtime override

# ─────────────────────────────
# 2. DETECT COLOR CAPABILITY
# ─────────────────────────────
if [[ -t 1 ]] && [[ $(tput colors) -ge 256 ]]; then
    COLOR_MODE="256"
else
    COLOR_MODE="basic"
fi

# ─────────────────────────────
# 3. RESET & TEXT ATTRIBUTES
# ─────────────────────────────
RESET=$'\e[0m'
BOLD=$'\e[1m'
DIM=$'\e[2m'
UNDERLINE=$'\e[4m'
BLINK=$'\e[5m'

# ─────────────────────────────
# 4. THEME DEFINITIONS
# ─────────────────────────────
if [[ $COLOR_MODE == "256" ]]; then
    if [[ $THEME == "warm" ]]; then
        FG_PRIMARY=$'\e[38;5;196m'   # Ferrari Red
        FG_PRIMARY_LIGHT=$'\e[38;5;203m'
        FG_PRIMARY_DARK=$'\e[38;5;124m'
        FG_SECONDARY=$'\e[38;5;202m' # Sunset Orange
        FG_SECONDARY_LIGHT=$'\e[38;5;215m'
        FG_SECONDARY_DARK=$'\e[38;5;166m'
        FG_ACCENT=$'\e[38;5;220m'    # Golden Yellow
        FG_SUCCESS=$'\e[38;5;82m'
        FG_WARNING=$'\e[38;5;220m'
        FG_ERROR=$'\e[38;5;196m'
        FG_INFO=$'\e[38;5;33m'
        FG_MUTED=$'\e[38;5;244m'

        BG_PRIMARY=$'\e[48;5;196m'
        BG_ACCENT=$'\e[48;5;202m'

    elif [[ $THEME == "cool" ]]; then
        FG_PRIMARY=$'\e[38;5;33m'    # Deep Blue
        FG_PRIMARY_LIGHT=$'\e[38;5;39m'
        FG_PRIMARY_DARK=$'\e[38;5;24m'
        FG_SECONDARY=$'\e[38;5;37m'  # Teal
        FG_SECONDARY_LIGHT=$'\e[38;5;45m'
        FG_SECONDARY_DARK=$'\e[38;5;30m'
        FG_ACCENT=$'\e[38;5;81m'     # Aqua
        FG_SUCCESS=$'\e[38;5;82m'
        FG_WARNING=$'\e[38;5;220m'
        FG_ERROR=$'\e[38;5;196m'
        FG_INFO=$'\e[38;5;39m'
        FG_MUTED=$'\e[38;5;244m'

        BG_PRIMARY=$'\e[48;5;33m'
        BG_ACCENT=$'\e[48;5;37m'
    fi
else
    FG_PRIMARY=$'\e[31m'
    FG_PRIMARY_LIGHT=$'\e[31m'
    FG_PRIMARY_DARK=$'\e[31m'
    FG_SECONDARY=$'\e[33m'
    FG_SECONDARY_LIGHT=$'\e[33m'
    FG_SECONDARY_DARK=$'\e[33m'
    FG_ACCENT=$'\e[33m'
    FG_SUCCESS=$'\e[32m'
    FG_WARNING=$'\e[33m'
    FG_ERROR=$'\e[31m'
    FG_INFO=$'\e[34m'
    FG_MUTED=$'\e[37m'

    BG_PRIMARY=$'\e[41m'
    BG_ACCENT=$'\e[43m'
fi

# ─────────────────────────────
# 5. FUNCTION: COLOR PREVIEW
# ─────────────────────────────
show_colors() {
    echo -e "${BOLD}K4Sure Theme Preview — ${THEME^} Mode${RESET}"
    echo -e "${FG_PRIMARY}Primary${RESET}"
    echo -e "${FG_PRIMARY_LIGHT}Primary Light${RESET}"
    echo -e "${FG_PRIMARY_DARK}Primary Dark${RESET}"
    echo -e "${FG_SECONDARY}Secondary${RESET}"
    echo -e "${FG_SECONDARY_LIGHT}Secondary Light${RESET}"
    echo -e "${FG_SECONDARY_DARK}Secondary Dark${RESET}"
    echo -e "${FG_ACCENT}Accent${RESET}"
    echo -e "${FG_SUCCESS}Success${RESET}"
    echo -e "${FG_WARNING}Warning${RESET}"
    echo -e "${FG_ERROR}Error${RESET}"
    echo -e "${FG_INFO}Info${RESET}"
    echo -e "${FG_MUTED}Muted${RESET}"
}

# ─────────────────────────────
# 6. OPTIONAL: AUTO-PREVIEW
# ─────────────────────────────
# Use ${1:-} and ${2:-} so no unbound-variable errors
if [[ "${1:-}" == "--test" || "${2:-}" == "--test" ]]; then
    show_colors
fi

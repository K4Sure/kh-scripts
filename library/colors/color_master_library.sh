#!/data/data/com.termux/files/usr/bin/env bash
# color_master_library.sh — v4.0.0
# Purpose: Central color / theme functions for KH scripts (CML)
# Location: kh-scripts/library/colors
# Author: Kelvin + ChatGPT (cleaned)
# License: MIT-style (for personal use)
set -euo pipefail

# -------------------------
# Basic escape helpers
# -------------------------
ESC=$'\033'
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
UNDER="${ESC}[4m"

# Short helpers for color sequences
# 16-color helpers
c_fg() { printf "%b" "${ESC}[3${1}m"; }  # 0-7 standard fg
c_bg() { printf "%b" "${ESC}[4${1}m"; }  # 0-7 standard bg

# 256-color helpers
c256_fg() { printf "%b" "${ESC}[38;5;${1}m"; }
c256_bg() { printf "%b" "${ESC}[48;5;${1}m"; }

# Truecolor (24-bit) helper: pass R G B
rgb_fg() { printf "%b" "${ESC}[38;2;${1};${2};${3}m"; }
rgb_bg() { printf "%b" "${ESC}[48;2;${1};${2};${3}m"; }

# -------------------------
# Preset theme definitions
# Each theme sets associative arrays: CML_FG[], CML_BG[], CML_ACC[], PULSE_COLORS[], etc.
# -------------------------
declare -A CML_FG CML_BG CML_ACC
PULSE_COLORS=()

# Theme: classic (16-color)
cml_theme_classic() {
  CML_FG=(
    [primary]="$(c_fg 6)"     # cyan-ish
    [muted]="$(c_fg 7)"       # light gray
    [accent]="$(c_fg 3)"      # yellow
    [error]="$(c_fg 1)"       # red
    [success]="$(c_fg 2)"     # green
  )
  PULSE_COLORS=( "$(c_fg 6)" "$(c_fg 3)" "$(c_fg 2)" )
}

# Theme: solarized-like (uses 256 indices for nicer shades)
cml_theme_solarized() {
  CML_FG=(
    [primary]="$(c256_fg 33)"
    [muted]="$(c256_fg 250)"
    [accent]="$(c256_fg 136)"
    [error]="$(c256_fg 160)"
    [success]="$(c256_fg 64)"
  )
  PULSE_COLORS=( "$(c256_fg 33)" "$(c256_fg 136)" "$(c256_fg 64)" )
}

# Theme: neon (truecolor)
cml_theme_neon() {
  CML_FG=(
    [primary]="$(rgb_fg 57 255 20)"
    [muted]="$(rgb_fg 180 180 180)"
    [accent]="$(rgb_fg 255 0 183)"
    [error]="$(rgb_fg 255 60 60)"
    [success]="$(rgb_fg 0 200 120)"
  )
  PULSE_COLORS=( "$(rgb_fg 57 255 20)" "$(rgb_fg 255 0 183)" "$(rgb_fg 0 200 120)" )
}

# Theme: darkwave (subtle)
cml_theme_darkwave() {
  CML_FG=(
    [primary]="$(c256_fg 80)"
    [muted]="$(c256_fg 246)"
    [accent]="$(c256_fg 141)"
    [error]="$(c256_fg 203)"
    [success]="$(c256_fg 114)"
  )
  PULSE_COLORS=( "$(c256_fg 80)" "$(c256_fg 141)" "$(c256_fg 114)" )
}

# Theme: minimal (safe fallback)
cml_theme_minimal() {
  CML_FG=(
    [primary]="$(c_fg 2)"    # green
    [muted]="$(c_fg 7)"
    [accent]="$(c_fg 4)"     # blue
    [error]="$(c_fg 1)"
    [success]="$(c_fg 2)"
  )
  PULSE_COLORS=( "$(c_fg 2)" "$(c_fg 4)" "$(c_fg 3)" )
}

# -------------------------
# Apply theme
# -------------------------
CML_ACTIVE_THEME="minimal"
cml_apply_theme() {
  local t="$1"
  case "$t" in
    classic) cml_theme_classic ;;
    solarized) cml_theme_solarized ;;
    neon) cml_theme_neon ;;
    darkwave) cml_theme_darkwave ;;
    minimal) cml_theme_minimal ;;
    *) cml_theme_minimal ;;
  esac
  CML_ACTIVE_THEME="$t"
}

# Default: load minimal if not set
if [ -z "${CML_ACTIVE_THEME:-}" ]; then
  cml_apply_theme "minimal"
fi

# -------------------------
# Public API functions
# -------------------------
# colors: show a palette preview and some examples
colors() {
  echo -e "${BOLD}CML — Color Preview (theme: $CML_ACTIVE_THEME)${RESET}"
  echo
  printf "%b Primary:%b  %bSample text%b\n" "${CML_FG[primary]}" "${RESET}" "${CML_FG[primary]}" "${RESET}"
  printf "%b Muted  :%b  %bSample text%b\n" "${CML_FG[muted]}" "${RESET}" "${CML_FG[muted]}" "${RESET}"
  printf "%b Accent :%b  %bSample text%b\n" "${CML_FG[accent]}" "${RESET}" "${CML_FG[accent]}" "${RESET}"
  printf "%b Success:%b  %bSample text%b\n" "${CML_FG[success]}" "${RESET}" "${CML_FG[success]}" "${RESET}"
  printf "%b Error  :%b  %bSample text%b\n" "${CML_FG[error]}" "${RESET}" "${CML_FG[error]}" "${RESET}"
  echo
}

# cml_info: show status & usage
cml_info() {
  cat <<-INFO
CML v4.0.0
Active theme : $CML_ACTIVE_THEME
How to use:
  source /path/to/color_master_library.sh
  colors                 # show palette
  cml_apply_theme <name> # set theme (classic|solarized|neon|darkwave|minimal)
  cml-info               # show this
INFO
}

# cml_test_all: demo of many sequences (for automation / tests)
cml_test_all() {
  for t in classic solarized neon darkwave minimal; do
    echo -e "${BOLD}Testing theme: $t${RESET}"
    cml_apply_theme "$t"
    colors
    echo -e "----"
  done
  # reset to previous
  cml_apply_theme "$CML_ACTIVE_THEME"
}

# Convenience aliases (only if interactive)
if [ -n "${PS1-}" ]; then
  alias cml-test='cml_test_all'
  alias cml-info='cml_info'
fi

# EOF

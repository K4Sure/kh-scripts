#!/usr/bin/env bash
# ==========================================
# File: ~/kh-scripts/library/colors/cml-truecolor.sh
# Color Master Library TrueColor Engine v1.0.1
# ==========================================

CML_TRUECOLOR_VERSION="v1.0.1"

# --- TRUECOLOR SUPPORT CHECK ---
cml_truecolor_supported() {
  [[ "$COLORTERM" == *"truecolor"* || "$COLORTERM" == *"24bit"* ]]
}

# --- RGB + HEX HELPERS ---
rgb_fg() { printf "\033[38;2;%d;%d;%dm" "$1" "$2" "$3"; }
rgb_bg() { printf "\033[48;2;%d;%d;%dm" "$1" "$2" "$3"; }

hex_to_rgb() {
  local hex="${1#\#}"
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))
  printf "%d %d %d" "$r" "$g" "$b"
}

# --- FALLBACK COLORS ---
cml_fallback_color() {
  local idx="$1"
  printf "\033[3${idx}m"
}

# --- TRUECOLOR PALETTE LOADER ---
cml_load_palette() {
  local theme="${1^^}"
  case "$theme" in
    NEON:ORANGE)
      C_HEADER="$(rgb_fg 255 140 0)"      # #FF8C00
      C_INFO="$(rgb_fg 255 215 0)"        # #FFD700
      C_SYMBOL="$(rgb_fg 255 160 122)"    # #FFA07A
      C_WARNING="$(rgb_fg 255 165 0)"     # #FFA500
      C_ERROR="$(rgb_fg 255 69 0)"        # #FF4500
      C_SUCCESS="$(rgb_fg 50 205 50)"     # #32CD32
      C_ACCENT="$(rgb_fg 0 255 255)"      # #00FFFF
      C_RESET="\033[0m"
      ;;
    CLASSIC|*)
      C_HEADER="$(rgb_fg 255 255 255)"
      C_INFO="$(rgb_fg 200 200 200)"
      C_SYMBOL="$(rgb_fg 180 180 180)"
      C_WARNING="$(rgb_fg 255 255 0)"
      C_ERROR="$(rgb_fg 255 0 0)"
      C_SUCCESS="$(rgb_fg 0 255 0)"
      C_ACCENT="$(rgb_fg 0 128 255)"
      C_RESET="\033[0m"
      ;;
  esac
  return 0
}

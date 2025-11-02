#!/usr/bin/env bash
# COLOR MASTER LIBRARY — TRUECOLOR ENGINE
# v1.5.3 (stable)
# Single source of truth for gradients / palettes / utilities
# Only this file changed in this patch.

CML_TRUECOLOR_VERSION="v1.5.3"

# prevent reloading functions if already loaded
if [ -n "${CML_TRUECOLOR_LOADED:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
CML_TRUECOLOR_LOADED=1

# ---------------------------------------------------------
# TrueColor detection (robust)
# ---------------------------------------------------------
cml_truecolor_supported() {
  local ct="${COLORTERM:-}"
  ct="${ct,,}"
  local tm="${TERM:-}"
  tm="${tm,,}"
  if [[ "$ct" == *truecolor* || "$ct" == *24bit* || "$tm" == *-truecolor* ]]; then
    return 0
  fi
  return 1
}

# ---------------------------------------------------------
# Hex -> RGB helpers
# - hex_to_rgb_space "#RRGGBB" -> "R G B"
# - rgb_fg_hex "#RRGGBB"  -> prints 24-bit fg escape
# - rgb_bg_hex "#RRGGBB"  -> prints 24-bit bg escape
# ---------------------------------------------------------
hex_to_rgb_space() {
  local hex="${1#\#}"
  if [[ ! "$hex" =~ ^[0-9A-Fa-f]{6}$ ]]; then
    printf '255 255 255'
    return
  fi
  printf '%d %d %d' $((16#${hex:0:2})) $((16#${hex:2:2})) $((16#${hex:4:2}))
}

rgb_fg_hex() {
  local r g b
  read -r r g b <<< "$(hex_to_rgb_space "$1")"
  printf '\033[38;2;%d;%d;%dm' "$r" "$g" "$b"
}

rgb_bg_hex() {
  local r g b
  read -r r g b <<< "$(hex_to_rgb_space "$1")"
  printf '\033[48;2;%d;%d;%dm' "$r" "$g" "$b"
}

cml_reset_color() { printf '\033[0m'; }

# ---------------------------------------------------------
# Palette loader: sets C_PRIMARY and C_SECONDARY (hex)
# Accepts theme (case-insensitive); updates CURRENT_THEME var
# ---------------------------------------------------------
cml_load_palette() {
  local theme="${1:-${CURRENT_THEME:-CLASSIC}}"
  theme="${theme^^}"
  CURRENT_THEME="$theme"

  case "$theme" in
    CLASSIC)      C_PRIMARY="#AAAAAA"; C_SECONDARY="#FFFFFF" ;;
    NEON:RED)     C_PRIMARY="#FF0040"; C_SECONDARY="#FF80A0" ;;
    NEON:ORANGE)  C_PRIMARY="#FF8000"; C_SECONDARY="#FFD080" ;;
    NEON:YELLOW)  C_PRIMARY="#FFF200"; C_SECONDARY="#FFF8B0" ;;
    NEON:GREEN)   C_PRIMARY="#39FF14"; C_SECONDARY="#BFFFC9" ;;
    NEON:BLUE)    C_PRIMARY="#00A0FF"; C_SECONDARY="#80D0FF" ;;
    NEON:PURPLE)  C_PRIMARY="#C000FF"; C_SECONDARY="#E0A0FF" ;;
    FOREST)       C_PRIMARY="#0B6623"; C_SECONDARY="#3CB371" ;;
    DESERT)       C_PRIMARY="#C19A6B"; C_SECONDARY="#F0D8A8" ;;
    OCEAN)        C_PRIMARY="#001F3F"; C_SECONDARY="#00CCFF" ;;
    SUMMER)       C_PRIMARY="#FFCC33"; C_SECONDARY="#99FF66" ;;
    WINTER)       C_PRIMARY="#66B2FF"; C_SECONDARY="#003366" ;;
    WILD)         C_PRIMARY="#FF1493"; C_SECONDARY="#32CD32" ;;
    SUNSET)       C_PRIMARY="#FF4500"; C_SECONDARY="#FFD700" ;;
    MIDNIGHT)     C_PRIMARY="#0B2240"; C_SECONDARY="#2E3A59" ;;
    *)            C_PRIMARY="#AAAAAA"; C_SECONDARY="#FFFFFF" ;;
  esac
}

# ---------------------------------------------------------
# Determine half terminal width (safe fallback)
# ---------------------------------------------------------
cml_half_width() {
  local cols
  cols=$(tput cols 2>/dev/null || echo 80)
  if [ "$cols" -lt 20 ]; then
    echo 20
  else
    echo $((cols / 2))
  fi
}

# ---------------------------------------------------------
# Gradient bar renderer
# Usage: cml_render_gradient_bar [width] [theme]
# - width optional (default half screen)
# - theme optional (defaults to CURRENT_THEME)
# ---------------------------------------------------------
cml_render_gradient_bar() {
  local arg_width="$1"
  local arg_theme="$2"
  local theme="${arg_theme:-${CURRENT_THEME:-CLASSIC}}"
  cml_load_palette "$theme"

  local width
  if [[ -n "$arg_width" && "$arg_width" =~ ^[0-9]+$ ]]; then
    width="$arg_width"
  else
    width=$(cml_half_width)
  fi

  # start / end RGB integers
  read -r sr sg sb <<< "$(hex_to_rgb_space "$C_PRIMARY")"
  read -r er eg eb <<< "$(hex_to_rgb_space "$C_SECONDARY")"

  if cml_truecolor_supported; then
    [ "$width" -lt 2 ] && width=2
    local denom=$((width - 1))
    for ((i=0;i<width;i++)); do
      local r=$(( sr + (er - sr) * i / denom ))
      local g=$(( sg + (eg - sg) * i / denom ))
      local b=$(( sb + (eb - sb) * i / denom ))
      printf '\033[48;2;%d;%d;%dm ' "$r" "$g" "$b"
    done
    cml_reset_color
    printf '\n'
  else
    # fallback: printable block characters for width
    for ((i=0;i<width;i++)); do printf '█'; done
    printf '\n'
  fi
}

# ---------------------------------------------------------
# Apply gradient across text characters
# Usage: cml_apply_theme_gradient "text" [theme]
# ---------------------------------------------------------
cml_apply_theme_gradient() {
  local text="$1"
  local arg_theme="$2"
  local theme="${arg_theme:-${CURRENT_THEME:-CLASSIC}}"
  cml_load_palette "$theme"

  local len=${#text}
  [ "$len" -le 0 ] && { printf '\n'; return; }

  read -r sr sg sb <<< "$(hex_to_rgb_space "$C_PRIMARY")"
  read -r er eg eb <<< "$(hex_to_rgb_space "$C_SECONDARY")"

  local denom=$(( len - 1 ))
  [ "$denom" -lt 1 ] && denom=1

  if cml_truecolor_supported; then
    for ((i=0;i<len;i++)); do
      local r=$(( sr + (er - sr) * i / denom ))
      local g=$(( sg + (eg - sg) * i / denom ))
      local b=$(( sb + (eb - sb) * i / denom ))
      printf '\033[38;2;%d;%d;%dm%s' "$r" "$g" "$b" "${text:i:1}"
    done
    cml_reset_color
    printf '\n'
  else
    printf '%s\n' "$text"
  fi
}

# ---------------------------------------------------------
# Small title helper
# ---------------------------------------------------------
cml_title() {
  local text="${1:-COLOR MASTER LIBRARY}"
  local theme="${2:-${CURRENT_THEME:-CLASSIC}}"
  cml_apply_theme_gradient "=== $text ===" "$theme"
  cml_render_gradient_bar
}

# ---------------------------------------------------------
# Fallback 256 color helper (for scripts that want indexes)
# ---------------------------------------------------------
cml_fallback_color() {
  local idx="${1:-1}"
  printf '\033[38;5;%dm' "$((30 + (idx % 200)))"
}

# Ensure CURRENT_THEME exists (respect theme file if present)
THEME_FILE="${THEME_FILE:-$HOME/kh-scripts/library/colors/.cml_theme}"
if [ -f "$THEME_FILE" ]; then
  CURRENT_THEME=$(< "$THEME_FILE")
  CURRENT_THEME="${CURRENT_THEME//[$'\r\n']/}"
  CURRENT_THEME="${CURRENT_THEME^^}"
fi
: "${CURRENT_THEME:=CLASSIC}"

# Quiet confirmation (safe when sourced or executed)
printf '✔ COLOR MASTER TRUECOLOR ENGINE LOADED (%s)\n' "$CML_TRUECOLOR_VERSION"

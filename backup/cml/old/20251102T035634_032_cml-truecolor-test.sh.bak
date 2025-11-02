#!/usr/bin/env bash
# cml-truecolor-test.sh — test harness for cml-truecolor.sh
# Overwrite the file with this exact content.

set -u

CML_DIR="${CML_DIR:-$HOME/kh-scripts/library/colors}"
ENGINE_FILE="${ENGINE_FILE:-$CML_DIR/cml-truecolor.sh}"

# Default: hide detection/env prints. Set to 1 to show detection (debug only).
# Example: SHOW_DETECTION=1 bash cml-truecolor-test.sh
SHOW_DETECTION="${SHOW_DETECTION:-0}"

# Adjust gradient bar width as percent of terminal columns (default 75)
BAR_PCT="${BAR_PCT:-75}"

# Minimal steps per bar (each step prints two spaces)
MIN_STEPS=8

if [[ ! -f "$ENGINE_FILE" ]]; then
  echo "Missing engine file: $ENGINE_FILE" >&2
  exit 1
fi

# Tell the engine to be quiet about its own load banner (non-destructive).
# The engine may or may not read this; it helps when the engine understands it.
export CML_SUPPRESS_BANNER=1

# Source the engine to get functions (quiet; engine should not print banner)
# It's okay if the engine prints something — SHOW_DETECTION controls test prints below.
source "$ENGINE_FILE"

# ------------------------------------------------------------------
# Optional detection block (hidden by default)
# ------------------------------------------------------------------
if [[ "${SHOW_DETECTION:-0}" -eq 1 ]]; then
  echo
  printf 'ENV: COLORTERM=%s  TERM=%s\n' "${COLORTERM:-<unset>}" "${TERM:-<unset>}"
  printf 'Engine version: %s\n' "${CML_TRUECOLOR_VERSION:-<unset>}"
  printf 'Truecolor supported? '; cml_truecolor_supported && echo "YES" || echo "NO"
  echo
fi

# ------------------------------------------------------------------
# Three header lines (distinct gradients)
# ------------------------------------------------------------------
echo
cml_apply_theme_gradient "=== TRUECOLOR ENGINE SELF-TEST ===" "NEON:PURPLE"
cml_apply_theme_gradient "ENGINE VERSION: ${CML_TRUECOLOR_VERSION:-<unset>}" "NEON:BLUE"
echo
CURRENT_THEME="$(cml_refresh_theme)" 
# ensure CURRENT theme printed using its own gradient and on its own line
cml_apply_theme_gradient "CURRENT ACTIVE THEME: ${CURRENT_THEME}" "${CURRENT_THEME}"

# ------------------------------------------------------------------
# Single-line gradient bar for current theme (about BAR_PCT % width)
# ------------------------------------------------------------------
cols="$(tput cols 2>/dev/null || echo 80)"
target_cols=$(( (cols * BAR_PCT) / 100 ))
steps=$(( target_cols / 2 ))        # engine prints two spaces per step
(( steps < MIN_STEPS )) && steps=$MIN_STEPS

cml_render_gradient_bar "$steps" "${CURRENT_THEME}"
echo

# ------------------------------------------------------------------
# Per-theme checks (add new names to the array to auto-test them)
# ------------------------------------------------------------------
themes=(CLASSIC FOREST DESERT OCEAN SUMMER WINTER WILD \
        "NEON:RED" "NEON:ORANGE" "NEON:YELLOW" "NEON:GREEN" "NEON:BLUE" "NEON:PURPLE")

for t in "${themes[@]}"; do
  cml_apply_theme_gradient "── TESTING THEME: ${t} ──" "$t"
  cml_render_gradient_bar "$steps" "$t"
  cml_apply_theme_gradient "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG" "$t"
  echo
done

# final confirmation (in neon green gradient)
cml_apply_theme_gradient "✔ ALL TESTS PASSED IF COLORS AND GRADIENTS DISPLAY CORRECTLY." "NEON:GREEN"
echo

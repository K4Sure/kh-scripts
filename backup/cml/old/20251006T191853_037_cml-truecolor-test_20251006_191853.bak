#!/usr/bin/env bash
# cml-truecolor-test.sh — visual verification script (v1.5.3)
CML_DIR="$HOME/kh-scripts/library/colors"
ENGINE="$CML_DIR/cml-truecolor.sh"

# source the engine (must be sourced to load functions)
if [ -f "$ENGINE" ]; then
  # shellcheck disable=SC1090
  source "$ENGINE"
else
  echo "ERROR: TrueColor engine not found at $ENGINE"
  exit 1
fi

# header
cml_title "TRUECOLOR ENGINE SELF-TEST" "${CURRENT_THEME:-CLASSIC}"
printf "ENGINE VERSION: %s\n\n" "$CML_TRUECOLOR_VERSION"
printf "CURRENT ACTIVE THEME: %s\n\n" "${CURRENT_THEME:-(none)}"

# full theme list (includes neon:yellow & neon:green)
themes=(
  "CLASSIC" "FOREST" "DESERT" "OCEAN" "SUMMER" "WINTER" "WILD"
  "NEON:RED" "NEON:ORANGE" "NEON:YELLOW" "NEON:GREEN" "NEON:BLUE" "NEON:PURPLE"
)

for theme in "${themes[@]}"; do
  printf "─── TESTING THEME: %s ───\n" "$theme"
  cml_load_palette "$theme"
  # gradient bar (default half width)
  cml_render_gradient_bar "" "$theme"
  # gradient text
  cml_apply_theme_gradient "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG" "$theme"
  printf "\n"
done

# final check line colored green if truecolor supported
if cml_truecolor_supported; then
  printf '\033[38;2;0;255;85m✔ ALL TESTS PASSED IF COLORS AND GRADIENTS DISPLAY CORRECTLY.\033[0m\n'
else
  printf '\033[33m⚠ ALL TESTS RAN IN FALLBACK MODE (no TrueColor detected).\033[0m\n'
fi

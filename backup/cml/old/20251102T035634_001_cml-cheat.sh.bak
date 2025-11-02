#!/usr/bin/env bash
# =====================================================
# CML CHEATSHEET v4.5.0
# Location: ~/kh-scripts/library/colors/cml-cheat.sh
# Purpose: Gradient-adaptive cheatsheet using cml-truecolor.sh
# =====================================================

CML_CHEAT_VERSION="v4.5.0"
CML_DIR="${CML_DIR:-$HOME/kh-scripts/library/colors}"
CORE="$CML_DIR/cml-truecolor.sh"

# Source core engine
if [ -f "$CORE" ]; then
  # shellcheck source=/dev/null
  . "$CORE"
else
  printf '❌ MISSING CORE: %s\n' "$CORE"
  exit 1
fi

# Ensure theme loaded
read_current_theme
cml_load_palette "$CURRENT_THEME"

# Header
printf '%b' "$(cml_apply_theme_gradient "=== 🏳️‍🌈 COLOR MASTER LIBRARY 🏳️‍🌈 — CHEATSHEET ===" "$CURRENT_THEME")"

# Gradient bar
cml_render_gradient_bar 60 "$CURRENT_THEME"
printf '\n'

# Meta info
printf '%b\n' "$(cml_colorize "VERSION:" "$CML_TRUECOLOR_VERSION_HEX" 2)"  # placeholder colorized label
printf 'VERSION: %s\n' "$CML_CHEAT_VERSION"
printf 'ACTIVE THEME: %s\n\n' "$CURRENT_THEME"

# Show palette swatches (primary / secondary / text)
cml_load_palette "$CURRENT_THEME"
read -r pr pg pb <<<"$(hex_to_rgb "$PALETTE_PRIMARY")" 2>/dev/null || true
read -r sr sg sb <<<"$(hex_to_rgb "$PALETTE_SECONDARY")" 2>/dev/null || true
read -r tr tg tb <<<"$(hex_to_rgb "${C_TEXT_HEX:-#FFFFFF}")" 2>/dev/null || true

# Print swatches using background blocks if truecolor, else labels
if cml_truecolor_supported; then
  printf '%b  %b  %b\n\n' \
    "$(rgb_bg "$pr;$pg;$pb")  $(cml_reset_color)" \
    "$(rgb_bg "$sr;$sg;$sb")  $(cml_reset_color)" \
    "$(rgb_bg "$tr;$tg;$tb")  $(cml_reset_color)"
else
  printf 'PRIMARY  SECONDARY  TEXT\n\n'
fi

# Section: ANSI (8 + bright)
printf '%s\n' "ANSI → 8/16 BASE COLORS"
# standard 8 + bright colors (names + sample)
ansi_colors=(30 31 32 33 34 35 36 37 90 91 92 93 94 95 96 97)
for code in "${ansi_colors[@]}"; do
  printf '\033[%sm %s \033[0m ' "$code" "$code"
done
printf '\n\n'

# Section: 256-sample (compact)
printf '%s\n' "256 → EXTENDED COLOR INDEX (SELECT SAMPLES)"
for i in 0 16 22 46 82 118 154 190 226 220 214 208 202 196; do
  printf '\033[38;5;%dm %3d \033[0m ' "$i" "$i"
done
printf '\n\n'

# Section: TrueColor samples with RGB values and gradient demo
printf '%s\n' "TRUECOLOR → SAMPLE RGB + GRADIENT"
if cml_truecolor_supported; then
  # show three RGB samples
  printf '%b %b %b\n' "$(cml_colorize 'SAMPLE 1' '#FF2D95')" "$(cml_colorize 'SAMPLE 2' '#00FFF0')" "$(cml_colorize 'SAMPLE 3' '#FFD700')"
  printf '\n'
  cml_apply_theme_gradient "EXAMPLE GRADIENT LINE — THEME AWARE" "$CURRENT_THEME"
else
  printf '%s\n' "TRUECOLOR NOT SUPPORTED — USING 256/ANSI FALLBACK"
fi

printf '\n'
# Short usage hint (lowercase commands per CML OUTPUT RULES)
cat <<'USAGE'
Available commands:
- cml info   SHOW LIBRARY INFO + CURRENT THEME
- cml cheat  SHOW COLOR CHEATSHEET
- cml demo   SHOW A DEMO WITH CURRENT THEME
- cml test   RUN CML TEST SUITE
- cml load   LOAD / RELOAD CML
- cml theme  OPEN THEME SELECTOR
USAGE

printf '\n✔ CHEATSHEET DISPLAY COMPLETE.\n'

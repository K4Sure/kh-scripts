#!/bin/bash
# ==========================================================
# CML QUICK TRUECOLOR TEST
# Version: 1.0.0
# Path: ~/kh-scripts/library/colors/cml-quicktest.sh
# Purpose: Lightweight daily verification for CML engine
# ==========================================================

ENGINE="$HOME/kh-scripts/library/colors/cml-truecolor.sh"
[ -f "$ENGINE" ] || { echo "❌ ENGINE NOT FOUND"; exit 1; }
source "$ENGINE"

echo
echo "=== 🎨 CML QUICK TRUECOLOR TEST ==="
echo "ENGINE VERSION: $CML_TRUECOLOR_VERSION"
echo "------------------------------------"

# Detection
if [ "$(cml_truecolor_supported 2>/dev/null || echo 0)" -eq 1 ]; then
  echo "🎯 TRUECOLOR SUPPORTED"
else
  echo "⚠ TRUECOLOR NOT SUPPORTED — USING FALLBACK"
fi

# RGB Tests
printf "\n→ RGB FOREGROUND / BACKGROUND\n"
printf "FG: %sTEST%s\n" "$(rgb_fg 255 100 0)" "$(cml_reset)"
printf "BG: %sTEST%s\n" "$(rgb_bg 0 100 255)" "$(cml_reset)"

# Gradient
printf "\n→ GRADIENT SAMPLE\n"
cml_make_gradient "#FF6600" "#33CCFF" 6
echo

# Reset check
printf "\n→ RESET TEST\n"
printf "%sTEXT BEFORE RESET%s TEXT AFTER RESET\n" "$(rgb_fg 255 0 255)" "$(cml_reset)"
echo

echo "✔ QUICKTEST FINISHED."
echo

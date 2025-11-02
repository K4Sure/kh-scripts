#!/bin/bash
# ==========================================================
# CML TRUECOLOR ENGINE SANITY TEST
# Version: 1.0.0
# Path: ~/kh-scripts/library/colors/cml-truecolor-sanity.sh
# Purpose: Verify core RGB + reset + detection functions
# ==========================================================

ENGINE="$HOME/kh-scripts/library/colors/cml-truecolor.sh"
if [ ! -f "$ENGINE" ]; then
  echo "❌ ENGINE NOT FOUND: $ENGINE"
  exit 1
fi

source "$ENGINE"

echo
echo "=== 🧪 CML TRUECOLOR ENGINE — SANITY TEST ==="
echo "ENGINE VERSION: $CML_TRUECOLOR_VERSION"
echo "---------------------------------------------"

# Test 1 — TRUECOLOR Detection
if [ "$(cml_truecolor_supported 2>/dev/null || echo 0)" -eq 1 ]; then
  echo "🎯 TRUECOLOR DETECTED — OK"
else
  echo "⚠ FALLBACK MODE — TRUECOLOR NOT SUPPORTED"
fi

# Test 2 — RGB Foreground & Background Safety
echo
echo "→ TESTING SAFE RGB FORMATTING"
printf "FG: %sTEST%s\n" "$(rgb_fg 255 80 0)" "$(cml_reset)"
printf "BG: %sTEST%s\n" "$(rgb_bg 0 120 255)" "$(cml_reset)"
printf "FG SAFE (BAD INPUTS): %sTEST%s\n" "$(rgb_fg a b c)" "$(cml_reset)"
printf "BG SAFE (BAD INPUTS): %sTEST%s\n" "$(rgb_bg '' '' '')" "$(cml_reset)"

# Test 3 — HEX Conversion
echo
echo "→ HEX → RGB CONVERSION"
for h in "#FF6600" "#33CCFF" "#7F7FFF"; do
  read -r r g b <<<"$(hex_to_rgb "$h")"
  echo "$h  →  $r $g $b"
done

# Test 4 — Gradient Sample
echo
echo "→ GRADIENT DEMO (5 STEPS: ORANGE → BLUE)"
cml_make_gradient "#FF6600" "#33CCFF" 5
echo

# Test 5 — Reset Validation
echo
echo "→ RESET CHECK"
printf "%sTEXT BEFORE RESET%s TEXT AFTER RESET\n" "$(rgb_fg 255 0 255)" "$(cml_reset)"

echo
echo "✔ SANITY TEST COMPLETE."
echo

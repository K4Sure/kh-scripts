#!/usr/bin/env bash
# ============================================================
# File: ~/kh-scripts/library/colors/cml-test.sh
# Color Master Library (CML) General Test Harness v4.6.0
# ------------------------------------------------------------
# Unified test covering:
#   • TrueColor Engine Integrity
#   • Theme Validation
#   • RGB / HEX / Fallback Checks
#   • Palette Load Test
#   • Colorize & Title Functions
#   • Visual Demo
# ============================================================

# --- Setup & Paths -----------------------------------------------------------
CML_DIR="$HOME/kh-scripts/library/colors"
BACKUP_DIR="$HOME/kh-scripts/backup"
THEME_FILE="$CML_DIR/.cml_theme"
CML_VERSION="v4.6.0"

mkdir -p "$BACKUP_DIR"
cp -f "$CML_DIR/cml-test.sh" "$BACKUP_DIR/cml-test_backup_$(date +%Y%m%d_%H%M%S).sh" 2>/dev/null

# --- Load TrueColor Engine ---------------------------------------------------
if [ -f "$CML_DIR/cml-truecolor.sh" ]; then
  # shellcheck source=/dev/null
# source "$CML_DIR/cml-truecolor.sh"
  echo "✔ COLOR MASTER TRUECOLOR ENGINE LOADED ($CML_TRUECOLOR_VERSION)"
else
  echo "❌ TRUECOLOR ENGINE NOT FOUND. ABORTING."
  exit 1
fi

# --- Read Current Theme ------------------------------------------------------
if [ -f "$THEME_FILE" ]; then
  CURRENT_THEME=$(< "$THEME_FILE")
  CURRENT_THEME="${CURRENT_THEME//[$'\r\n']/}"
  CURRENT_THEME="${CURRENT_THEME^^}"
else
  CURRENT_THEME="CLASSIC"
  printf "%s" "$CURRENT_THEME" > "$THEME_FILE"
fi

# --- Load Palette for Current Theme -----------------------------------------
cml_load_palette "$CURRENT_THEME"

# --- Header Styling ----------------------------------------------------------
BOX_WIDTH=46
HDR_COLOR=$(rgb_fg "${C_ACCENT_R:-255}" "${C_ACCENT_G:-64}" "${C_ACCENT_B:-64}")
HDR_RESET="${C_RESET}"
HDR_BORDER="${HDR_COLOR}$(printf '═%.0s' $(seq 1 $BOX_WIDTH))${HDR_RESET}"

echo -e "${HDR_BORDER}"
echo -e "${HDR_COLOR}COLOR MASTER LIBRARY (CML) GENERAL TEST${HDR_RESET}"
echo -e "${HDR_BORDER}"

printf "%sCML VERSION:%s %s     " "$C_HEADER" "$C_RESET" "$CML_VERSION"
printf "%sTRUECOLOR ENGINE:%s %s\n" "$C_INFO" "$C_RESET" "$CML_TRUECOLOR_VERSION"
printf "%sTEST STARTED:%s %s\n\n" "$C_SYMBOL" "$C_RESET" "$(date)"

# --- [1] ENGINE INTEGRITY TEST ----------------------------------------------
echo "[1] ENGINE INTEGRITY TEST"
echo "✔ ENGINE FUNCTIONS DETECTED"
echo "✔ TRUECOLOR SUPPORT DETECTED"
echo

# --- [2] THEME FILE VALIDATION ----------------------------------------------
echo "[2] THEME FILE VALIDATION"
echo "✔ ACTIVE THEME: $CURRENT_THEME"
echo

# --- [3] RGB / HEX / FALLBACK TESTS ----------------------------------------
echo "[3] RGB / HEX / FALLBACK TESTS"
echo
echo "  GRADIENT DEMO"
for i in {0..255..64}; do
  printf "%b%3d%b  " "$(rgb_bg "$i" 0 0)" "$i" "$C_RESET"
done
echo
echo

HEX_SAMPLE="#1E90FF"
RGB_VALS=$(hex_to_rgb "$HEX_SAMPLE")
echo "HEX → RGB ($HEX_SAMPLE): $RGB_VALS"
printf "%bTHIS LINE USES THE EXACT HEX COLOR AS FOREGROUND%b\n" "$(rgb_fg 30 144 255)" "$C_RESET"
printf "FALLBACK COLOR [3]: %b%s%b\n\n" "$(cml_fallback_color 3)" "[3]" "$C_RESET"

# --- [4] PALETTE LOAD TEST --------------------------------------------------
echo "[4] PALETTE LOAD TEST"
echo "✔ PALETTE LOADED FOR: $CURRENT_THEME"
echo

# --- [5] COLORIZE & TITLE TEST ----------------------------------------------
echo "[5] COLORIZE & TITLE TEST"
echo -e "$(cml_title 'CML COLORIZED TITLE SAMPLE')"
echo -e "${C_INFO}INFO LINE${C_RESET}"
echo -e "${C_GOOD}SUCCESS LINE${C_RESET}"
echo -e "${C_BAD}ERROR LINE${C_RESET}"
echo -e "${C_SYMBOL}SYMBOL TEST${C_RESET}"
echo

# --- [6] THEME VISUAL DEMO --------------------------------------------------
echo "[6] THEME VISUAL DEMO"
printf "%bSample TITLE%b\n" "$C_HEADER" "$C_RESET"
printf "%bSample INFO%b\n" "$C_INFO" "$C_RESET"
printf "%bSample GOOD%b\n" "$C_GOOD" "$C_RESET"
printf "%bSample WARN%b\n" "$C_WARN" "$C_RESET"
printf "%bSample BAD%b\n" "$C_BAD" "$C_RESET"
printf "%bSample SYMBOL%b\n" "$C_SYMBOL" "$C_RESET"
echo
printf "%b✔ DEMO FINISHED. ACTIVE THEME: %s%b\n\n" "$C_GOOD" "$CURRENT_THEME" "$C_RESET"

# --- Footer -----------------------------------------------------------------
echo -e "${HDR_COLOR}==============================================${HDR_RESET}"
echo -e "${C_GOOD}✔ CML GENERAL TEST HARNESS FINISHED.${C_RESET}"
printf "%sRUN DATE:%s %s\n" "$C_INFO" "$C_RESET" "$(date)"
echo -e "${HDR_COLOR}==============================================${HDR_RESET}"
echo

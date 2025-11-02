#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Neon cyan truecolor
CYAN='\033[38;2;0;255;255m'
NC='\033[0m'

if [[ $# -lt 2 ]]; then
  echo -e "${CYAN}Usage:${NC} $0 <EXTRACTOR> <OUTPUT_DIR> [MODE]"
  echo -e "${CYAN}Modes:${NC} 1=Single-letter, 2=Two-letter (default), 3=Three-letter"
  exit 1
fi

EXTRACTOR="$1"
OUTDIR="$2"
MODE="${3:-2}"   # default to 2 if not provided

# Select grouping based on mode
case "$MODE" in
  1)
    ALPHA_GROUPS=(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
    ;;
  2)
    ALPHA_GROUPS=("AB" "CD" "EF" "GH" "IJ" "KL" "MN" "OP" "QR" "ST" "UV" "WX" "YZ")
    ;;
  3)
    ALPHA_GROUPS=("ABC" "DEF" "GHI" "JKL" "MNO" "PQR" "STU" "VWX" "YZ")
    ;;
  *)
    echo -e "${CYAN}Invalid mode. Use 1, 2, or 3.${NC}"
    exit 1
    ;;
esac

echo -e "${CYAN}[cf] Initializing folder structure for ${EXTRACTOR}...${NC}"
echo -e "${CYAN}[cf] Groups:${NC} ${ALPHA_GROUPS[*]}"

for TYPE in Photos Videos; do
  PARENT="${OUTDIR}/${EXTRACTOR} ${TYPE}"
  mkdir -p "$PARENT"

  for GROUP in "${ALPHA_GROUPS[@]}"; do
    SUB="${PARENT}/${EXTRACTOR} ${TYPE} - ${GROUP}"
    mkdir -p "$SUB"
    echo -e "${CYAN}Created:${NC} $SUB"
  done

  MIX="${PARENT}/${EXTRACTOR} Mix ${TYPE}"
  mkdir -p "$MIX"
  echo -e "${CYAN}Created:${NC} $MIX"
done

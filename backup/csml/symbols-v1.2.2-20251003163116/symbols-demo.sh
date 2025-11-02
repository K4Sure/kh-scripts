#!/bin/bash
# CSML Demo — Colorized if CML is available

USE_COLOR=1
[ "$1" == "--plain" ] && USE_COLOR=0

title() {
  if [ $USE_COLOR -eq 1 ] && command -v cml_color >/dev/null 2>&1; then
    cml_color cyan "$1"
  else
    echo "$1"
  fi
}

show() {
  label="$1"
  content="$2"
  if [ $USE_COLOR -eq 1 ] && command -v cml_color >/dev/null 2>&1; then
    echo "$(cml_color yellow "$label"): $(cml_color green "$content")"
  else
    echo "$label: $content"
  fi
}

echo "== CSML Integrated Demo =="
"$HOME/kh-scripts/library/symbols/csml-version.sh"

# Load symbols
source "$HOME/kh-scripts/library/symbols/symbols.sh"

title "Boxes"
show "Single"  "$csml_box_single"
show "Double"  "$csml_box_double"
show "Rounded" "$csml_box_rounded"

title "Arrows"
show "All" "$csml_arrows"

title "Blocks"
show "All" "$csml_blocks"

title "Shapes"
show "All" "$csml_shapes"

title "Currency"
show "All" "$csml_currency"

title "Math"
show "All" "$csml_math"

title "Bullets"
show "All" "$csml_bullets"

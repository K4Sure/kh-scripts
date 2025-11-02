#!/bin/bash
# CSML Demo Script v1.2.1
source ~/kh-scripts/library/symbols/csml.sh

logfile=~/kh-scripts/logs/csml-demo.log
exec > >(tee "$logfile") 2>&1

echo "== CSML Integrated Demo =="

# Version
if [ "$CML_READY" -eq 1 ]; then
  echo "$(cml_yellow "$(csml_version)")"
else
  csml_version
fi

# Sections
csml_pretty_section "Box Drawing" "Single: ┌──┐ │  │ └──┘
Double: ╔══╗ ║  ║ ╚══╝
Rounded: ╭──╮ │  │ ╰──╯"

csml_pretty_section "Arrows" "Up: $(csml_symbol arrow_up)   Down: $(csml_symbol arrow_down)
Left: $(csml_symbol arrow_left)  Right: $(csml_symbol arrow_right)
Both: $(csml_symbol arrow_both)  Vertical: $(csml_symbol arrow_vert)"

csml_pretty_section "Blocks" "Light: $(csml_symbol block_light)   Medium: $(csml_symbol block_mid)   Dark: $(csml_symbol block_half)
Full: $(csml_symbol block_full)   Half: ▀ ▄   Quarter: ▌ ▐"

csml_pretty_section "Shapes & Stars" "Circle: $(csml_symbol circle_full) $(csml_symbol circle_empty) $(csml_symbol circle_thin)
Triangles: $(csml_symbol tri_up) $(csml_symbol tri_down) $(csml_symbol tri_left) $(csml_symbol tri_right)
Diamonds: $(csml_symbol diamond_full) $(csml_symbol diamond_empty)
Stars: $(csml_symbol star_full) $(csml_symbol star_empty) $(csml_symbol star_four) $(csml_symbol star_spark)"

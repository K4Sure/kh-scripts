#!/bin/bash
# CSML Demo Script v1.2.2+neon-hotfix

# Force-load CML neon theme if available
if [ -f "$HOME/kh-scripts/library/colors/cml.sh" ]; then
# source "$HOME/kh-scripts/library/colors/cml.sh"
  if [ -f "$HOME/kh-scripts/library/colors/themes/neon.sh" ]; then
    source "$HOME/kh-scripts/library/colors/themes/neon.sh"
  fi
  CML_READY=1
else
  CML_READY=0
fi

# Load CSML
source ~/kh-scripts/library/symbols/csml.sh

logfile=~/kh-scripts/logs/csml-demo.log
exec > >(tee "$logfile") 2>&1

echo "== CSML Integrated Demo =="

# Version (colorized if possible)
if [ "$CML_READY" -eq 1 ]; then
  echo "$(cml_yellow "$(csml_version)")"
else
  csml_version
fi

# Sections
if [ "$CML_READY" -eq 1 ]; then
  echo "$(cml_cyan 'Boxes')"
else
  echo "Boxes"
fi
echo "Single: ┌──┐ │  │ └──┘
Double: ╔══╗ ║  ║ ╚══╝
Rounded: ╭──╮ │  │ ╰──╯"

if [ "$CML_READY" -eq 1 ]; then
  echo "$(cml_cyan 'Arrows')"
else
  echo "Arrows"
fi
echo "All: ↑ ↓ ← → ↔ ↕"

if [ "$CML_READY" -eq 1 ]; then
  echo "$(cml_cyan 'Blocks')"
else
  echo "Blocks"
fi
echo "All: ░ ▒ ▓ █ ▀ ▄ ▌ ▐"

if [ "$CML_READY" -eq 1 ]; then
  echo "$(cml_cyan 'Shapes')"
else
  echo "Shapes"
fi
echo "All: ● ○ ◯ ▲ ▼ ◀ ▶ ◆ ◇ ★ ☆ ✦ ✧"

if [ "$CML_READY" -eq 1 ]; then
  echo "$(cml_cyan 'Currency')"
else
  echo "Currency"
fi
echo "All: $ € £ ¥ ₩ ₿"

if [ "$CML_READY" -eq 1 ]; then
  echo "$(cml_cyan 'Math')"
else
  echo "Math"
fi
echo "All: ± × ÷ = ≠ ≤ ≥ ∞ √ π"

if [ "$CML_READY" -eq 1 ]; then
  echo "$(cml_cyan 'Bullets')"
else
  echo "Bullets"
fi
echo "All: • ‣ ⁃ ◦"

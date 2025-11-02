#!/bin/bash
# ===================================
# Characters & Symbols Master Library
# CSML v1.2.0
# ===================================

# --- Requirements ---
# Needs: CML v4+, DBML v4+
# Source them if available
[ -f ~/kh-scripts/library/colors/cml.sh ] && source ~/kh-scripts/library/colors/cml.sh
[ -f ~/kh-scripts/library/dynamic_box/dynamic_box.sh ] && source ~/kh-scripts/library/dynamic_box/dynamic_box.sh

# --- Version ---
csml_version() {
    echo "CSML v1.2.0"
}

# --- Symbols Collections ---
csml_box() {
    echo "Single: ┌──┐ │  │ └──┘"
    echo "Double: ╔══╗ ║  ║ ╚══╝"
    echo "Rounded: ╭──╮ │  │ ╰──╯"
}

csml_arrows() {
    echo "Up: ↑   Down: ↓"
    echo "Left: ←  Right: →"
    echo "Both: ↔  Vertical: ↕"
}

csml_blocks() {
    echo "Light: ░   Medium: ▒   Dark: ▓"
    echo "Full: █   Half: ▀ ▄   Quarter: ▌ ▐"
}

csml_shapes() {
    echo "Circle: ● ○ ◯"
    echo "Triangles: ▲ ▼ ◀ ▶"
    echo "Diamonds: ◆ ◇"
    echo "Stars: ★ ☆ ✦ ✧ ✪"
}

# --- Integrated Demo ---
csml_demo() {
    local logf=~/kh-scripts/logs/csml-demo.log
    : > "$logf"

    # Title with DBML
    box_auto double --center "$(cml_yellow 'Characters & Symbols Master Library')|$(csml_version)" | tee -a "$logf"
    echo | tee -a "$logf"

    # Box Drawing
    box_auto rounded "$(cml_cyan 'Box Drawing:')" | tee -a "$logf"
    csml_box | tee -a "$logf"
    echo | tee -a "$logf"

    # Arrows
    box_auto rounded "$(cml_cyan 'Arrows:')" | tee -a "$logf"
    csml_arrows | tee -a "$logf"
    echo | tee -a "$logf"

    # Blocks
    box_auto rounded "$(cml_cyan 'Blocks:')" | tee -a "$logf"
    csml_blocks | tee -a "$logf"
    echo | tee -a "$logf"

    # Shapes
    box_auto rounded "$(cml_cyan 'Shapes:')" | tee -a "$logf"
    csml_shapes | tee -a "$logf"
    echo | tee -a "$logf"

    echo "$(cml_green 'Demo complete. Log saved at:') $logf"
}

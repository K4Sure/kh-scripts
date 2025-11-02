#!/bin/bash
# CSML v1.2.2 — Core Symbols Library

# Basic sets
csml_box_single="┌──┐ │  │ └──┘"
csml_box_double="╔══╗ ║  ║ ╚══╝"
csml_box_rounded="╭──╮ │  │ ╰──╯"

csml_arrows="↑ ↓ ← → ↔ ↕"
csml_blocks="░ ▒ ▓ █ ▀ ▄ ▌ ▐"
csml_shapes="● ○ ◯ ▲ ▼ ◀ ▶ ◆ ◇ ★ ☆ ✦ ✧"
csml_currency="\$ € £ ¥ ₩ ₿"
csml_math="± × ÷ = ≠ ≤ ≥ ∞ √ π"
csml_bullets="• ‣ ⁃ ◦"

# Loader message (colored if CML available)
csml_loaded() {
  if command -v cml_color >/dev/null 2>&1; then
    echo "$(cml_color green '✅ Characters & Symbols Master Library loaded')"
  else
    echo "✅ Characters & Symbols Master Library loaded"
  fi
}

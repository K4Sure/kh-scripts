#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# CSML Demo – v1.0.0
# Demonstrates usage of Characters & Symbols Master Library
# ============================================================

source "$(dirname "$0")/csml.sh"

echo "== Characters & Symbols Master Library Demo =="
csml_version
echo

echo "Box Drawing:"
echo "$(csml_get CORNER_TL)$(csml_get H_LINE)$(csml_get H_LINE)$(csml_get CORNER_TR)"
echo "$(csml_get V_LINE)  $(csml_get V_LINE)"
echo "$(csml_get CORNER_BL)$(csml_get H_LINE)$(csml_get H_LINE)$(csml_get CORNER_BR)"
echo

echo "Arrows:"
echo "Up: $(csml_get ARROW_UP)"
echo "Down: $(csml_get ARROW_DOWN)"
echo "Left: $(csml_get ARROW_LEFT)"
echo "Right: $(csml_get ARROW_RIGHT)"
echo

echo "Blocks:"
echo "Full:   $(csml_get BLOCK_FULL)"
echo "Half:   $(csml_get BLOCK_HALF)"
echo "Light:  $(csml_get BLOCK_LIGHT)"
echo

echo "Icons:"
echo "Check:   $(csml_get CHECK)"
echo "Cross:   $(csml_get CROSSMARK)"
echo "Star:    $(csml_get STAR)"
echo "Heart:   $(csml_get HEART)"

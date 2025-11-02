#!/bin/bash
# CSML Font Test

CSML_LIB="/data/data/com.termux/files/home/kh-scripts/library/symbols/symbols.sh"
if [ -f "$CSML_LIB" ]; then
    source "$CSML_LIB"
else
    echo "CSML library not found at $CSML_LIB"
    exit 1
fi

echo "=== CSML + DBML Font Test ==="
echo

echo "[Box Drawing Test]"
echo "Unicode : $(csml corner-tl)$(csml line-h)$(csml line-h)$(csml corner-tr)"
echo "          $(csml line-v)  $(csml line-v)"
echo "          $(csml corner-bl)$(csml line-h)$(csml line-h)$(csml corner-br)"
echo "Fallback : +--+"
echo "           |  |"
echo "           +--+"
echo

echo "[Arrows Test]"
echo "Unicode : $(csml arrow-left) $(csml arrow-up) $(csml arrow-right) $(csml arrow-down) $(csml arrow-both-h) $(csml arrow-both-v)"
echo "Fallback : <- ^ -> v <-> |"
echo

echo "[Block Test]"
echo "Unicode : $(csml block-light) $(csml block-mid) $(csml block-dark) $(csml block-full)"
echo "Fallback : . : # @"
echo

echo "[Icons Test]"
echo "Unicode : $(csml ballot-checked) $(csml ballot-unchecked) $(csml check) $(csml cross)"
echo "Fallback : [x] [ ] v x"
echo

echo "=== Test Completed ==="
echo "If you see ▯ (tofu), your Termux font lacks that symbol."
echo "Tip: Install Nerd Fonts (JetBrainsMono Nerd Font or FiraCode Nerd Font)."

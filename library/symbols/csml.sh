#!/bin/bash
# Characters & Symbols Master Library (CSML)
# v1.2.3-pre (Neon-aware)

CSML_VERSION="v1.2.3-pre"

# Detect & load CML (force neon if exists)
CML_READY=0
if [ -f "$HOME/kh-scripts/library/colors/cml.sh" ]; then
  source "$HOME/kh-scripts/library/colors/cml.sh"
  if [ -f "$HOME/kh-scripts/library/colors/themes/neon.sh" ]; then
    source "$HOME/kh-scripts/library/colors/themes/neon.sh"
  fi
  CML_READY=1
fi

# Detect DBML
DBML_READY=0
if [ -f "$HOME/kh-scripts/library/dynamic_box/dynamic_box.sh" ]; then
  source "$HOME/kh-scripts/library/dynamic_box/dynamic_box.sh"
  DBML_READY=1
fi

# Version
csml_version() {
  echo "CSML $CSML_VERSION"
}

# Symbol lookup (unchanged)
csml_symbol() {
  case "$1" in
    arrow_up)    echo "↑" ;;
    arrow_down)  echo "↓" ;;
    arrow_left)  echo "←" ;;
    arrow_right) echo "→" ;;
    arrow_both)  echo "↔" ;;
    arrow_vert)  echo "↕" ;;
    star_full)   echo "★" ;;
    star_empty)  echo "☆" ;;
    star_four)   echo "✦" ;;
    star_spark)  echo "✧" ;;
    block_full)  echo "█" ;;
    block_half)  echo "▓" ;;
    block_mid)   echo "▒" ;;
    block_light) echo "░" ;;
    check)       echo "✔" ;;
    cross)       echo "✘" ;;
    heart)       echo "♥" ;;
    music)       echo "♪" ;;
    circle_full) echo "●" ;;
    circle_empty)echo "○" ;;
    circle_thin) echo "◯" ;;
    tri_up)      echo "▲" ;;
    tri_down)    echo "▼" ;;
    tri_left)    echo "◀" ;;
    tri_right)   echo "▶" ;;
    diamond_full)echo "◆" ;;
    diamond_empty)echo "◇" ;;
    curr_dollar) echo "$" ;;
    curr_euro)   echo "€" ;;
    curr_pound)  echo "£" ;;
    curr_yen)    echo "¥" ;;
    curr_won)    echo "₩" ;;
    curr_btc)    echo "₿" ;;
    math_plusminus) echo "±" ;;
    math_times)  echo "×" ;;
    math_div)    echo "÷" ;;
    math_equal)  echo "=" ;;
    math_noteq)  echo "≠" ;;
    math_le)     echo "≤" ;;
    math_ge)     echo "≥" ;;
    math_inf)    echo "∞" ;;
    math_sqrt)   echo "√" ;;
    math_pi)     echo "π" ;;
    bullet_dot)  echo "•" ;;
    bullet_tri)  echo "‣" ;;
    bullet_dash) echo "⁃" ;;
    bullet_hollow) echo "◦" ;;
    *)           echo "?" ;;
  esac
}

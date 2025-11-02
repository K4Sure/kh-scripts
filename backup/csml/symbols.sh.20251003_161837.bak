#!/bin/bash
# CSML v1.1.0 – Enhanced Expansion

show_symbol() {
    local name="$1"
    local fallback_mode="$2"
    case "$name" in
        # Arrows
        arrow_up)     [[ $fallback_mode == "--fallback" ]] && echo "^"  || echo "↑" ;;
        arrow_down)   [[ $fallback_mode == "--fallback" ]] && echo "v"  || echo "↓" ;;
        arrow_left)   [[ $fallback_mode == "--fallback" ]] && echo "<"  || echo "←" ;;
        arrow_right)  [[ $fallback_mode == "--fallback" ]] && echo ">"  || echo "→" ;;
        arrow_both)   [[ $fallback_mode == "--fallback" ]] && echo "<>" || echo "↔" ;;
        arrow_vert)   [[ $fallback_mode == "--fallback" ]] && echo "|"  || echo "↕" ;;
        # Stars
        star_full)    [[ $fallback_mode == "--fallback" ]] && echo "*"  || echo "★" ;;
        star_empty)   [[ $fallback_mode == "--fallback" ]] && echo "o"  || echo "☆" ;;
        star_four)    [[ $fallback_mode == "--fallback" ]] && echo "+"  || echo "✦" ;;
        star_spark)   [[ $fallback_mode == "--fallback" ]] && echo "."  || echo "✧" ;;
        # Blocks
        block_full)   [[ $fallback_mode == "--fallback" ]] && echo "#"  || echo "█" ;;
        block_half)   [[ $fallback_mode == "--fallback" ]] && echo "="  || echo "▓" ;;
        block_mid)    [[ $fallback_mode == "--fallback" ]] && echo "-"  || echo "▒" ;;
        block_light)  [[ $fallback_mode == "--fallback" ]] && echo "."  || echo "░" ;;
        # Misc
        check)        [[ $fallback_mode == "--fallback" ]] && echo "OK" || echo "✔" ;;
        cross)        [[ $fallback_mode == "--fallback" ]] && echo "X"  || echo "✘" ;;
        heart)        [[ $fallback_mode == "--fallback" ]] && echo "<3" || echo "♥" ;;
        music)        [[ $fallback_mode == "--fallback" ]] && echo "~"  || echo "♪" ;;
        # Currency (new)
        dollar)       [[ $fallback_mode == "--fallback" ]] && echo "$"  || echo "$" ;;
        euro)         [[ $fallback_mode == "--fallback" ]] && echo "EUR"|| echo "€" ;;
        yen)          [[ $fallback_mode == "--fallback" ]] && echo "YEN"|| echo "¥" ;;
        pound)        [[ $fallback_mode == "--fallback" ]] && echo "GBP"|| echo "£" ;;
        baht)         [[ $fallback_mode == "--fallback" ]] && echo "THB"|| echo "฿" ;;
        bitcoin)      [[ $fallback_mode == "--fallback" ]] && echo "BTC"|| echo "₿" ;;
        # Math (new)
        multiply)     [[ $fallback_mode == "--fallback" ]] && echo "x"  || echo "×" ;;
        divide)       [[ $fallback_mode == "--fallback" ]] && echo "/"  || echo "÷" ;;
        plusminus)    [[ $fallback_mode == "--fallback" ]] && echo "+-" || echo "±" ;;
        sqrt)         [[ $fallback_mode == "--fallback" ]] && echo "sqrt"|| echo "√" ;;
        infinity)     [[ $fallback_mode == "--fallback" ]] && echo "inf"|| echo "∞" ;;
        approx)       [[ $fallback_mode == "--fallback" ]] && echo "~"  || echo "≈" ;;
        # Bullets (new)
        bullet_dot)   [[ $fallback_mode == "--fallback" ]] && echo "*"  || echo "•" ;;
        bullet_tri)   [[ $fallback_mode == "--fallback" ]] && echo ">"  || echo "‣" ;;
        bullet_dash)  [[ $fallback_mode == "--fallback" ]] && echo "-"  || echo "⁃" ;;
        *)
            echo "Unknown symbol: $name" ;;
    esac
}

if [[ "$1" == "--fallback" ]]; then
    shift
    show_symbol "$1" "--fallback"
else
    show_symbol "$1"
fi

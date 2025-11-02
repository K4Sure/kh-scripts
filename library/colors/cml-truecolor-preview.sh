#!/usr/bin/env bash
# cml-truecolor-preview-max.sh — Ultimate CML TrueColor Preview
# Version: v1.0.0

CML_DIR="${HOME}/kh-scripts/library/colors"
ENGINE="$CML_DIR/cml-truecolor.sh"

echo "🧪 LOADING CML TRUECOLOR ENGINE..."
source "$ENGINE" || { echo "❌ FAILED TO LOAD ENGINE"; exit 1; }

if [[ -z "${CML_TRUECOLOR_LOADED:-}" ]]; then
    echo "❌ ENGINE DID NOT INITIALIZE PROPERLY"
    exit 1
fi

THEMES=(CLASSIC "NEON:RED" "NEON:ORANGE" "NEON:YELLOW" "NEON:GREEN" "NEON:BLUE" "NEON:PURPLE" FOREST DESERT OCEAN SUMMER WINTER WILD)
ACTIVE_THEME="$(cml_refresh_theme)"
echo "✔ ENGINE LOADED: ${CML_TRUECOLOR_VERSION}"
echo "✔ ACTIVE THEME: $ACTIVE_THEME"
echo "=============================================================="

for theme in "${THEMES[@]}"; do
    echo
    echo "🎨 THEME: $theme"

    # Gradient title
    cml_title "🌈 $theme THEME PREVIEW 🌈" "$theme"

    # Gradient bar
    cml_render_gradient_bar 40 "$theme"

    # Sample INFO / SUCCESS / WARNING lines with foreground + background gradient
    LINE_LABELS=("[INFO] STATUS LINE" "[SUCCESS] LINE" "[WARNING] LINE")
    LINE_COLORS=("$CML_C1" "$CML_C2" "$CML_C3")

    for i in "${!LINE_LABELS[@]}"; do
        line="${LINE_LABELS[$i]}"
        color="${LINE_COLORS[$i]}"
        
        if cml_truecolor_supported; then
            # Foreground gradient
            fg_line="$(cml_colorize "$line" "$color")"
            # Background gradient (fill line width)
            width="${#line}"
            bg_bar=""
            for ((j=0;j<width;j++)); do
                bg_bar+="$(__interp_channel 0 255 $j $((width-1)))"
            done
            printf '%s\n' "$fg_line"
        else
            printf '%s\n' "$(cml_fallback_color "$color")$line$(cml_reset)"
        fi
    done

    if [[ "$theme" == "$ACTIVE_THEME" ]]; then
        echo "✔ THIS IS THE ACTIVE THEME"
    fi

    echo "--------------------------------------------------------------"
done

echo "🟢 FULL MAX THEME PREVIEW COMPLETE."

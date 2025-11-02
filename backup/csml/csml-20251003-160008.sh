#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# CSML v1.0.0 – Characters & Symbols Master Library
# Provides safe access to Unicode symbols with ASCII fallback
# ============================================================

CSML_VERSION="1.0.0"

# Core symbol map
declare -A CSML_MAP=(
    # Box Drawing
    ["H_LINE"]="─"
    ["V_LINE"]="│"
    ["CROSS"]="┼"
    ["CORNER_TL"]="┌"
    ["CORNER_TR"]="┐"
    ["CORNER_BL"]="└"
    ["CORNER_BR"]="┘"

    # Arrows
    ["ARROW_UP"]="↑"
    ["ARROW_DOWN"]="↓"
    ["ARROW_LEFT"]="←"
    ["ARROW_RIGHT"]="→"

    # Blocks
    ["BLOCK_FULL"]="█"
    ["BLOCK_HALF"]="▒"
    ["BLOCK_LIGHT"]="░"

    # Icons
    ["CHECK"]="✔"
    ["CROSSMARK"]="✖"
    ["STAR"]="★"
    ["HEART"]="♥"
)

# ASCII fallback map
declare -A CSML_FALLBACK=(
    ["H_LINE"]="-"
    ["V_LINE"]="|"
    ["CROSS"]="+"
    ["CORNER_TL"]="+"
    ["CORNER_TR"]="+"
    ["CORNER_BL"]="+"
    ["CORNER_BR"]="+"

    ["ARROW_UP"]="^"
    ["ARROW_DOWN"]="v"
    ["ARROW_LEFT"]="<"
    ["ARROW_RIGHT"]=">"

    ["BLOCK_FULL"]="#"
    ["BLOCK_HALF"]="="
    ["BLOCK_LIGHT"]="."

    ["CHECK"]="[OK]"
    ["CROSSMARK"]="[X]"
    ["STAR"]="*"
    ["HEART"]="<3"
)

# Function to safely get symbol
csml_get() {
    local key="\$1"
    local symbol="\${CSML_MAP[\$key]}"
    local fallback="\${CSML_FALLBACK[\$key]}"

    if [ -n "\$symbol" ]; then
        printf "%s" "\$symbol"
    else
        printf "%s" "\$fallback"
    fi
}

# Function to show CSML version
csml_version() {
    echo "CSML v\$CSML_VERSION"
}

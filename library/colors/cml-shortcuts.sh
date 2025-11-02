#!/usr/bin/env bash
# cml-shortcuts.sh — Unified CML command handler
# Version: v4.4.4

CML_DIR="${HOME}/kh-scripts/library/colors"
THEME_FILE="$CML_DIR/.cml_theme"
CML_SHORTCUTS_VERSION="v4.4.4"

# ------------------------
# Helpers
# ------------------------
cml_refresh_theme() {
    [[ -f "$THEME_FILE" ]] && cat "$THEME_FILE" || echo "CLASSIC"
}

cml_header() {
    echo
    printf '%b\n' "\033[38;2;255;105;180m=== 🏳️‍🌈 COLOR MASTER LIBRARY (CML) 🏳️‍🌈 ===\033[0m"
    echo
    printf 'CURRENT THEME: %b\n' "$(cml_colorize "$(cml_refresh_theme)" "#00FFFF")"
    echo
    printf 'VERSION: %b\n' "$CML_SHORTCUTS_VERSION"
    echo
    printf 'AVAILABLE COMMANDS:\n'
    echo "• cml info   → SHOW LIBRARY INFO + CURRENT THEME"
    echo "• cml cheat  → SHOW COLOR CHEATSHEET"
    echo "• cml demo   → SHOW A DEMO WITH CURRENT THEME"
    echo "• cml test   → RUN CML TEST SUITE"
    echo "• cml load   → LOAD / RELOAD CML"
    echo "• cml theme  → OPEN THEME SELECTOR"
    echo "• cml tht    → RUN CML FULL MAX THEME PREVIEW"
    echo
}

# ------------------------
# Command Implementations
# ------------------------
cml_info() {
    cml_header
}

cml_demo() {
    if [ -f "$CML_DIR/cml-demo.sh" ]; then
        bash "$CML_DIR/cml-demo.sh"
    else
        echo "❌ DEMO SCRIPT NOT FOUND"
    fi
}

cml_test() {
    if [ -f "$CML_DIR/cml-truecolor-tester.sh" ]; then
        bash "$CML_DIR/cml-truecolor-tester.sh"
    else
        echo "❌ TEST SCRIPT NOT FOUND"
    fi
}

cml_load() {
    # Reload CML Core & TrueColor engine
    [[ -f "$CML_DIR/cml.sh" ]] && source "$CML_DIR/cml.sh"
    [[ -f "$CML_DIR/cml-truecolor.sh" ]] && source "$CML_DIR/cml-truecolor.sh"
    echo "✔ CML RELOADED"
}

cml_theme() {
    if declare -f cml_theme_selector >/dev/null; then
        cml_theme_selector
    else
        echo "❌ THEME SELECTOR NOT FOUND"
    fi
}

cml_tht() {
    if [ -f "$CML_DIR/cml-truecolor-preview.sh" ]; then
        "$CML_DIR/cml-truecolor-preview.sh"
    else
        echo "❌ TRUECOLOR PREVIEW SCRIPT NOT FOUND"
    fi
}

# ------------------------
# Main dispatcher
# ------------------------
cml_main() {
    local cmd="$1"; shift
    case "$cmd" in
        info)   cml_info ;;
        demo)   cml_demo ;;
        test)   cml_test ;;
        load)   cml_load ;;
        theme)  cml_theme ;;
        tht)    cml_tht ;;
        ""|help) cml_header ;;
        *)      echo "❌ UNKNOWN COMMAND: $cmd"; cml_header ;;
    esac
}

# ------------------------
# Execute if script is called directly
# ------------------------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    cml_main "$@"
fi

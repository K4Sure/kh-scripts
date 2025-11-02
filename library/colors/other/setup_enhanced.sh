#!/bin/bash

# Enhanced Color Master Library Setup Script
# Simplified version to avoid HERE document issues

set -e  # Exit on error

KH_SCRIPTS_DIR="/data/data/com.termux/files/home/kh-scripts"
LIBRARY_DIR="$KH_SCRIPTS_DIR/Library"

echo "=== Enhanced Color Master Library Setup ==="

# Create Library directory if it doesn't exist
mkdir -p "$LIBRARY_DIR"

# ============================================================================
# 1. CREATE BASIC COLOR LIBRARY (Simplified)
# ============================================================================

echo "Installing enhanced color master library..."
cat > "$LIBRARY_DIR/color_master_library.sh" << 'EOF'
#!/bin/bash
# Termux Color Master Library v3.0 (Simplified)

readonly CML_VERSION="3.0.0"
readonly CML_PATH="/data/data/com.termux/files/home/kh-scripts/Library"
readonly CML_DEBUG=${CML_DEBUG:-0}
export CML_VERSION CML_PATH CML_DEBUG

# Color detection
cml_detect_color_support() {
    if [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]; then
        export CML_COLOR_MAX=16777216
        export CML_COLOR_SUPPORT="truecolor"
    elif [[ "$TERM" == *"256color"* ]]; then
        export CML_COLOR_MAX=256
        export CML_COLOR_SUPPORT="256color"
    else
        export CML_COLOR_MAX=16
        export CML_COLOR_SUPPORT="16color"
    fi
}
cml_detect_color_support

# Basic colors
readonly CML_RESET='\033[0m'
readonly CML_RED='\033[0;31m'
readonly CML_GREEN='\033[0;32m'
readonly CML_YELLOW='\033[0;33m'
readonly CML_BLUE='\033[0;34m'
readonly CML_CYAN='\033[0;36m'
readonly CML_WHITE='\033[0;37m'

# Utility functions
cml_print() {
    printf '%b%s%b' "$1" "$2" "$CML_RESET"
}

cml_log_info() { 
    cml_print "$CML_CYAN" "[INFO] "
    printf '%s\n' "$1"
}

cml_log_success() { 
    cml_print "$CML_GREEN" "[SUCCESS] "
    printf '%s\n' "$1"
}

cml_log_error() { 
    cml_print "$CML_RED" "[ERROR] "
    printf '%s\n' "$1"
}

cml_test_all() {
    echo "=== Color Test ==="
    cml_print "$CML_RED" "Red "
    cml_print "$CML_GREEN" "Green " 
    cml_print "$CML_BLUE" "Blue"
    echo ""
    echo "Support: $CML_COLOR_SUPPORT"
    echo "Max Colors: $CML_COLOR_MAX"
}

export -f cml_detect_color_support cml_print cml_log_info cml_log_success cml_log_error cml_test_all

if [[ $- == *i* ]] && [[ ${CML_NO_BANNER:-0} -eq 0 ]]; then
    cml_print "$CML_GREEN" "✓ "
    printf "Color Library v%s loaded\n" "$CML_VERSION"
fi
EOF

# ============================================================================
# 2. CREATE DISCOVERY SYSTEM
# ============================================================================

echo "Installing library discovery system..."
cat > "$LIBRARY_DIR/cml_discovery.sh" << 'EOF'
#!/bin/bash
# Color Library Discovery System

cml_find_library() {
    local paths=(
        "$KH_LIBRARY_DIR/color_master_library.sh"
        "/data/data/com.termux/files/home/kh-scripts/Library/color_master_library.sh"
        "$HOME/kh-scripts/Library/color_master_library.sh"
    )
    
    for path in "${paths[@]}"; do
        if [[ -f "$path" ]]; then
            echo "$path"
            return 0
        fi
    done
    return 1
}

cml_auto_load() {
    if [[ -n "$CML_LOADED" ]]; then
        return 0
    fi
    
    local lib_path=$(cml_find_library)
    if [[ -n "$lib_path" ]]; then
        source "$lib_path"
        export CML_LOADED=1
        return 0
    else
        return 1
    fi
}

cml_setup_script() {
    local script_name="${1:-Unknown Script}"
    if cml_auto_load; then
        cml_log_info "Starting: $script_name"
    else
        echo "Starting: $script_name"
    fi
}

export -f cml_find_library cml_auto_load cml_setup_script
EOF

# ============================================================================
# 3. CREATE TEMPLATE GENERATOR
# ============================================================================

echo "Installing script template generator..."
cat > "$LIBRARY_DIR/cml_template.sh" << 'EOF'
#!/bin/bash
# Script Template Generator

cml_new_script() {
    local script_name="$1"
    if [[ -z "$script_name" ]]; then
        echo "Usage: cml_new_script <script_name>"
        return 1
    fi
    
    if [[ ! "$script_name" =~ \.sh$ ]]; then
        script_name="${script_name}.sh"
    fi
    
    if [[ -f "$script_name" ]]; then
        echo "Error: File already exists: $script_name"
        return 1
    fi
    
    cat > "$script_name" << 'SCRIPTEOF'
#!/bin/bash
# New Script Template

# Load color library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/../Library/cml_discovery.sh" ]]; then
    source "$SCRIPT_DIR/../Library/cml_discovery.sh"
    cml_auto_load
fi

main() {
    if [[ -n "$CML_LOADED" ]]; then
        cml_setup_script "$(basename "$0")"
        cml_log_info "Script is running with color support!"
    else
        echo "Script is running without color support"
    fi
}

main "$@"
SCRIPTEOF

    chmod +x "$script_name"
    echo "Created: $script_name"
}

export -f cml_new_script
EOF

# ============================================================================
# 4. CREATE SIMPLE DOCUMENTATION
# ============================================================================

echo "Creating documentation..."
# Create README.md using echo commands
{
echo "# Color Master Library"
echo ""
echo "## Quick Start"
echo '```bash'
echo "source \"$LIBRARY_DIR/cml_discovery.sh\""
echo "cml_auto_load"
echo "cml_log_info \"Hello World\""
echo '```'
} > "$LIBRARY_DIR/README.md"

# Create CHEATSHEET.md
{
echo "# Color Library Cheat Sheet"
echo ""
echo "## Commands"
echo "- cml-new script.sh - Create new script"
echo "- cml-test - Test library"
echo "- cml-help - Show help"
} > "$LIBRARY_DIR/CHEATSHEET.md"

# ============================================================================
# 5. SET UP BASH ALIASES
# ============================================================================

echo "Setting up bash aliases..."
BASHRC_FILE="/data/data/com.termux/files/home/.bashrc"

# Remove any existing cml aliases
sed -i '/cml-new/d' "$BASHRC_FILE"
sed -i '/cml-test/d' "$BASHRC_FILE"
sed -i '/cml-help/d' "$BASHRC_FILE"
sed -i '/cml-reload/d' "$BASHRC_FILE"

# Add new aliases
cat >> "$BASHRC_FILE" << 'EOF'

# Color Master Library Aliases
alias cml-new='source /data/data/com.termux/files/home/kh-scripts/Library/cml_template.sh; cml_new_script'
alias cml-test='source /data/data/com.termux/files/home/kh-scripts/Library/color_master_library.sh; cml_test_all'
alias cml-help='cat /data/data/com.termux/files/home/kh-scripts/Library/CHEATSHEET.md'
alias cml-reload='source /data/data/com.termux/files/home/kh-scripts/Library/color_master_library.sh'
EOF

# ============================================================================
# 6. SET PERMISSIONS
# ============================================================================

echo "Setting permissions..."
chmod +x "$LIBRARY_DIR"/*.sh

# ============================================================================
# 7. CREATE VERIFICATION SCRIPT
# ============================================================================

echo "Creating verification script..."
cat > "$KH_SCRIPTS_DIR/verify_simple.sh" << 'EOF'
#!/bin/bash

echo "=== Simple Color Library Verification ==="

# Test if files exist
files=(
    "color_master_library.sh"
    "cml_discovery.sh" 
    "cml_template.sh"
    "README.md"
    "CHEATSHEET.md"
)

for file in "${files[@]}"; do
    if [[ -f "/data/data/com.termux/files/home/kh-scripts/Library/$file" ]]; then
        echo "✓ $file"
    else
        echo "✗ $file"
    fi
done

# Test basic functionality
if source "/data/data/com.termux/files/home/kh-scripts/Library/color_master_library.sh" 2>/dev/null; then
    echo "✓ Library loads successfully"
    cml_test_all
else
    echo "✗ Library failed to load"
fi

echo "✅ Verification completed!"
EOF

chmod +x "$KH_SCRIPTS_DIR/verify_simple.sh"

# ============================================================================
# COMPLETION
# ============================================================================

echo ""
echo "=== Enhanced Color Library Setup Complete ==="
echo ""
echo "📁 Library Location: $LIBRARY_DIR"
echo ""
echo "🚀 Quick Commands:"
echo "   cml-new script.sh     # Create new script"
echo "   cml-test              # Test library"
echo "   cml-help              # Show help"
echo "   cml-reload            # Reload library"
echo ""
echo "🔍 Test the setup:"
echo "   ./verify_simple.sh"
echo ""
echo "🔄 Reload your terminal or run: source ~/.bashrc"


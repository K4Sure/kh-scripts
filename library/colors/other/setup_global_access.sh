#!/bin/bash

# Setup script for global access to kh-scripts Library

KH_SCRIPTS_DIR="/data/data/com.termux/files/home/kh-scripts"
LIBRARY_DIR="$KH_SCRIPTS_DIR/Library"
BASHRC_FILE="/data/data/com.termux/files/home/.bashrc"
ZSHRC_FILE="/data/data/com.termux/files/home/.zshrc"
PROFILE_FILE="/data/data/com.termux/files/home/.profile"

# Create directories if they don't exist
echo "Creating directory structure..."
mkdir -p "$LIBRARY_DIR"

# Set environment variable for easy access
echo "Setting up environment variables..."

# Add to shell configuration files
add_to_file() {
    local file="$1"
    local content="$2"
    
    if [ -f "$file" ]; then
        if ! grep -q "KH_SCRIPTS_DIR" "$file"; then
            echo "$content" >> "$file"
            echo "✓ Added to $file"
        else
            echo "✓ Already exists in $file"
        fi
    else
        echo "✗ $file not found"
    fi
}

# Add to bashrc
add_to_file "$BASHRC_FILE" "
# KH Scripts Library Global Access
export KH_SCRIPTS_DIR=\"$KH_SCRIPTS_DIR\"
export KH_LIBRARY_DIR=\"$LIBRARY_DIR\"
source \"\$KH_LIBRARY_DIR/color_master_library.sh\"
"

# Add to zshrc if exists
add_to_file "$ZSHRC_FILE" "
# KH Scripts Library Global Access
export KH_SCRIPTS_DIR=\"$KH_SCRIPTS_DIR\"
export KH_LIBRARY_DIR=\"$LIBRARY_DIR\"
source \"\$KH_LIBRARY_DIR/color_master_library.sh\"
"

# Add to profile for all shells
add_to_file "$PROFILE_FILE" "
# KH Scripts Library Global Access
export KH_SCRIPTS_DIR=\"$KH_SCRIPTS_DIR\"
export KH_LIBRARY_DIR=\"$LIBRARY_DIR\"
"

# Create a symlink in /data/data/com.termux/files/usr/bin for easy access
echo "Creating global symlinks..."
ln -sf "$LIBRARY_DIR/color_master_library.sh" "/data/data/com.termux/files/usr/bin/color-lib" 2>/dev/null && echo "✓ Created symlink: color-lib" || echo "✗ Symlink creation failed"

# Make the library executable
chmod +x "$LIBRARY_DIR/color_master_library.sh"

echo ""
echo "=== Global Access Setup Complete ==="
echo "Library Location: $LIBRARY_DIR"
echo "Environment Variables:"
echo "  KH_SCRIPTS_DIR: $KH_SCRIPTS_DIR"
echo "  KH_LIBRARY_DIR: $LIBRARY_DIR"
echo ""
echo "Usage in scripts:"
echo "  source \$KH_LIBRARY_DIR/color_master_library.sh"
echo "  # or simply:"
echo "  source color_master_library.sh  # if in the same directory"
echo ""
echo "Restart your terminal or run: source $BASHRC_FILE"


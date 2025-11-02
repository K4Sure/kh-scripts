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
    if [[ -f "/data/data/com.termux/files/home/kh-scripts/library/colors/$file" ]]; then
        echo "✓ $file"
    else
        echo "✗ $file"
    fi
done

# Test basic functionality
if source "/data/data/com.termux/files/home/kh-scripts/library/colors/color_master_library.sh" 2>/dev/null; then
    echo "✓ Library loads successfully"
    cml_test_all
else
    echo "✗ Library failed to load"
fi

echo "✅ Verification completed!"

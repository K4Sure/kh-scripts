#!/bin/bash

# Quick test for color master library

echo "Testing Color Master Library..."

# Try to load the library
if [ -f "/data/data/com.termux/files/home/kh-scripts/Library/color_master_library.sh" ]; then
    source "/data/data/com.termux/files/home/kh-scripts/Library/color_master_library.sh"
    echo "✓ Library loaded successfully"
    
    # Test basic functionality
    echo -e "${GREEN}✓ Green text test${COLOR_RESET}"
    echo -e "${RED}✓ Red text test${COLOR_RESET}"
    echo -e "${BLUE}✓ Blue text test${COLOR_RESET}"
    
    # Test function
    log_success "Library is working correctly!"
    
else
    echo "✗ Library not found at expected location"
    echo "Please run the setup script first"
fi


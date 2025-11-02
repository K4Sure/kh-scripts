#!/bin/bash

# Load the color master library
source /data/data/com.termux/files/home/kh-scripts/Library/color_master_library.sh

echo "=== Color Master Library Examples ==="
echo ""

# Show library info
color_info
echo ""

# Basic usage examples
echo "--- Basic Color Examples ---"
print_color $RED "This is red text"
echo ""
print_color_bg $WHITE $BG_BLUE "White text on blue background"
echo ""
print_color $BOLD_GREEN "This is bold green text"
echo ""

# 256-color examples
if [ "$COLOR_SUPPORT" = "256color" ] || [ "$COLOR_SUPPORT" = "truecolor" ]; then
    echo "--- 256-Color Examples ---"
    print_256 196 "Fire red "
    print_256 46 "Electric green "
    print_256 39 "Sky blue "
    print_256 213 "Hot pink "
    print_256 226 "Lemon yellow"
    echo -e "\n"
fi

# True color examples
if [ "$COLOR_SUPPORT" = "truecolor" ]; then
    echo "--- True Color Examples ---"
    truecolor_rainbow "Rainbow colored text using true color!"
    echo -e "\n"
    
    echo "--- Gradient Examples ---"
    truecolor_gradient "Sunset Gradient" 255 0 0 255 165 0
    echo ""
    truecolor_gradient "Ocean Gradient" 0 0 255 0 255 255
    echo -e "\n"
fi

# Logging examples
echo "--- Logging Examples ---"
log_info "This is an informational message"
log_success "Operation completed successfully!"
log_warning "This is a warning message"
log_error "An error occurred during processing"
log_debug "Debug information: variable x = 42"

# Status examples
echo "--- Status Indicators ---"
echo "System check: $(status_ok) Memory usage"
echo "System check: $(status_fail) Disk space"
echo "System check: $(status_warn) CPU temperature"
echo "System check: $(status_info) Network status"

# Prompt examples
echo "--- Prompt Examples ---"
echo "$(prompt_success) $(prompt_user)@$(prompt_host) $(prompt_directory) $(prompt_arrow)"


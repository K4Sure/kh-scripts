#!/bin/bash
# New Script Template
# Generated with Color Master Library

# Load color library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/../library/colors/cml_discovery.sh" ]]; then
    source "$SCRIPT_DIR/../library/colors/cml_discovery.sh"
    cml_auto_load
elif [[ -f "/data/data/com.termux/files/home/kh-scripts/library/colors/cml_discovery.sh" ]]; then
    source "/data/data/com.termux/files/home/kh-scripts/library/colors/cml_discovery.sh"
    cml_auto_load
fi

# Main function
main() {
    if [[ -n "$CML_LOADED" ]]; then
        # Use cml_setup_script if available, otherwise fallback
        if command -v cml_setup_script >/dev/null 2>&1; then
            cml_setup_script "$(basename "$0")"
        else
            cml_log_info "Starting: $(basename "$0")"
        fi
        
        cml_log_info "Script is running with color support!"
        cml_log_success "Template working correctly"
        
        # Theme usage examples (exact formatting you want)
        cml_print_theme "primary" "Primary theme color example"
        echo
        cml_print_theme "secondary" "Secondary theme color example"
        echo
    else
        echo "Starting: $(basename "$0")"
        echo "INFO: Script running without color support"
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

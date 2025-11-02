#!/bin/bash
# Script Template Generator for Color Master Library v4.0.0

cml_create_script() {
    local script_path="$1"
    local script_name=$(basename "$script_path")
    
    if [[ -f "$script_path" ]]; then
        echo "ERROR: Script already exists: $script_path" >&2
        return 1
    fi
    
    cat > "$script_path" << 'SCRIPT_TEMPLATE'
#!/bin/bash
# New Script Template
# Generated with Color Master Library v4.0.0

# Load color library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/../library/colors/cml_discovery.sh" ]]; then
# source "$SCRIPT_DIR/../library/colors/cml_discovery.sh"
    cml_auto_load
elif [[ -f "/data/data/com.termux/files/home/kh-scripts/library/colors/cml_discovery.sh" ]]; then
# source "/data/data/com.termux/files/home/kh-scripts/library/colors/cml_discovery.sh"
    cml_auto_load
fi

# Main function
main() {
    # Empty line at the beginning
    echo

    if [[ -n "$CML_LOADED" ]]; then
        # Use cml_setup_script if available, otherwise fallback
        if command -v cml_setup_script >/dev/null 2>&1; then
            cml_setup_script "$(basename "$0")"
        else
            cml_log_info "Starting: $(basename "$0")"
        fi

        cml_log_info "Script is running with Color Master Library v4.0.0!"
        cml_log_success "Template working correctly"

        # v4.0.0 Feature examples
        cml_print_theme "primary" "Primary theme color"
        echo
        cml_print_theme "secondary" "Secondary theme color"
        echo
        cml_print_theme "bg" " Background example "
        echo
        cml_log_info_ts "Timestamp demo"
    else
        echo "Starting: $(basename "$0")"
        echo "INFO: Script running without color support"
    fi

    # Empty line at the end
    echo
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
SCRIPT_TEMPLATE

    chmod +x "$script_path"
    echo "Created: $script_path (v4.0.0)"
}

cml_new_script() {
    local script_name="$1"
    if [[ -z "$script_name" ]]; then
        echo "Usage: cml_new_script <script_name>"
        return 1
    fi
    
    if [[ ! "$script_name" =~ \.sh$ ]]; then
        script_name="${script_name}.sh"
    fi
    
    cml_create_script "$PWD/$script_name"
}

export -f cml_create_script cml_new_script

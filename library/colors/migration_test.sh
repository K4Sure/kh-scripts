#!/bin/bash
# New Script Template

# Load color library using absolute path
if [[ -f "/data/data/com.termux/files/home/kh-scripts/library/colors/cml_discovery.sh" ]]; then
    source "/data/data/com.termux/files/home/kh-scripts/library/colors/cml_discovery.sh"
    cml_auto_load
fi

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
    else
        echo "Script is running without color support"
    fi
}

main "$@"

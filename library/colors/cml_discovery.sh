#!/bin/bash
# Color Library Discovery System

cml_find_library() {
    local paths=(
        "$KH_LIBRARY_DIR/color_master_library.sh"
        "/data/data/com.termux/files/home/kh-scripts/library/colors/color_master_library.sh"
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

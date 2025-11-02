#!/bin/bash
# Dynamic Box Master Library Loader
# Auto-discovers and loads the DBML library

DBML_LOADER_VERSION="1.0.0"

dbml_autodiscover() {
    local possible_paths=(
        "$HOME/kh-scripts/library/dynamic_box/dynamic_box_master_library.sh"
        "/data/data/com.termux/files/home/kh-scripts/library/dynamic_box/dynamic_box_master_library.sh"
        "$(dirname "$0")/dynamic_box_master_library.sh"
        "./dynamic_box_master_library.sh"
    )
    
    for path in "${possible_paths[@]}"; do
        if [[ -f "$path" ]]; then
            echo "$path"
            return 0
        fi
    done
    
    return 1
}

dbml_load() {
    if [[ -n "$DBML_LOADED" ]]; then
        echo "Dynamic Box Library already loaded"
        return 0
    fi
    
    local lib_path
    if [[ -n "$1" && -f "$1" ]]; then
        lib_path="$1"
    else
        lib_path=$(dbml_autodiscover)
    fi
    
    if [[ -z "$lib_path" ]]; then
        echo "Error: Dynamic Box Library not found!" >&2
        echo "Searched in:"
        echo "  $HOME/kh-scripts/library/dynamic_box/"
        echo "  /data/data/com.termux/files/home/kh-scripts/library/dynamic_box/"
        echo "  Current directory"
        return 1
    fi
    
    if source "$lib_path"; then
        echo "✓ Dynamic Box Library loaded from: $lib_path"
        return 0
    else
        echo "Error: Failed to load library from: $lib_path" >&2
        return 1
    fi
}

# Main loader logic
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script executed directly
    dbml_load "$@"
else
    # Script sourced
    if [[ -z "$DBML_LOADED" ]]; then
        dbml_load
    fi
fi


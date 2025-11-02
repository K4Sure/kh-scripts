#!/bin/bash

# Color Master Library Module Loader
# Dynamically loads modules based on color support

CML_BASE_DIR="${CML_BASE_DIR:-/data/data/com.termux/files/home/kh-scripts/library/colors}"

# Load core utilities first
source "$CML_BASE_DIR/cml_core.sh"

# Load modules based on color support
case "$CML_COLOR_SUPPORT" in
    truecolor)
        source "$CML_BASE_DIR/cml_truecolor.sh"
        source "$CML_BASE_DIR/cml_256.sh"
        source "$CML_BASE_DIR/cml_16.sh"
        ;;
    256color)
        source "$CML_BASE_DIR/cml_256.sh"
        source "$CML_BASE_DIR/cml_16.sh"
        ;;
    *)
        source "$CML_BASE_DIR/cml_16.sh"
        ;;
esac

# Load semantic palette system
source "$CML_BASE_DIR/cml_semantic.sh"

# Load utility functions
source "$CML_BASE_DIR/cml_utils.sh"


#!/bin/bash
# CSML Installer v1.0.0-prelaunch

BASE_DIR="$HOME/kh-scripts"
LIB_DIR="\$BASE_DIR/library/symbols"
LOG_DIR="\$BASE_DIR/logs"
mkdir -p "\$LIB_DIR" "\$LOG_DIR"

echo "=== Installing CSML v1.0.0-prelaunch ===" | tee "\$LOG_DIR/csml-install.log"
cp -v "\$BASE_DIR/install-csml.sh" "\$LIB_DIR/" | tee -a "\$LOG_DIR/csml-install.log"
echo "Done. CSML installed."

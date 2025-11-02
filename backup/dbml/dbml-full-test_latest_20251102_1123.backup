#!/bin/bash
# DBML v4.2.3-stable Combined Test Suite
# Author: KH project (professional build)
# Purpose: Verify all Dynamic Box Master Library (DBML) functions
# Log: ~/kh-scripts/logs/dbml-test.log

# --- Setup ---
export LANG=${LANG:-en_US.UTF-8}
export LC_ALL=${LC_ALL:-en_US.UTF-8}
LOG_DIR="$HOME/kh-scripts/logs"
BACKUP_DIR="$HOME/kh-scripts/backup"
SCRIPT_NAME="dbml-full-test.sh"
LOG_FILE="$LOG_DIR/dbml-test.log"

mkdir -p "$LOG_DIR" "$BACKUP_DIR"

# Backup this script
cp -f "$HOME/kh-scripts/$SCRIPT_NAME" "$BACKUP_DIR/${SCRIPT_NAME}.bak"

# Redirect all output to log (tee shows it live + saves it)
exec > >(tee "$LOG_FILE") 2>&1

echo "=== DBML v4.2.3-stable Combined Test Suite ==="
echo "Started at: $(date)"
echo "Log file: $LOG_FILE"
echo

# --- 1. Box Drawing Test ---
echo "[1] Box Drawing Styles"
bash "$HOME/kh-scripts/library/dynamic_box/dynamic_box.sh" <<'EOC'
box_auto single "DBML Stable|Box Drawing Test|Single"
box_auto double "DBML Stable|Box Drawing Test|Double"
box_auto rounded "DBML Stable|Box Drawing Test|Rounded"
EOC
echo

# --- 2. Alignment & Wrapping Test ---
echo "[2] Alignment & Wrapping"
bash "$HOME/kh-scripts/library/dynamic_box/dynamic_box.sh" <<'EOC'
box_auto double "Normal left (default)|Works well"
box_auto double --center "Center aligned|Text block"
box_wrap rounded 20 --right "This is a long sentence that should wrap nicely at spaces."
EOC
echo

# --- 3. UTF-8 Safe Repeat Test ---
echo "[3] UTF-8 Repeat Test"
bash "$HOME/kh-scripts/utf8-safe-test.sh"
echo

# --- 4. Version Check ---
echo "[4] Version Check"
bash "$HOME/kh-scripts/library/dynamic_box/dynamic_box.sh" dbml_version
echo

echo "=== DBML v4.2.3-stable Test Suite Completed ==="
echo "Finished at: $(date)"

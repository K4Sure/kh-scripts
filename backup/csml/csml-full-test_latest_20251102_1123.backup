#!/bin/bash
# CSML Combined Test Suite (Expanded)
# v1.0.0-prelaunch

LOGFILE="$HOME/kh-scripts/logs/csml-test.log"

echo "=== CSML v1.0.0-prelaunch Combined Test Suite ==="
echo "Started at: $(date)" | tee "$LOGFILE"
echo >> "$LOGFILE"

# Section 1: Version
echo "[1] Version" | tee -a "$LOGFILE"
bash -c "source ~/kh-scripts/library/symbols/symbols.sh && csml_version" | tee -a "$LOGFILE"
echo >> "$LOGFILE"

# Section 2: Arrows
echo "[2] Arrows Test" | tee -a "$LOGFILE"
for s in arrow_up arrow_down arrow_left arrow_right arrow_both arrow_vert; do
  out=$(bash -c "source ~/kh-scripts/library/symbols/symbols.sh && csml_symbol $s")
  printf "%-12s -> %s %s %s\n" "$s" "$out" "$out" "$out" | tee -a "$LOGFILE"
done
echo >> "$LOGFILE"

# Section 3: Stars
echo "[3] Stars Test" | tee -a "$LOGFILE"
for s in star_full star_empty star_four star_spark; do
  out=$(bash -c "source ~/kh-scripts/library/symbols/symbols.sh && csml_symbol $s")
  printf "%-12s -> %s %s %s\n" "$s" "$out" "$out" "$out" | tee -a "$LOGFILE"
done
echo >> "$LOGFILE"

# Section 4: Blocks
echo "[4] Blocks Test" | tee -a "$LOGFILE"
for s in block_full block_half block_mid block_light; do
  out=$(bash -c "source ~/kh-scripts/library/symbols/symbols.sh && csml_symbol $s")
  printf "%-12s -> %s %s %s\n" "$s" "$out" "$out" "$out" | tee -a "$LOGFILE"
done
echo >> "$LOGFILE"

# Section 5: Misc
echo "[5] Misc Test" | tee -a "$LOGFILE"
for s in check cross heart music; do
  out=$(bash -c "source ~/kh-scripts/library/symbols/symbols.sh && csml_symbol $s")
  printf "%-12s -> %s %s %s\n" "$s" "$out" "$out" "$out" | tee -a "$LOGFILE"
done
echo >> "$LOGFILE"

# Section 6: Demo
echo "[6] Demo Script Output" | tee -a "$LOGFILE"
bash ~/kh-scripts/library/symbols/symbols-demo.sh | tee -a "$LOGFILE"

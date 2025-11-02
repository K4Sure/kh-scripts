#!/bin/bash
# CSML v1.1.0-upgrade - Sync cheatsheet from symbols-map.txt

MAP=~/kh-scripts/library/symbols/symbols-map.txt
CHEAT=~/kh-scripts/library/symbols/symbols-cheatsheet.txt

{
  echo "== CSML Cheatsheet v1.1.0-upgrade =="
  echo
  current_section=""
  while IFS='|' read -r name utf8 fallback; do
    # Auto-group by prefix
    section=\$(echo "\$name" | cut -d_ -f1)
    if [[ "\$section" != "\$current_section" ]]; then
      echo
      echo "\${section^}:"
      current_section="\$section"
    fi
    printf " %-10s → %s   (fallback: %s)\n" "\$name" "\$utf8" "\$fallback"
  done < "\$MAP"
} > "\$CHEAT"

echo "Cheatsheet synced to \$CHEAT"

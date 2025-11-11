#!/usr/bin/env sh
# palette_loader v0.1.0 - outputs key:value pairs from a simple YAML palette
theme="${1:-lib/cml/themes/theme-default_v1.0.0.yaml}"
[ -f "$theme" ] || { echo "theme missing: $theme" >&2; exit 1; }
awk '/^[[:alnum:]_-]+:/{gsub(/^[[:space:]]+|[[:space:]]+$/,""); sub(/: */," "); print}' "$theme" 2>/dev/null || true

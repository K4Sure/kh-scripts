#!/usr/bin/env sh
# cml_palette v0.2.0 - load a named palette from lib/cml/themes and print key:value
set -e
name="${1:-theme-default}"
theme="lib/cml/themes/${name}_v1.0.0.yaml"
if [ ! -f "$theme" ]; then
  echo "ERROR: theme not found: $theme" >&2
  exit 2
fi
# naive YAML top-level palette extractor: prints key:value for entries under palette
awk '
  /^palette:/ { inpal=1; next }
  inpal && /^[[:space:]]+[[:alnum:]_-]+:/ {
    gsub(/^[[:space:]]+|[[:space:]]+$/,"")
    sub(/: */,":")
    print
  }
  inpal && NF==0 { exit }
' "$theme" | sed 's/^[[:space:]]*//' || true

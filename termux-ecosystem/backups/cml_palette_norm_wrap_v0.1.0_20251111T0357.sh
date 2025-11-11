#!/usr/bin/env sh
# cml_palette normalization wrapper: lowercase keys, trim values, theme shortcuts
set -e

PL="lib/cml/src/cml_palette_v0.3.0.sh"

# Map first argument to concrete theme path while preserving remaining args
if [ $# -ge 1 ]; then
  first="$1"; shift
  case "$first" in
    base)      first="lib/cml/themes/base_v1.0.0.yaml" ;;
    edge_base) first="lib/cml/themes/edge_base_v1.0.0.yaml" ;;
  esac
  # Rebuild positional args with mapped first
  set -- "$first" "$@"
fi

# If stdin is piped and "-" isn’t present, append "-"
if [ ! -t 0 ]; then
  need_dash=1
  for a in "$@"; do
    [ "x$a" = "x-" ] && { need_dash=0; break; }
  done
  [ $need_dash -eq 1 ] && set -- "$@" -
fi

# Execute core loader, then normalize: keys lowercase, values trimmed and de-quoted
"$PL" "$@" | awk -F: '
  {
    key=$1
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
    key=tolower(key)

    val=substr($0, index($0,":")+1)
    # Remove surrounding double quotes if present, then trim spaces
    sub(/^"[[:space:]]*/, "", val)
    sub(/[[:space:]]*"$/, "", val)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)

    print key ":" val
  }
' | sort

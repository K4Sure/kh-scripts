#!/usr/bin/env sh
# cml_palette v0.3.0 — portable, stdin-aware
set -e

usage(){
  cat >&2 <<USAGE
Usage: $0 <base.yaml> [override.yaml ... | -]
- reads palette keys from files under "palette:" block
- reads raw key:value lines from stdin when "-" is provided
Later inputs override earlier ones (last-wins).
USAGE
  exit 2
}

[ $# -lt 1 ] && usage

TMP=${TMPDIR:-/tmp}/cmlpal.$$.$RANDOM
trap 'rm -f "$TMP"' EXIT
: > "$TMP"

read_file_palette() {
  awk '
    BEGIN{inpal=0}
    /^palette:[[:space:]]*$/ { inpal=1; next }
    inpal && /^[[:space:]]+[[:alnum:]_-]+:[[:space:]]*/ {
      sub(/^[[:space:]]+/, "");
      gsub(/:[[:space:]]*/, ":", $0);
      print $0
    }
  ' "$1" 2>/dev/null || true
}

read_stdin_raw() {
  awk '
    /^[[:space:]]*[[:alnum:]_-]+:[[:space:]]*/ {
      sub(/^[[:space:]]+/, "");
      gsub(/:[[:space:]]*/, ":", $0);
      print $0
    }
  ' /dev/stdin 2>/dev/null || true
}

# Resolve base (allow direct path or themed name)
first="$1"; shift
case "$first" in
  */*|*.yaml) base="$first" ;;
  *) base="lib/cml/themes/${first}_v1.0.0.yaml" ;;
esac

[ ! -f "$base" ] && { echo "ERROR: base theme not found: $base" >&2; exit 3; }
read_file_palette "$base" >> "$TMP"

# Process overrides; consume stdin only once
stdin_done=0
for of in "$@"; do
  if [ "x$of" = "x-" ]; then
    [ "$stdin_done" -eq 0 ] && { read_stdin_raw >> "$TMP"; stdin_done=1; }
  elif [ -f "$of" ]; then
    read_file_palette "$of" >> "$TMP"
  else
    echo "WARNING: override not found: $of" >&2
  fi
done

# last-wins reducer
awk -F: '
  {
    key=$1; gsub(/^[[:space:]]+|[[:space:]]+$/,"",key);
    val=substr($0, index($0,":")+1);
    sub(/^[[:space:]]+/,"",val);
    last[key]=val;
  }
  END {
    for (k in last) print k ":" last[k]
  }
' "$TMP" | sort

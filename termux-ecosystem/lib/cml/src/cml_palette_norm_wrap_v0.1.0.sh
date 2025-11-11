#!/usr/bin/env sh
# cml_palette normalization wrapper: lowercase keys, trim values, theme shortcuts, validation, order
set -e

PL="lib/cml/src/cml_palette_v0.3.0.sh"

# Map first argument to concrete theme path while preserving remaining args
if [ $# -ge 1 ]; then
  first="$1"; shift
  case "$first" in
    base)      first="lib/cml/themes/base_v1.0.0.yaml" ;;
    edge_base) first="lib/cml/themes/edge_base_v1.0.0.yaml" ;;
  esac
  set -- "$first" "$@"
fi

# If stdin is piped and "-" isn’t present, append "-"
if [ ! -t 0 ]; then
  need_dash=1
  for a in "$@"; do [ "x$a" = "x-" ] && { need_dash=0; break; }; done
  [ $need_dash -eq 1 ] && set -- "$@" -
fi

# Natural key order (optional): set ORDER=rgb to sort x,y,z,a,b,c...
ORDER="${ORDER:-rgb}" # default rgb (x,y,z first), override with ORDER=az

# Execute core loader, then normalize, validate, and order
"$PL" "$@" | awk -F: -v ORDER="$ORDER" '
  function trim(s){ gsub(/^[[:space:]]+|[[:space:]]+$/,"",s); return s }
  function dequote(s){
    sub(/^"[[:space:]]*/, "", s); sub(/[[:space:]]*"$/, "", s);
    return trim(s)
  }
  function warn(msg){ print "WARNING: " msg > "/dev/stderr" }

  {
    key=tolower(trim($1))
    val=dequote(substr($0, index($0,":")+1))

    # Hex validation: accept #rgb or #rrggbb
    if (val !~ /^#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?$/) {
      warn("invalid hex for " key ": " val)
    }

    last[key]=val
  }
  END {
    if (ORDER == "rgb") {
      # print x,y,z first if present, then remaining keys sorted
      base[1]="x"; base[2]="y"; base[3]="z"
      for (i=1;i<=3;i++) { k=base[i]; if (k in last) print k ":" last[k] }
      # collect remaining keys
      n=0
      for (k in last) {
        if (k!="x" && k!="y" && k!="z") { n++; rest[n]=k }
      }
      # simple bubble sort for small sets
      for (i=1;i<=n;i++) for (j=i+1;j<=n;j++) if (rest[i] > rest[j]) { tmp=rest[i]; rest[i]=rest[j]; rest[j]=tmp }
      for (i=1;i<=n;i++) print rest[i] ":" last[rest[i]]
    } else {
      # alphabetical stable order
      for (k in last) print k ":" last[k]
    }
  }
' | { [ "$ORDER" = "az" ] && sort || cat; }

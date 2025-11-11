#!/usr/bin/env sh
# cml_palette normalization wrapper v0.1.0
set -e
PL="lib/cml/src/cml_palette_v0.3.0.sh"
if [ $# -ge 1 ]; then first="$1"; shift
  case "$first" in
    base) first="lib/cml/themes/base_v1.0.0.yaml" ;;
    edge_base) first="lib/cml/themes/edge_base_v1.0.0.yaml" ;;
  esac
  set -- "$first" "$@"
fi
if [ ! -t 0 ]; then
  need_dash=1
  for a in "$@"; do [ "x$a" = "x-" ] && { need_dash=0; break; }; done
  [ $need_dash -eq 1 ] && set -- "$@" -
fi
ORDER="${ORDER:-rgb}"
"$PL" "$@" | awk -F: -v ORDER="$ORDER" '
  function trim(s){ gsub(/^[[:space:]]+|[[:space:]]+$/,"",s); return s }
  function dequote(s){ sub(/^"[[:space:]]*/,"",s); sub(/[[:space:]]*"$/,"",s); return trim(s) }
  {
    key=tolower(trim($1))
    val=dequote(substr($0, index($0,":")+1))
    if (val !~ /^#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?$/) {
      print "FATAL: invalid hex for " key ": " val > "/dev/stderr"
      exit 2
    }
    last[key]=val
  }
  END {
    if (ORDER=="rgb") {
      base[1]="x"; base[2]="y"; base[3]="z"
      for (i=1;i<=3;i++) { k=base[i]; if (k in last) print k ":" last[k] }
      n=0; for (k in last) if (k!="x" && k!="y" && k!="z") { n++; rest[n]=k }
      for (i=1;i<=n;i++) for (j=i+1;j<=n;j++) if (rest[i] > rest[j]) { tmp=rest[i]; rest[i]=rest[j]; rest[j]=tmp }
      for (i=1;i<=n;i++) print rest[i] ":" last[rest[i]]
    } else {
      for (k in last) print k ":" last[k]
    }
  }
' | { [ "$ORDER" = "az" ] && sort || cat; }

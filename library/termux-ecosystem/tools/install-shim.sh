#!/usr/bin/env bash
# install-shim.sh — write shims that call BMC with the original namespaced export
set -euo pipefail

HOME_DIR="${HOME:-/data/data/com.termux/files/home}"
BASE="$HOME_DIR/kh-scripts"
LIBROOT="$BASE/library/termux-ecosystem"
SHIMDIR="$BASE/bin"
BMC_BOOTSTRAP="$HOME_DIR/bmc/bootstrap.sh"

err() { printf "ERR: %s\n" "$*" >&2; }
info() { printf "INFO: %s\n" "$*"; }

usage() {
  cat <<EOF
Usage:
  $0 create <libname> [shim-name ...]
  $0 remove <libname> [shim-name ...]
  $0 refresh <libname>
EOF
  exit 2
}

manifest_path() {
  local lib="$1"
  printf "%s/%s/current/MANIFEST.yml" "$LIBROOT" "$lib"
}

# parse exports and emit lines: shim_name|entry_name
# e.g., csml-set|csml::set
parse_exports_from_manifest() {
  local manifest="$1"
  awk '
    /^exports:/ {flag=1; next}
    /^[[:alnum:]_][[:alnum:][:space:]_-]*:/{ if(flag) flag=0 }
    flag && NF { gsub(/- /,""); gsub(/^[[:space:]]+|[[:space:]]+$/,""); print }
  ' "$manifest" | sed -E 's/^[[:space:]]*//; s/[[:space:]]*$//' | while IFS= read -r exp; do
    [ -z "$exp" ] && continue
    shim=$(printf "%s" "$exp" | sed 's/::/-/g')
    printf "%s|%s\n" "$shim" "$exp"
  done
}

write_shim() {
  local shim="$1"
  local lib="$2"
  local entry="$3"   # namespaced entry like csml::set
  local path="$SHIMDIR/$shim"

  mkdir -p "$SHIMDIR"
  cat > "$path" <<'SHIM'
#!/usr/bin/env bash
set -euo pipefail
HOME_DIR="${HOME:-/data/data/com.termux/files/home}"
BMC_BOOTSTRAP='__BMC_BOOTSTRAP__'
LIB_NAME='__LIB_NAME__'
ENTRY_NAME='__ENTRY_NAME__'
exec "$BMC_BOOTSTRAP" "$LIB_NAME" "$ENTRY_NAME" "$@"
SHIM

  sed -i "s|__BMC_BOOTSTRAP__|${BMC_BOOTSTRAP}|g" "$path"
  sed -i "s|__LIB_NAME__|${lib}|g" "$path"
  sed -i "s|__ENTRY_NAME__|${entry}|g" "$path"

  chmod 0755 "$path"
  info "wrote shim: $path"
}

create_shims_from_manifest() {
  local lib="$1"
  local manifest
  manifest="$(manifest_path "$lib")"
  if [ ! -f "$manifest" ]; then
    err "manifest not found: $manifest"
    exit 4
  fi
  local pair
  parse_exports_from_manifest "$manifest" | while IFS='|' read -r shim entry; do
    [ -z "$shim" ] && continue
    write_shim "$shim" "$lib" "$entry"
  done
}

remove_shims() {
  local lib="$1"; shift
  mkdir -p "$SHIMDIR"
  if [ $# -eq 0 ]; then
    for f in "$SHIMDIR"/*; do
      [ -f "$f" ] || continue
      if grep -q "BMC bootstrap" "$f" 2>/dev/null || grep -q "__LIB_NAME__" "$f" 2>/dev/null; then
        if grep -q "$lib" "$f" 2>/dev/null; then
          rm -f "$f"
          info "removed shim $f"
        fi
      fi
    done
    return 0
  fi
  for s in "$@"; do
    local path="$SHIMDIR/$s"
    if [ -f "$path" ]; then
      rm -f "$path"
      info "removed shim $path"
    else
      info "shim not found: $path"
    fi
  done
}

# main
[ $# -ge 2 ] || { usage; }
cmd="$1"; shift

case "$cmd" in
  create)
    lib="$1"; shift
    if [ $# -gt 0 ]; then
      for s in "$@"; do
        write_shim "$s" "$lib" "$s"
      done
    else
      create_shims_from_manifest "$lib"
    fi
    ;;
  refresh)
    lib="$1"
    remove_shims "$lib"
    create_shims_from_manifest "$lib"
    ;;
  remove)
    lib="$1"; shift
    remove_shims "$lib" "$@"
    ;;
  *)
    usage
    ;;
esac

exit 0

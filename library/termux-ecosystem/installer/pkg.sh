#!/usr/bin/env bash
# pkg.sh — atomic installer for termux-ecosystem libraries
set -euo pipefail

HOME_DIR="${HOME:-/data/data/com.termux/files/home}"
BASE="$HOME_DIR/kh-scripts"
LIBROOT="$BASE/library/termux-ecosystem"
SHIMTOOL="$LIBROOT/tools/install-shim.sh"
LINT="$LIBROOT/lint/manifest_lint.sh"
LOGDIR="$LIBROOT/logs"
KEEP_VERSIONS="${KEEP_VERSIONS:-3}"

err(){ echo "ERR: $*" >&2; }
info(){ echo "INFO: $*"; }

usage(){
  cat <<EOF
Usage: $0 install <name> <version> <source-dir>
       $0 uninstall <name> <version>
       $0 rotate <name>
EOF
  exit 2
}

do_lint_manifest(){
  local m="$1"
  if [ -x "$LINT" ]; then
    "$LINT" "$m"
  else
    info "manifest linter not found; skipping lint"
  fi
}

run_tests_if_present(){
  local wd="$1"
  if [ -x "$wd/tests/smoke.sh" ]; then
    info "running smoke tests"
    (cd "$wd" && ./tests/smoke.sh)
  else
    info "no smoke.sh found; skipping tests"
  fi
}

rotate_versions(){
  local name="$1"
  local d="$LIBROOT/$name"
  [ -d "$d" ] || return 0
  info "rotating versions for $name (keep $KEEP_VERSIONS)"
  cd "$d" || return 0
  ls -1dt v* 2>/dev/null | sed -n "$((KEEP_VERSIONS+1)),\$p" | xargs -r -I{} rm -rf "{}"
}

install_package(){
  local name="$1"; local ver="$2"; local src="$3"
  [ -d "$src" ] || { err "source dir not found: $src"; return 4; }

  local tmp
  tmp="$(mktemp -d "$LIBROOT/tmp.${name}.XXXXXXXX")"
  info "created tmpdir $tmp"

  mkdir -p "$tmp/$name/v$ver"
  cp -a "$src/." "$tmp/$name/v$ver/"

  local manifest="$tmp/$name/v$ver/MANIFEST.yml"
  [ -f "$manifest" ] || { err "MANIFEST.yml missing in source"; rm -rf "$tmp"; return 5; }

  do_lint_manifest "$manifest"
  run_tests_if_present "$tmp/$name/v$ver"

  mkdir -p "$LIBROOT/$name"
  local dest="$LIBROOT/$name/v$ver"
  if [ -e "$dest" ]; then err "version already installed: $dest"; rm -rf "$tmp"; return 6; fi

  mv "$tmp/$name/v$ver" "$dest"
  rmdir --ignore-fail-on-non-empty "$tmp/$name" || true
  rm -rf "$tmp"

  ln -sfn "$dest" "$LIBROOT/$name/current"
  info "flipped current -> $dest"

  rotate_versions "$name"

  mkdir -p "$LOGDIR"
  echo "$(date --iso-8601=seconds) INSTALL $name v$ver by $(whoami)" >> "$LOGDIR/installer.log"
  info "installed $name v$ver"

  if [ -x "$SHIMTOOL" ]; then
    "$SHIMTOOL" refresh "$name" || info "shim refresh failed for $name"
  fi
}

uninstall_package(){
  local name="$1"; local ver="$2"
  local target="$LIBROOT/$name/v$ver"
  [ -e "$target" ] || { err "not installed: $target"; return 7; }
  rm -rf "$target"
  local cur="$LIBROOT/$name/current"
  if [ -L "$cur" ] && [ "$(readlink -f "$cur")" = "$(readlink -f "$target")" ]; then
    rm -f "$cur"
    info "removed current symlink"
  fi
  mkdir -p "$LOGDIR"
  echo "$(date --iso-8601=seconds) UNINSTALL $name v$ver by $(whoami)" >> "$LOGDIR/installer.log"
  info "uninstalled $name v$ver"
}

case "${1:-}" in
  install) [ $# -eq 4 ] || usage; install_package "$2" "$3" "$4" ;;
  uninstall) [ $# -eq 3 ] || usage; uninstall_package "$2" "$3" ;;
  rotate) [ $# -eq 2 ] || usage; rotate_versions "$2" ;;
  *) usage ;;
esac

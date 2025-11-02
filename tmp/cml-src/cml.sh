#!/usr/bin/env bash
# cml.sh — minimal Color Master Library test entrypoint
set -euo pipefail
cml::version() { printf "%s\n" "1.2.0"; }
cml::init() {
  : "${CML_INITIALIZED:=0}"
  if [ "$CML_INITIALIZED" -eq 1 ]; then return 0; fi
  export CML_INITIALIZED=1
  export CML_PALETTE="default"
}
cml::color() {
  local name="${1:-default}"
  case "$name" in
    red) printf '\033[31m';;
    green) printf '\033[32m';;
    reset) printf '\033[0m';;
    *) printf '';;
  esac
}
cml::print() {
  local msg="$*"
  cml::init
  printf "%s%s%s\n" "$(cml::color red)" "$msg" "$(cml::color reset)"
}
if [ "${1:-}" = "__call__" ]; then
  shift
  export_name="$1"; shift
  case "$export_name" in
    cml::init) cml::init "$@"; exit 0;;
    cml::color) cml::color "$@"; exit 0;;
    cml::print) cml::print "$@"; exit 0;;
    *) echo "ERR: unknown export: $export_name" >&2; exit 2;;
  esac
fi

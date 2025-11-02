#!/usr/bin/env bash
set -euo pipefail
csml::version(){ printf "%s\n" "1.0.0"; }
csml::init(){ : "${CSML_INITIALIZED:=0}"; export CSML_INITIALIZED=1; }
csml::set(){ csml::init; printf "csml::set %s\n" "$*"; }
if [ "${1:-}" = "__call__" ]; then shift; cmd="$1"; shift; case "$cmd" in csml::init) csml::init "$@";; csml::set) csml::set "$@";; *) echo "ERR: unknown" >&2; exit 2;; esac; exit 0; fi

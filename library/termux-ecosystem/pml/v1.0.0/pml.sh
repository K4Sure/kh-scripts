#!/usr/bin/env bash
set -euo pipefail
pml::version(){ printf "%s\n" "1.0.0"; }
pml::init(){ export PML_INIT=1; }
pml::echo(){ pml::init; printf "pml::echo %s\n" "$*"; }
if [ "${1:-}" = "__call__" ]; then shift; cmd="$1"; shift; case "$cmd" in pml::init) pml::init "$@";; pml::echo) pml::echo "$@";; *) echo "ERR: unknown" >&2; exit 2;; esac; exit 0; fi

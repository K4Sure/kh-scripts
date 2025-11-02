#!/usr/bin/env bash
set -euo pipefail
dbml::version(){ printf "%s\n" "1.0.0"; }
dbml::init(){ export DBML_INIT=1; }
dbml::connect(){ dbml::init; printf "dbml::connect %s\n" "$*"; }
if [ "${1:-}" = "__call__" ]; then shift; cmd="$1"; shift; case "$cmd" in dbml::init) dbml::init "$@";; dbml::connect) dbml::connect "$@";; *) echo "ERR: unknown" >&2; exit 2;; esac; exit 0; fi

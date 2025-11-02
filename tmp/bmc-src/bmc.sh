#!/usr/bin/env bash
set -euo pipefail
bmc::version(){ printf "%s\n" "1.0.0"; }
# dispatcher contract only for version check
if [ "${1:-}" = "__call__" ]; then shift; cmd="$1"; shift; case "$cmd" in bmc::version) bmc::version;; *) echo "ERR: unknown"; exit 2;; esac; exit 0; fi
